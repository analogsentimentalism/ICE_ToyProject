module cnn_top #(

) (
	input	clk
);

`define		H			48
`define		W			48
`define 	DATA_WIDTH	32

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
) u_conv_0 (
	.clk			(	clk						),
	.reset			(	u_conv_0_reset			),
	.image0			(	u_conv_0_image0			),
	.image1			(	u_conv_0_image1			),
	.image2			(	u_conv_0_image2			),
	.image_start	(	u_conv_0_image_start	),
	.filters		(	u_conv_0_filters		),
	.outputCONV		(	u_conv_0_outputCONV		),
	.done			(	u_conv_0_done			)
);

relu #(
	.H	(	`H	),
	.W	(	`W	),
	.D	(	6	)
) u_relu_0 (
	.input_data		(),
	.output_data	()
);

max_pooling_mult #(
	.D	(	6	),
	.H	(	`H	),
	.W	(	`W	)
) u_max_0 (
	.clk				(	clk				), 
	.reset				(	u_max_0_reset	), 
	.multi_input_data	(	), 
	.multi_output_data	(), 
	.valid_i			(	), 
	.valid_o			()
);

convLayerMulti #(
	.H	(	`H/2	),
	.W	(	`W/2	),
	.F	(	5		),
	.K	(	16		)
) u_conv_1 (
	.clk			(	clk						),
	.reset			(	u_conv_1_reset			),
	.image0			(	u_conv_1_image0			),
	.image1			(	u_conv_1_image1			),
	.image2			(	u_conv_1_image2			),
	.image_start	(	u_conv_1_image_start	),
	.filters		(	u_conv_1_filters		),
	.outputCONV		(	u_conv_1_outputCONV		),
	.done			(	u_conv_1_done			)
);

relu #(
	.H	(	`H/2	),
	.W	(	`W/2	),
	.D	(	16		)
) u_relu_1 (
	.input_data		(),
	.output_data	()
);

relu #(
	.H	(	`H/2	),					// 우리 파이썬 코드에 있어서 일단 넣음.
	.W	(	`W/2	),					// 한번 더 relu해서 바뀔거 없어 보이긴함.
	.D	(	16		)
) u_relu_2 (
	.input_data		(),
	.output_data	()
);

max_pooling_mult #(
	.D	(	16		),
	.H	(	`H/2	),
	.W	(	`W/2	)
) u_max_1 (
	.clk				(	clk				), 
	.reset				(	u_max_1_reset	), 
	.multi_input_data	(	), 
	.multi_output_data	(), 
	.valid_i			(	), 
	.valid_o			()
);

convLayerMulti #(
	.H	(	`H/4	),
	.W	(	`W/4	),
	.F	(	3		),
	.K	(	64		)
) u_conv_2 (
	.clk			(	clk						),
	.reset			(	u_conv_2_reset			),
	.image0			(	u_conv_2_image0			),
	.image1			(	u_conv_2_image1			),
	.image2			(	u_conv_2_image2			),
	.image_start	(	u_conv_2_image_start	),
	.filters		(	u_conv_2_filters		),
	.outputCONV		(	u_conv_2_outputCONV		),
	.done			(	u_conv_2_done			)
);

relu #(
	.H	(	`H/4	),
	.W	(	`W/4	),
	.D	(	64		)
) u_relu_3 (
	.input_data		(),
	.output_data	()
);

max_pooling_mult #(
	.D	(	64		),
	.H	(	`H/4	),
	.W	(	`W/4	)
) u_max_2 (
	.clk				(	clk				), 
	.reset				(	u_max_2_reset	), 
	.multi_input_data	(	), 
	.multi_output_data	(), 
	.valid_i			(	), 
	.valid_o			()
);

dense_top #(
	.H			(	`H/4-2				),
	.W			(	`W/4-2				),
	.DEPTH		(	64					),
	.BIAS		(	128					)
	.BIASFILE	(	"dense0_bias.txt"	),
	.KERNELFILE	(	"dense0_kernel.txt"	)
) u_dense_0 (

);

relu #(
	.H	(	1		),
	.W	(	128		),
	.D	(	1		)
) u_relu_4 (
	.input_data		(),
	.output_data	()
);

dense_top #(
	.H			(	`H/4-2				),
	.W			(	`W/4-2				),
	.DEPTH		(	1					),
	.BIAS		(	7					)
	.BIASFILE	(	"dense1_bias.txt"	),
	.KERNELFILE	(	"dense1_kernel.txt"	)
) u_dense_1 (

);

softmax #(
	
) u_softmax_0 (
	.inputs		(),
	.clk		(	clk	),
	.enable		(),
	.outputs	(),
	.valid_o	()
);


endmodule