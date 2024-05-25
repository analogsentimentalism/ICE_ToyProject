
module tb_line_3_buffer;

    // Parameters
    parameter DATA_BITS = 8;
    parameter D = 1;
    parameter H = 24;
    parameter W = 24;
    parameter K = 6;

    // Inputs
    reg clk;
    reg resetn;
    reg [W*DATA_BITS*K-1:0] input_data;
    reg valid_i;

    // Outputs
    wire [W*DATA_BITS*K-1:0] output_1;
    wire [W*DATA_BITS*K-1:0] output_2;
    wire [W*DATA_BITS*K-1:0] output_3;
    wire valid_o;

    // Instantiate the 3_line_buffer module
    line_3_buffer #(DATA_BITS, D, H, W, K) uut (
        .clk(clk),
        .resetn(resetn),
        .input_data(input_data),
        .output_1(output_1),
        .output_2(output_2),
        .output_3(output_3),
        .valid_i(valid_i),
        .valid_o(valid_o)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize inputs
        resetn = 0;
        input_data = 0;
        valid_i = 0;

        // Reset the system
        #10 resetn = 1;

        // Apply test vectors
        #10 input_data = {6{192'hA1A2A3A4A5A6A7A8A9AAABACADAEAF}}; valid_i = 1;
        #10 valid_i = 0;

        #10 input_data = {6{192'hB1B2B3B4B5B6B7B8B9BABBBCBDBEBF}}; valid_i = 1;
        #10 valid_i = 0;

        #10 input_data = {6{192'hC1C2C3C4C5C6C7C8C9CACBCCCDCECF}}; valid_i = 1;
        #10 valid_i = 0;

        #10 input_data = {6{192'hA1A2A3A4A5A6A7A8A9AAABACADAEAF}}; valid_i = 1;
        #10 valid_i = 0;

        #10 input_data = {6{192'hB1B2B3B4B5B6B7B8B9BABBBCBDBEBF}}; valid_i = 1;
        #10 valid_i = 0;

        #10 input_data = {6{192'hC1C2C3C4C5C6C7C8C9CACBCCCDCECF}}; valid_i = 1;
        #10 valid_i = 0;

        // Wait and observe outputs
        #30;
        
        // Additional test vectors can be added here
        // ...

        // Finish simulation
        #50 $finish;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time=%0t | resetn=%b | input_data=%h | output_1=%h | output_2=%h | output_3=%h | valid_i=%b | valid_o=%b", 
                 $time, resetn, input_data, output_1, output_2, output_3, valid_i, valid_o);
    end

endmodule