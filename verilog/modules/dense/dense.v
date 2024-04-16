module dense #(
	parameter	W 			= 96	,
	parameter	H 			= 96	,
	parameter	BIAS 		= 256	,
	parameter	DATA_WIDTH	= 32

) (
	input								clk				,
	input	[DATA_WIDTH * W * H -1:0]	data_i			,
	input	[DATA_WIDTH * BIAS-1:0]		bias_i			,
	input	[DATA_WIDTH * W * H -1:0]	kernal_i		,
	output	[DATA_WIDTH * BIAS-1:0]		result_o
);

wire	[DATA_WIDTH-1:0]			temp		[0:2*W*H-2]	;
wire	[DATA_WIDTH-1:0]			bias_result	[0:BIAS-1]	;
genvar i, j, k, l;
generate
	for(i=0;i<H;i=i+1) begin: multi
		for(j=0;j<W;j=j+1) begin
			FloatingMultiplication multiplication (
				.A		(	data_i		[(i*H+j)*DATA_WIDTH+:DATA_WIDTH]		),
				.B		(	kernal_i	[(i*H+j)*DATA_WIDTH+:DATA_WIDTH]		),
				.clk	(	clk									),
				.result	(	temp		[i*H+j]					)
			);
		end
	end
	for(k=0;k<2*W*H-1;k=k+2) begin: addition
		FloatingAddition addition (
			.A		(	temp	[k]	),
			.B		(	temp	[k + 1]	),
			.result	(	temp	[W*H+k/2]	)
		);
	end

	for(l=0;l<BIAS;l=l+1) begin: bias
		FloatingAddition bias_adder (
			.A		(	temp		[2*W*H-2]					),
			.B		(	bias_i		[l*DATA_WIDTH+:DATA_WIDTH]	),
			.result	(	bias_result	[l]							)
		);

		relu #(
			.D(1),
			.H(1),
			.W(1)
		) u_relu (
			.input_data		(	bias_result	[l]									),
			.output_data	(	result_o	[l*DATA_WIDTH+:DATA_WIDTH]			)
		);
	end
endgenerate
endmodule