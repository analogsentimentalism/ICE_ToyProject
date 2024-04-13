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
	.beta_i			(	betas[0]		),
	.moving_mean_i	(	moving_means[0]	),
	.denominator_i	(	denominators[0]	),
	.result_o		(	result_o		)
);

task show(
	input [DATA_WIDTH - 1 :0] a, b, c, d, e, f
);
begin
	$display("data\t\t: %f", $bitstoshortreal(a)	);
	$display("gamma\t\t: %f", $bitstoshortreal(b)	);
	$display("means\t\t: %f", $bitstoshortreal(c)	);
	$display("denom\t\t: %f", $bitstoshortreal(d)	);
	$display("beta\t\t: %f", $bitstoshortreal(e)	);
	$display("result:\t%f", $bitstoshortreal(f)		);
end
endtask

initial begin
	$readmemh(	BETAFILE,	betas				);
	$readmemh(	GAMMAFILE,	gammas				);
	$readmemh(	MMFILE,		moving_means		);
	$readmemh(	MVFILE,		denominators		);
end

always begin
	#1	clk 	= ~clk	;
end

integer i;

initial begin
	show(data_i, gammas[0], moving_means[0], denominators[0], betas[0], result_o)	;
	clk		= 1'b1			;
	for(i=0; i<10; i = i + 1) begin
		#10 data_i	= $urandom()	;
		#1 show(data_i, gammas[0], moving_means[0], denominators[0], betas[0], result_o)	;
		$display("------------------------------------------");
	end

end

endmodule