module image_buffer(
    clk, image, enable, receptiveField, rst_n
);

//this modules takes as inputs the image, a row number and a column number
//it fills the output array with matrices of the parts of the image to be sent to the conv units


parameter DATA_WIDTH = 8;
parameter D = 3; //Depth of the filter
parameter H = 96; //Height of the image
parameter W = 96; //Width of the image
parameter F = 3; //Size of the filter

parameter S_IDLE = 1'b0;
parameter S_BUF = 1'b1;

input clk;
input rst_n;
input [0:D*H*W*DATA_WIDTH-1] buffer;
input enable;
output reg [0:(((W-F+1)/2)*D*F*F*DATA_WIDTH)-1] receptiveField; //array to hold the matrices (parts of the image) to be sent to the conv units
reg state, state_n;
reg [10:0] buf_index;
wire valid;
always@(*) begin
    case(state)
        S_IDLE : begin
            if(enable) begin
                valid = 1'b0;
                state_n = S_VALID;
            end
            else
                state_n = state;
        end
        
        S_BUF : begin
            if (buf_index == 11'd27647) begin
                valid = 1'b1;
                state_n = S_IDLE;
            end
            else
                state_n = state;
        end
    endcase
end

always@(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        state <= S_IDLE;
    else
        state <= state_n;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        buf_index <= 11'h0;
    else if (buf_index == 11'd27647)
        buf_index <= 11'h0;
    else if (state = S_BUF)
        buf_index <= buf_index + 11'd1;
    else
        buf_index <= buf_index;
end

//address: counter to fill the receptive filed array
//c: counter to loop on the columns of the input image
//k: counter to loop on the depth of the input image
//i: counter to loop on the rows of the input image
integer address, c, k, i;

always @ (image or rowNumber or column) begin  
    if (valid) begin
        address = 0;
	    if (column == 0) begin //if the column is zero fill the array with the parts of the image correspoding to the first half of pixels of the row (with rowNumber) of the output image
	    	for (c = 0; c < (W-F+1)/2; c = c + 1) begin
	    		for (k = 0; k < D; k = k + 1) begin
	    			for (i = 0; i < F; i = i + 1) begin
	    				receptiveField[address*F*DATA_WIDTH+:F*DATA_WIDTH] = image[rowNumber*W*DATA_WIDTH+c*DATA_WIDTH+k*H*W*DATA_WIDTH+i*W*DATA_WIDTH+:F*DATA_WIDTH];
	    				address = address + 1;
	    			end
	    		end
	    	end
	    end else begin //if the column is zero fill the array with the parts of the image correspoding to the second half of pixels of the row (with rowNumber) of the output image
	    	for (c = (W-F+1)/2; c < (W-F+1); c = c + 1) begin
	    		for (k = 0; k < D; k = k + 1) begin
	    			for (i = 0; i < F; i = i + 1) begin
	    				receptiveField[address*F*DATA_WIDTH+:F*DATA_WIDTH] = image[rowNumber*W*DATA_WIDTH+c*DATA_WIDTH+k*H*W*DATA_WIDTH+i*W*DATA_WIDTH+:F*DATA_WIDTH];
	    				address = address + 1;
	    			end
	    		end
	    	end
	    end
    end
	
end

endmodule