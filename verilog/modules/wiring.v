wire [1*24*8-1 :0] u_fifo_0_rdata;
wire [1*(24+2)*8-1 :0] u_conv_1_image0;
wire [1*(24+2)*8-1 :0] u_conv_1_image1;
wire [1*(24+2)*8-1 :0] u_conv_1_image2;
wire buffer_1_valid_i;
wire u_conv_1_image_start;
wire u_conv_1_done;

wire [1*24*4*8-1:0] u_conv_1_outputCONV;
wire [1*24*4*8-1:0] u_relu_1_outputRELU;

wire [1*12*4*8-1:0] u_max_pooling2d_1_output;
wire u_max_pooling2d_1_valid_o;

wire [1*(12+2)*4*8-1:0] u_conv_2_image0;
wire [1*(12+2)*4*8-1:0] u_conv_2_image1;
wire [1*(12+2)*4*8-1:0] u_conv_2_image2;
wire u_conv_2_image_start;
wire u_conv_2_done;

wire [1*12*8*8-1:0] u_conv_2_outputCONV;
wire [1*12*8*8-1:0] u_relu_2_outputRELU;

wire [1*6*8*8-1:0] u_max_pooling2d_2_output;
wire u_max_pooling2d_2_valid_o;

wire [1*(6+2)*8*8-1:0] u_conv_3_image0;
wire [1*(6+2)*8*8-1:0] u_conv_3_image1;
wire [1*(6+2)*8*8-1:0] u_conv_3_image2;
wire u_conv_3_image_start;
wire u_conv_3_done;

wire [1*6*12*8-1:0] u_conv_3_outputCONV;
wire [1*6*12*8-1:0] u_relu_3_outputRELU;

wire [1*3*12*8-1:0] u_max_pooling2d_3_output;
wire u_max_pooling2d_3_valid_o;
