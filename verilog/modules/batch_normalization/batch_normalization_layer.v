module batch_normalization_layer #(
	parameter	DATA_WIDTH	= 32										,
	parameter	FILTERS		= 64										,
	parameter	DEPTH		= 1											,
	parameter	INPUT		= 30										,
	parameter	BETAFILE	= "batch_normalization_beta.txt"			,
	parameter	GAMMAFILE	= "batch_normalization_gamma.txt"			,
	parameter	MMFILE		= "batch_normalization_moving_mean.txt"		,
	parameter	MVFILE		= "batch_normalization_denominator.txt"
) (
	input			[DEPTH * INPUT * INPUT * DATA_WIDTH * FILTERS - 1:0]	input_layer	,
	input																	clk			,
	output			[DEPTH * INPUT * INPUT * DATA_WIDTH * FILTERS - 1:0]	output_layer	
);

reg	[DATA_WIDTH - 1:0]	betas				[0:FILTERS-1]	;
reg	[DATA_WIDTH - 1:0]	gammas				[0:FILTERS-1]	;
reg	[DATA_WIDTH - 1:0]	moving_means		[0:FILTERS-1]	;
reg	[DATA_WIDTH - 1:0]	moving_variences	[0:FILTERS-1]	;

initial begin
	$readmemh(	BETAFILE,	betas				);
	$readmemh(	GAMMAFILE,	gammas				);
	$readmemh(	MMFILE,		moving_means		);
	$readmemh(	MVFILE,		moving_variences	);
end

genvar i;
generate
	for(i=0; i<FILTERS; i = i + 1) begin: generate_block
		batch_normalization u_batch_normalization (
			.clk			(	clk											),
			.data_i			(	input_layer		[i * DATA_WIDTH * DEPTH * INPUT * INPUT +:DATA_WIDTH * DEPTH * INPUT * INPUT]),
			.gamma_i		(	gammas			[i]							),
			.moving_mean_i	(	moving_means	[i]							),
			.denominator_i	(	denominators	[i]							),
			.result_o		(	output_layer	[i * DATA_WIDTH * DEPTH * INPUT * INPUT +:DATA_WIDTH * DEPTH * INPUT * INPUT])
		);
	end
endgenerate

endmodule