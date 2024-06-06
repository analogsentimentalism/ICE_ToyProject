module dense_top #(
	parameter	DATA_WIDTH	= 8,
	parameter	NUMI_ONCE = 3*8
) (
	input									clk,
	input									rstn,
	input	[DATA_WIDTH*NUMI_ONCE-1:0	]	data_i,
	input									valid_i,
	output	[DATA_WIDTH*7-1:0			]	data_o,
	output									valid_o
);

wire	[DATA_WIDTH-1:0				]	data_w;
wire									valid_w;

dense_int_front #(
	.BIASFILE	(	"mini_dense0_bias.txt"		),
	.KERNELFILE	(	"mini_dense0_kernel.txt"	),
	.H			(	3							),
	.W			(	3							),
	.D			(	8							),
	.B			(	64							),
	.DATA_WIDTH	(	DATA_WIDTH					)
) dense_front (
	.clk		(	clk							),
	.rstn		(	rstn						),
	.valid_i	(	valid_i						),
	.data_i		(	data_i						),
	.data_o		(	data_w						),
	.valid_o	(	valid_w						)
);

dense_int_rear #(
	.BIASFILE	(	"mini_dense1_bias.txt"		),
	.KERNELFILE	(	"mini_dense1_kernel.txt"	),
	.D			(	64 							),
	.B			(	7							),
	.DATA_WIDTH	(	DATA_WIDTH					)
) dense_rear (
	.clk		(	clk							),
	.rstn		(	rstn						),
	.valid_i	(	valid_w						),
	.data_i		(	data_w						),
	.data_o		(	data_o						),
	.valid_o	(	valid_o						)
);

endmodule