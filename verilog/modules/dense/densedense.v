module densedense #(
	parameter	DATA_WIDTH	= 8,
	parameter	NUMI_ONCE = 2*64
) (
	input								clk,
	input								rstn,
	input	[DATA_WIDTH*NUMI_ONCE-1:0]	data_i,
	input								valid_i,
	output	[DATA_WIDTH-1:0]			data_o,
	output								valid_o
);

wire	[DATA_WIDTH-1:0]	data_w;
wire						valid_w;

dense_opt #(
	.BIASFILE	(	"mini_dense0_bias.txt"		),
	.KERNELFILE	(	"mini_dense0_kernel.txt"	),
	.H			(	2							),
	.W			(	2							),
	.DEPTH		(	64							),
	.BIAS		(	128							),
	.DATA_WIDTH	(	DATA_WIDTH					),
	.ONCE		(	64							),
	.ONCE_B		(	1							)
) dense_front (
	.clk		(	clk							),
	.rstn		(	rstn						),
	.valid_i	(	valid_i						),
	.data_i		(	data_i						),
	.data_o		(	data_w						),
	.valid_o	(	valid_w						)
);

dense_opt #(
	.BIASFILE	(	"mini_dense1_bias.txt"		),
	.KERNELFILE	(	"mini_dense1_kernel.txt"	),
	.H			(	1							),
	.W			(	1							),
	.DEPTH		(	128							),
	.BIAS		(	7							),
	.DATA_WIDTH	(	DATA_WIDTH					),
	.ONCE		(	1							),
	.ONCE_B		(	1							)
) dense_rear (
	.clk		(	clk							),
	.rstn		(	rstn						),
	.valid_i	(	valid_w						),
	.data_i		(	data_w						),
	.data_o		(	data_o						),
	.valid_o	(	valid_o						)
);

endmodule