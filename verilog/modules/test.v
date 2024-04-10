module test ();

reg [31:0] w [1:0];
initial begin
$readmemh("123.txt", w);
end

endmodule