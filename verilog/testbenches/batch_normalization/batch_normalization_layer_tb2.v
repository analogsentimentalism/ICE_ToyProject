`timescale 1 ns / 10 ps

module batch_normalization_layer_tb #(
	parameter	DATA_WIDTH	= 32	,
	parameter	FILTERS		= 64	,
	parameter	DEPTH		= 1		,
	parameter	INPUT		= 30
) ();

reg	 	[DEPTH * INPUT * INPUT * DATA_WIDTH * FILTERS - 1:0] 	input_layer	;
reg													clk			;
wire	[DEPTH * INPUT * INPUT * DATA_WIDTH * FILTERS - 1:0] 	output_layer;

batch_normalization_layer u_batch_normalization_layer (
	.input_layer	(	input_layer		),
	.clk			(	clk				),
	.output_layer	(	output_layer	)
);

initial begin
	forever	#1	clk 	= ~clk	;
end

integer i, j, k;

integer output_log;

initial begin
	// output_log = $fopen("../BN_layer_log.txt", "wb"	);
	for(i=0; i<FILTERS; i = i + 1) begin
		for(j=0; j<DEPTH * INPUT; j = j +1) begin
			for(k=0; k<INPUT;k=k+1) begin
				#5; input_layer[(i*INPUT*INPUT+j*INPUT+k)*DATA_WIDTH+:DATA_WIDTH]	= j*4;
				// $write("%f\t", $bitstoshortreal(input_layer[(i*INPUT*INPUT+j*INPUT+k)*DATA_WIDTH+:DATA_WIDTH]));
				// $fwrite(output_log, "%f\t", $bitstoshortreal(input_layer[(i*INPUT*INPUT+j*INPUT+k)*DATA_WIDTH+:DATA_WIDTH]));
			end
			// $fwrite(output_log, "\n");
			// $display();
		end
		// $display("\n");
		// $fwrite(output_log, "\n\n");
	end
	// $display("\n\n\n");
	// $fwrite(output_log, "\n\n\n");
	#1;
	// for(i=0; i<FILTERS; i = i + 1) begin
	// 	$display("%dth FILTER", i);
	// 	for(j=0; j < DEPTH * INPUT; j = j +1) begin
	// 		for(k=0; k<INPUT; k = k+1) begin
	// 			$write("%f\t", $bitstoshortreal(output_layer[(i*INPUT*INPUT+j*INPUT+k)*DATA_WIDTH+:DATA_WIDTH]));
	// 			$fwrite(output_log, "%f\t", $bitstoshortreal(output_layer[(i*INPUT*INPUT+j*INPUT+k)*DATA_WIDTH+:DATA_WIDTH]));
	// 		end
	// 		// $fwrite(output_log, "\n");
	// 		$display();
	// 	end
	// 	// $fwrite(output_log, "\n\n");
	// 	$display("\n");
	// end

	// $fclose(output_log);
	$finish();
end

endmodule