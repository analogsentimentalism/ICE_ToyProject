module floatComp(
    floatA, floatB, Max
);
parameter DATA_BITS = 8;

input [DATA_BITS-1 : 0] floatA, floatB;
output reg [DATA_BITS-1 : 0] Max;

reg signA, signB;
reg [3:0] exponentA, exponentB;
reg [2:0] mantissaA, mantissaB;

always@(floatA or floatB) begin
    signA = floatA[7];
    signB = floatB[7];
    exponentA = floatA[6:3];
    exponentB = floatB[6:3];
    mantissaA = floatA[2:0];
    mantissaB = floatB[2:0];

    case ({signA, signB})
        2'b00 : begin
            if(exponentA > exponentB) 
                Max = floatA;
            else if (exponentA < exponentB)
                Max = floatB;
            else begin
                if (mantissaA > mantissaB)
                    Max = floatA;
                else if (mantissaA < mantissaB)
                    Max = floatB;
                else
                    Max = floatA;
            end
        end
        2'b01 : Max = floatA;
        2'b10 : Max = floatB;
        2'b11 : begin
            if(exponentA > exponentB)
                Max = floatB;
            else if (exponentA < exponentB)
                Max = floatA;
            else begin
                if (mantissaA > mantissaB)
                    Max = floatB;
                else if (mantissaA < mantissaB)
                    Max = floatA;
                else
                    Max = floatA;
            end
        end
        default : Max = 8'h0;
    endcase

end
endmodule