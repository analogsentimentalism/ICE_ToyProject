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

reg										valid_n;

reg		[clogb2(ONCE-1)-1:0]			o_cnt							;
reg		[clogb2(BIAS-1)-1:0]			b_cnt							;	// # of bias
reg		[clogb2(BIAS-1)-1:0]			b_cnt_prev						;	// # of bias
reg		[clogb2(H-1)-1:0]				h_cnt							;	// # of height

wire	[DATA_WIDTH*(2*W-1)-1:0]		temp				[0:ONCE-1]	;
reg		[DATA_WIDTH-1:0]				bias				[0:ONCE_B-1];
wire	[DATA_WIDTH*W-1:0]				kernels_w			[0:ONCE-1]	;

wire	[DATA_WIDTH-1:0]				results_once		[0:2*ONCE-2];

reg		[DATA_WIDTH-1:0]				results_onces		[0:H*DEPTH/ONCE-1];
wire	[DATA_WIDTH-1:0]				results_onces_w		[0:2*(DEPTH*H/ONCE)-2];

reg		[DATA_WIDTH-1:0]				results_before_bias	[0:BIAS-1];

reg										mem_wait						;

wire	[ONCE_B * DATA_WIDTH-1:0]		mem_b							;
wire	[ONCE * W * DATA_WIDTH-1:0]		mem_k							;

wire	[clogb2(DEPTH*H*BIAS/ONCE-1)-1:0]	kptr						;
assign	kptr	= (b_cnt << clogb2(H-1)) + h_cnt;

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
				.floatA		(	data_i		[j*W*DATA_WIDTH + i*DATA_WIDTH+:DATA_WIDTH]		),
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
		assign	kernels_w[i]	= mem_k[i*W*DATA_WIDTH+h_cnt*W*ONCE*DATA_WIDTH+:W*DATA_WIDTH];
		assign	results_once[i]	= temp[i][2*(W-1)*DATA_WIDTH+:DATA_WIDTH];
	end

	for (i=0;i<2*ONCE-2;i=i+2) begin: once_total
		floatAdd add_once (
			.floatA		(	results_once		[i]			),
			.floatB		(	results_once		[i+1]		),
			.sum		(	results_once		[ONCE+i/2]	)	// 한번 끝. results_once[2*ONCE-2]에 결과.
		);
	end

	for (i=0;i<H*DEPTH/ONCE;i=i+1) begin: assign_results_onces_wire
		assign	results_onces_w[i]	= results_onces[i];
	end

	for (i=0;i<2*(DEPTH*H/ONCE)-2;i=i+2) begin: before_bias
		floatAdd before_bias (
			.floatA		(	results_onces_w		[i]					),
			.floatB		(	results_onces_w		[i+1]				),
			.sum		(	results_onces_w		[DEPTH*H/ONCE+i/2]	)	// kernel 다 더한 것
		);
	end

endgenerate

floatAdd bias_adder (
	.floatA		(	results_before_bias	[b_cnt]	),
	.floatB		(	bias				[0]		),
	.sum		(	data_o						)
);

integer k;
always	@(posedge clk) begin: set_results_onces
	if(~rstn) begin
		// for(k=0;k<DEPTH*H/ONCE-1;k=k+1) begin
		// 	results_onces[k]	<=	{DATA_WIDTH{1'b0}};
		// end
		for(k=0;k<BIAS;k=k+1) begin
			results_before_bias[k]	<= {DATA_WIDTH{1'b0}};
		end
		o_cnt		<= 'b0;
		b_cnt		<= 'b0;
		h_cnt		<= 'b0;
		mem_wait	<= 'b0;
		valid_o		<= 'b0;
		valid_n		<= 'b0;
	end
	else begin
		if (valid_i | |o_cnt | |b_cnt | |mem_wait) begin
			if(mem_wait) begin
				if (o_cnt == ONCE-1) begin
					o_cnt	<= 'b0;
					if (b_cnt == BIAS-1) begin
						b_cnt	<= 'b0;
						results_before_bias[b_cnt]	<= results_onces_w[2*(DEPTH*H/ONCE)-2];
						mem_wait	<= 'b0;
						if(h_cnt == H-1) begin
							h_cnt	<= 'b0;
						end
						else begin
							h_cnt	<= h_cnt + 'b1;
						end
					end
					else begin
						b_cnt	<= b_cnt + 'b1;
					end

				end
				else begin
					o_cnt	<= o_cnt + 'b1;
				end
			end
			else begin
				mem_wait	<= 'b1;
			end
		end
		valid_n	<= (o_cnt == 0) & (h_cnt == H-1) & (b_cnt != b_cnt_prev);	// BIAS 하나씩.
		valid_o	<= valid_n;
	end
end

always @(posedge clk) begin
	b_cnt_prev	<= b_cnt;
end

always	@(*) begin: set_once_kernels
	for(k=0;k<ONCE_B;k=k+1) begin
		bias[k]				<= mem_b[k*DATA_WIDTH+:DATA_WIDTH];
	end
	if(valid_i) begin
		results_onces[h_cnt]	<= results_once[2*ONCE-2];
	end
end

function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
	depth = depth >> 1;
endfunction


endmodule