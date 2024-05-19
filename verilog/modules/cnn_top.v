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

convLayerMulti #(
	.H	(	`H	),
	.W	(	`W	),
	.F	(	5	),
	.K	(	6	)
) u_conv2d_1 (
	.clk			(	clk						),
	.reset			(	resetn					),
	.image0			(	u_conv_1_image0			),
	.image1			(	u_conv_1_image1			),
	.image2			(	u_conv_1_image2			),
	.image_start	(	u_conv_1_image_start	),
	.filters		(	u_conv_1_filters		),
	.outputCONV		(	u_conv_1_outputCONV		),
	.done			(	u_conv_1_done			)
);
relu #(
	.H	(	`H	),
	.W	(	`W	),
	.D	(	6	)
) u_relu_1 (
	.input_data		(u_conv_1_outputCONV),
	.output_data	(u_relu_1_outputRELU)
);


max_pooling_mult #(
	.D	(	6	),
	.H	(	`H	),
	.W	(	`W	)
) u_max_pooling2d_1 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_1_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_1_output), 
	.valid_i			(	u_conv_1_done	), 
	.valid_o			(	u_max_pooling2d_1_valid_o)
);
convLayerMulti #(
	.H	(	`H	),
	.W	(	`W	),
	.F	(	5	),
	.K	(	6	)
) u_conv2d_2 (
	.clk			(	clk						),
	.reset			(	resetn					),
	.image0			(	u_conv_2_image0			),
	.image1			(	u_conv_2_image1			),
	.image2			(	u_conv_2_image2			),
	.image_start	(	u_conv_2_image_start	),
	.filters		(	u_conv_2_filters		),
	.outputCONV		(	u_conv_2_outputCONV		),
	.done			(	u_conv_2_done			)
);
relu #(
	.H	(	`H	),
	.W	(	`W	),
	.D	(	6	)
) u_relu_2 (
	.input_data		(u_conv_2_outputCONV),
	.output_data	(u_relu_2_outputRELU)
);

max_pooling_mult #(
	.D	(	6	),
	.H	(	`H	),
	.W	(	`W	)
) u_max_pooling2d_2 (
	.clk				(	clk				), 
	.reset				(	resetn			), 
	.multi_input_data	(	u_relu_2_outputRELU), 
	.multi_output_data	(	u_max_pooling2d_2_output), 
	.valid_i			(	u_conv_2_done), 
	.valid_o			(	u_max_pooling2d_2_valid_o)
);
convLayerMulti #(
	.H	(	`H	),
	.W	(	`W	),
	.F	(	5	),
	.K	(	6	)
) u_conv2d_3 (
	.clk			(	clk						),
	.reset			(	resetn					),
	.image0			(	u_conv_3_image0			),
	.image1			(	u_conv_3_image1			),
	.image2			(	u_conv_3_image2			),
	.image_start	(	u_conv_3_image_start	),
	.filters		(	u_conv_3_filters		),
	.outputCONV		(	u_conv_3_outputCONV		),
	.done			(	u_conv_3_done			)
);
relu #(
	.H	(	`H	),
	.W	(	`W	),
	.D	(	6	)
) u_relu_3 (
	.input_data		(u_conv_3_outputCONV),
	.output_data	(u_relu_3_outputRELU)
);
max_pooling_mult #(
	.D	(	6	),
	.H	(	`H	),
	.W	(	`W	)
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