module max_pooling_mult(
    clk, reset, multi_input_data, multi_output_data
);

parameter DATA_BITS = 32;
parameter D = 32;
parameter H = 46;
parameter W = 46;

input reset, clk;
input [H*W*D*DATA_BITS-1:0] multi_input_data;
output reg [(H*W/4) *D*DATA_BITS-1:0] multi_output_data;

reg [H*W*DATA_BITS -1:0] single_input_data;
wire [(H*W/4) * DATA_BITS -1:0] single_output_data;
integer counter;

max_pooling_single u_max_pooling_single(
    .single_input_data(single_input_data),
    .single_output_data(single_output_data)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter = 0;
    end
    else if (counter <D) begin
        counter = counter + 1;
    end
end

always@(*) begin
    single_input_data = multi_input_data[counter * H * W * DATA_BITS+:H*W*DATA_BITS];
    multi_output_data[counter * H * W / 4 *DATA_BITS +:(H*W/4) *DATA_BITS] = single_output_data;

end

endmodule