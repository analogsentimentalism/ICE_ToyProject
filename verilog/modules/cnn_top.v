module cnn_top #(

) (
	input	clk,
	input   resetn
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


wire [8*24*1-1:0]u_conv_1_image;
wire u_conv_1_image_start;
wire [8*24-1:0]u_conv_1_outputCONV;

wire [8*24-1:0]u_relu_1_outputRELU;
wire [8*12-1:0]u_max_pooling2d_1_output;
wire u_conv_1_done;
wire u_max_pooling2d_1_valid_o;

wire u_conv_2_outputCONV;
wire u_relu_2_outputRELU;

wire u_max_pooling2d_2_output;
wire u_conv_2_done;
wire u_max_pooling2d_2_valid_o;

wire u_conv_3_outputCONV;

wire u_relu_3_outputRELU;
wire u_max_pooling2d_3_output;
wire u_conv_3_done;
wire u_max_pooling2d_3_valid_o;

wire u_dense_0_valid_o;
wire u_dense_0_output;

wire u_relu_4_outputRELU;

wire u_dense_1_valid_o;
wire u_dense_1_output;


fifo #() u_fifo_0 (
.i_clk		(	clk				),
.i_resetn	(	u_fifo_0_resetn	),
.i_ren		(	u_fifo_0_ren	),
.i_wen		(	u_fifo_0_wen	),
.i_wdata	(	u_fifo_0_wdata	),

.o_rdata	(	u_fifo_0_rdata	),
.o_empty	(	u_fifo_0_empty	)
    o_full
);
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
	.H	(	24	),
	.W	(	24	),
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
	.H	(	12	),
	.W	(	12	),
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
	.H	(	6	),
	.W	(	6	),
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


dense_top #(
	.H			(	`H/4-2				),
	.W			(	`W/4-2				),
	.DEPTH		(	64					),
	.BIAS		(	128					),
	.BIASFILE	(	"dense0_bias.txt"	),
	.KERNELFILE	(	"dense0_kernel.txt"	)
) u_dense_0 (
	.clk		(	clk					),
	.rstn 		(	resetn				),
	.valid_i 	(	u_max_pooling2d_3_valid_o),
	.valid_o	(	u_dense_0_valid_o	),
	.data_i	(	u_max_pooling2d_3_output),
	.data_o		(	u_dense_0_output	)
);

relu #(
	.H	(	`H	),
	.W	(	`W	),
	.D	(	6	)
) u_relu_4 (
	.input_data		(u_dense_0_output),
	.output_data	(u_relu_4_outputRELU)
);

dense_top #(
	.H			(	`H/4-2				),
	.W			(	`W/4-2				),
	.DEPTH		(	1					),
	.BIAS		(	7					)
	.BIASFILE	(	"dense1_bias.txt"	),
	.KERNELFILE	(	"dense1_kernel.txt"	)
) u_dense_1 (
	.clk		(	clk					),
	.rstn 		(	resetn				),
	.valid_i 	(	u_dense_0_valid_o),
	.valid_o	(	u_dense_1_valid_o	),
	.data_i		(	u_relu_4_outputRELU),
	.data_o		(	u_dense_1_output	)
);


endmodule