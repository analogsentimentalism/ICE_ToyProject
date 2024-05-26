`timescale 1 ns / 10 ps
module max_pooling_mult(

    clk, reset, multi_input_data, multi_output_data, valid_i, valid_o
);

parameter DATA_BITS = 8;
parameter D = 1;
parameter H = 24;
parameter W = 24;

input reset, clk;
input valid_i;

input [1*W*D*DATA_BITS-1:0] multi_input_data;
output reg [(1*W/2) *D*DATA_BITS-1:0] multi_output_data;
output reg valid_o;

reg [2*W*D*DATA_BITS -1:0] single_input_data;
reg [W*D*DATA_BITS-1 :0] first_line;  // maxpool �몢以꾩뵫 �빐�빞�븯�땲源� �궡遺��뿉�꽌 �븳踰� ���옣
reg [W*D*DATA_BITS-1 :0] second_line;
reg check; //second源뚯� �옒 李쇰뒗吏�

wire [(1*W/2)*D * DATA_BITS -1:0] single_output_data;

max_pooling_single #(
    .DATA_BITS(DATA_BITS),
    .W(W),
    .D(D),
    .H(H))
    u_max_pooling_single(
    .single_input_data(single_input_data),
    .single_output_data(single_output_data)
);

always@(posedge clk or posedge reset) begin
    if(reset) begin
        first_line <= 'd0;
    end
    else if (valid_i & !check)
        first_line <= multi_input_data;
    else
        first_line <= first_line;
end
always@(posedge clk or posedge reset) begin
    if(reset) begin
        second_line <= 'd0;
    end
    else if (valid_i & check)
        second_line <= multi_input_data;
    else
        second_line <= second_line;
end

always@(posedge clk or posedge reset) begin
    if(reset) 
        check <= 1'b0;
    else if (valid_i)
        check <= !check;
    else
        check <= check;
end




always@(*) begin
    single_input_data = {second_line, first_line};
    multi_output_data = single_output_data;
    valid_o           = (check & valid_i) ? 1'b1 : 1'b0; 
end

endmodule