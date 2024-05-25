`timescale 1 ns / 10 ps

module conv_top_TB();
  
reg reset, clk;
reg [1*1*4*8*14-1:0] image0; //depth * data_width * width
reg [1*1*4*8*14-1:0] image1;
reg [1*1*4*8*14-1:0] image2;
wire [4*1*12*8*4-1:0] outputConv;//depth * data_width * width * filter
reg                 image_start;
wire                image_done;
localparam PERIOD = 100;

integer i;

always
	#(PERIOD/2) clk = ~clk;
	
	//4*12*8
initial begin 
	#0
	clk = 1'b0;
	reset = 1;
	image_start = 1'b0;
	//We test with a 1*32*32 image and 6 5*5 filters, all the values are 4
	//Expected output 4704 (6*28*28) values equal to 400 (16*25)
	image0 = {4{112'h00_383028_383028_383028_383028_00}};//{96{32'h4000_0000}}; 
    image1 = {4{112'h00_383028_383028_383028_383028_00}};//{96{32'h4000_0000}}; 
    image2 = {4{112'h00_383028_383028_383028_383028_00}};//{96{32'h4000_0000}}; 
    
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
//filters[1*3*3*32+:3*3*32] = {9{32'h20800000}};
	#PERIOD
	reset = 0;
	#PERIOD
#PERIOD
#PERIOD
#PERIOD
    image_start = 1'b1;
    #PERIOD
    image_start = 1'b0;	#PERIOD
#PERIOD
#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD
#PERIOD
    image_start = 1'b1;
    #PERIOD
    image_start = 1'b0;	#PERIOD
#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD#PERIOD
#PERIOD
#PERIOD
    image_start = 1'b1;
    #PERIOD
    image_start = 1'b0;

	
end


conv_top #(
   .KERNELFILE("mini_conv1_kernel.txt"),.BIASFILE("mini_conv1_bias.txt"),.DATA_WIDTH(8), .D(4), .H(12), .W(12), .F(3), .K(8)
)UUT 
(
	.clk(clk),
	.image0(image0),
	.image1(image1),
	.image2(image2),
	.image_start(image_start),
	.rstn_i(reset),
	.output_add_o(outputConv),
	.output_add_done_o(image_done)
);

endmodule
