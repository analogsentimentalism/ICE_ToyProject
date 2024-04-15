module batch_normalization_element #(
	parameter	DATA_WIDTH	= 32
) (
	input						clk				,
	input	[DATA_WIDTH-1:0]	data_i			,
	input	[DATA_WIDTH-1:0]	gamma_i			,
	input	[DATA_WIDTH-1:0]	beta_i			,
	input	[DATA_WIDTH-1:0]	moving_mean_i	,
	input	[DATA_WIDTH-1:0]	denominator_i	,
	output	[DATA_WIDTH-1:0]	result_o
);

wire	[DATA_WIDTH-1:0]	sub		;
wire	[DATA_WIDTH-1:0]	mul		;
wire	[DATA_WIDTH-1:0]	div		;

FloatingAddition subtraction (
	.A			(	data_i			),
	.B			(	{~moving_mean_i[DATA_WIDTH-1], moving_mean_i[DATA_WIDTH-2:0]}	),
	.result		(	sub				)
	);

FloatingMultiplication multiplication (
	.A			(	gamma_i			),
	.B			(	sub				),
	.clk		(	clk				),
	.result		(	mul				)
);

FloatingDivision division (
	.A			(	mul				),
	.B			(	denominator_i	),
	.clk		(	clk				),
	.result		(	div				)
);

FloatingAddition addition (
	.A			(	div				),
	.B			(	beta_i			),
	.result		(	result_o		)
	);

endmodule