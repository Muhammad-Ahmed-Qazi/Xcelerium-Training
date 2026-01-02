`timescale 1ns/1ps

module tb_bram_demo;

    logic        clk;
    logic        rst_n;
    logic        we;
    logic        re;
    logic [7:0]  addr;
    logic [7:0]  din;
    logic [7:0]  dout;

    // DUT
    bram_demo_top dut (
        .clk  (clk),
        .rst_n(rst_n),
        .we   (we),
        .re   (re),
        .addr (addr),
        .din  (din),
        .dout (dout)
    );

    // Clock: 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        we    = 0;
        re    = 0;
        addr  = 0;
        din   = 0;

        #20 rst_n = 1;

        // WRITE cycle
        @(posedge clk);
        we   <= 1;
        addr <= 8'd10;
        din  <= 8'hA5;

        @(posedge clk);
        we <= 0;

        // READ cycle
        @(posedge clk);
        re   <= 1;
        addr <= 8'd10;

        repeat (4) @(posedge clk);
		  //repeat (4) @(posedge clk) begin
				//$display("READ DATA = %h (expected A5)", dout);
		  // end
		  $display("READ DATA = %h (expected A5)", dout);
		  
        #20 $finish;
    end

endmodule
