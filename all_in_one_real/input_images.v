module input_images #(
	parameter	W		= 24,
	parameter	IMAGES	= "images.txt"
) (
	input				clk,
	input				rstn,
	input	[3:0	]	sw,
	input				button,
	input				conv_done,
	output	[W*8-1:0]	data_o,
	output	reg			valid_o
);

reg		[clogb2(W-1)-1:0	]	cnt;
reg								button_reg;
reg								button_p;
reg								mem_wait;

wire	[8:0]					addr;
assign	addr	= cnt + sw * W;

rom #(
	.RAM_WIDTH	(	W * 8			), 
	.RAM_DEPTH	(	W * 16			),
	.INIT_FILE	(	IMAGES			)
) image_rom (
	.clk	(	clk				),
	.en		(	1'b1			),
	.addra	(	addr			),
	.dout	(	data_o			)
);

always @(posedge clk) begin
	if (~rstn) begin
		cnt	<= {clogb2(W-1){1'b0}};
		button_reg	<= 1'b0;
		button_p	<= 1'b0;
		mem_wait	<= 1'b0;
	end
	else begin
		button_reg	<= button;
		button_p	<= button_reg;
		if(~button_p & button_reg | |cnt | mem_wait) begin
			if(mem_wait) begin
				if(cnt	<= 1) begin
					valid_o		<= 1'b1;
					mem_wait	<= 1'b0;
					cnt			<= cnt + 1;
				end
				else begin
					if(conv_done) begin
						mem_wait	<= 1'b1;
						if(cnt==W) begin
							cnt	<= cnt;
						end
						else begin
							valid_o		<= 1'b1;
							cnt	<= cnt + 1;
						end
					end
					else begin
						valid_o		<= 1'b0;
					end
				end

			end
			else begin
				mem_wait	<= 1'b1;
				valid_o		<= 1'b0;
			end
		end
	end
end

function integer clogb2;
input integer depth;
	for (clogb2=0; depth>0; clogb2=clogb2+1)
	depth = depth >> 1;
endfunction

endmodule