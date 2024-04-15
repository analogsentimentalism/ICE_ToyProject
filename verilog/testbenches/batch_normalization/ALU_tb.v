`timescale 1 ns / 10 ps

module ALU_tb();

reg			[31:0]	A		;
reg			[31:0]	B		;
reg					clk		;

wire		[31:0]	result	;

FloatingDivision Div (
	.A		(	A		),
    .B		(	B		),
    .clk	(	clk		),
    .result	(	result	)
	);

// FloatingMultiplication Mul (
// 	.A		(	A		),
//     .B		(	B		),
//     .clk	(	clk		),
//     .result	(	result	)
// 	);

// FloatingAddition Add (
// 	.A		(	A		),
//     .B		(	B		),
//     .result	(	result	)
// );

initial begin
	forever #1	clk	= ~clk	;
end

integer i, j;

initial begin
	B	= $shortrealtobits(-0.019338);
	for(i=0; i<100; i=i+1) begin
		A	= $shortrealtobits(0.015638 + 0.00005*i);
		#1 $display("%.6f + %.6f = %.6f", $bitstoshortreal(A), $bitstoshortreal(B), $bitstoshortreal(result));
	end
	$finish();
end

endmodule