/* verilator lint_off WIDTHEXPAND */

module uart_tx #(
    parameter int DATA_BITS = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  baud_tick,
    input  logic                  send,
    input  logic [DATA_BITS-1:0]  data_in,
    output logic                  tx,
    output logic                  busy
);

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    logic [DATA_BITS-1:0]         shift_reg;
    logic [$clog2(DATA_BITS)-1:0] bit_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            shift_reg <= '0;
            bit_cnt   <= '0;
        end else begin
            case (state)

                IDLE: begin
                    if (send) begin
                        shift_reg <= data_in;
                        bit_cnt   <= '0;
                        state     <= START;
                    end
                end

                START: begin
                    if (baud_tick)
                        state <= DATA;
                end

                DATA: begin
                    if (baud_tick) begin
                        shift_reg <= {1'b1, shift_reg[DATA_BITS-1:1]};
                        if (bit_cnt == DATA_BITS-1)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1;
                    end
                end

                STOP: begin
                    if (baud_tick)
                        state <= IDLE;
                end

            endcase
        end
    end

    // Outputs
    always_comb begin
        tx   = 1'b1;
        busy = (state != IDLE);

        case (state)
            START: tx = 1'b0;
            DATA:  tx = shift_reg[0];
            STOP:  tx = 1'b1;
            default: tx = 1'b1;
        endcase
    end

endmodule
