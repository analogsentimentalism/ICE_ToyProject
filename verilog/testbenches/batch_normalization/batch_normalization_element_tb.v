`timescale 1 ns / 10 ps

module batch_normalization_element_tb #(
	parameter	FILTERS		= 64									,
	parameter	DATA_WIDTH	= 32									,
	parameter	BETAFILE	= "batch_normalization_beta.txt"		,
	parameter	GAMMAFILE	= "batch_normalization_gamma.txt"		,
	parameter	MMFILE		= "batch_normalization_moving_mean.txt"	,
	parameter	MVFILE		= "batch_normalization_denominator.txt"								
) ();

reg		[DATA_WIDTH - 1:0]	betas				[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	gammas				[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	moving_means		[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	denominators		[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	data_i								;
reg							clk									;

wire	[DATA_WIDTH - 1:0]	result_o							;

batch_normalization_element u_batch_normalization (
	.clk			(	clk				),
	.data_i			(	data_i			),	
	.gamma_i		(	gammas[0]		),
	.moving_mean_i	(	moving_means[0]	),
	.denominator_i	(	denominators[0]	),
	.result_o		(	result_o		)
);

initial begin
	$readmemh(	BETAFILE,	betas				);
	$readmemh(	GAMMAFILE,	gammas				);
	$readmemh(	MMFILE,		moving_means		);
	$readmemh(	MVFILE,		denominators		);
end

always begin
	#1	clk 	= ~clk	;
end

initial begin
	clk		= 1'b1			;
	data_i	= 32'h3f69fbe7	;
	#10;
	data_i	= 32'h3e9ff2e5	;
end

endmodule