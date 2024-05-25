`timescale 1 ns / 10 ps

module dense_opt2 #(
	parameter	BIASFILE	= "mini_dense1_bias.txt"	,
	parameter	KERNELFILE	= "mini_dense1_kernel.txt"	,
	parameter	H			= 64							,
	parameter	W			= 1							,
	parameter	DEPTH		= 1						,	// 이전 레이어의 depth
	parameter	BIAS		= 7						,
	parameter	DATA_WIDTH	= 8
) (
	input									clk		,
	input									rstn	,
	input									valid_i	,
	input		[DATA_WIDTH-1:0]			data_i	,
	output		[DATA_WIDTH*BIAS-1:0]			data_o	,
	output	reg								valid_o
);

reg		[DATA_WIDTH-1:0]				data_i_reg			[0:H-1]		;
reg										valid_i_reg;

reg										valid_n;

reg		[clogb2(BIAS-1)-1:0]			b_cnt							;	// # of bias
reg		[clogb2(H-1)-1:0]				h_cnt_p							;	// # of bias
reg		[clogb2(H-1)-1:0]				h_cnt							;	// # of height
reg		[clogb2(H-1)-1:0]				cnt								;

wire	[DATA_WIDTH-1:0]				temp				[0:BIAS-1]	;
reg		[DATA_WIDTH-1:0]				bias				[0:BIAS-1]	;

reg		[DATA_WIDTH*BIAS-1:0]			results_onces		[0:H-1];
wire	[DATA_WIDTH*BIAS-1:0]			results_end			[0:2*H-2];

reg										mem_wait						;
reg										mem_wait_p						;

wire	[BIAS * DATA_WIDTH-1:0]			mem_k							;

initial begin
	$readmemh(BIASFILE, bias);
end

rom #(
	.RAM_WIDTH(BIAS * DATA_WIDTH), 
	.RAM_DEPTH(H),
	.INIT_FILE(KERNELFILE)
) krom (
	.clk	(	clk		),
	.en		(	1'b1	),
	.addra	(	h_cnt	),
	.dout	(	mem_k	)
);

wire	[DATA_WIDTH-1:0]	data_i_w;

assign	data_i_w	= data_i_reg[h_cnt];

genvar i, j;
generate
	for(j=0;j<BIAS;j=j+1) begin: width_multi_block
		floatMult multiplication (
			.floatA		(	data_i_w	),
			.floatB		(	mem_k	[j*DATA_WIDTH+:DATA_WIDTH]	),
			.product	(	temp	[j]							)
		);
	end

	for (i=0;i<H;i=i+1) begin: result_end_set
		assign	results_end	[i]	= results_onces	[i]; 
	end

	for (j=0;j<2*H-2; j=j+2) begin
		for (i=0;i<BIAS;i=i+1) begin: before_bias
			floatAdd before_bias (
				.floatA		(	results_end		[j][i*DATA_WIDTH+:DATA_WIDTH]			),
				.floatB		(	results_end		[j+1][i*DATA_WIDTH+:DATA_WIDTH]		),
				.sum		(	results_end		[H+j/2][i*DATA_WIDTH+:DATA_WIDTH]	)	// kernel 다 더한 것
			);
		end
	end

	for(i=0;i<BIAS;i=i+1) begin
		floatAdd bias_adder (
			.floatA		(	results_end	[2*H-2][i*DATA_WIDTH+:DATA_WIDTH]	),
			.floatB		(	bias		[i]				),
			.sum		(	data_o		[i*DATA_WIDTH+:DATA_WIDTH]			)
		);
	end
endgenerate

integer k;
always @(posedge clk) begin
	if (~rstn) begin
		for(k=0;k<H;k=k+1) begin
			data_i_reg [k]	<= {DATA_WIDTH{1'b0}};
		end
		
		cnt			<= 'b0;
		valid_i_reg	<= 1'b0;
	end
	else begin
		valid_i_reg	<= valid_i;
		if(valid_i)  begin
			data_i_reg[cnt]	<= data_i;
			if(cnt	== H - 1) begin
				cnt	<= 0;
			end
			else begin
				cnt	<= cnt + 1;
			end
		end
	end
end

reg flag, flag_n;
always	@(posedge clk) begin: set_results_onces
	if(~rstn) begin
		for(k=0;k<BIAS;k=k+1) begin
			results_onces[k]	<= {DATA_WIDTH*H{1'b0}};
		end
		b_cnt		<= 'b0;
		h_cnt		<= 'b0;
		h_cnt_p		<= 'b0;
		mem_wait	<= 'b0;
		mem_wait_p	<= 'b0;
		valid_o		<= 'b0;
		valid_n		<= 'b0;
		flag		<= 'b0;
		flag_n		<= 'b1;
	end
	else begin
		flag_n		<= flag;
		mem_wait_p	<= mem_wait;
		h_cnt_p	<= h_cnt;
		if (valid_i_reg | |b_cnt | |mem_wait | |h_cnt) begin
			if(mem_wait) begin
				for(k=0;k<BIAS;k=k+1) begin
					results_onces[h_cnt][k*DATA_WIDTH+:DATA_WIDTH]	<= temp[k];
				end
				mem_wait	<= 'b0;
				if(h_cnt == H-1) begin
					h_cnt	<= 'b0;
					flag	<= 'b0;
				end
				else begin
					if(h_cnt == H-2) begin
						flag = 1'b1;
					end
					h_cnt	<= h_cnt + 'b1;
				end
			end
			else begin
				mem_wait	<= 'b1;
			end
		end
		valid_o	<= flag_n & (h_cnt == 0) & ~mem_wait & mem_wait_p;	// BIAS 하나씩.
	end
end

function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
	depth = depth >> 1;
endfunction


endmodule