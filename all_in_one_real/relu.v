module relu(
    input_data, output_data
);

parameter DATA_BITS = 8;
parameter D = 32;
parameter H = 23;
parameter W = 23;

input [W*D*DATA_BITS -1 : 0] input_data;
output [W*D*DATA_BITS -1 : 0] output_data;

genvar i;

generate
for (i=0; i<W*D; i = i + 1) begin
        assign output_data[i*DATA_BITS +: DATA_BITS] = (input_data[i*DATA_BITS+7]) ? 8'h0 : input_data[i*DATA_BITS +: DATA_BITS];
end
endgenerate


endmodule
