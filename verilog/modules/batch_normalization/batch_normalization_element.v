module batch_normalization_element #(
	parameter	DATA_WIDTH	= 32
) (
	input						clk				,
	input	[DATA_WIDTH-1:0]	data_i			,
	input	[DATA_WIDTH-1:0]	gamma_i			,
	input	[DATA_WIDTH-1:0]	moving_mean_i	,
	input	[DATA_WIDTH-1:0]	denominator_i	,
	output	[DATA_WIDTH-1:0]	result_o
);

wire	[DATA_WIDTH-1:0]	sub		;
wire	[DATA_WIDTH-1:0]	mul		;

wire	overflow_sub		;
wire	overflow_mul		;
wire	overflow_div		;

wire	underflow_sub		;
wire	underflow_mul		;
wire	underflow_div		;

wire	exception_sub		;
wire	exception_mul		;
wire	exception_div		;

FloatingAddition subtraction (
	.A			(	data_i			),
	.B			(	{~moving_mean_i[DATA_WIDTH-1], moving_mean_i[DATA_WIDTH-2:0]}	),
	.clk		(	clk				),
	.overflow	(	overflow_sub	),
	.underflow	(	underflow_sub 	),
	.exception	(	exception_sub	),
	.result		(	sub				)
	);

FloatingMultiplication multiplication (
	.A			(	gamma_i			),
	.B			(	sub				),
	.clk		(	clk				),
	.overflow	(	overflow_mul	),
	.underflow	(	underflow_mul	),
	.exception	(	exception_mul	),
	.result		(	mul				)
);

FloatingDivision division (
	.A			(	mul				),
	.B			(	denominator_i	),
	.clk		(	clk				),
	.overflow	(	overflow_div	),
	.underflow	(	underflow_div	),
	.exception	(	exception_div	),
	.result		(	result_o		)
);

endmodule