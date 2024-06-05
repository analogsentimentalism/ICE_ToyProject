
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/23 22:15:27
// Design Name: 
// Module Name: add_output
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module add_output#(
parameter       D = 4,
parameter       H = 24,
parameter       F = 3,
parameter       K = 8,
parameter       DATA_WIDTH = 8
 
    
)
(
    input                                   clk,
    input                                   rst_n,
    input       [0:D*H*K*DATA_WIDTH-1   ]   output_convmul_i,
    input                                   done_convmul_i,
    input       [0:K*DATA_WIDTH-1       ]   bias,
    output      [0:H*K*DATA_WIDTH-1     ]   output_add_o,
    output                                  done_add_o
    );


    
    reg                                 state;
    reg         [ 3:0]                  counter; //4 bit counter is enough to control 12 filter (max size)
    reg         [0:D*H*K*DATA_WIDTH-1]  input_data;
    reg         [0:H*DATA_WIDTH-1    ]  add_input    [K-1:0];
    reg         [0:H*DATA_WIDTH-1    ]  add_output   [K-1:0];
   wire    [0:H*DATA_WIDTH-1    ]  add_out_wire   [K-1:0];

   assign output_add_o = {add_output[7],add_output[6],add_output[5],add_output[4],add_output[3],add_output[2],add_output[1],add_output[0]};
   assign done_add_o = (counter == D);
    
   reg      [0:H*DATA_WIDTH-1]      bias_r[K-1:0];
    
    always @ (posedge clk or posedge rst_n) begin
        if(rst_n) begin
            counter = 'h0;
        end
        else begin
             if(done_convmul_i) begin
                counter = 'h0;
             end
             else if (counter == D)
                counter <= D+1;
             else if(state) begin
                counter = counter + 'b1;
             end
        end
    end    
    
    always @ (posedge clk or posedge rst_n) begin
        if(rst_n) begin
            state = 'h0;
        end
        else begin
            if(done_convmul_i) begin
                state = 1'b1;
            end
            else if(counter == D) begin
                state = 1'b0;
            end
        end
    end
    
    always @ (posedge clk or posedge rst_n) begin
        if(rst_n) begin
            input_data = 'h0;
        end
        else begin
            if(done_convmul_i) begin
                input_data = output_convmul_i;
            end
        end
    end
    
    integer i,h;
    
    always @ (*) begin
        for(h = 0; h < K ; h = h + 1) begin
            bias_r[h] = {H{bias[2*h+:DATA_WIDTH]}};
        end
    end
    
    always @ (*) begin
        for(i = 0; i < K ; i = i + 1) begin
            add_input[i]    = (counter < D) ? input_data[(i*H*D*DATA_WIDTH + H*DATA_WIDTH*counter)+:H*DATA_WIDTH] : bias_r[i];//add_input[i];
        end
    end
    genvar j,k,l;
generate
   for(l=0;l<K;l=l+1) begin

       always @ (posedge clk or posedge rst_n) begin
      if (rst_n) begin
         add_output[l] <= 'h0;
      end
      else if (counter == D+1)
         add_output[l] <= 'h0;
      else
         add_output[l] <= add_out_wire[l];
   end
end
endgenerate

    generate 
   for(k=0;k<K;k=k+1) begin
        for(j=0;j<H;j=j+1) begin
            floatAdd u_floatAdd(
            .floatA(add_input[k][DATA_WIDTH*j+:8]),
            .floatB(add_output[k][DATA_WIDTH*j+:8]),
            .sum(add_out_wire[k][DATA_WIDTH*j+:8])
      );
   end
end
    endgenerate
    
endmodule
