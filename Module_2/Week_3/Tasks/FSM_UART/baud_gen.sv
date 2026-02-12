/* verilator lint_off WIDTHEXPAND */

module baud_gen #(
    parameter int unsigned CLK_FREQ_MHZ = 50,
    parameter int unsigned BAUD_RATE     = 9600
)(
    input logic clk,
    input logic rst_n,
    output logic baud_tick
);

    localparam int unsigned CLKS_PER_BIT = (CLK_FREQ_MHZ * 1000000) / BAUD_RATE;
    localparam int unsigned CNT_WIDTH = $clog2(CLKS_PER_BIT + 1);

    logic [CNT_WIDTH-1:0] cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt       <= '0;
            baud_tick <= 1'b0;
        end else begin
            if (cnt == CLKS_PER_BIT - 1) begin
                cnt       <= '0;
                baud_tick <= 1'b1;
            end else begin
                cnt       <= cnt + 1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule
