`timescale 1ns / 1ps
//for 3by3 kernel

module fifo #(
    parameter DATA_WIDTH = 32,
    parameter DATA_LEN = 48,
    parameter FIFO_DEPTH = 8,
    parameter PTR_SIZE = 3,
    parameter FILTER_SIZE = 5,
    parameter FILTER_LEN = 3,
    parameter kernel_txt = "conv0_kernel.txt"
    )
    (
    input                                   i_clk,
    input                                   i_resetn,
    input                                   i_ren,
    input                                   i_wen,
    input       [DATA_WIDTH*DATA_LEN-1:0]   i_wdata,
    
    input                                   i_valid_conv,

    output reg  [DATA_WIDTH*DATA_LEN-1:0]   o_rdata,
    output                                  o_empty,
    output                                  o_full,
    
    output      [DATA_WIDTH*DATA_LEN-1:0]       o_image1,
    output      [DATA_WIDTH*DATA_LEN-1:0]       o_image2,
    output      [DATA_WIDTH*DATA_LEN-1:0]       o_image3,   
    output      [FILTER_SIZE*FILTER_SIZE-1:0]   o_kernel
    );
    
    reg         [DATA_WIDTH*DATA_LEN-1:0]   mem_fifo [0:FIFO_DEPTH-1];
    reg             [PTR_SIZE:0]   r_rptr;
    reg             [PTR_SIZE:0]   r_wptr;
    
    reg		[DATA_WIDTH-1:0]			kernels		[0:FILTER_SIZE*FILTER_SIZE*FILTER_LEN-1]	;
    
    initial begin
	     $readmemh(	kernel_txt,	kernels	);
    end
    
    assign o_empty = (r_wptr <= r_rptr + 'h2 );
    assign o_full  = (r_wptr[PTR_SIZE-1:0] == r_rptr[PTR_SIZE-1:0]) & (r_wptr[PTR_SIZE] != r_rptr[PTR_SIZE]);
    
    always @ (posedge i_clk or negedge i_resetn) begin         // WRITE POINTER
        if (!i_resetn) begin
            r_wptr <= 'd0;
        end
        else if (!o_full && i_wen) begin
            r_wptr <= r_wptr + 1;
        end
        else begin
            r_wptr <= r_wptr;
        end
    end
    
    always @ (posedge i_clk or negedge i_resetn) begin          // READ POINTER
        if (!i_resetn) begin
            r_rptr <= 'd0;
        end
        else if (!o_empty && i_ren) begin
            r_rptr <= r_rptr + 1;
        end
        else begin
            r_rptr <= r_rptr;
        end
    end

    always @ (posedge i_clk) begin         					     // WRITE
        if (!o_full && i_wen) begin
            mem_fifo[r_wptr[PTR_SIZE-1:0]] <= i_wdata;
        end
    end
    
    always @ (posedge i_clk) begin                               //READ
        if (!o_empty && i_ren) begin
            o_rdata <= mem_fifo[r_rptr[PTR_SIZE-1:0]];
        end
    end

endmodule