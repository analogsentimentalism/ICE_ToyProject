module dense #(
	parameter	NUMS		= 96 * 96 * 32			,	// 전체 원소 개수
	parameter	BIAS 		= 256					,
	parameter	DATA_WIDTH	= 32					,
	parameter	BIASFILE	= "dense_bias.txt"		,
	parameter	KERNELFILE	= "dense_kernel.txt"
) (
	input								clk				,
	input	[DATA_WIDTH * NUMS -1:0]	data_i			,
	output	[DATA_WIDTH * BIAS-1:0]		result_o
);

wire	[DATA_WIDTH-1:0]	temp		[0:2*NUMS-2]	;
wire	[DATA_WIDTH-1:0]	bias_result	[0:BIAS-1]	;

reg		[DATA_WIDTH-1:0]	bias		[0:BIAS-1]	;
reg		[DATA_WIDTH-1:0]	kernel		[0:NUMS-1]	;

initial begin
	$readmemh(	BIASFILE,	bias	);
	$readmemh(	KERNELFILE,	kernel	);
end

genvar i, j, k, l;
generate
	for(i=0;i<NUMS;i=i+1) begin: multi_block
		FloatingMultiplication multiplication (
			.A		(	data_i	[i*DATA_WIDTH+:DATA_WIDTH]	),
			.B		(	kernel	[i]							),
			.clk	(	clk									),
			.result	(	temp	[i]							)
		);
	end
	for(k=0;k<2*NUMS-1;k=k+2) begin: addition_block
		FloatingAddition addition (
			.A		(	temp	[k]			),
			.B		(	temp	[k + 1]		),
			.result	(	temp	[NUMS+k/2]	)
		);
	end

	for(l=0;l<BIAS;l=l+1) begin: bias_block
		FloatingAddition bias_adder (
			.A		(	temp		[2*NUMS-2]	),
			.B		(	bias		[l]			),
			.result	(	bias_result	[l]			)
		);

		relu #(
			.D(1),
			.H(1),
			.W(1)
		) u_relu (
			.input_data		(	bias_result	[l]									),
			.output_data	(	result_o	[l*DATA_WIDTH+:DATA_WIDTH]			)
		);
	end
endgenerate
endmodule