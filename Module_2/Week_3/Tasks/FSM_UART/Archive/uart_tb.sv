`timescale 1ns/1ps
`default_nettype none

module uart_tb;

    parameter time CLK_PERIOD = 20ns;
    parameter int  CLK_FREQ_MHZ = 50;
    parameter int  BAUD_RATE = 9600;
    parameter int  DATA_BITS = 8;

    logic clk, rst_n;

    uart_if #(
        .DATA_BITS(DATA_BITS),
        .CLK_FREQ_MHZ(CLK_FREQ_MHZ),
        .BAUD_RATE(BAUD_RATE)
    ) uif (
        .clk(clk),
        .rst_n(rst_n)
    );

    uart_top dut (uif.dut);

    // Clock
    always #(CLK_PERIOD/2) clk <= ~clk;

    // Loopback
    assign uif.uart_rx = uif.uart_tx;

    // Synchronous send task (TX only)
    task automatic send_byte(input logic [7:0] data);
        @(posedge clk);
        uif.tx_data_in = data;
        uif.tx_send    = 1'b1;
        @(posedge clk);
        uif.tx_send    = 1'b0;
    endtask

    // RX wait task
    task automatic wait_rx(output logic [7:0] data);
        @(posedge uif.rx_valid);
        data = uif.rx_data_out;
    endtask

    logic [7:0] rx_byte;

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(2, uart_tb);

        clk = 0;
        rst_n = 0;
        uif.tx_send = 0;
        uif.tx_data_in = '0;

        #200;
        rst_n = 1;

        $display("[%0t] RESET RELEASED", $time);

        // TX and RX must run in parallel
        fork
            begin
                send_byte(8'hAA);
            end

            begin
                wait_rx(rx_byte);
                $display("[%0t] RX VALID: 0x%02h", $time, rx_byte);

                if (rx_byte !== 8'hAA) begin
                    $error("RX DATA MISMATCH");
                    $fatal;
                end
            end
        join

        #1ms;
        $display("TEST PASSED");
        $finish;
    end

    // Proper timeout
    initial begin
        #20ms;
        $display("ERROR: SIMULATION TIMEOUT");
        $fatal;
    end

endmodule
