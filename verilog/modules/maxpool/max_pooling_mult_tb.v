

`timescale 1 ns / 10 ps

module max_pooling_mult_tb ();

reg clk,reset;
reg [32*46*46*32-1:0] multi_input_data;
wire [32*23*23*32-1:0] multi_output_data;

localparam PERIOD = 100;

integer i;

always
	#(PERIOD/2) clk = ~clk;
	
initial begin
    #0
    clk = 1'b0;
	reset = 1;
    multi_input_data = {16928{128'h0C0000008C0000000A0000000B000000}};
    #(PERIOD)
	  reset = 0;
    
    #(8*PERIOD)
    for (i = 32*23*23-1; i >=0; i = i - 1) begin
		  $displayh(multi_output_data[i*32+:32]);
	  end
	#(PERIOD)
	reset =1;
    	multi_input_data = {16928{128'h0C0000008C0000000D0000000A000000}};
	#(PERIOD)
	reset=0;	
	#(8*PERIOD)
    for (i = 32*23*23-1; i >=0; i = i - 1) begin
		  $displayh(multi_output_data[i*32+:32]);
	  end
	$stop;
end
max_pooling_mult UUT
  (
    .clk(clk),
    .reset(reset),
    .multi_input_data(multi_input_data),
    .multi_output_data(multi_output_data)
  );
endmodule                                                             