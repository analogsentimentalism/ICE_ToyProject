`timescale 1ns / 1ps
module conv_top #(
	parameter	KERNELFILE	  = "mini_conv1_kernel.txt"		,
	parameter  BIASFILE       = "mini_conv1_bias.txt",
	parameter  D           = 4,
	parameter	H			= 12					,
	parameter	W			= 12						,
	parameter	DATA_WIDTH	= 8					,
	parameter	K           = 4,
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


  rom #(
    .RAM_WIDTH(D*F*F*K*DATA_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(1),                     // Specify RAM depth (number of entries)
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

//assign  bias = 64'h9C8D158DA39F0199;

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
