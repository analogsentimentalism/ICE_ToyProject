module dense_top #(
	parameter	BIASFILE	= "dense0_bias.txt"		,
	parameter	KERNELFILE	= "dense0_kernel.txt"	,
	parameter	H			= 5						,
	parameter	W			= 5						,
	parameter	DEPTH		= 64					,
	parameter	BIAS		= 128					,
	parameter	DATA_WIDTH	= 32					,
	parameter	NUMS		= DEPTH * H * W
) (
	input									clk				,
	input	[DATA_WIDTH * NUMS * BIAS -1:0]	data_i			,
	input									rstn_i			,
	output	[DATA_WIDTH * BIAS-1:0]			result_o
);

reg		[DATA_WIDTH-1:0]			biases		[0:BIAS-1]		;
reg		[DATA_WIDTH-1:0]			kernels		[0:NUMS*BIAS-1]	;
wire	[DATA_WIDTH-1:0]			result_oc					;
reg		[DATA_WIDTH*NUMS-1:0]		data_ic						;
reg		[DATA_WIDTH-1:0]			bias_c						;
reg		[DATA_WIDTH*NUMS-1:0]		kernel_c					;
reg		[6:0]						cnt							;

wire	[DATA_WIDTH*NUMS-1:0]		ordered		[0:BIAS-1]		;

initial begin
	$readmemh(	BIASFILE,	biases	);
	$readmemh(	KERNELFILE,	kernels	);
end

genvar i, j;
generate
	for(i=0;i<NUMS;i=i+1) begin: ordered_assign_block
		for(j=0;j<BIAS;j=j+1) begin
			assign	ordered[j][i*DATA_WIDTH+:DATA_WIDTH]	= kernels	[i*BIAS+j]	;
		end
	end
	
	// for(i=0;i<BIAS;i=i+1) begin
	// 	dense #(
	// 		.DEPTH	(	DEPTH	),
	// 		.H		(	H		),
	// 		.W		(	W		)
	// 	) u_dense (
	// 		.clk		(	clk		),
	// 		.data_i		(	data_i		[DATA_WIDTH*NUMS*i+:DATA_WIDTH]	),
	// 		.kernel_i	(	kernel		[i]								),
	// 		.bias_i		(	biases		[i]								),
	// 		.result_o	(	result_o	[BIAS*i*DATA_WIDTH+:DATA_WIDTH])
	// 	);
	// end

	for(i=0;i<BIAS;i=i+1) begin: result_assign_block
		assign	result_o	[DATA_WIDTH*i+:DATA_WIDTH]	= result_oc	;
	end
endgenerate

dense #(
	.DEPTH	(	DEPTH	),
	.H		(	H		),
	.W		(	W		)
) u_dense (
	.clk		(	clk			),
	.data_i		(	data_ic		),
	.kernel_i	(	kernel_c	),
	.bias_i		(	bias_c		),
	.result_o	(	result_oc	)
);

always @(posedge clk) begin
	if (!rstn_i) begin
		cnt	=	7'b0			;
	end

	else begin
		cnt	<= cnt + 7'b1	;
		if (cnt == BIAS) cnt <= 7'b0	;
	end
end

always @(cnt) begin
	data_ic		<= data_i	[cnt*NUMS*DATA_WIDTH+:NUMS*DATA_WIDTH]	;
	kernel_c	<= ordered	[cnt]									;
	bias_c		<= biases	[cnt]									;
end



endmodule