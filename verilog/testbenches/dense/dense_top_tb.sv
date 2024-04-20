`timescale 1ns/1ns
module dense_top_tb #(
	parameter	BIASFILE	= "dense0_bias.txt"		,
	parameter	KERNELFILE	= "dense0_kernel.txt"	,
	parameter	H			= 5						,
	parameter	W			= 5						,
	parameter	DEPTH		= 64					,
	parameter	BIAS		= 128					,
	parameter	DATA_WIDTH	= 32					,
	parameter	NUMS		= DEPTH * H * W
) ();

reg											clk		;
reg		[DATA_WIDTH * NUMS * BIAS - 1:0]	data_i	;
reg											rstn	;

wire	[DATA_WIDTH * BIAS - 1:0]	result_o		;

dense_top #(
	.H(H),
	.W(W),
	.DEPTH(DEPTH),
	.BIAS(BIAS)
) u_dense_top (
	.clk		(	clk			),
	.data_i		(	data_i		),
	.result_o	(	result_o	),
	.rstn_i		(	rstn		)
);



initial begin
	forever	#1	clk	= ~clk	;
end

initial begin
	std::randomize(data_i);
	clk	= 1'b1	;
	rstn= 1'b1	;
	#5	rstn	= 1'b0;
	#5	rstn	= 1'b1;
end

endmodule