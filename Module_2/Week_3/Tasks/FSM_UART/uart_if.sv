interface uart_if #(
    parameter int DATA_BITS = 8,
    parameter int CLK_FREQ_MHZ = 50,
    parameter int BAUD_RATE = 9600
)(
    input logic clk,
    input logic rst_n
);

    // Physical serial wires
    logic uart_tx;
    logic uart_rx;

    // TX signals
    logic                   tx_send;
    logic [DATA_BITS-1:0]   tx_data_in;
    logic                   tx_busy;

    // RX signals
    logic                   rx_valid;
    logic [DATA_BITS-1:0]   rx_data_out;

    // FSM output for coverage
    logic [1:0]             rx_state;

    // MODPORTS
    modport dut (
        input clk, rst_n, tx_send, tx_data_in, uart_rx,
        output tx_busy, rx_valid, rx_data_out, uart_tx, rx_state
    );

    modport tx_master (
        input clk, rst_n, tx_busy,
        output tx_send, tx_data_in
    );

    modport rx_slave (
        input clk, rst_n,
        output rx_valid, rx_data_out, rx_state
    );

    modport pins (
        output uart_tx,
        input uart_rx
    );

    modport monitor (
        input clk, rst_n, tx_send, tx_data_in, tx_busy,
              rx_valid, rx_data_out, rx_state, uart_tx, uart_rx
    );

endinterface
