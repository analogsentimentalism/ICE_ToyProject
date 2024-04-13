`timescale 1 ns / 10 ps

module batch_normalization_layer_tb #(
	parameter	DATA_WIDTH	= 32	,
	parameter	FILTERS		= 64	,
	parameter	DEPTH		= 1		,
	parameter	INPUT		= 30
) ();

reg	 	[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0] 	input_layer	;
reg													clk			;
wire	[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0] 	output_layer;

batch_normalization u_batch_normalization (
	.input_layer	(	input_layer	),
	.clk			(	clk			),
	.output_layer	(	output_layer)
);

initial begin
	forever	#1	clk 	= ~clk	;
end

initial begin
	input_layer	= {3600{8'hAC}};
	#1;
	$display("%h", output_layer);
end

endmodule