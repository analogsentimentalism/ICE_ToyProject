`timescale 1ns / 10ps
module MaxUnit_tb ();

reg [31:0] numA;
reg [31:0] numB;
reg [31:0] numC;
reg [31:0] numD;

wire [31:0] MaxOut;

initial begin

numA = 32'h0C000000;
numB = 32'h8C000000;
numC = 32'h0A000000;
numD = 32'h0B000000;
#10
numA = 32'h0C000000;
numB = 32'h8C000000;
numC = 32'h0A000000;
numD = 32'h10000000;

#10
$stop;
end

MaxUnit UUT(
	.numA(numA),
	.numB(numB),
	.numC(numC),
	.numD(numD),
	.MaxOut(MaxOut)
);
endmodule