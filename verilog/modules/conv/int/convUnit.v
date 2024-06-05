`timescale 1 ns / 10 ps

module convUnit(clk,reset,image0,image1,image2,filter,result);

parameter input_DATA_WIDTH = 8;
parameter output_DATA_WIDTH = 32;
parameter D = 1; //depth of the filter
parameter F = 3; //size of the filter

input clk, reset;
//input   i_valid;
input signed  [F*input_DATA_WIDTH-1:0] image0;
input signed  [F*input_DATA_WIDTH-1:0] image1;
input signed   [F*input_DATA_WIDTH-1:0] image2;
input signed   [F*F*input_DATA_WIDTH-1:0] filter;
output signed  [output_DATA_WIDTH-1:0] result;
//output  reg o_valid;
 
reg signed  [input_DATA_WIDTH-1:0] selectedInput1, selectedInput2;

integer i;

processingElement PE
	(
		.clk(clk),
		.reset(reset),
		.floatA(selectedInput1),
		.floatB(selectedInput2),
		.result(result)
	);

// The convolution is calculated in a sequential process to save hardware
// The result of the element wise matrix multiplication is finished after (F*F+2) cycles (2 cycles to reset the processing element and F*F cycles to accumulate the result of the F*F multiplications) 
always @ (posedge clk, posedge reset) begin
	if (reset == 1'b1) begin // reset
		i = 0;
		selectedInput1 = 0;
		selectedInput2 = 0;
		//o_valid = 1'b0;
	end else if (i > F*F-1) begin // if the convolution is finished but we still wait for other blocks to finsih, send zeros to the conv unit (in case of pipelining)
		selectedInput1 = 0;
		selectedInput2 = 0;
		//o_valid = 1'b1;
	end else if (i < F) begin // send one element of the image part and one element of the filter to be multiplied and accumulated
		selectedInput1 = image2[input_DATA_WIDTH*i+:input_DATA_WIDTH];
		selectedInput2 = filter[input_DATA_WIDTH*i+:input_DATA_WIDTH];
		i = i + 1;
		//o_valid = 1'b0;
	end else if(i < 2*F) begin
	    selectedInput1 = image1[input_DATA_WIDTH*(i-3)+:input_DATA_WIDTH];
		selectedInput2 = filter[input_DATA_WIDTH*i+:input_DATA_WIDTH];
		i = i + 1;
	end else if(i < 3*F) begin
	    selectedInput1 = image0[input_DATA_WIDTH*(i-6)+:input_DATA_WIDTH];
		selectedInput2 = filter[input_DATA_WIDTH*i+:input_DATA_WIDTH];
		i = i + 1;
	end
end

endmodule


//reg r_valid;


/*
processingElement PE_1_1
	(
		.clk(clk),
		.reset(reset),
		.floatA(image0[1*DATA_WIDTH-1:0*DATA_WIDTH]),
		.floatB(filter[1*DATA_WIDTH-1:0*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_1_2
	(
		.clk(clk),
		.reset(reset),
		.floatA(image0[2*DATA_WIDTH-1:1*DATA_WIDTH]),
		.floatB(filter[2*DATA_WIDTH-1:1*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_1_3
	(
		.clk(clk),
		.reset(reset),
		.floatA(image0[3*DATA_WIDTH-1:2*DATA_WIDTH]),
		.floatB(filter[3*DATA_WIDTH-1:2*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_2_1
	(
		.clk(clk),
		.reset(reset),
		.floatA(image1[1*DATA_WIDTH-1:0*DATA_WIDTH]),
		.floatB(filter[4*DATA_WIDTH-1:3*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_2_2
	(
		.clk(clk),
		.reset(reset),
		.floatA(image1[2*DATA_WIDTH-1:1*DATA_WIDTH]),
		.floatB(filter[5*DATA_WIDTH-1:4*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_2_3
	(
		.clk(clk),
		.reset(reset),
		.floatA(image1[3*DATA_WIDTH-1:2*DATA_WIDTH]),
		.floatB(filter[6*DATA_WIDTH-1:5*DATA_WIDTH]),
		.result(result)
	);
processingElement PE_3_1
	(
		.clk(clk),
		.reset(reset),
		.floatA(image2[1*DATA_WIDTH-1:0*DATA_WIDTH]),
		.floatB(filter[7*DATA_WIDTH-1:6*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_3_2
	(
		.clk(clk),
		.reset(reset),
		.floatA(image2[2*DATA_WIDTH-1:1*DATA_WIDTH]),
		.floatB(filter[8*DATA_WIDTH-1:7*DATA_WIDTH]),
		.result(result)
	);
	
processingElement PE_3_3
	(
		.clk(clk),
		.reset(reset),
		.floatA(image2[3*DATA_WIDTH-1:2*DATA_WIDTH]),
		.floatB(filter[9*DATA_WIDTH-1:8*DATA_WIDTH]),
		.result(result)
	);

// The convolution is calculated in a sequential process to save hardware
// The result of the element wise matrix multiplication is finished after (F*F+2) cycles (2 cycles to reset the processing element and F*F cycles to accumulate the result of the F*F multiplications) 
always @ (posedge clk, posedge reset) begin
	if (reset == 1'b1) begin // reset
		i = 0;
		selectedInput1 = 0;
		selectedInput2 = 0;
	end else if (i > D*F*F-1) begin // if the convolution is finished but we still wait for other blocks to finsih, send zeros to the conv unit (in case of pipelining)
		selectedInput1 = 0;
		selectedInput2 = 0;
	end else begin // send one element of the image part and one element of the filter to be multiplied and accumulated
		selectedInput1 = image[DATA_WIDTH*i+:DATA_WIDTH];
		selectedInput2 = filter[DATA_WIDTH*i+:DATA_WIDTH];
	end
end
*/
/*
always @ (posedge clk, posedge reset) begin
    if(reset == 1'b1) begin
        r_valid = 1'b0;
    end
    else if(i == F*F-1) begin
        r_valid = 1'b1;
    end
end

assign o_valid = r_valid;

endmodule

*/

