`timescale 1ns/1ps

module uart_top #()(
    uart_if.dut uif
);

    logic baud_tick;

    // Baud generator (match your module name!)
    baud_gen #(
        .CLK_FREQ_MHZ(uif.CLK_FREQ_MHZ),
        .BAUD_RATE(uif.BAUD_RATE)
    ) u_baud (
        .clk(uif.clk),      // ← matches interface clk
        .rst_n(uif.rst_n),  // ← matches rst_n
        .baud_tick(baud_tick)
    );

    // UART Transmitter (explicit ports to match YOUR interface names)
    uart_tx #(
        .DATA_BITS(uif.DATA_BITS)
    ) u_tx (
        .clk(uif.clk),
        .rst_n(uif.rst_n),
        .baud_tick(baud_tick),
        .send(uif.tx_send),     // ← tx_send from interface
        .data_in(uif.tx_data_in),   // ← tx_data_in from interface  
        .tx(uif.uart_tx),       // ← uart_tx from interface
        .busy(uif.tx_busy)      // ← tx_busy to interface
    );

    // UART Receiver (explicit ports)
    uart_rx #(
        .DATA_BITS(uif.DATA_BITS),
        .CLKS_PER_BIT((uif.CLK_FREQ_MHZ * 1000000) / uif.BAUD_RATE)
    ) u_rx (
        .clk(uif.clk),
        .rst_n(uif.rst_n),
        .baud_tick(baud_tick),
        .rx(uif.uart_rx),       // ← uart_rx from interface
        .rx_valid(uif.rx_valid), // ← rx_valid to interface
        .data_out(uif.rx_data_out),  // ← rx_data_out to interface
        .rx_state(uif.rx_state) // ← rx_state to interface
    );

endmodule
