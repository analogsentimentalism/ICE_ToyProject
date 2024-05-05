
`timescale 1 ns / 10 ps

module floatAdd (floatA,floatB,sum);
	
input [7:0] floatA, floatB;
output reg [7:0] sum;

reg sign;
reg [3:0] exponent;
reg [2:0] mantissa;
reg [3:0] exponentA, exponentB;
reg [3:0] fractionA, fractionB, fraction;	//fraction = {1,mantissa}
reg [3:0] shiftAmount;
reg cout;

always @ (floatA or floatB) begin
	exponentA = floatA[6:3];
	exponentB = floatB[6:3];
	fractionA = {1'b1,floatA[2:0]};
	fractionB = {1'b1,floatB[2:0]}; 
	
	exponent = exponentA;

	if (floatA == 0) begin						//special case (floatA = 0)
		sum = floatB;
	end else if (floatB == 0) begin					//special case (floatB = 0)
		sum = floatA;
	end else begin
		if (exponentB > exponentA) begin
			shiftAmount = exponentB - exponentA;
			fractionA = fractionA >> (shiftAmount);
			exponent = exponentB;
		end else if (exponentA > exponentB) begin 
			shiftAmount = exponentA - exponentB;
			fractionB = fractionB >> (shiftAmount);
			exponent = exponentA;
		end
		if (floatA[7] == floatB[7]) begin			//same sign
			{cout,fraction} = fractionA + fractionB;
			if (cout == 1'b1) begin
				{cout,fraction} = {cout,fraction} >> 1;
				exponent = exponent + 1;
			end
			sign = floatA[7];
		end else begin						//different signs
			if (floatA[7] == 1'b1) begin
				{cout,fraction} = fractionB - fractionA;
			end else begin
				{cout,fraction} = fractionA - fractionB;
			end
			sign = cout;
			if (cout == 1'b1) begin
				fraction = -fraction;
			end else begin
			end
			if (fraction [3] == 0) begin
				if (fraction[2] == 1'b1) begin
					fraction = fraction << 1;
					exponent = exponent - 1;
				end else if (fraction[1] == 1'b1) begin
					fraction = fraction << 2;
					exponent = exponent - 2;
				end else if (fraction[0] == 1'b1) begin
					fraction = fraction << 3;
					exponent = exponent - 3;
                end
			end
		end
		mantissa = fraction[2:0];
		sum = {sign,exponent,mantissa};			
	end		
end

endmodule
