`timescale 1 ns / 10 ps

module convLayerMulti(clk,reset,image0,image1,image2,image_start,filters,outputCONV,done);

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
output  reg [0:K*H*DATA_WIDTH-1] outputCONV;
output                     reg    done;

wire [0:K*(H-F+1)*DATA_WIDTH-1] outputConv;


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

wire [K-1:0] valid; // if 1 line of convolution finished



// for image which is not sliced. for 48 by 48 image
/*
integer image_done;
assign done = (image_done == W);



always @ (*) begin
s	if (reset == 1'b1) begin
		image_done = 0;       
	end begin
	  if (image_start) begin
	    image_done = 0;
	  end else begin
    		if (valid && image_done < W) begin
			   image_done = image_done + 1;
		  end
	  end
	end
end

*/
integer row_counter;

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1) begin
		row_counter = 0;
	end else begin
	  if (image_start) begin
	    row_counter = row_counter + 1;
	  end else if(row_counter == H) begin
			row_counter = 0;
	 end
end
end

reg image_valid;
always @ (posedge clk or posedge reset) begin
  if(reset == 1'b1) begin
    image_valid <= 1'b0;
  end
else if(image_start) begin
  image_valid <= 1'b1;
end
else if(done) begin
  image_valid <= 1'b0;
end
end

always @ (*) begin
  if(reset == 1'b1 || image_start == 1'b1) begin
    done = 1'b0;  
  end else begin
    if(valid[0]) begin
      done = 1'b1;
    end
    else begin
      done = 1'b0;
    end
   end
end
  

genvar i;

generate
	for (i = 0; i < K; i = i + 1) begin //We generate K single conv layers (K = number of filters) and send to each layer the image and the corresponding filter
		convLayerSingle 
		#(
		  .DATA_WIDTH(DATA_WIDTH), .D(D), .H(H), .W(W), .F(F)
		)UUT 
		(
			.clk(clk),
			   .image_valid(image_valid),
	     		.reset(reset),
	     		.image0(image0),
	     		.image1(image1),
	     		.image2(image2),
	    		 .filter(filters[D*F*F*DATA_WIDTH*i+:D*F*F*DATA_WIDTH]),
	     		.outputConv(outputConv[(H-F+1)*DATA_WIDTH*i+:(H-F+1)*DATA_WIDTH]),
	     		.o_valid(valid[i])
      		);
  	end
endgenerate

integer j;
always @ (*) begin
for(j=0;j<H;j=j+1) begin
  if(row_counter <= F/2 || row_counter > H - F/2) begin
    outputCONV[H*DATA_WIDTH*j+:H*DATA_WIDTH] = 'b0;
  end else begin
    outputCONV[H*DATA_WIDTH*j+:H*DATA_WIDTH] = {32'b0, outputConv[(H-F+1)*DATA_WIDTH*j+:(H-F+1)*DATA_WIDTH], 32'b0};
  end    
end
end


endmodule

