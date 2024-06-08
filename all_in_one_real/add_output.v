
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
parameter       input_DATA_WIDTH = 32,
parameter       output_DATA_WIDTH = 8,
parameter       shift = 10
    
)
(
    input                                   clk,
    input                                   rst_n,
    input       [0:D*H*K*input_DATA_WIDTH-1   ]   output_convmul_i,
    input                                   done_convmul_i,
    input       [0:K*input_DATA_WIDTH-1       ]   bias,
    output    reg   [0:H*K*output_DATA_WIDTH-1     ]   output_add_o,
    output                                  done_add_o
    );
/*backup
    reg                                 state;
    reg         [ 3:0]                  counter; //4 bit counter is enough to control 12 filter (max size)
    reg         [0:D*H*K*input_DATA_WIDTH-1]  input_data;
    reg    signed     [0:H*input_DATA_WIDTH-1    ]  add_input    [K-1:0];
    reg    signed     [0:H*input_DATA_WIDTH-1    ]  add_output   [K-1:0];
    reg    signed     [0:H*output_DATA_WIDTH-1   ]  add_out_wire [K-1:0];
*/
    reg                                 state;
    reg         [ 3:0]                  counter; //4 bit counter is enough to control 12 filter (max size)
    reg         [0:D*H*K*input_DATA_WIDTH-1]  input_data;
    reg    signed     [0:input_DATA_WIDTH-1    ]  add_input    [K-1:0][H-1:0];
    reg    signed     [0:input_DATA_WIDTH-1    ]  add_output   [K-1:0][H-1:0];
    reg    signed     [0:output_DATA_WIDTH-1   ]  add_out_wire [K-1:0][H-1:0];

   // assign output_add_o = {add_output[7],add_output[6],add_output[5],add_output[4],add_output[3],add_output[2],add_output[1],add_output[0]};
   integer m, n;
 always @ (*) begin
        for(m=0;m<K;m=m+1) begin
            for(n = 0; n<H; n = n+1) begin
                output_add_o[ n*output_DATA_WIDTH + H*output_DATA_WIDTH*m +:output_DATA_WIDTH] = add_out_wire[m][n];
            end
        end
 end


   assign done_add_o = (counter == D+1);
    
 //  reg      [0:H*input_DATA_WIDTH-1]      bias_r[K-1:0];
    
    always @ (posedge clk or posedge rst_n) begin
        if(rst_n) begin
            counter = 'h0;
        end
        else begin
             if(done_convmul_i) begin
                counter = 'h0;
             end
             else if (counter == D+1)
                counter = D+2;
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
            else if(counter == D+1) begin
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
    
    integer a,i,h;
    
 /*   always @ (*) begin
        for(h = 0; h < K ; h = h + 1) begin
            bias_r[h] = {H{bias[input_DATA_WIDTH*h+:input_DATA_WIDTH]}};
        end
    end*/
    
    always @ (*) begin
       for(i = 0; i < K ; i = i + 1) begin
            for(a = 0; a<H; a = a+1) begin
            add_input[i][a]    = (counter < D) ? input_data[(a*input_DATA_WIDTH + H*i*input_DATA_WIDTH +H*K*input_DATA_WIDTH*counter)+:input_DATA_WIDTH] 
                                                : bias[i*input_DATA_WIDTH+:input_DATA_WIDTH];//add_input[i];
        end
    end
    end
    
    integer k, j;
   always @ (posedge clk) begin
   for(k=0;k<K;k=k+1) begin
        for(j=0;j<H;j=j+1) begin
            if(counter == D+2 || counter == 0) begin
                add_output[k][j] = 'h0;
            end 
            else begin
                add_output[k][j] = (add_input[k][j]) + (add_output[k][j]);
            end
           /* floatAdd u_floatAdd(
            .floatA(add_input[k][DATA_WIDTH*j+:8]),
            .floatB(add_output[k][DATA_WIDTH*j+:8]),
            .sum(add_out_wire[k][DATA_WIDTH*j+:8])
      );*/
      end
   end
end




    integer u,U;
always @ (*) begin
   for(u=0;u<K;u=u+1) begin
        for(U=0;U<H;U=U+1) begin
            if($signed(add_output[u][U]>>>shift) >= $signed('d127)) begin
                 add_out_wire[u][U] = 8'b0111_1111;
            end
            else if($signed(add_output[u][U]>>>shift) < $signed(-'d128)) begin
                add_out_wire[u][U] = 8'b1000_0000;
            end 
            else begin
                add_out_wire[u][U] = $signed(add_output[u][U]>>>shift);
            end 
          end
   end
end
 
 
    
endmodule
