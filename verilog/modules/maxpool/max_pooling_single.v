module max_pooling_single(
    single_input_data, single_output_data
);

parameter DATA_BITS = 32;
parameter D = 32;
parameter W = 92;
parameter H = 92;

input [2*W*D*DATA_BITS - 1:0] single_input_data;
output [(1*W/2)*D*DATA_BITS -1 : 0] single_output_data;

genvar i, j;


generate
    for(i=0;i<D;i = i+1)
        for( j= 0; j<W; j = j+2) begin
            MaxUnit u_MaxUnit(
                .numA(single_input_data[D*(j)*DATA_BITS+:DATA_BITS]),
                .numB(single_input_data[D*(j+1)*DATA_BITS+:DATA_BITS]),
                .numC(single_input_data[D*(W+j)*DATA_BITS+:DATA_BITS]),
                .numD(single_input_data[D*(W+j+1)*DATA_BITS+:DATA_BITS]),
                .MaxOut(single_output_data[D*(j/2)*DATA_BITS+:DATA_BITS])
            );
        end
    end
endgenerate
// 00 -> 0 / 02 -> 1 04 -> 2 06 -> 3 .. 0 94 -> 37 20 -> 95
endmodule

