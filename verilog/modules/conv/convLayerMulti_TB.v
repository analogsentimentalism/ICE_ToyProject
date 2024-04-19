`timescale 1 ns / 10 ps

module convLayerMulti_TB();
  
reg reset, clk;
reg [1*1*9*32-1:0] image0;
reg [1*1*9*32-1:0] image1;
reg [1*1*9*32-1:0] image2;
reg [4*1*3*3*32-1:0] filters;
wire [4*1*9*32-1:0] outputConv;
reg                 image_start;
wire                image_done;
localparam PERIOD = 100;

integer i;

always
	#(PERIOD/2) clk = ~clk;
	
	
initial begin 
	#0
	clk = 1'b0;
	reset = 1;
	//We test with a 1*32*32 image and 6 5*5 filters, all the values are 4
	//Expected output 4704 (6*28*28) values equal to 400 (16*25)
	image0 = {9{32'h4000_0000}};//{96{32'h4000_0000}};
	image1 = {9{32'h4000_0000}};//{96{32'h4080_0000}};
	image2 = {9{32'h4000_0000}};//{96{32'h4100_0000}};
  filters[4*3*3*32-1:0] = {36{32'h4000_0000}};//, 108{32'h4080_0000}, 108{32'h4000_0000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
	#PERIOD
	reset = 0;
	#PERIOD
	image_start = 1'b1;
  #PERIOD
  image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;	
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#(PERIOD * 1000)
	image_start = 1'b1;
	#PERIOD
	image_start = 1'b0;
	#((65*63+1)**PERIOD)
	for (i = 1*62*62-1; i >=0; i = i - 1) begin
		$displayh(outputConv[i*32+:32]);
	end
	$stop;
end

convLayerMulti #(
   .DATA_WIDTH(32), .D(1), .H(9), .W(9), .F(3), .K(4)
)UUT 
(
	.clk(clk),
	.reset(reset),
	.image0(image0),
	.image1(image1),
	.image2(image2),
	.image_start(image_start),
	.filters(filters),
	.outputCONV(outputConv),
	.done(image_done)
);

endmodule


