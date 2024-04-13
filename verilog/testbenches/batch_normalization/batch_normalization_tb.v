`timescale 1 ns / 10 ps

module batch_normalization_tb #(
	parameter	DATA_WIDTH	= 32	,
	parameter	FILTERS		= 64	,
	parameter	DEPTH		= 1		,
	parameter	INPUT		= 30	,
	parameter	BETAFILE	= "batch_normalization_beta.txt"		,
	parameter	GAMMAFILE	= "batch_normalization_gamma.txt"		,
	parameter	MMFILE		= "batch_normalization_moving_mean.txt"	,
	parameter	MVFILE		= "batch_normalization_denominator.txt"	
) ();

reg	 	[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0] 	input_layer	;
reg													clk			;
wire	[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0] 	output_layer;

batch_normalization u_batch_normalization (
	.input_layer	(	input_layer	),
	.clk			(	clk			),
	.output_layer	(	output_layer)
);

task show(
	input [DATA_WIDTH - 1 :0] a, b, c, d, e, f
);
begin
	$display("data\t\t: %f", $bitstoshortreal(a)	);
	$display("gamma\t\t: %f", $bitstoshortreal(b)	);
	$display("mean\t\t: %f", $bitstoshortreal(c)	);
	$display("denom\t\t: %f", $bitstoshortreal(d)	);
	$display("beta\t\t: %f", $bitstoshortreal(e)	);
	$display("result\t\t:%f", $bitstoshortreal(f)	);
end
endtask

initial begin
	$readmemh(	BETAFILE,	betas				);
	$readmemh(	GAMMAFILE,	gammas				);
	$readmemh(	MMFILE,		moving_means		);
	$readmemh(	MVFILE,		denominators		);
end

initial begin
	forever	#1	clk 	= ~clk	;
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