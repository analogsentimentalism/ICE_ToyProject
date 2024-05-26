`timescale 1ns / 1ps

module tb_cnn_top();

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns
    parameter RESET_DURATION = 50; // Reset duration in ns

    // Inputs
    reg clk;
    reg resetn;
    reg [1*24*8-1:0] input_data;
    reg buffer_1_valid_i;

    // Outputs
    wire [8*7-1:0] dense_out;
    wire dense_valid;

    // Instantiate the Unit Under Test (UUT)
    cnn_top uut (
        .clk(clk),
        .resetn(resetn),
        .input_data(input_data),
        .buffer_1_valid_i(buffer_1_valid_i),
        .dense_out(dense_out),
        .dense_valid(dense_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        resetn = 0;
        input_data = 0;
        buffer_1_valid_i = 0;

        // Apply reset
        #(RESET_DURATION);
        resetn = 1;

        // Apply test vectors
        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1717121A1B0801081E292D2F30312E2A2416040110001633;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1314131C0E010A222C303132333232302D27190A0A08012D;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h161218180104202B30313131323231312F2B24160C100120;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h17131A0C0816282E3030313132323232302D292012110108;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1616180A12202D313131313132323332312F2A2317110101;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1515141319262B2F30302F2E30312F2D2F302D261A100101;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h16161119202A2B2A2C2B2C2A2B2B2B2C2E302F2A20100401;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
        // Apply test vectors
        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1515101C1C2729252523282A25201F1F292C2827260A0401;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h21130E19242C2A1E1417262B2315141821252A29290E110A;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h2E120A1A190E080E10192B332B1C1818140E152529180E18;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h30120A181A1C2022252A3036302A26242122282B291D1D1C;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h33220C1E282A2A2B2D313236312F302E2E2F2F2E2C20271E;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h352918222D30303131303236322F31323231302F2D25292B;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h362F2D2B2E303232322F333634302F323231302E2B292B33;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
        // Apply test vectors
        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h342E2C2D303031323130323333312F3030302E2C2A273033;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h291C242C2F303030302C2229271A2B302F2D2C2B29182E33;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1C14012A2E302F30323024201F242E312F2D2C2A280C2029;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1D1604252E2F2F3031302C26242A2E302F2D2B2B2504191E;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h1D15041D2D2E2E2E2C2C2C29282A28282A2B2B2A1F010413;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h21180E172A2C2C2C2B2D2A29262A2F2F2A2A292912010101;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
                #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h303031302E2929292E302F29272A2D2C2A2526281811262E;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
                        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h35353536342A26272622211C1C1C1C212423262B31313232;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
                        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h35363635342F272528272322232222242424272B31313131;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
                        #(CLK_PERIOD);
        buffer_1_valid_i = 1;
        input_data = 192'h3636363533302C2626292523252322242423272A30313131;
        #(CLK_PERIOD);
        buffer_1_valid_i = 0;
        // Wait for outputs
        #(10000*CLK_PERIOD);
        
        
        
        // Check results
        if (dense_valid) begin
            $display("Test Passed: Dense output is valid.");
            $display("Dense Output: %h", dense_out);
        end else begin
            $display("Test Failed: Dense output is not valid.");
        end

        // Finish simulation
        #(10*CLK_PERIOD);
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("At time %t, clk = %b, resetn = %b, buffer_1_valid_i = %b, dense_out = %h, dense_valid = %b",
                 $time, clk, resetn, buffer_1_valid_i, dense_out, dense_valid);
    end

endmodule