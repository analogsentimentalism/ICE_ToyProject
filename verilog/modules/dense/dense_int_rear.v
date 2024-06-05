module dense_int_rear #(
	parameter	BIASFILE	= "mini_dense1_bias.txt"	,
	parameter	KERNELFILE	= "mini_dense1_kernel.txt"	,
	parameter	D			= 64						,	// 이전 레이어의 depth
	parameter	B			= 7							,
	parameter	DATA_WIDTH	= 8
) (
	input									clk		,
	input									rstn	,
	input									valid_i	,
	input	signed	[DATA_WIDTH-1:0		]	data_i	,
	output			[DATA_WIDTH*B-1:0	]	data_o	,
	output	reg								valid_o
);

reg		signed	[DATA_WIDTH-1:0		]	data_i_reg;
reg		signed	[31:0				]	bias	[0:B-1];
wire			[B*DATA_WIDTH-1:0	]	mem_k;

reg		signed	[15:0				]	before_bias		[0:B-1];
wire	signed	[31:0				]	before_result	[0:B-1];

reg				[clogb2(D-1)-1:0	]	d_cnt;

reg										mem_wait,	mem_wait_p;

initial begin: mem_b_init
	$readmemh(BIASFILE, bias);
end

rom #(
	.RAM_WIDTH	(	B * DATA_WIDTH	), 
	.RAM_DEPTH	(	D				),
	.INIT_FILE	(	KERNELFILE		)
) krom (
	.clk	(	clk		),
	.en		(	1'b1	),
	.addra	(	d_cnt	),
	.dout	(	mem_k	)
);

genvar gi;
generate
	for(gi=0;gi<B;gi=gi+1) begin
		assign	before_result[gi]					= before_bias[gi] + bias[gi];
		assign	data_o[gi*DATA_WIDTH+:DATA_WIDTH]	= before_result[gi]	> 8'sd127 ? 8'sd127 :
														(before_result[gi] < -8'd128 ? -8'd128 :
														before_result[gi] & 8'hFF);
	end
endgenerate

always @(posedge clk) begin: input_reg
	if (~rstn) begin
		data_i_reg	<= {DATA_WIDTH{1'b0}};
	end
	else begin
		data_i_reg	<= data_i;
	end
end

integer k;
always @(posedge clk) begin: set_result
	if (~rstn) begin
		d_cnt		<= 'b0;
		mem_wait	<= 'b0;
		mem_wait_p	<= 'b0;
		valid_o		<= 'b0;
		for(k=0;k<B;k=k+1) begin
			before_bias[k]	<= 16'b0;
		end
	end
	else begin
		if (valid_i | mem_wait) begin
			if(mem_wait) begin
				mem_wait	<= 'b0;
				for(k=0;k<B;k=k+1) begin
					before_bias[k]	<= before_bias[k] + data_i_reg * $signed(mem_k[k*DATA_WIDTH+:DATA_WIDTH]);
				end
				if(d_cnt == D-1) begin
					d_cnt	<= 'b0;
					valid_o	<= 'b1;
				end
				else begin
					d_cnt	<= d_cnt + 'b1;
					valid_o	<= 'b0;
				end
			end
			else begin
				mem_wait	<= 'b1;
				valid_o		<= 'b0;
			end
		end
		else begin
			valid_o	<= 'b0;
		end
	end
end

function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
	depth = depth >> 1;
endfunction

endmodule