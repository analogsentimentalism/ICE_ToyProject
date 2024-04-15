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

reg														clk				;
reg		[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0]		data_i			;
reg		[DATA_WIDTH - 1:0]	betas				[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	gammas				[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	moving_means		[0:FILTERS-1]	;
reg		[DATA_WIDTH - 1:0]	denominators		[0:FILTERS-1]	;
wire	[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0]		result_o		;

batch_normalization u_batch_normalization (
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

integer i, j;

integer output_log;

initial begin
	output_log = $fopen("../BN_log.txt", "wb"	);
	clk		= 1'b1			;
	for(i=0; i < DEPTH * INPUT; i = i +1) begin
		for(j=0; j<INPUT; j = j+1) begin
			data_i[(i*j+j)*DATA_WIDTH+:DATA_WIDTH]	= $shortrealtobits(0.019338 - DEPTH * INPUT * INPUT * 0.000025+(i*INPUT+j)*0.00005);
			$write("%f\t", $bitstoshortreal(data_i[(i*j+j)*DATA_WIDTH+:DATA_WIDTH]));
			$fwrite(output_log, "%f\t", $bitstoshortreal(data_i[(i*j+j)*DATA_WIDTH+:DATA_WIDTH]));
		end
		$fwrite(output_log, "\n");
		$display();
	end
	$fwrite(output_log, "\n");
	$display("\n----------------------------------------------\n");
	#1;
	for(i=0; i < DEPTH * INPUT; i = i +1) begin
		for(j=0; j<INPUT; j = j+1) begin
			$write("%f\t", $bitstoshortreal(result_o[(i*INPUT+j)*DATA_WIDTH+:DATA_WIDTH]));
			$fwrite(output_log,"%f\t", $bitstoshortreal(result_o[(i*INPUT+j)*DATA_WIDTH+:DATA_WIDTH]));
		end
		$fwrite(output_log, "\n");
		$display();
	end

	// 정규화 안된 놈들 찾아내기
	// for(i=0;i<DEPTH*INPUT*INPUT;i=i+1) begin
	// 	data_i[i*DATA_WIDTH+:DATA_WIDTH]	= $shortrealtobits(0.019338 - DEPTH * INPUT * INPUT * 0.000025+i*0.00005);
	// 	#1;
	// 	if($bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH])>1 |$bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH])<-1) begin
	// 		$display("%f, %f", $bitstoshortreal(data_i[i*DATA_WIDTH+:DATA_WIDTH]), $bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH]));
	// 		$display("-------------------------");
	// 	end
	// end

	// for(i=0;i<DEPTH*INPUT*INPUT;i=i+1) begin
	// 	data_i[i*DATA_WIDTH+:DATA_WIDTH]	= $shortrealtobits(0.019338 - DEPTH * INPUT * INPUT * 0.000025+i*0.00005);
	// 	#1;
	// 	// if($bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH])>1 |$bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH])<-1) begin
	// 		$display("%f, %f", $bitstoshortreal(data_i[i*DATA_WIDTH+:DATA_WIDTH]), $bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH]));
	// 		$display("-------------------------");
	// 	// end
	// end
	$fclose(output_log);
	$finish();
end

endmodule