`timescale 1ns/1ns

module tb_cnn_top ();

reg						clk;
reg						resetn;
reg		[1*24*8-1:0	]	input_data;
reg						buffer_1_valid_i;
wire	[7:0		]	led_o;
wire					dense_valid;

cnn_top dut (
	.clk				(	clk					),
	.resetn				(	resetn				),
	.input_data			(	input_data			),
	.buffer_1_valid_i	(	buffer_1_valid_i	),
	.led_o				(	led_o				),
	.dense_valid		(	dense_valid			)
);

initial begin
	forever #5 clk = ~clk;
end


integer i;
initial begin
	clk	= 1'b1;
	resetn	= 1'b0;
	repeat(10) @(posedge clk);
	resetn	= 1'b1;
	repeat(10) @(posedge clk);

	for(i=0;i<24;i=i+1) begin
		input_data			={(1*24){8'd10 + i}};
		buffer_1_valid_i	= 1'b1;
		repeat(1) @(posedge clk);
		buffer_1_valid_i	= 1'b0;
		repeat(1000) @(posedge clk);
	end
end

endmodule