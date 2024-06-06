`timescale 1ns / 1ps

module dense_opt_tb #(
	parameter	BIASFILE	= "mini_dense0_bias.txt"		,
	parameter	KERNELFILE	= "mini_dense0_kernel.txt"	,
	parameter	H			= 2						,
	parameter	W			= 2						,
	parameter	DEPTH		= 64					,
	parameter	BIAS		= 128					,
	parameter	DATA_WIDTH	= 32					,
	parameter	NUMS		= DEPTH * H * W
) ();

reg											clk			;
reg		[DATA_WIDTH * H * DEPTH - 1:0]		data_i		;
reg											rstn		;
reg											valid_i		;
wire	[DATA_WIDTH - 1:0]			result_o	;
wire										valid_o		;

reg		[DATA_WIDTH * NUMS * BIAS - 1:0]	data_arr	;

dense_int_front #(
	.H			(	H			),
	.W			(	W			),
	.DEPTH		(	DEPTH		),
	.BIAS		(	BIAS		),
	.DATA_WIDTH	(	DATA_WIDTH	)
) u_dense_opt (
	.clk		(	clk			),
	.rstn		(	rstn		),
	.data_i		(	data_i		),
	.data_o		(	result_o	),
	.valid_i	(	valid_i		),
	.valid_o	(	valid_o		)
);

initial begin
	forever	#1	clk	= ~clk	;
end


integer i, j;

initial begin
	for(i=0;i<NUMS * BIAS;i=i+1) begin
		data_arr[i*DATA_WIDTH+:DATA_WIDTH]	= $shortrealtobits(i*1.0+0.1);
	end
end

initial begin
	clk	= 1'b1	;
	rstn= 1'b0	;
	valid_i	= 1'b0;
	repeat (5) @(posedge clk);
	rstn	= 1'b1;
	repeat (1) @(posedge clk);
	valid_i	= 1'b1;
	for(j=0;j<H;j=j+1) begin
		data_i	= data_arr	[j*DATA_WIDTH*W*DEPTH+:DATA_WIDTH*W*DEPTH]	;
		repeat (1) @(posedge clk);
	end
end

endmodule