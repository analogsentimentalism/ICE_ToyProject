module dense_int_front #(
	parameter	BIASFILE	= "mini_dense0_bias.txt"	,
	parameter	KERNELFILE	= "mini_dense0_kernel.txt"	,
	parameter	H			= 3							,
	parameter	W			= 3							,
	parameter	D			= 12						,	// 이전 레이어의 depth
	parameter	B			= 64						,
	parameter	DATA_WIDTH	= 8
) (
	input									clk		,
	input									rstn	,
	input									valid_i	,
	input		[W*D*DATA_WIDTH-1:0	]		data_i	,
	output		[DATA_WIDTH-1:0		]		data_o	,
	output	reg								valid_o
);

reg		[W*D*DATA_WIDTH-1:0]			data_i_reg;

wire	signed	[15:0				]	data_iw			[0:D*W-1];
reg		signed	[31:0				]	before_bias		[0:B-1	];
wire	signed	[31:0				]	before_result;
wire			[DATA_WIDTH*W-1:0	]	kernel_width	[0:D-1	];
reg		signed	[31:0				]	bias;

wire	[31:0					]	mem_b;
wire	[D * W * DATA_WIDTH-1:0	]	mem_k;

wire	[clogb2(H*B-1)-1:0		]	kptr;
reg		[clogb2(H-1)-1:0		]	h_cnt;	
reg		[clogb2(B-1)-1:0		]	b_cnt;

reg									mem_wait,	mem_wait_p;
reg									flag,		flag_n;
rom #(
	.RAM_WIDTH	(	32			), 
	.RAM_DEPTH	(	B			),
	.INIT_FILE	(	BIASFILE	)
) brom (
	.clk	(	clk		),
	.en		(	1'b1	),
	.addra	(	b_cnt	),
	.dout	(	mem_b	)
);

assign	kptr	= b_cnt * H + h_cnt;

rom #(
	.RAM_WIDTH	(	W * D * DATA_WIDTH	), 
	.RAM_DEPTH	(	H * B				),
	.INIT_FILE	(	KERNELFILE			)
) krom (
	.clk	(	clk		),
	.en		(	1'b1	),
	.addra	(	kptr	),
	.dout	(	mem_k	)
);

genvar	gi, gj;
generate
	for(gi=0;gi<D;gi=gi+1) begin: assgin_kernel_width
		assign	kernel_width	[gi]	= mem_k		[gi*W*DATA_WIDTH+:W*DATA_WIDTH];
	end

	for(gi=0;gi<D;gi=gi+1) begin: input_to_signed
		for(gj=0;gj<W;gj=gj+1) begin
			assign	data_iw			[gi*W+gj]	= $signed(data_i_reg[gi*DATA_WIDTH+:DATA_WIDTH]) *
													$signed(kernel_width[gi][gj*DATA_WIDTH+:DATA_WIDTH]);
		end
	end
endgenerate

assign	before_result	= (before_bias [b_cnt] + bias) >>> 16;
assign	data_o	= before_result	> $signed({1'b0, 8'd127}) ? $signed({1'b0, 8'd127}) :
								(before_result < -$signed({1'b0, 8'd128}) ? -$signed({1'b0, 8'd128}) :
									{before_result[31], before_result[6:0]});

always @(posedge clk) begin: input_reg
	if (~rstn) begin
		data_i_reg	<= {W*D*DATA_WIDTH{1'b0}};
	end
	else begin
		if(valid_i) data_i_reg	<= data_i;
	end
end

reg				yet;

integer k;
always	@(posedge clk) begin: set_results_onces
	if(~rstn) begin
		b_cnt		<= 'b0;
		h_cnt		<= 'b0;
		mem_wait	<= 'b0;
		mem_wait_p	<= 'b0;
		valid_o		<= 'b0;
		flag		<= 'b0;
		flag_n		<= 'b0;
		yet			<= 'b0;
		for(k=0;k<B;k=k+1) begin
			before_bias[k] <= 32'b0;
		end
	end
	else begin
		flag_n		<= flag;
		mem_wait_p	<= mem_wait;
		if(valid_i & |b_cnt) begin
			yet	<= 'b1;
		end
		if (valid_i | |b_cnt | mem_wait | yet) begin
			if(~(valid_i | |b_cnt | mem_wait) & yet) begin
				yet	<= 1'b0;
			end
			if(mem_wait) begin
				mem_wait	<= 'b0;
				for(k=0;k<W*D;k=k+1) begin
					before_bias[b_cnt] = before_bias[b_cnt] + data_iw[k];
				end
				if (b_cnt == B-1) begin
					b_cnt	<= 'b0;
					if(h_cnt == H-1) begin
						h_cnt	<= 'b0;
						flag	<= 'b0;
					end
					else begin
						h_cnt	<= h_cnt + 'b1;
						if (h_cnt == H-2) begin
							flag <= 'b1;
						end
					end
				end
				else begin
					b_cnt	<= b_cnt + 'b1;
				end
			end
			else begin
				mem_wait	<= 'b1;
			end
		end
		valid_o	<= flag_n & ~mem_wait & mem_wait_p;	// BIAS 하나씩.
	end
end

always	@(*) begin: set_once_kernels
	if(~rstn) begin
		bias	<= {DATA_WIDTH{1'b0}};
	end
	else begin
		bias		<= mem_b;
	end
end

function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
	depth = depth >> 1;
endfunction

endmodule