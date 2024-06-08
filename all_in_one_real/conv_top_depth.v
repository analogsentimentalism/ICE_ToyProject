`timescale 1ns / 1ps
module conv_top #(
	parameter	KERNELFILE	  = "mini_conv1_kernel_0605.txt"		,
	parameter  BIASFILE       = "mini_conv1_bias_0605.txt",
	parameter  D           = 4,
	parameter	H			= 6					,
	parameter	W			= 6						,
	parameter	input_DATA_WIDTH	= 8					,
	parameter  output_DATA_WIDTH   = 32                ,
	parameter	K           = 8,
	parameter  F           = 3,
	parameter	shift = 10
) (
	input									clk				,
	input signed 	[input_DATA_WIDTH * 1 * (W+2) - 1:0]	    image0			,
	input signed 	[input_DATA_WIDTH * 1 * (W+2) - 1:0]	    image1			,
	input signed 	[input_DATA_WIDTH * 1 * (W+2) - 1:0]	    image2			,
	input                                   image_start     ,
	input									rstn_i			,
	output signed 	[input_DATA_WIDTH * W * K - 1:0]      output_add_o,
	output                                  output_add_done_o,
	output                                 done_w
);



wire    signed     [output_DATA_WIDTH * 1 * W * K - 1:0]     result_w; // conv_multi result

wire                                                         add_start_w;
wire         [1*K*F*F*input_DATA_WIDTH-1:0]            kernel;
reg         [K*output_DATA_WIDTH-1:0]                 bias[0:0];
wire        [K*output_DATA_WIDTH-1:0]                 bias_w;
reg                [D* output_DATA_WIDTH * 1 * W * K - 1:0]  result_reg;
reg     [1:0]           depth_calc; // depth_calc is depth of calc (# of input channel)

always @ (posedge clk) begin
    if(rstn_i) begin
        depth_calc <= 'b0;
    end
    else begin
        if(depth_calc < (D-1) && done_w) begin
            depth_calc <= depth_calc + 1'b1;
        end
        else if(depth_calc == (D-1) && done_w) begin
            depth_calc <= 'b0;
        end
    end
end

assign add_start_w = ((depth_calc == (D-1)) && done_w);

  rom #(
    .RAM_WIDTH(F*F*K*input_DATA_WIDTH),                       // Specify RAM data width
    .RAM_DEPTH(D),                     // Specify RAM depth (number of entries)
    //.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(KERNELFILE)                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) rom_kernel (
.clk(clk),
.addra(depth_calc),
.en(1'b1),
.dout(kernel)
  );
  
initial begin
    $readmemh(BIASFILE, bias);
end
assign bias_w = bias[0];

/*rom #(
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
*/
/*genvar i;
generate
    for (i=0;i<D;i=i+1) begin  
*///for multi-depth conv - removed for LUT    
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
	       .image0     (   image0[input_DATA_WIDTH*(W+2) - 1:input_DATA_WIDTH*(W+2)*(0)] ),
	       .image1     (   image1[input_DATA_WIDTH*(W+2) - 1:input_DATA_WIDTH*(W+2)*(0)] ),
	       .image2     (   image2[input_DATA_WIDTH*(W+2) - 1:input_DATA_WIDTH*(W+2)*(0)] ),
	       .image_start(	image_start		),
	       .filters	    (	kernel[K*F*F*input_DATA_WIDTH*(1)-1:K*F*F*input_DATA_WIDTH*0]	),
           .outputCONV  (   result_w[output_DATA_WIDTH*W*K*(1)-1:output_DATA_WIDTH*K*W*0]),
	       .done        (   done_w   )
        );

//end
//endgenerate //removed for mutli-depth conv

//assign  bias = 64'h9C8D158DA39F0199;

always @ (posedge clk) begin
    if(rstn_i) begin
        result_reg = 'h0;
    end

    else if(done_w) begin
    if(D==1) begin
                result_reg[output_DATA_WIDTH * (1) * W * K - 1:output_DATA_WIDTH * (0) * W * K ] = result_w;
    end
    else if(D==2) begin
           if(depth_calc=='b0) begin
                result_reg[output_DATA_WIDTH * (1) * W * K - 1:output_DATA_WIDTH * (0) * W * K ] = result_w;
           end else if(depth_calc=='b1)begin
                result_reg[output_DATA_WIDTH * (2) * W * K - 1:output_DATA_WIDTH * (1) * W * K ] = result_w;
           end 
    end
    else if(D==4) begin
           if(depth_calc=='b0) begin
                result_reg[output_DATA_WIDTH * (1) * W * K - 1:output_DATA_WIDTH * (0) * W * K ] = result_w;
           end else if(depth_calc=='b1)begin
                result_reg[output_DATA_WIDTH * (2) * W * K - 1:output_DATA_WIDTH * (1) * W * K ] = result_w;
           end else if(depth_calc=='b10)begin
                result_reg[output_DATA_WIDTH * (3) * W * K - 1:output_DATA_WIDTH * (2) * W * K ] = result_w;
           end else if(depth_calc=='b11)begin
                result_reg[output_DATA_WIDTH * (4) * W * K - 1:output_DATA_WIDTH * (3) * W * K ] = result_w;
           end 
    end
    end
end

add_output #(
.D(D),
.H(H),
.F(F),
.K(K),
.input_DATA_WIDTH(32),
.output_DATA_WIDTH(8),
.shift(shift)	
) add_output(
.clk(clk),
.rst_n(rstn_i),
.output_convmul_i(result_reg),
.done_convmul_i(add_start_w),
.bias(bias_w),
.output_add_o(output_add_o),
.done_add_o(output_add_done_o)
);




endmodule
