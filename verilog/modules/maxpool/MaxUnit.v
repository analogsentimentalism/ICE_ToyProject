module MaxUnit(
    numA, numB, numC, numD, MaxOut
);
parameter DATA_BITS = 32;
input [DATA_BITS-1:0] numA,numB, numC, numD;
output [DATA_BITS-1:0] MaxOut;

wire [DATA_BITS-1 : 0] comp1result;
wire [DATA_BITS-1 : 0] comp2result;

floatComp FCOMP1 (numA, numB, comp1result);
floatComp FCOMP1 (comp1result, numC, comp2result);
floatComp FCOMP1 (comp2result, numD, MaxOut);

endmodule
