module cnn_top #(

) (
	input	clk,
	input   resetn,
	input 	[1*24*8-1:0] input_data,
	input buffer_1_valid_i;
);

`define		H			24
`define		W			24
`define 	DATA_WIDTH	8

reg			u_fifo_0_resetn	;
reg			u_fifo_0_ren	;
reg			u_fifo_0_wen	;
reg			u_fifo_0_wdata	;

wire		u_fifo_0_rdata	;
wire		u_fifo_0_empty	;


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

wire [7:0] dense_out;
wire dense_valid;

line_3_buffer #(
	.D	(	1 	),
	.H  ( 	24	),
	.W	(	24	),
	.DATA_BITS	(8),
	.K  (	1	)
) u_line_3_buffer_1 (
	.clk	(clk),
	.resetn	(resetn),
	.input_data(u_fifo_0_rdata),
	.output_1(u_conv_1_image0),
	.output_2(u_conv_1_image1),
	.output_3(u_conv_1_image2),
	.valid_i(buffer_1_valid_i),
	.valid_o(u_conv_1_image_start),
	.behind_conv_done(u_conv_1_done)
);
conv_top #(
	.D 	( 	1	)
	.H	(	26	),
	.W	(	26	),
	.F	(	3	),
	.K	(	4	),
	.DATA_BITS(8)
) u_conv2d_1 (
	.clk			(	clk						),
	.rstn_i			(	resetn					),
	.image0			(	u_conv_1_image0			),
	.image1			(	u_conv_1_image1			),
	.image2			(	u_conv_1_image2			),
	.image_start	(	u_conv_1_image_start	),
	.result_o		(	u_conv_1_outputCONV		),
	.done			(	u_conv_1_done			)
);
relu #(
	.H	(	24	),
	.W	(	24	),
	.D	(	4	)
) u_relu_1 (
	.input_data		(u_conv_1_outputCONV),
	.output_data	(u_relu_1_outputRELU)
);


max_pooling_mult #(
	.D	(	4	),
	.H	(	24	),
	.W	(	24	)
) u_max_pooling2d_1 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_1_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_1_output), 
	.valid_i			(	u_conv_1_done	), 
	.valid_o			(	u_max_pooling2d_1_valid_o)
);
line_3_buffer #(
	.D	(	1 	),
	.H  ( 	12	),
	.W	(	12	),
	.DATA_BITS	(8),
	.K  (	4	)
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
	.D 	( 	4	)
	.H	(	14	),
	.W	(	14	),
	.F	(	3	),
	.K	(	8	),
	.DATA_BITS(8)

) u_conv2d_2 (
	.clk			(	clk						),
	.rstn_i			(	resetn					),
	.image0			(u_conv_2_image0),
	.image0			(u_conv_2_image1),
	.image0			(u_conv_2_image2),
	.image_start	(	u_conv_2_image_start),
	.result_o		(	u_conv_2_outputCONV		),
	.done			(	u_conv_2_done			)
	
);
relu #(
	.H	(	12	),
	.W	(	12	),
	.D	(	8	)
) u_relu_2 (
	.input_data		(u_conv_2_outputCONV),
	.output_data	(u_relu_2_outputRELU)
);

max_pooling_mult #(
	.D	(	8	),
	.H	(	12	),
	.W	(	12	)
) u_max_pooling2d_2 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_2_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_2_output), 
	.valid_i			(	u_conv_2_done), 
	.valid_o			(	u_max_pooling2d_2_valid_o)
);

line_3_buffer #(
	.D	(	1 	),
	.H  ( 	6	),
	.W	(	6	),
	.DATA_BITS	(8),
	.K  (	8	)
) u_line_3_buffer_2 (
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
	.D 	( 	8	)
	.H	(	8	),
	.W	(	8	),
	.F	(	3	),
	.K	(	12	),
	.DATA_BITS(8)


) u_conv2d_3 (
	.clk			(	clk						),
	.rstn_i			(	resetn					),
	.image0			(	u_conv_3_image0),
	.image1			(	u_conv_3_image1),
	.image2			(	u_conv_3_image2),
	.image_start	(	u_conv_3_image_start	),
	.result_o		(	u_conv_3_outputCONV		),
	.done			(	u_conv_3_done			)
);
relu #(
	.H	(	6	),
	.W	(	6	),
	.D	(	12	)
) u_relu_3 (
	.input_data		(u_conv_3_outputCONV),
	.output_data	(u_relu_3_outputRELU)
);
max_pooling_mult #(
	.D	(	12	),
	.H	(	6	),
	.W	(	6	)
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
	.data_o(dense_out)
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