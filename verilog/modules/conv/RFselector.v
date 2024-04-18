NO USE
/*
`timescale 1 ns / 10 ps

module RFselector(image,rowNumber,receptiveField);

parameter DATA_WIDTH = 32;
parameter D = 1; //Depth of the filter
parameter H =48; //Height of the image
parameter W =48; //Width of the image
parameter F = 5; //Size of the filter

input [0:D*H*W*DATA_WIDTH-1] image;
input [5:0] rowNumber;
output reg [0:((W-F+1)*D*F*F*DATA_WIDTH)-1] receptiveField;

integer address, c, k, i;

always @ (image or rowNumber) begin
	address = 0;
	for (c = 0; c <  W-F+1; c = c + 1) begin
		for (k = 0; k < D; k = k + 1) begin
			for (i = 0; i < F; i = i + 1) begin
				receptiveField[address*F*DATA_WIDTH+:F*DATA_WIDTH] = image[rowNumber*W*DATA_WIDTH+c*DATA_WIDTH+k*H*W*DATA_WIDTH+i*W*DATA_WIDTH+:F*DATA_WIDTH];
				address = address + 1;
			end
		end
	end
end

endmodule
*/
