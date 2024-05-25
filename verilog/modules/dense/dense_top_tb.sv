`timescale	1ns/1ns
module dense_top_tb #(
	parameter	INPUT_PERIOD	= 200,
	parameter	DATA_WIDTH		= 8,
	parameter	NUMI_ONCE		= 36
) ();

reg									clk;
reg									rstn;
reg		[DATA_WIDTH*NUMI_ONCE-1:0]	data_i;
reg									valid_i;

wire	[DATA_WIDTH*7-1:0]			data_o;
wire								valid_o;

reg		[DATA_WIDTH*NUMI_ONCE-1:0]	data_temp;

densedense #(
	.DATA_WIDTH	(	DATA_WIDTH	),
	.NUMI_ONCE	(	NUMI_ONCE	)
) u_densedense (
	.clk		(	clk		),
	.rstn		(	rstn	),
	.data_i		(	data_i	),
	.valid_i	(	valid_i	),
	.data_o		(	data_o	),
	.valid_o	(	valid_o	)
);

initial begin
	forever	#1	clk	= ~clk;
end

integer 	i,	j;
initial begin
	clk		= 1'b1;
	rstn	= 1'b0;
	valid_i	= 0;
	data_i	= 0;
	repeat(50) @(posedge clk);
	rstn	= 1'b1;
	repeat(50) @(posedge clk);
	for(i=0;i<3;i=i+1) begin
		for(j=0;j<NUMI_ONCE;j=j+1) begin
			if(i==0) begin
				data_temp	[j*DATA_WIDTH+:DATA_WIDTH]	= 8'h1C + j/2;
			end
			if(i==1) begin
				data_temp	[j*DATA_WIDTH+:DATA_WIDTH]	= 8'h2C + j/2;
			end
			if(i==2) begin
				data_temp	[j*DATA_WIDTH+:DATA_WIDTH]	= 8'h10 + j/2;
			end
		end 
		input_data(data_temp);
		repeat(INPUT_PERIOD)	@(posedge clk);
	end
end

task input_data (
	input	[DATA_WIDTH*NUMI_ONCE-1:0]	data
);
begin
	data_i	= data;
	valid_i	= 1'b1;
	$display("%d::\tINPUT:\t\t%h", $time, data);
	repeat(1)	@(posedge clk);
	data_i	= {(DATA_WIDTH*NUMI_ONCE){1'b0}};
	valid_i	= 1'b0;
end
endtask

endmodule