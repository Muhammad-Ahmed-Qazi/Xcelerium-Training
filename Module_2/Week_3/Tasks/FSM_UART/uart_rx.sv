/* verilator lint_off WIDTHEXPAND */

module uart_rx #(
    parameter int DATA_BITS = 8
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    baud_tick,
    input  logic                    rx,
    output logic                    rx_valid,
    output logic [DATA_BITS-1:0]    data_out,
    // FSM state outputs for coverage (Verilator-safe)
    output logic [1:0]              rx_state
);

    typedef enum logic [1:0] {
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3
    } state_t;

    state_t current_state, next_state;
    logic [DATA_BITS-1:0] shift_reg;
    logic [$clog2(DATA_BITS)-1:0] bit_count;
    logic rx_sync0, rx_sync1;
    logic rx_synced;
    logic start_edge;

    // Synchronise async rx input
    always_ff @(posedge clk) begin
        rx_sync0 <= rx;
        rx_sync1 <= rx_sync0;
    end
    assign rx_synced = rx_sync1;

    // Start bit edge detection
    assign start_edge = (rx_synced == 1'b0) && (rx_sync0 == 1'b1);

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            bit_count <= '0;
            shift_reg <= '0;
        end else begin
            current_state <= next_state;

            if (next_state == DATA && current_state == START)
                shift_reg <= '0;
            else if (next_state == DATA && baud_tick) begin
                shift_reg <= {shift_reg[DATA_BITS-2:0], rx_synced};
                if (bit_count == DATA_BITS - 1)
                    bit_count <= '0;
                else
                    bit_count <= bit_count + 1;
            end else
                bit_count <= '0;
        end
    end

    // Combinational next state and output
    always_comb begin
        next_state = current_state;
        rx_valid = 1'b0;
        data_out = shift_reg;

        unique case (current_state)
            IDLE:  if (start_edge) next_state = START;
            START: if (baud_tick) begin
                       if (rx_synced == 1'b0) next_state = DATA;
                       else next_state = IDLE; // False start
                   end
            DATA:  if (baud_tick && (bit_count == DATA_BITS - 1)) next_state = STOP;
            STOP:  if (baud_tick) begin
                       if (rx_synced == 1'b1) begin
                           next_state = IDLE;
                           rx_valid = 1'b1;
                       end else next_state = IDLE; // Framing error
                   end
            default: next_state = IDLE;
        endcase
    end

    // FSM state output for Verilator-safe coverage
    assign rx_state = current_state;

endmodule
