module conv1_buf #(parameter WIDTH = 96, HEIGHT = 96, DATA_BITS = 8)(
    input clk,
    input rst_n,
    input [DATA_BITS - 1 : 0] data_in,
    output reg [DATA_BITS - 1 : 0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4,
                                    data_out_5, data_out_6, data_out_7, data_out_8,
    output valid_out_buf
)

localparam FILTER_SIZE = 'd3;

reg [DATA_BITS - 1 : 0] buffer [0 : WIDTH * FILTER_SIZE - 1];
reg [FILTER_SIZE * WIDTH - 1 : 0] buffer_index;
reg [7:0] width_index;
reg [7:0] height_index;
reg [2:0] buffer_flag;


