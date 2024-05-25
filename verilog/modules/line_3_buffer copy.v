module line_3_buffer(
    clk, resetn, input_data, output_1, output_2, output_3, valid_i, valid_o
);
parameter DATA_BITS = 8;
parameter D = 1;
parameter H = 24;
parameter W = 24;
parameter K = 6;
input clk, resetn;
input [D*W*DATA_BITS*K-1:0] input_data;
output [D*W*DATA_BITS*K-1:0] output_1;
output [D*W*DATA_BITS*K-1:0] output_2;
output [D*W*DATA_BITS*K-1:0] output_3;
input valid_i;
output valid_o;
reg valid;

reg [W*DATA_BITS*K-1:0] buffer [2:0];
reg [1:0] buffer_full;
reg [1:0] counter;
wire [1:0] ptr1, ptr2, ptr3;
assign ptr1 = counter;
assign ptr2 = (counter<2'b10) ? counter + 2'h1 : 2'b00;
assign ptr3 = (ptr2<2'b10) ? ptr2+3'h1 : 2'b00;   
assign output_1 = buffer[ptr1];
assign output_2 = buffer[ptr2];
assign output_3 = buffer[ptr3];
assign valid_o = valid;
always @ (posedge clk or negedge resetn) begin
    if (!resetn)
        valid <= 1'b0;
    else if (valid)
        valid<= 1'b0;
    else if (valid_i & (buffer_full >= 2'b01))
        valid<=1'b1;
end
always @(posedge clk or negedge resetn)begin
    if (!resetn)
        counter <= 2'h0;
    else if ((counter == 2'b10)&valid_i)
        counter <= 2'h0;
    else if(valid_i)
        counter <= counter+ + 2'b1;
end
always@(posedge clk or negedge resetn) begin
    if (!resetn)
        buffer_full <= 2'h0;
    else if (buffer_full == 2'b10)
        buffer_full <= buffer_full;
    else if (valid_i)
        buffer_full <= buffer_full + 2'b1;
end
genvar i;
generate
    for (i=0; i<3; i=i+1) begin
        always @ (posedge clk or negedge resetn) begin
            if(!resetn)
                buffer[i] <= 'h0;
            else if ((valid_i)&(i == counter))
                buffer[i] <= input_data;
        end
end
endgenerate
endmodule