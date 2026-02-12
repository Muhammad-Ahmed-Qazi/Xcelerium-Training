`timescale 1ns/1ps
`default_nettype none

`include "uart_if.sv"
import uart_tb_pkg::*;

module uart_tb;

    logic clk, rst_n;
    parameter DATA_BITS = 8;
    parameter CLK_FREQ_MHZ = 50;
    parameter BAUD_RATE = 9600;
    parameter CLK_PERIOD = 20ns;

    // Interface
    uart_if #(DATA_BITS, CLK_FREQ_MHZ, BAUD_RATE) uif(.clk(clk), .rst_n(rst_n));

    // DUT
    uart_top dut(uif.dut);

    // Clock
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Reset
    initial begin
        rst_n = 0;
        #200;
        rst_n = 1;
        $display("[%0t] RESET RELEASED", $time);
    end

    // mailboxes
    mailbox #(UART_Transaction) tx_mbx = new();
    mailbox #(UART_Transaction) rx_mbx = new();

    // class handles
    UART_Generator gen;
    UART_Driver   drv;
    UART_Monitor  mon;
    UART_Scoreboard sb;

    initial begin
        // construct classes
        gen = new(tx_mbx);
        drv = new(uif.dut, tx_mbx);
        mon = new(uif.dut, rx_mbx);
        sb  = new(rx_mbx, tx_mbx);

        // start tasks
        fork
            gen.run();
            drv.run();
            mon.run();
            sb.run();
        join_none;
    end

    // Timeout
    initial #20ms $fatal("SIMULATION TIMEOUT");

endmodule
