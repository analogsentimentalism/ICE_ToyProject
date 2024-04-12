module max_pooling(
    clk, rst_n, input_data, output_data
);

parameter DATA_BITS = 32;
parameter D = 32;
parameter W = 46;
parameter H = 46;

input reset, clk;
input [0: H*W*DATA_BITS - 1] input_data;
output [(H*W/4)*DATA_BITS -1 : 0] output_data;

genvar i, j;


generate
    for (i = 0; i<H; i = i+2) begin
        for( j= 0; j<W; j = j+2) begin
            
            output_data[((i*37) +(j/2))*DATA_BITS +: 8] =  
        end
    end
endgenerate
// 00 -> 0 / 02 -> 1 04 -> 2 06 -> 3 .. 0 94 -> 37 20 -> 95
endmodule

