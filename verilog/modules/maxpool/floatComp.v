module floatComp(
    floatA, floatB, Max
);
parameter DATA_BITS = 32;

input [DATA_BITS-1 : 0] floatA, floatB;
output reg [DATA_BITS-1 : 0] Max;

reg signA, signB;
reg [7:0] exponentA, exponentB;
reg [22:0] mantissaA, mantissaB;

always@(floatA or floatB) begin
    signA = floatA[31];
    signB = floatB[31];
    exponentA = floatA[30:23];
    exponentB = floatB[30:23];
    mantissaA = floatA[22:0];
    mantissaB = floatB[22:0];

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
        default : Max = 32'h0;
    endcase

end
endmodule