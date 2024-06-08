`timescale 1ns/1ns

module tb_cnn_top ();

reg					clk;
reg					resetn;
reg		[3:0	]	sw;
reg					button;
wire	[7:0	]	led_o;
wire				dense_valid;

cnn_top dut (
	.clk				(	clk					),
	.resetn				(	resetn				),
	.sw					(	sw					),
	.button				(	button				),
	.led_o				(	led_o				),
	.dense_valid		(	dense_valid			)
);

initial begin
	forever #1 clk = ~clk;
end


integer i;
initial begin
	clk		= 1'b1;
	resetn	= 1'b0;
	sw		= 4'b0;
	button	= 1'b0;
	repeat(10) @(posedge clk);
	resetn	= 1'b1;
	repeat(10) @(posedge clk);
	button	= 1'b1;
end

endmodule