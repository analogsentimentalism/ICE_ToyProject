
`timescale 1 ns / 10 ps

module floatMult (floatA,floatB,product);

input [7:0] floatA, floatB;
output reg [7:0] product;

reg sign;
reg [3:0] exponent;
reg [2:0] mantissa;
reg [3:0] fractionA, fractionB;	//fraction = {1,mantissa}
reg [7:0] fraction;

always @ (floatA or floatB) begin
	if (floatA == 0 || floatB == 0) begin
		product = 0;
	end else begin
		sign = floatA[7] ^ floatB[7];
		exponent = floatA[6:3] + floatB[6:3] - 4'd7;
	
		fractionA = {1'b1,floatA[2:0]};
		fractionB = {1'b1,floatB[2:0]};
		fraction = fractionA * fractionB;
		
		if (fraction[7] == 1'b1) begin
			fraction = fraction << 1;
			exponent = exponent - 1; 
		end else if (fraction[6] == 1'b1) begin
			fraction = fraction << 2;
			exponent = exponent - 2;
		end else if (fraction[5] == 1'b1) begin
			fraction = fraction << 3;
			exponent = exponent - 3;

		mantissa = fraction[7:5];
		product = {sign,exponent,mantissa};
	end
end

endmodule
