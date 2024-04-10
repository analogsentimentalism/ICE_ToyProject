module batch_normalization #(
	FLOAT_BIT	= 8											,
	FILTERS		= 64										,
	INOUT_SIZE	= 48										,
	BETAFILE	= "batch_normalization_beta.txt"			,
	GAMMAFILE	= "batch_normalization_gamma.txt"			,
	MMFILE		= "batch_normalization_moving_mean.txt"		,
	MVFILE		= "batch_normalization_movine_varience.txt"	,
) (
	input		[INOUT_SIZE-1:0]	
);

// params
reg	[FLOAT_BIT-1:0]	betas				[0:FILTERS-1]	;
reg	[FLOAT_BIT-1:0]	gammas				[0:FILTERS-1]	;
reg	[FLOAT_BIT-1:0]	moving_means		[0:FILTERS-1]	;
reg	[FLOAT_BIT-1:0]	moving_variences	[0:FILTERS-1]	;

// read params
initial begin
	$readmemh(	BETAFILE,	betas				);
	$readmemh(	GAMMAFILE,	gammas				);
	$readmemh(	MMFILE,		moving_means		);
	$readmemh(	MVFILE,		moving_variences	);
end

endmodule