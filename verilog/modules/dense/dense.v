module dense #(
	parameter	DEPTH		= 64					,
	parameter	H			= 5						,
	parameter	W			= 5						,
	parameter	NUMS		= DEPTH * H * W	,	// 전체 원소 개수, Depth * Width * Height
	parameter	DATA_WIDTH	= 32
) (
	input								clk			,
	input	[DATA_WIDTH * NUMS -1:0]	data_i		,
	input	[DATA_WIDTH * NUMS -1:0]	kernel_i	,
	input	[DATA_WIDTH-1:0]			bias_i		,
	output	[DATA_WIDTH-1:0]			result_o
);

wire	[DATA_WIDTH-1:0]	temp		[0:2*NUMS-2]	;

genvar i, j, k, l;
generate
	for(i=0;i<NUMS;i=i+1) begin: multi_block
		FloatingMultiplication multiplication (
			.A		(	data_i	[i*DATA_WIDTH+:DATA_WIDTH]		),
			.B		(	kernel_i	[i*DATA_WIDTH+:DATA_WIDTH]	),
			.clk	(	clk										),
			.result	(	temp	[i]								)
		);
	end
	for(k=0;k<2*NUMS-1;k=k+2) begin: addition_block
		FloatingAddition addition (
			.A		(	temp	[k]			),
			.B		(	temp	[k + 1]		),
			.result	(	temp	[NUMS+k/2]	)
		);
	end
endgenerate

FloatingAddition bias_adder (
	.A		(	temp		[2*NUMS-2]	),
	.B		(	bias_i					),
	.result	(	result_o	)
);

endmodule