`timescale 1 ns / 10 ps

module dense_opt #(
	parameter	BIASFILE	= "2424_dense0_bias.txt"		,
	parameter	KERNELFILE	= "2424_dense0_kernel.txt"	,
	parameter	H			= 2						,
	parameter	W			= 2						,
	parameter	DEPTH		= 64					,	// 이전 레이어의 depth
	parameter	BIAS		= 128					,
	parameter	BIAS_BIT	= 8						,
	parameter	DATA_WIDTH	= 32					,
	parameter	PERBIAS		= DEPTH * H * W
) (
	input									clk		,
	input									rstn	,
	input									valid_i	,
	input		[W*DEPTH*DATA_WIDTH-1:0]	data_i	,
	output		[DATA_WIDTH-1:0]			data_o	,
	output	reg								valid_o
);

reg		[DATA_WIDTH-1:0]	biases		[0:BIAS-1]			;
reg		[DATA_WIDTH-1:0]	kernels		[0:PERBIAS*BIAS-1]	;

reg		[DATA_WIDTH-1:0]	d_cnt							;	// # of depth
reg		[DATA_WIDTH-1:0]	b_cnt							;	// # of bias
reg		[DATA_WIDTH-1:0]	h_cnt							;	// # of height

wire	[DATA_WIDTH-1:0]	temp		[0:2*W-2]			;
reg		[DATA_WIDTH-1:0]	kernel_w			[0:W-1]		;

reg		[DATA_WIDTH-1:0]	results_width	[0:BIAS-1]		;
reg		[DATA_WIDTH-1:0]	result_width					;
wire	[DATA_WIDTH-1:0]	result_width_temp				;

reg		[DATA_WIDTH-1:0]	result_bias					;
reg		[DATA_WIDTH-1:0]	bias							;
wire	[DATA_WIDTH-1:0]	result_bias_temp				;

reg		[DATA_WIDTH-1:0]	results		[0:BIAS-1]			;

initial begin
	$readmemh(	BIASFILE,	biases	);
	$readmemh(	KERNELFILE,	kernels	);
end

genvar i, j, k, l;
generate
	for(i=0;i<W;i=i+1) begin: multi_block	// Width까지는 병렬로 처리.
		FloatingMultiplication multiplication (
			.A		(	data_i		[i*DATA_WIDTH+:DATA_WIDTH]	),
			.B		(	kernel_w	[i]							),
			.result	(	temp		[i]							)
		);
	end
	for(i=0;i<2*W-2;i=i+2) begin: add_block
		FloatingAddition addition (
			.A		(	temp	[i]		),
			.B		(	temp	[i+1]	),
			.result	(	temp	[W+i/2]	)	// width 다 더한 것 temp [2*W-2]
		);
	end
endgenerate

FloatingAddition width_adder (
	.A		(	temp		[2*W-2]	),
	.B		(	result_width		),
	.result	(	result_width_temp	)	// kernel 다 더한 것
);

FloatingAddition bias_adder (
	.A		(	result_bias			),
	.B		(	bias				),
	.result	(	result_bias_temp	)
);

always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		d_cnt				<= 'b0	;
		b_cnt				<= 'b0	;
		h_cnt				<= 'b0	;
	end
	else if (valid_i) begin
		valid_o	<= 1'b0	;
		if (b_cnt == BIAS-1) begin
			b_cnt	<= 'b0	;
			if (d_cnt == DEPTH-1) begin
				d_cnt	<= 'b0	;
				if (h_cnt == H-1) begin
					h_cnt	<= 'b0	;
					valid_o	<= 1'b1	;
				end
				else begin
					h_cnt	<= h_cnt + 'b1	;
				end
			end
			else begin
				d_cnt	<= d_cnt + 'b1	;
			end
		end
		else begin
			b_cnt	<= b_cnt + 'b1	;
		end
	end
	else begin
		b_cnt	<= b_cnt	;
		d_cnt	<= d_cnt	;
		h_cnt	<= h_cnt	;
	end
end

integer	kernel_index	;

always @(b_cnt or d_cnt or h_cnt or rstn or valid_i) begin
	if(valid_i) begin
		for (kernel_index=0;kernel_index<W;kernel_index=kernel_index+1) begin
			kernel_w[kernel_index]	<= kernels	[kernel_index*DEPTH*BIAS+h_cnt*W*DEPTH*BIAS+d_cnt*BIAS+b_cnt];
		end
	end
	else begin
		for (kernel_index=0;kernel_index<W;kernel_index=kernel_index+1) begin
			kernel_w[kernel_index]	<= kernel_w	[kernel_index];
		end
	end
end

always @(b_cnt or valid_i or rstn) begin
	if (~rstn) begin
		result_width <= 'b0;
		result_bias <= 'b0;
		bias	<= 'b0;
	end
	else if (valid_i) begin
		result_width <= results_width[b_cnt];
		result_bias <= results_width[b_cnt];
		bias	<= biases[b_cnt];
	end
	else begin
		result_width <= result_width;
		result_bias <= result_bias;
		bias <= bias;
	end
end

integer ai;

always @(posedge clk) begin
	if (~rstn) begin
		for(ai=0;ai<BIAS;ai=ai+1) begin
			results_width[ai]	<= 'b0	;
		end
	end
	else if (valid_i) begin
		results_width[b_cnt] <= result_width_temp;
	end
	else begin
		results_width[b_cnt]	<= results_width[b_cnt];
	end
end

assign data_o = result_bias_temp;

// always @(result_bias_temp) begin
// 	data_o[b_cnt*DATA_WIDTH+:DATA_WIDTH] <= result_bias_temp;
// end

endmodule