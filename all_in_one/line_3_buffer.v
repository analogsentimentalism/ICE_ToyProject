module line_3_buffer(
    clk, resetn, input_data, output_1, output_2, output_3, valid_i, valid_o, behind_conv_done
);
parameter DATA_BITS = 8;
parameter D = 1;
parameter H = 3;
parameter W = 12;
parameter K = 2;
input clk, resetn;
input [D*W*DATA_BITS*K-1:0] input_data;
input behind_conv_done;
output [D*(W+2)*DATA_BITS-1:0] output_1;
output [D*(W+2)*DATA_BITS-1:0] output_2;
output [D*(W+2)*DATA_BITS-1:0] output_3;
input valid_i;
output valid_o;
reg valid;
reg [4:0] zero_padding_counter; 
reg [D*(W+2)*DATA_BITS*K-1:0] buffer [2:0];
reg [1:0] buffer_full;
reg [1:0] counter;
wire [1:0] ptr1, ptr2, ptr3;
reg [2:0] out_counter;

reg button;
assign ptr1 = counter;
assign ptr2 = (counter<2'b10) ? counter + 2'h1 : 2'b00;
assign ptr3 = (ptr2<2'b10) ? ptr2+3'h1 : 2'b00;   
assign output_1 = buffer[ptr1][D*(W+2)*DATA_BITS*out_counter +: D*(W+2)*DATA_BITS];
assign output_2 = buffer[ptr2][D*(W+2)*DATA_BITS*out_counter +: D*(W+2)*DATA_BITS];
assign output_3 = buffer[ptr3][D*(W+2)*DATA_BITS*out_counter +: D*(W+2)*DATA_BITS];
assign valid_o = (zero_padding_counter == 'h0) ? 1'b0 : valid;

always@(posedge clk or negedge resetn) begin
    if (!resetn)
        button <= 1'b0;
    else if((zero_padding_counter == H) & (out_counter == K-1) & behind_conv_done & button)
        button <= 1'b0;
    else if ((zero_padding_counter == H) & (out_counter == K-1) & behind_conv_done)
        button <= 1'b1;
    
end
always@ (posedge clk or negedge resetn) begin
    if(!resetn)
        out_counter <= 3'h0;
    else if ((out_counter == K-1 ) & behind_conv_done)
        out_counter <= 3'h0;        
    else if(behind_conv_done)
        out_counter <= out_counter + 3'b001;

    else
        out_counter <= out_counter;
end

always@(posedge clk or negedge resetn) begin
    if(!resetn)
        zero_padding_counter <= 5'h0;
    else if(valid_i)
        zero_padding_counter <= zero_padding_counter + 5'h1;
    else if ((zero_padding_counter == H) & behind_conv_done & (out_counter == K-1) & button)
        zero_padding_counter <= 5'h0;
end
always @ (posedge clk or negedge resetn) begin
    if (!resetn)
        valid <= 1'b0;
    else if (valid)
        valid<= 1'b0;
    else if (button & behind_conv_done)
        valid <= 1'b1;
    else if((zero_padding_counter == H) & (out_counter < K) & (behind_conv_done) & !button)
        valid <= 1'b1;
    else if((zero_padding_counter == H) & (out_counter < K-1) & (behind_conv_done) & button)
        valid <= 1'b1;
    else if ((valid_i & (buffer_full >= 2'b01)) | ((out_counter < K-1) & behind_conv_done))
        valid<=1'b1;
    
end
always @(posedge clk or negedge resetn)begin
    if (!resetn)
        counter <= 2'h0;
    else if ((counter == 2'b10)&(valid_i | ((zero_padding_counter == H) & behind_conv_done & (out_counter == K-1))))
        counter <= 2'h0;
    else if(valid_i|((zero_padding_counter == H)& behind_conv_done)&(out_counter == K-1))
        counter <= counter + 2'b1;
end
always@(posedge clk or negedge resetn) begin
    if (!resetn)
        buffer_full <= 2'h00;
    else if (buffer_full == 2'b10)
        buffer_full <= buffer_full;
    else if (valid_i)
        buffer_full <= buffer_full + 2'b1;
end
genvar i,j;
generate
    for (i=0; i<3; i=i+1) begin
        for(j=0;j<K;j=j+1)begin
        always @ (posedge clk or negedge resetn) begin
            if(!resetn)
                buffer[i][D*(W+2)*DATA_BITS*j+:D*(W+2)*DATA_BITS] <= 'h0;
            else if ((valid_i)&(i == counter))
                buffer[i][D*(W+2)*DATA_BITS*j+:D*(W+2)*DATA_BITS] <= {{D*DATA_BITS{1'b0}},input_data[D*W*DATA_BITS*j+:D*W*DATA_BITS],{D*DATA_BITS{1'b0}}};
            else if (((zero_padding_counter==H)&behind_conv_done&(out_counter == K-1)) & (i == counter))
                buffer[i][D*(W+2)*DATA_BITS*j+:D*(W+2)*DATA_BITS] <= 'h0;
        end
    end
end
endgenerate
endmodule