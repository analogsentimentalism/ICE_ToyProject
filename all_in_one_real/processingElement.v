`timescale 1 ns / 10 ps

module processingElement(clk,reset,floatA,floatB,result);

parameter input_DATA_WIDTH = 8;
parameter output_DATA_WIDTH = 32;

input clk, reset;
input [input_DATA_WIDTH-1:0] floatA, floatB;
output reg signed [output_DATA_WIDTH-1:0] result;

wire signed [output_DATA_WIDTH-1:0] multResult;

floatMult FM (floatA,floatB,multResult);

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1) begin
		result = 0;
	end else begin
		result <= result + multResult;
	end
end

endmodule