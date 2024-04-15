module batch_normalization_layer #(
	parameter	DATA_WIDTH	= 32										,
	parameter	FILTERS		= 64										,
	parameter	NUM			= 0											; // 몇번째 layer인지. layer 너무 커서 분할 용도.
	parameter	DEPTH		= 1											,
	parameter	INPUT		= 30										,
	parameter	BETAFILE	= "batch_normalization_beta.txt"			,
	parameter	GAMMAFILE	= "batch_normalization_gamma.txt"			,
	parameter	MMFILE		= "batch_normalization_moving_mean.txt"		,
	parameter	MVFILE		= "batch_normalization_denominator.txt"		,
) (
	input			[DEPTH * INPUT * INPUT * DATA_WIDTH * FILTERS - 1:0]	input_layer	,
	input																	clk			,
	output			[DEPTH * INPUT * INPUT * DATA_WIDTH * FILTERS - 1:0]	output_layer	
);

reg		[DATA_WIDTH - 1:0]	betas_all			[0:63]			;
reg		[DATA_WIDTH - 1:0]	gammas_all			[0:63]			;
reg		[DATA_WIDTH - 1:0]	moving_means_all	[0:63]			;
reg		[DATA_WIDTH - 1:0]	denominators_all	[0:63]			;

wire	[DATA_WIDTH - 1:0]	betas				[0:FILTERS-1]	;
wire	[DATA_WIDTH - 1:0]	gammas				[0:FILTERS-1]	;
wire	[DATA_WIDTH - 1:0]	moving_means		[0:FILTERS-1]	;
wire	[DATA_WIDTH - 1:0]	denominators		[0:FILTERS-1]	;

genvar n;
generate
	for(n=0; n<FILTERS; n=n+1) begin
		assign	betas			[n]	= betas_all 		[NUM*FILTERS + n]	;
		assign	gammas			[n]	= gammas_all		[NUM*FILTERS + n]	;
		assign	moving_means	[n]	= moving_means_all	[NUM*FILTERS + n]	;
		assign	denominators	[n]	= denominators_all 	[NUM*FILTERS + n]	;
	end
endgenerate

initial begin
	$readmemh(	BETAFILE,	betas_all			);
	$readmemh(	GAMMAFILE,	gammas_all			);
	$readmemh(	MMFILE,		moving_means_all	);
	$readmemh(	MVFILE,		denominators_all	);
end

genvar i;
generate
	for(i=0; i<FILTERS; i = i + 1) begin: generate_block
		batch_normalization u_batch_normalization (
			.clk			(	clk											),
			.data_i			(	input_layer		[i * DATA_WIDTH * DEPTH * INPUT * INPUT +:DATA_WIDTH * DEPTH * INPUT * INPUT]),
			.beta_i			(	betas			[i]							),
			.gamma_i		(	gammas			[i]							),
			.moving_mean_i	(	moving_means	[i]							),
			.denominator_i	(	denominators	[i]							),
			.result_o		(	output_layer	[i * DATA_WIDTH * DEPTH * INPUT * INPUT +:DATA_WIDTH * DEPTH * INPUT * INPUT])
		);
	end
endgenerate

endmodule