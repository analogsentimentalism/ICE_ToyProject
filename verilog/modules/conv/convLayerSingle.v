/*`timescale 1 ns / 10 ps

module convLayerSingle(clk,reset,i_valid,image,filter,outputConv,o_valid);

parameter DATA_WIDTH = 32;
parameter D = 1; //Depth of the filter
parameter H = 64; //Height of the image
parameter W = 64; //Width of the image
parameter F = 3; //Size of the filter

input clk, reset, i_valid;
input [0:D*H*W*DATA_WIDTH-1] image;
input [0:D*F*F*DATA_WIDTH-1] filter;
output reg [0:(H-F+1)*(W-F+1)*DATA_WIDTH-1] outputConv; // output of the module
output o_valid;

wire [0:(W-F+1)*DATA_WIDTH-1] outputConvUnits; // output of the conv units and input to the row selector

reg internalReset;
wire [0:((W-F+1)*D*F*F*DATA_WIDTH)-1] receptiveField; // array of the matrices to be sent to conv units


integer counter;
reg [6:0] rowNumber; // determine the row that is calculated by the conv units

RFselector
#(
	.DATA_WIDTH(DATA_WIDTH),
	.D(D),
	.H(H),
	.W(W),
	.F(F)
) RF
(
	.image(image),
	.rowNumber(rowNumber),
	.receptiveField(receptiveField)
);

genvar n;

generate 
	for (n = 0; n < (H-F+1); n = n + 1) begin 
		convUnit
		#(
			.D(D),
			.F(F)
		) CU
		(
			.clk(clk),
			.reset(internalReset),
			.image(receptiveField[n*D*F*F*DATA_WIDTH+:D*F*F*DATA_WIDTH]),
			.filter(filter),
			.result(outputConvUnits[n*DATA_WIDTH+:DATA_WIDTH])
		);
	end
endgenerate

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1) begin
		internalReset = 1'b1;
		rowNumber = 0;
		counter = 0;
	end else if (rowNumber < H-F+1) begin
		if (counter == D*F*F+2) begin
			rowNumber = rowNumber + 1;
			counter = 0;
			internalReset = 1'b1;
		end else begin
			internalReset = 0;
			counter = counter + 1;
		end
	end
end

//always @ (*) begin
//	outputConv[rowNumber*(H-F+1)*DATA_WIDTH+:(W-F+1)*DATA_WIDTH] = outputConvUnits;
//end

endmodule*/

`timescale 1 ns / 10 ps

module convLayerSingle(clk,reset,image_valid,image0,image1,image2,filter,outputConv,o_valid);

parameter DATA_WIDTH = 8;
parameter D = 1; //Depth of the filter
parameter H = 6; //Height of the image
parameter W = 6; //Width of the image
parameter F = 3; //Size of the filter

input clk, reset;
input                        image_valid;
input [0:1*(W+2)*DATA_WIDTH-1] image0; //input image is 1 line
input [0:1*(W+2)*DATA_WIDTH-1] image1;
input [0:1*(W+2)*DATA_WIDTH-1] image2;
input [0:F*F*DATA_WIDTH-1] filter;
output [0:W*DATA_WIDTH-1] outputConv; // output of the module
output reg                   o_valid;

//wire [(W-F+1)*DATA_WIDTH-1:0] outputConvUnits; // output of the conv units and input to the row selector

reg internalReset;


integer i, counter;

/*
always @ (posedge clk or posedge reset) begin
    if(reset) begin
        image_buffer_0 <= 'h0;
        image_buffer_1 <= 'h0;
        image_buffer_2 <= 'h0;
    end
    else if(i_image_valid) begin
            image_buffer_0 <= image_buffer_1;
            image_buffer_1 <= image_buffer_2;
            image_buffer_2 <= image;
    end
end
*/

genvar n;

generate 
	for (n = 0; n < W; n = n + 1) begin 
		convUnit
		#(
			.D(D),
			.F(F)
		) CU
		(
			.clk(clk),
			.reset(internalReset),
			.image0(image0[n*DATA_WIDTH+:F*DATA_WIDTH]),
			.image1(image1[n*DATA_WIDTH+:F*DATA_WIDTH]),
			.image2(image2[n*DATA_WIDTH+:F*DATA_WIDTH]),
			.filter(filter),
			.result(outputConv[n*DATA_WIDTH+:DATA_WIDTH])
		);
	end
endgenerate

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1 || image_valid == 1'b0) begin
		internalReset = 1'b1;
		counter = 0;
		o_valid = 1'b0;
	end 
	else begin
		  if (counter == D*F*F+1) begin
		    o_valid = 1'b1;
		    counter = counter + 1;
		  end  
		  else if (counter == D*F*F+2) begin
			   counter = 0;
			   internalReset = 1'b1;
			   o_valid = 1'b0;
		  end else begin
			   internalReset = 0;
			   counter = counter + 1;
			   o_valid = 1'b0;
		  end
	end
end

endmodule

