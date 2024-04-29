

`timescale 1 ns / 10 ps

module max_pooling_mult_tb ();

reg clk,reset;
reg [1*48*32-1:0] multi_input_data;
wire [1*24*32-1:0] multi_output_data;
wire valid_o;
reg valid_i;
localparam PERIOD = 100;

integer i;

always
	#(PERIOD/2) clk = ~clk;
	
initial begin
    #0
    clk = 1'b0;
	reset = 1;
    multi_input_data = {24{64'h0C0000008C000000}};
	valid_i = 1'b1;
    #(PERIOD)
	  reset = 0;
	#(PERIOD)
	valid_i = 1'b0;
	#(PERIOD)
	valid_i = 1'b1;
	multi_input_data = {24{64'hA0000000B000000}};
    #(8*PERIOD)
    for (i = 4*46-1; i >=0; i = i - 1) begin
		  $displayh(multi_output_data[i*32+:32]);
	end
	#(PERIOD)
	$stop;
end
max_pooling_mult UUT
  (
    .clk(clk),
    .reset(reset),
    .valid_i(valid_i),
    .valid_o(valid_o),
    .multi_input_data(multi_input_data),
    .multi_output_data(multi_output_data)
  );
endmodule                                                             