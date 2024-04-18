module max_pooling_mult(
    clk, reset, multi_input_data, multi_output_data, valid_i, valid_o
);

parameter DATA_BITS = 32;
parameter D = 64;
parameter H = 92;
parameter W = 92;

input reset, clk;
input valid;
input [1*W*D*DATA_BITS-1:0] multi_input_data;
output reg [(1*W/2) *D*DATA_BITS-1:0] multi_output_data;
output reg valid_o;

reg [2*W*D*DATA_BITS -1:0] single_input_data;
reg [W*D*DATA_BITS-1 :0] first_line;  // maxpool 두줄씩 해야하니까 내부에서 한번 저장
reg [W*D*DATA_BITS-1 :0] second_line;
reg check; //second까지 잘 찼는지

wire [(1*W/2)*D * DATA_BITS -1:0] single_output_data;

max_pooling_single u_max_pooling_single(
    .single_input_data(single_input_data),
    .single_output_data(single_output_data)
);

always@(posedge clk or posedge reset) begin
    if(reset) begin
        first_line <= 'd0;
    end
    else if (valid & !check)
        first_line <= multi_input_data;
    else
        first_line <= first_line;
end
always@(posedge clk or posedge reset) begin
    if(reset) begin
        second_line <= 'd0;
    end
    else if (valid & check)
        second_line <= multi_input_data;
    else
        second_line <= second_line;
end

always@(posedge clk or posedge reset) begin
    if(reset) 
        check <= 1'b0;
    else if (valid)
        check <= !check;
    else
        check <= check;
end


always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter = 0;
    end
    else if (counter <D) begin
        counter = counter + 1;
    end
end

always@(*) begin
    single_input_data = {second_line, first_line};
    multi_output_data = single_output_data;
    valid_o           = (!check & valid_i) ? 1'b1 : 1'b0;
end

endmodule