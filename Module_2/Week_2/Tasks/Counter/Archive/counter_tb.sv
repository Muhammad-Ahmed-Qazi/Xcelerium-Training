module counter_tb;

    reg        clk;
    reg        rst_n;
    reg        en;
    reg        up_dn;
    wire [15:0] count;

    // DUT instantiation
    counter #(.COUNT_WIDTH(16)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),module counter_tb;

    reg        clk;
    reg        rst_n;
    reg        en;
    reg        up_dn;
    wire [15:0] count;

    // DUT instantiation
    counter #(.COUNT_WIDTH(16)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .up_dn (up_dn),
        .count (count)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk   = 0;
        rst_n = 0;
        en    = 0;
        up_dn = 1;

        // Apply reset
        #12;
        rst_n = 1;
        $display("Reset released: count = %0d (expected 0)", count);

        // Count up
        en = 1;
        up_dn = 1;
        repeat (5) @(posedge clk);
        $display("After counting up: count = %0d (expected 5)", count);

        // Hold value
        en = 0;
        repeat (3) @(posedge clk);
        $display("Hold test: count = %0d (expected 5)", count);

        // Count down
        en = 1;
        up_dn = 0;
        repeat (3) @(posedge clk);
        $display("After counting down: count = %0d (expected 2)", count);

        // Wrap-around test
        @(posedge clk);
        count_force_test();

        $display("Counter testbench completed.");
        $finish;
    end

    task count_force_test;
        begin
            // Force counter near zero and decrement
            force dut.count = 16'd0;
            @(posedge clk);
            release dut.count;
            $display("Wrap-around test: count = %0d (expected 65535)", count);
        end
    endtask

endmodule

        .up_dn (up_dn),
        .count (count)
    );

    // Printing waveform
    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);
    end

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk   = 0;
        rst_n = 0;
        en    = 0;
        up_dn = 1;

        // Apply reset
        #12;
        rst_n = 1;
        $display("Reset released: count = %0d (expected 0)", count);

        // Count up
        en = 1;
        up_dn = 1;
        repeat (5) @(posedge clk);
        $display("After counting up: count = %0d (expected 5)", count);

        // Hold value
        en = 0;
        repeat (3) @(posedge clk);
        $display("Hold test: count = %0d (expected 5)", count);

        // Count down
        en = 1;
        up_dn = 0;
        repeat (3) @(posedge clk);
        $display("After counting down: count = %0d (expected 2)", count);

        // Wrap-around test
        @(posedge clk);
        count_force_test();

        $display("Counter testbench completed.");
        $finish;
    end

    task count_force_test;
        begin
            // Force counter near zero and decrement
            force dut.count = 16'd0;
            @(posedge clk);
            release dut.count;
            $display("Wrap-around test: count = %0d (expected 65535)", count);
        end
    endtask

endmodule
