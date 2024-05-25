`timescale 1ns / 1ps
module conv_top #(
	parameter	KERNELFILE	  = "mini_conv1_kernel.txt"		,
	parameter  BIASFILE       = "mini_conv1_bias.txt",
	parameter  D           = 4,
	parameter	H			= 12					,
	parameter	W			= 12						,
	parameter	DATA_WIDTH	= 8					,
	parameter	K           = 6,
	parameter  F           = 3
) (
	input									clk				,
	input	[DATA_WIDTH * D * (W+2) - 1:0]	    image0			,
	input	[DATA_WIDTH * D * (W+2) - 1:0]	    image1			,
	input	[DATA_WIDTH * D * (W+2) - 1:0]	    image2			,
	input                                   image_start     ,
	input									rstn_i			,
	output	[DATA_WIDTH * W * K - 1:0]      output_add_o,
	output                                  output_add_done_o
);

wire        [DATA_WIDTH * D * W * K - 1:0]      result_w;
wire                                            done_w;
wire        [D*K*F*F*DATA_WIDTH-1:0]            kernel;
wire        [K*DATA_WIDTH-1:0]                  bias;


/*
integer i, j;
always @ (kernel or rstn_i) begin
        kernels[DATA_WIDTH*54-1:DATA_WIDTH*53] <= kernel[0];
        kernels[DATA_WIDTH*53-1:DATA_WIDTH*52] <= kernel[1];
        kernels[DATA_WIDTH*52-1:DATA_WIDTH*51] <= kernel[2];
        kernels[DATA_WIDTH*51-1:DATA_WIDTH*50] <= kernel[3];
        kernels[DATA_WIDTH*50-1:DATA_WIDTH*49] <= kernel[4];
        kernels[DATA_WIDTH*49-1:DATA_WIDTH*48] <= kernel[5];
        kernels[DATA_WIDTH*48-1:DATA_WIDTH*47] <= kernel[6];
        kernels[DATA_WIDTH*47-1:DATA_WIDTH*46] <= kernel[7];
        kernels[DATA_WIDTH*46-1:DATA_WIDTH*45] <= kernel[8];
        kernels[DATA_WIDTH*45-1:DATA_WIDTH*44] <= kernel[9];
        kernels[DATA_WIDTH*44-1:DATA_WIDTH*43] <= kernel[10];
        kernels[DATA_WIDTH*43-1:DATA_WIDTH*42] <= kernel[11];
        kernels[DATA_WIDTH*42-1:DATA_WIDTH*41] <= kernel[12];
        kernels[DATA_WIDTH*41-1:DATA_WIDTH*40] <= kernel[13];
        kernels[DATA_WIDTH*40-1:DATA_WIDTH*39] <= kernel[14];
        kernels[DATA_WIDTH*39-1:DATA_WIDTH*38] <= kernel[15];
        kernels[DATA_WIDTH*38-1:DATA_WIDTH*37] <= kernel[16];
        kernels[DATA_WIDTH*37-1:DATA_WIDTH*36] <= kernel[17];
        kernels[DATA_WIDTH*36-1:DATA_WIDTH*35] <= kernel[18];
        kernels[DATA_WIDTH*35-1:DATA_WIDTH*34] <= kernel[19];
        kernels[DATA_WIDTH*34-1:DATA_WIDTH*33] <= kernel[20];
        kernels[DATA_WIDTH*33-1:DATA_WIDTH*32] <= kernel[21];
        kernels[DATA_WIDTH*32-1:DATA_WIDTH*31] <= kernel[22];
        kernels[DATA_WIDTH*31-1:DATA_WIDTH*30] <= kernel[23];
        kernels[DATA_WIDTH*30-1:DATA_WIDTH*29] <= kernel[24];
        kernels[DATA_WIDTH*29-1:DATA_WIDTH*28] <= kernel[25];
        kernels[DATA_WIDTH*28-1:DATA_WIDTH*27] <= kernel[26];
        kernels[DATA_WIDTH*27-1:DATA_WIDTH*26] <= kernel[27];
        kernels[DATA_WIDTH*26-1:DATA_WIDTH*25] <= kernel[28];
        kernels[DATA_WIDTH*25-1:DATA_WIDTH*24] <= kernel[29];
        kernels[DATA_WIDTH*24-1:DATA_WIDTH*23] <= kernel[30];
        kernels[DATA_WIDTH*23-1:DATA_WIDTH*22] <= kernel[31];
        kernels[DATA_WIDTH*22-1:DATA_WIDTH*21] <= kernel[32];
        kernels[DATA_WIDTH*21-1:DATA_WIDTH*20] <= kernel[33];
        kernels[DATA_WIDTH*20-1:DATA_WIDTH*19] <= kernel[34];
        kernels[DATA_WIDTH*19-1:DATA_WIDTH*18] <= kernel[35];
        kernels[DATA_WIDTH*18-1:DATA_WIDTH*17] <= kernel[36];
        kernels[DATA_WIDTH*17-1:DATA_WIDTH*16] <= kernel[37];
        kernels[DATA_WIDTH*16-1:DATA_WIDTH*15] <= kernel[38];
        kernels[DATA_WIDTH*15-1:DATA_WIDTH*14] <= kernel[39];
        kernels[DATA_WIDTH*14-1:DATA_WIDTH*13] <= kernel[40];
        kernels[DATA_WIDTH*13-1:DATA_WIDTH*12] <= kernel[41];
        kernels[DATA_WIDTH*12-1:DATA_WIDTH*11] <= kernel[42];
        kernels[DATA_WIDTH*11-1:DATA_WIDTH*10] <= kernel[43];
        kernels[DATA_WIDTH*10-1:DATA_WIDTH*9]  <= kernel[44];
        kernels[DATA_WIDTH*9-1:DATA_WIDTH*8]   <= kernel[45];
        kernels[DATA_WIDTH*8-1:DATA_WIDTH*7]   <= kernel[46];
        kernels[DATA_WIDTH*7-1:DATA_WIDTH*6]   <= kernel[47];
        kernels[DATA_WIDTH*6-1:DATA_WIDTH*5]   <= kernel[48];
        kernels[DATA_WIDTH*5-1:DATA_WIDTH*4]   <= kernel[49];
        kernels[DATA_WIDTH*4-1:DATA_WIDTH*3]   <= kernel[50];
        kernels[DATA_WIDTH*3-1:DATA_WIDTH*2]   <= kernel[51];
        kernels[DATA_WIDTH*2-1:DATA_WIDTH*1]   <= kernel[52];
        kernels[DATA_WIDTH*1-1:DATA_WIDTH*0]   <= kernel[53];
end
*/

/*
reg     image_start;
always@(posedge clk or negedge rstn_i) begin
    if(rstn_i) begin
        image_start <= 1'b1;
    end
    else begin
        if(image_start == 1'b1) begin
            image_start <= 1'b0;
        end
        else if(done_i) begin
            image_start <= 1'b1;
        end
    end
end
*/


  rom #(
    .RAM_WIDTH(D*F*F*K*DATA_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(2),                     // Specify RAM depth (number of entries)
    //.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(KERNELFILE)                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) rom_kernel (
.clk(clk),
.addra('h0),
.en(1'b1),
.dout(kernel)
  );

rom #(
    .RAM_WIDTH(K*DATA_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(1),                     // Specify RAM depth (number of entries)
    //.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(BIASFILE)                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) rom_bias (
.clk(clk),
.addra('h0),
.en(1'b1),
.dout(bias)
  );

genvar i;
generate
    for (i=0;i<D;i=i+1) begin  
    
        convLayerMulti #(
            .DATA_WIDTH (DATA_WIDTH),
            .D (1),
            .H (H),
            .W (W),
            .F (F),
            .K (K)
        ) u_conv(
	       .clk		(	clk		),
	       .reset     (	rstn_i	),
	       .image0     (   image0[DATA_WIDTH*(W+2)*(i+1) - 1:DATA_WIDTH*(W+2)*(i)] ),
	       .image1     (   image1[DATA_WIDTH*(W+2)*(i+1) - 1:DATA_WIDTH*(W+2)*(i)] ),
	       .image2     (   image2[DATA_WIDTH*(W+2)*(i+1) - 1:DATA_WIDTH*(W+2)*(i)] ),
	       .image_start(	image_start		),
	       .filters	    (	kernel[K*F*F*DATA_WIDTH*(i+1)-1:K*F*F*DATA_WIDTH*i]	),
           .outputCONV  (   result_w[DATA_WIDTH*W*K*(i+1)-1:DATA_WIDTH*K*W*i]),
	       .done        (   done_w   )
        );
    end
endgenerate

add_output #(
.D(D),
.H(H),
.F(F),
.K(K),
.DATA_WIDTH(DATA_WIDTH)
) add_output(
.clk(clk),
.rst_n(rstn_i),
.output_convmul_i(result_w),
.done_convmul_i(done_w),
.bias(bias),
.output_add_o(output_add_o),
.done_add_o(output_add_done_o)
);



endmodule
