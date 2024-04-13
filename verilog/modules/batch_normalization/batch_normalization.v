module batch_normalization #(
	parameter	DATA_WIDTH	= 32										,
	parameter	FILTERS		= 64										,
	parameter	DEPTH		= 1											,
	parameter	INPUT		= 30										,
) (
	input			[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0]	data_i	,
	input														clk				,
	input			[INPUT * INPUT * DATA_WIDTH - 1 : 0]		gamma_i			,
	input			[INPUT * INPUT * DATA_WIDTH - 1 : 0]		moving_means_i	,
	input			[INPUT * INPUT * DATA_WIDTH - 1 : 0]		denominators_i	,
	output			[DEPTH * INPUT * INPUT * DATA_WIDTH - 1:0]	result_o	
);

genvar i;
generate
	for(i=0; i<DEPTH * INPUT * INPUT; i = i + 1) begin: generate_block
		batch_normalization_element u_PE (
			.clk			(	clk											),
			.data_i			(	data_i			[i * DATA_WIDTH+:DATA_WIDTH]),
			.gamma_i		(	gamma_i			[i * DATA_WIDTH+:DATA_WIDTH]),
			.moving_mean_i	(	moving_means_i	[i * DATA_WIDTH+:DATA_WIDTH]),
			.denominator_i	(	denominators_i	[i * DATA_WIDTH+:DATA_WIDTH]),
			.result_o		(	result_o		[i * DATA_WIDTH+:DATA_WIDTH])
		);
	end
endgenerate

endmodule