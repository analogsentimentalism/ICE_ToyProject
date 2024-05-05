`timescale 1ns / 1ps

module dense_tb #(
	parameter 	W			= 5*5*64*128,	// NUMS로 고쳐야하지만 귀찮아서 걍...
	parameter	H			= 1,
	parameter	BIAS		= 128,
	parameter	DATA_WIDTH	= 32
) ();

reg 		clk			;
reg	[W*H*DATA_WIDTH-1:0]	data_i		;
reg	[BIAS*DATA_WIDTH-1:0]	bias_i		;
reg	[W*H*DATA_WIDTH-1:0]	kernal_i	;
wire[BIAS*DATA_WIDTH-1:0]	result_o	;

dense #(
	.NUMS		(	W*H			),
	.BIAS		(	BIAS		),
	.DATA_WIDTH	(	DATA_WIDTH	)
) u_dense (
	.clk		(	clk			),
	.data_i		(	data_i		),
	.result_o	(	result_o	)
);

integer i,j;

initial begin
#1	clk	= ~clk	;	
end

initial begin
	clk	= 1'b1	;
	for(i=0;i<W*H;i=i+1) begin
		data_i	[i*DATA_WIDTH+:DATA_WIDTH]	= $shortrealtobits(1.5 + i * 0.03)	;
	end
	
	for(i=0;i<BIAS;i=i+1) begin
		#5 $display("result%d:\t\t%f", i+1, $bitstoshortreal(result_o[i*DATA_WIDTH+:DATA_WIDTH]));
	end
	$finish();
end

endmodule