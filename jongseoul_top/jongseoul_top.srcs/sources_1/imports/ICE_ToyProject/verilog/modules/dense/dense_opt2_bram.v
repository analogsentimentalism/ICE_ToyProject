`timescale 1 ns / 10 ps

module dense_opt #(
	parameter	BIASFILE	= "2424_dense0_bias.txt"	,
	parameter	KERNELFILE	= "2424_dense0_kernel.txt"	,
	parameter	H			= 2							,
	parameter	W			= 2							,
	parameter	DEPTH		= 64						,	// 이전 레이어의 depth
	parameter	BIAS		= 128						,
	parameter	DATA_WIDTH	= 8							,
	parameter	ONCE		= DEPTH						,
	parameter	ONCE_B		= 1
) (
	input									clk		,
	input									rstn	,
	input									valid_i	,
	input		[W*ONCE*DATA_WIDTH-1:0]	data_i	,
	output		[DATA_WIDTH-1:0]			data_o	,
	output	reg								valid_o
);

reg		[W*ONCE*DATA_WIDTH-1:0]			data_i_reg;
reg										valid_i_reg;

reg										valid_n;

reg		[clogb2(BIAS-1)-1:0]			b_cnt							;	// # of bias
reg		[clogb2(H-1)-1:0]				h_cnt_p							;	// # of bias
reg		[clogb2(H-1)-1:0]				h_cnt							;	// # of height

wire	[DATA_WIDTH*(2*W-1)-1:0]		temp				[0:ONCE-1]	;
reg		[DATA_WIDTH-1:0]				bias				[0:ONCE_B-1];
wire	[DATA_WIDTH*W-1:0]				kernels_w			[0:ONCE-1]	;

wire	[DATA_WIDTH-1:0]				results_once		[0:2*ONCE-2];
reg		[DATA_WIDTH*BIAS-1:0]			results_onces		[0:H-1];
wire	[DATA_WIDTH*BIAS-1:0]			results_end			[0:2*H-2];

reg										mem_wait						;
reg										mem_wait_p						;

wire	[ONCE_B * DATA_WIDTH-1:0]		mem_b							;
wire	[ONCE * W * DATA_WIDTH-1:0]		mem_k							;

wire	[clogb2(DEPTH*H*BIAS/ONCE-1)-1:0]	kptr						;
assign	kptr	= b_cnt * H + h_cnt;

rom #(
	.RAM_WIDTH(ONCE_B * DATA_WIDTH), 
	.RAM_DEPTH(BIAS / ONCE_B),
	.INIT_FILE(BIASFILE)
) brom (
	.clk	(	clk		),
	.en		(	1'b1	),
	.addra	(	b_cnt	),
	.dout	(	mem_b	)
);

rom #(
	.RAM_WIDTH(ONCE * W * DATA_WIDTH), 
	.RAM_DEPTH(DEPTH * H * BIAS / ONCE),
	.INIT_FILE(KERNELFILE)
) krom (
	.clk	(	clk		),
	.en		(	1'b1	),
	.addra	(	kptr	),
	.dout	(	mem_k	)
);

genvar i, j;
generate
	for(j=0;j<ONCE;j=j+1) begin: multiply_with_kernels
		for(i=0;i<W;i=i+1) begin: width_multi_block	// Width까지는 병렬로 처리.
			floatMult multiplication (
				.floatA		(	data_i_reg	[j*W*DATA_WIDTH + i*DATA_WIDTH+:DATA_WIDTH]		),
				.floatB		(	kernels_w	[j][i*DATA_WIDTH+:DATA_WIDTH]	),
				.product	(	temp		[j][i*DATA_WIDTH+:DATA_WIDTH]	)
			);
		end

		for(i=0;i<2*(W-1);i=i+2) begin: add_block
			floatAdd addition (
				.floatA		(	temp	[j][i*DATA_WIDTH+:DATA_WIDTH]		),
				.floatB		(	temp	[j][(i+1)*DATA_WIDTH+:DATA_WIDTH]	),
				.sum		(	temp	[j][(W+i/2)*DATA_WIDTH+:DATA_WIDTH]	)	// width 다 더한 것 temp [2*W-2]
			);
		end
	end

	for (i=0;i<ONCE;i=i+1) begin: assgin_kernels_and_results_once
		assign	kernels_w[i]	= mem_k[i*W*DATA_WIDTH+:W*DATA_WIDTH];
		assign	results_once[i]	= temp[i][2*(W-1)*DATA_WIDTH+:DATA_WIDTH];
	end

	for (i=0;i<2*ONCE-2;i=i+2) begin: once_total
		floatAdd add_once (
			.floatA		(	results_once		[i]			),
			.floatB		(	results_once		[i+1]		),
			.sum		(	results_once		[ONCE+i/2]	)	// 한번 끝. results_once[2*ONCE-2]에 결과.
		);
	end

	for (i=0;i<H;i=i+1) begin: result_end_set
		assign	results_end	[i]	= results_onces	[i]; 
	end

	for (j=0;j<2*H-2; j=j+2) begin
		for (i=0;i<BIAS;i=i+1) begin: before_bias
			floatAdd before_bias (
				.floatA		(	results_end		[j][i*DATA_WIDTH+:DATA_WIDTH]			),
				.floatB		(	results_end		[j+1][i*DATA_WIDTH+:DATA_WIDTH]		),
				.sum		(	results_end		[H+j/2][i*DATA_WIDTH+:DATA_WIDTH]	)	// kernel 다 더한 것
			);
		end
	end


endgenerate

floatAdd bias_adder (
	.floatA		(	results_end	[2*H-2][b_cnt*DATA_WIDTH+:DATA_WIDTH]	),
	.floatB		(	bias		[0]				),
	.sum		(	data_o						)
);

always @(posedge clk) begin
	if (~rstn) begin
		data_i_reg	<= {W*ONCE*DATA_WIDTH{1'b0}};
		valid_i_reg	<= 1'b0;
	end
	else begin
		valid_i_reg	<= valid_i;
		if(valid_i) data_i_reg	<= data_i;
	end
end

reg flag, flag_n;

integer k;
always	@(posedge clk) begin: set_results_onces
	if(~rstn) begin
		for(k=0;k<H;k=k+1) begin
			results_onces[k]	<= {(DATA_WIDTH*BIAS){1'b0}};
		end
		b_cnt		<= 'b0;
		h_cnt		<= 'b0;
		h_cnt_p		<= 'b0;
		mem_wait	<= 'b0;
		mem_wait_p	<= 'b0;
		valid_o		<= 'b0;
		valid_n		<= 'b0;
		flag		<= 'b0;
		flag_n		<= 'b0;
	end
	else begin
		flag_n		<= flag;
		mem_wait_p	<= mem_wait;
		h_cnt_p	<= h_cnt;
		if (valid_i_reg | |b_cnt | |mem_wait) begin
			if(mem_wait) begin
				results_onces[h_cnt][b_cnt*DATA_WIDTH+:DATA_WIDTH]	<= results_once[2*ONCE-2];
				mem_wait	<= 'b0;
				if (b_cnt == BIAS-1) begin
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
		for(k=0;k<ONCE_B;k=k+1) begin
			bias[k]				<= {DATA_WIDTH{1'b0}};
		end
	end
	else begin
		for(k=0;k<ONCE_B;k=k+1) begin
			bias[k]				<= mem_b[k*DATA_WIDTH+:DATA_WIDTH];
		end
	end
end

function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
	depth = depth >> 1;
endfunction


endmodule