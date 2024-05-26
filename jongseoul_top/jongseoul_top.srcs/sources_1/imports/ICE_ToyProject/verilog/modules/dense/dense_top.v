module dense_top #(
	parameter	DATA_WIDTH	= 8,
	parameter	NUMI_ONCE = 3*12
) (
	input								clk,
	input								rstn,
	input	[DATA_WIDTH*NUMI_ONCE-1:0]	data_i,
	input								valid_i,
	output	[DATA_WIDTH*7-1:0]			data_o,
	output								valid_o
);

reg		[DATA_WIDTH*NUMI_ONCE-1:0]	data_i_reg;
reg									valid_i_reg;

wire	[DATA_WIDTH-1:0]	data_w;
wire						valid_w;

dense_opt #(
	.BIASFILE	(	"mini_dense0_bias.txt"		),
	.KERNELFILE	(	"mini_dense0_kernel.txt"	),
	.H			(	3							),
	.W			(	3							),
	.DEPTH		(	12							),
	.BIAS		(	64							),
	.DATA_WIDTH	(	DATA_WIDTH					),
	.ONCE		(	12							),
	.ONCE_B		(	1							)
) dense_front (
	.clk		(	clk							),
	.rstn		(	rstn						),
	.valid_i	(	valid_i_reg					),
	.data_i		(	data_i_reg					),
	.data_o		(	data_w						),
	.valid_o	(	valid_w						)
);

dense_opt2 #(
	.BIASFILE	(	"mini_dense1_bias.txt"		),
	.KERNELFILE	(	"mini_dense1_kernel.txt"	),
	.H			(	64							),
	.W			(	1							),
	.DEPTH		(	1 							),
	.BIAS		(	7							),
	.DATA_WIDTH	(	DATA_WIDTH					)
) dense_rear (
	.clk		(	clk							),
	.rstn		(	rstn						),
	.valid_i	(	valid_w						),
	.data_i		(	data_w						),
	.data_o		(	data_o						),
	.valid_o	(	valid_o						)
);

always @(posedge clk) begin
	data_i_reg	<= data_i;
	valid_i_reg	<= valid_i;
end

endmodule