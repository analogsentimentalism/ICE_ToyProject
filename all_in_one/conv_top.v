`timescale 1ns / 1ps
module conv_top #(
	parameter	KERNELFILE	  = "mini_conv1_kernel_int.txt"		,
	parameter  BIASFILE       = "mini_conv1_bias_int.txt",
	parameter  D           = 4,
	parameter	H			= 12					,
	parameter	W			= 12						,
	parameter	input_DATA_WIDTH	= 8					,
	parameter  output_DATA_WIDTH   = 32                ,
	parameter	K           = 4,
	parameter  F           = 3
) (
	input									clk				,
	input signed 	[input_DATA_WIDTH * D * (W+2) - 1:0]	    image0			,
	input signed 	[input_DATA_WIDTH * D * (W+2) - 1:0]	    image1			,
	input signed 	[input_DATA_WIDTH * D * (W+2) - 1:0]	    image2			,
	input                                   image_start     ,
	input									rstn_i			,
	output signed 	[input_DATA_WIDTH * W * K - 1:0]      output_add_o,
	output                                  output_add_done_o
);

wire    signed     [output_DATA_WIDTH * D * W * K - 1:0]      result_w;
wire                                            done_w[D-1:0];
wire    signed     [D*K*F*F*input_DATA_WIDTH-1:0]            kernel;
wire    signed     [K*output_DATA_WIDTH-1:0]                  bias;


  rom #(
    .RAM_WIDTH(D*F*F*K*input_DATA_WIDTH),                       // Specify RAM data width
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
    .RAM_WIDTH(K*output_DATA_WIDTH),                       // Specify RAM data width
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
            .input_DATA_WIDTH (input_DATA_WIDTH),
            .output_DATA_WIDTH (output_DATA_WIDTH),
            .D (D),
            .H (H),
            .W (W),
            .F (F),
            .K (K)
        ) u_conv(
	       .clk		(	clk		),
	       .reset     (	rstn_i	),
	       .image0     (   image0[input_DATA_WIDTH*(W+2)*(i+1) - 1:input_DATA_WIDTH*(W+2)*(i)] ),
	       .image1     (   image1[input_DATA_WIDTH*(W+2)*(i+1) - 1:input_DATA_WIDTH*(W+2)*(i)] ),
	       .image2     (   image2[input_DATA_WIDTH*(W+2)*(i+1) - 1:input_DATA_WIDTH*(W+2)*(i)] ),
	       .image_start(	image_start		),
	       .filters	    (	kernel[K*F*F*input_DATA_WIDTH*(i+1)-1:K*F*F*input_DATA_WIDTH*i]	),
           .outputCONV  (   result_w[output_DATA_WIDTH*W*K*(i+1)-1:output_DATA_WIDTH*K*W*i]),
	       .done        (   done_w[i]   )
        );
    end
endgenerate

//assign  bias = 64'h9C8D158DA39F0199;

add_output #(
.D(D),
.H(H),
.F(F),
.K(K),
.input_DATA_WIDTH(output_DATA_WIDTH),
.output_DATA_WIDTH(input_DATA_WIDTH)
) add_output(
.clk(clk),
.rst_n(rstn_i),
.output_convmul_i(result_w),
.done_convmul_i(done_w[0]),
.bias(bias),
.output_add_o(output_add_o),
.done_add_o(output_add_done_o)
);



endmodule
