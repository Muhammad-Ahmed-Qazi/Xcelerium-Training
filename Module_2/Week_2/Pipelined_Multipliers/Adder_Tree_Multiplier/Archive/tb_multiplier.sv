/* verilator lint_off UNUSEDSIGNAL */
module tb_multiplier();

    // =========================================================================
    // SIGNAL DECLARATIONS
    // =========================================================================
    logic                  clk;
    logic                  rst_n;
    logic [7:0]            A_in;
    logic [7:0]            B_in;
    logic                  EA;
    logic                  EB;
    logic                  start;
    logic [15:0]           P_out;
    logic                  P_out_valid;
    
    // Scoreboard signals
    logic [15:0]           expected;
    logic [15:0]           p_val;
    logic [7:0]            a_val, b_val;
    
    // =========================================================================
    // QUEUE DECLARATIONS
    // =========================================================================
    logic [7:0] A_queue [$];
    logic [7:0] B_queue [$];
    
    // =========================================================================
    // PRINTING WAVEFORM
    // =========================================================================
    initial begin
        $dumpfile("tb_multiplier.vcd");
        $dumpvars(0, tb_multiplier);
    end
    
    // =========================================================================
    // DUT INSTANTIATION
    // =========================================================================
    `ifdef ARRAY_MULT
        array_multiplier #(
            .DATA_WIDTH(8)
        ) dut (
            .clk(clk),
            .rst_n(rst_n),
            .EA(EA),
            .EB(EB),
            .start(start),
            .A_in(A_in),
            .B_in(B_in),
            .P_out(P_out),
            .P_out_valid(P_out_valid)
        );
    `else
        adder_tree_multiplier #(
            .DATA_WIDTH(8)
        ) dut (
            .clk(clk),
            .rst_n(rst_n),
            .EA(EA),
            .EB(EB),
            .start(start),
            .A_in(A_in),
            .B_in(B_in),
            .P_out(P_out),
            .P_out_valid(P_out_valid)
        );
    `endif

    
    // =========================================================================
    // CLOCK GENERATION
    // =========================================================================
    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // 10ns period
    end
    
    // =========================================================================
    // RESET SEQUENCE
    // =========================================================================
    initial begin
        rst_n = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;
    end
    
    // =========================================================================
    // DRIVER PROCESS (Stimulus Application)
    // =========================================================================
    initial begin
        // Wait for reset to deassert
        @(posedge rst_n);
        
        // Test Vector 1: 10 * 15 = 150
        A_in = 8'd10;
        B_in = 8'd15;
        EA = 1;
        EB = 1;
        start = 1;
        A_queue.push_back(A_in);
        B_queue.push_back(B_in);
        @(negedge clk);
        EA = 0;
        EB = 0;
        start = 0;
        @(posedge clk);
        
        // Test Vector 2: 0 * 255 = 0 (boundary condition)
        A_in = 8'd0;
        B_in = 8'd255;
        EA = 1;
        EB = 1;
        start = 1;
        A_queue.push_back(A_in);
        B_queue.push_back(B_in);
        @(negedge clk);
        EA = 0;
        EB = 0;
        start = 0;
        @(posedge clk);
        
        // Test Vector 3: 255 * 255 = 65025 (max boundary)
        A_in = 8'd255;
        B_in = 8'd255;
        EA = 1;
        EB = 1;
        start = 1;
        A_queue.push_back(A_in);
        B_queue.push_back(B_in);
        @(negedge clk);
        EA = 0;
        EB = 0;
        start = 0;
        @(posedge clk);
        
        // Test Vector 4: 128 * 128 = 16384 (power of 2)
        A_in = 8'd128;
        B_in = 8'd128;
        EA = 1;
        EB = 1;
        start = 1;
        A_queue.push_back(A_in);
        B_queue.push_back(B_in);
        @(negedge clk);
        EA = 0;
        EB = 0;
        start = 0;
        @(posedge clk);
        
        // Signal end of test
        #100;
        $finish;
    end
    
    // =========================================================================
    // SCOREBOARD PROCESS (Self-Checking)
    // =========================================================================
    initial begin
        integer test_num = 0;

        // Wait for reset to deassert
        @(posedge rst_n);

        // Optional: let pipeline settle for a bit
        repeat (1) @(posedge clk);

        forever begin
            @(posedge clk);  // sample on clock edge

            // Only check when DUT says output is valid
            if (P_out_valid) begin
                if (A_queue.size() > 0 && B_queue.size() > 0) begin
                    // Pop corresponding input operands
                    a_val = A_queue.pop_front();
                    b_val = B_queue.pop_front();

                    // Compute expected result
                    expected = a_val * b_val;

                    // Sample DUT output
                    p_val = P_out;

                    // Compare and log
                    test_num = test_num + 1;
                    if (p_val == expected) begin
                        $display("[PASS] Test %0d: A=%3d, B=%3d | Expected=%5d, Got=%5d",
                                 test_num, a_val, b_val, expected, p_val);
                    end else begin
                        $display("[FAIL] Test %0d: A=%3d, B=%3d | Expected=%5d, Got=%5d",
                                 test_num, a_val, b_val, expected, p_val);
                    end
                end else begin
                    // No operands queued but DUT claims valid output
                    $display("[WARN] P_out_valid asserted but no queued inputs remain. P_out=%0d",
                             P_out);
                end
            end
        end
    end

    
endmodule
