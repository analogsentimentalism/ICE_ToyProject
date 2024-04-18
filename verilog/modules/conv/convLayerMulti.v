`timescale 1 ns / 10 ps

module convLayerMulti(clk,reset,image0,image1,image2,image_start,filters,outputConv,done);

parameter DATA_WIDTH = 32;
parameter D = 1; //Depth of image and filter
parameter H = 64; //Height of image
parameter W = 64; //Width of image
parameter F = 3; //Size of filter
parameter K = 2; //Number of filters applied

input clk, reset;
input   [0:D*H*1*DATA_WIDTH-1] image0;
input   [0:D*H*1*DATA_WIDTH-1] image1;
input   [0:D*H*1*DATA_WIDTH-1] image2;
input                          image_start;
input   [0:K*D*F*F*DATA_WIDTH-1] filters;
output  [0:K*(W-F+1)*DATA_WIDTH-1] outputConv;
output                         done;

/*assign image_done = (counter == 4'b1010);

always @ (posedge clk or posedge reset) begin
  if(reset) begin
    counter   <= 4'b0;
  end
  else begin
    if(image_start) begin
      counter <= 4'b0;
    end
    else begin
      counter <= counter + 1'b1;
      
    end
  end   
end*/

integer counter;

reg image_done;
assign done = image_done;

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1) begin
		image_done = 1'b0;
		counter = 0;
	end begin
	  if (image_start) begin
	    counter = 0;
	    image_done = 1'b0;
	  end else begin
    		if (counter == D*F*F) begin
			   image_done = 1'b1;
		  end else begin
			   counter = counter + 1;
			   image_done = 1'b0;
		  end
	  end
	 end
end

integer j;



genvar i;

generate
	for (i = 0; i < K; i = i + 1) begin //We generate K single conv layers (K = number of filters) and send to each layer the image and the corresponding filter
		convLayerSingle 
		#(
		  .DATA_WIDTH(DATA_WIDTH), .D(D), .H(H), .W(W), .F(F)
		)UUT 
		(
			.clk(clk),
	     		.reset(reset),
	     		.image0(image0),
	     		.image1(image1),
	     		.image2(image2),
	    		 .filter(filters[D*F*F*DATA_WIDTH*i+:D*F*F*DATA_WIDTH]),
	     		.outputConv(outputConv[(H-F+1)*DATA_WIDTH*i+:(H-F+1)*DATA_WIDTH]),
	     		.image_valid(!done)
      		);
  	end
endgenerate


endmodule

