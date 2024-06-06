module cnn_top #(

) (
	input	clk,
	input   resetn,
	input 	[1*24*8-1:0] input_data,
	input buffer_1_valid_i,
	output [8*7-1:0] dense_out,
	output dense_valid
);

`define		H			24
`define		W			24
`define 	DATA_WIDTH	8



wire [1*24*8-1 :0] u_fifo_0_rdata;
wire [1*(24+2)*8-1 :0] u_conv_1_image0;
wire [1*(24+2)*8-1 :0] u_conv_1_image1;
wire [1*(24+2)*8-1 :0] u_conv_1_image2;
wire buffer_1_valid_i;
wire u_conv_1_image_start;
wire u_conv_1_done;

wire [1*24*2*8-1:0] u_conv_1_outputCONV;
wire [1*24*2*8-1:0] u_relu_1_outputRELU;

wire [1*12*2*8-1:0] u_max_pooling2d_1_output;
wire u_max_pooling2d_1_valid_o;

wire [1*(12+2)*2*8-1:0] u_conv_2_image0;
wire [1*(12+2)*2*8-1:0] u_conv_2_image1;
wire [1*(12+2)*2*8-1:0] u_conv_2_image2;
wire u_conv_2_image_start;
wire u_conv_2_done;

wire [1*12*4*8-1:0] u_conv_2_outputCONV;
wire [1*12*4*8-1:0] u_relu_2_outputRELU;

wire [1*6*4*8-1:0] u_max_pooling2d_2_output;
wire u_max_pooling2d_2_valid_o;

wire [1*(6+2)*4*8-1:0] u_conv_3_image0;
wire [1*(6+2)*4*8-1:0] u_conv_3_image1;
wire [1*(6+2)*4*8-1:0] u_conv_3_image2;
wire u_conv_3_image_start;
wire u_conv_3_done;

wire [1*6*8*8-1:0] u_conv_3_outputCONV;
wire [1*6*8*8-1:0] u_relu_3_outputRELU;

wire [1*3*8*8-1:0] u_max_pooling2d_3_output;
wire u_max_pooling2d_3_valid_o;

line_3_buffer #(
	.D	(	1 	),
	.H  ( 	24	),
	.W	(	24	),
	.DATA_BITS	(8),
	.K  (	1	)

) u_line_3_buffer_1 (
	.clk	(clk),
	.resetn	(resetn),
	.input_data(input_data),
	.output_1(u_conv_1_image0),
	.output_2(u_conv_1_image1),
	.output_3(u_conv_1_image2),
	.valid_i(buffer_1_valid_i),
	.valid_o(u_conv_1_image_start),
	.behind_conv_done(u_conv_1_done)
);
conv_top #(
	.D 	( 	1	),
	.H	(	24	),
	.W	(	24	),
	.F	(	3	),
	.K	(	2	),
	.DATA_WIDTH(8),
	.KERNELFILE ("mini_conv0_kernel.txt"),
	.BIASFILE  ("mini_conv0_bias.txt")
) u_conv2d_1 (
	.clk			(	clk						),
	.rstn_i			(	~resetn					),
	.image0			(	u_conv_1_image0			),
	.image1			(	u_conv_1_image1			),
	.image2			(	u_conv_1_image2			),
	.image_start	(	u_conv_1_image_start	),
	.output_add_o		(	u_conv_1_outputCONV		),
	.output_add_done_o			(	u_conv_1_done			)
);
relu #(
	.H	(	24	),
	.W	(	24	),
	.D	(	2	)
) u_relu_1 (
	.input_data		(u_conv_1_outputCONV),
	.output_data	(u_relu_1_outputRELU)
);


max_pooling_mult #(
	.D	(	2	),
	.H	(	24	),
	.W	(	24	),
	.DATA_BITS(8)
) u_max_pooling2d_1 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_1_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_1_output), 
	.valid_i			(	u_conv_1_done	), 
	.valid_o			(	u_max_pooling2d_1_valid_o)
);
line_3_buffer #(
	.D	(	2 	),
	.H  ( 	12	),
	.W	(	12	),
	.DATA_BITS	(8),
	.K  (	2	)
) u_line_3_buffer_2 (
	.clk	(clk),
	.resetn	(resetn),
	.input_data(u_max_pooling2d_1_output),
	.output_1(u_conv_2_image0),
	.output_2(u_conv_2_image1),
	.output_3(u_conv_2_image2),
	.valid_i(u_max_pooling2d_1_valid_o),
	.valid_o(u_conv_2_image_start),
	.behind_conv_done(u_conv_2_done)
);
conv_top #(
	.D 	( 	2	),
	.H	(	12	),
	.W	(	12	),
	.F	(	3	),
	.K	(	4	),
	.DATA_WIDTH(8),
	.KERNELFILE ("mini_conv1_kernel.txt"),
	.BIASFILE  ("mini_conv1_bias.txt")

) u_conv2d_2 (
	.clk			(	clk						),
	.rstn_i			(	~resetn					),
	.image0			(u_conv_2_image0),
	.image1			(u_conv_2_image1),
	.image2			(u_conv_2_image2),
	.image_start	(	u_conv_2_image_start),
	.output_add_o		(	u_conv_2_outputCONV		),
	.output_add_done_o			(	u_conv_2_done			)
	
);
relu #(
	.H	(	12	),
	.W	(	12	),
	.D	(	4	)
) u_relu_2 (
	.input_data		(u_conv_2_outputCONV),
	.output_data	(u_relu_2_outputRELU)
);

max_pooling_mult #(
	.D	(	4	),
	.H	(	12	),
	.W	(	12	),
	.DATABITS(8)
) u_max_pooling2d_2 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_2_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_2_output), 
	.valid_i			(	u_conv_2_done), 
	.valid_o			(	u_max_pooling2d_2_valid_o)
);

line_3_buffer #(
	.D	(	4 	),
	.H  ( 	6	),
	.W	(	6	),
	.DATA_BITS	(8),
	.K  (	4	)
) u_line_3_buffer_3 (
	.clk	(clk),
	.resetn	(resetn),
	.input_data(u_max_pooling2d_2_output),
	.output_1(u_conv_3_image0),
	.output_2(u_conv_3_image1),
	.output_3(u_conv_3_image2),
	.valid_i(u_max_pooling2d_2_valid_o),
	.valid_o(u_conv_3_image_start),
	.behind_conv_done(u_conv_3_done)
);
conv_top #(
	.D 	( 	4	),
	.H	(	6	),
	.W	(	6	),
	.F	(	3	),
	.K	(	8	),
	.DATA_WIDTH(8),
				.KERNELFILE ("mini_conv2_kernel.txt"),
	.BIASFILE  ("mini_conv2_bias.txt")


) u_conv2d_3 (
	.clk			(	clk						),
	.rstn_i			(	~resetn					),
	.image0			(	u_conv_3_image0),
	.image1			(	u_conv_3_image1),
	.image2			(	u_conv_3_image2),
	.image_start	(	u_conv_3_image_start	),
	.output_add_o		(	u_conv_3_outputCONV		),
	.output_add_done_o			(	u_conv_3_done			)
);
relu #(
	.H	(	6	),
	.W	(	6	),
	.D	(	8	)
) u_relu_3 (
	.input_data		(u_conv_3_outputCONV),
	.output_data	(u_relu_3_outputRELU)
);
max_pooling_mult #(
	.D	(	8	),
	.H	(	6	),
	.W	(	6	),
	.DATA_BITS(8)
) u_max_pooling2d_3 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_3_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_3_output), 
	.valid_i			(	u_conv_3_done), 
	.valid_o			(	u_max_pooling2d_3_valid_o)
);

dense_top u_dense_top(
	.clk(clk),
	.rstn(resetn),
	.valid_i(u_max_pooling2d_3_valid_o),
	.data_i(u_max_pooling2d_3_output),
	.data_o(dense_out),
	.valid_o(dense_valid)
);

//dense_top #(
//	.H			(	`H/4-2				),
//	.W			(	`W/4-2				),
//	.DEPTH		(	64					),
//	.BIAS		(	128					),
//	.BIASFILE	(	"dense0_bias.txt"	),
//	.KERNELFILE	(	"dense0_kernel.txt"	)
//) u_dense_0 (
//	.clk		(	clk					),
//	.rstn 		(	resetn				),
//	.valid_i 	(	u_max_pooling2d_3_valid_o),
//	.valid_o	(	u_dense_0_valid_o	),
//	.data_i	(	u_max_pooling2d_3_output),
//	.data_o		(	u_dense_0_output	)
//);
//
//relu #(
//	.H	(	`H	),
//	.W	(	`W	),
//	.D	(	6	)
//) u_relu_4 (
//	.input_data		(u_dense_0_output),
//	.output_data	(u_relu_4_outputRELU)
//);
//
//dense_top #(
//	.H			(	`H/4-2				),
//	.W			(	`W/4-2				),
//	.DEPTH		(	1					),
//	.BIAS		(	7					)
//	.BIASFILE	(	"dense1_bias.txt"	),
//	.KERNELFILE	(	"dense1_kernel.txt"	)
//) u_dense_1 (
//	.clk		(	clk					),
//	.rstn 		(	resetn				),
//	.valid_i 	(	u_dense_0_valid_o),
//	.valid_o	(	u_dense_1_valid_o	),
//	.data_i		(	u_relu_4_outputRELU),
//	.data_o		(	u_dense_1_output	)
//);


endmodule