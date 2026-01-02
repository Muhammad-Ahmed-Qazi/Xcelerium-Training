//------------------------------------------------------------------------------
// Module: array_multiplier
// Description:
//   Implements a NxN pipelined combinational multiplier using an array multiplier architecture.
//   Partial products are generated and reduced through adders. 2-stage pipeline is
//   employed for improved throughput.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2026-01-01
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

module array_multiplier #(
    // Parameter declarations
    parameter int DATA_WIDTH = 8
) (
    // Port declarations
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire                     EA,
    input  wire                     EB,
    input  wire                     start,
    input  wire [DATA_WIDTH-1:0]    A_in,
    input  wire [DATA_WIDTH-1:0]    B_in,

    output reg  [2*DATA_WIDTH-1:0]  P_out,
    output reg                      P_out_valid
);

    localparam int SPLIT = DATA_WIDTH / 2;
    localparam int HI_PP = DATA_WIDTH - SPLIT;

    // ============================================================
    // Input registers
    // ============================================================
    reg [DATA_WIDTH-1:0] a_reg;
    reg [DATA_WIDTH-1:0] b_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= '0;
            b_reg <= '0;
        end else begin
            if (EA) a_reg <= A_in;
            if (EB) b_reg <= B_in;
        end
    end

    // ============================================================
    // Partial products (combinational)
    // ============================================================
    wire [2*DATA_WIDTH-1:0] pp [0:DATA_WIDTH-1];

    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : GEN_PP
            assign pp[i] = b_reg[i]
                         ? ({{DATA_WIDTH{1'b0}}, a_reg} << i)
                         : '0;
        end
    endgenerate

    // ============================================================
    // Stage 1: accumulate lower half (0 .. SPLIT-1)
    // ============================================================
    wire [2*DATA_WIDTH-1:0] sum_stage1 [0:SPLIT-1];

    assign sum_stage1[0] = pp[0];

    generate
        for (i = 1; i < SPLIT; i = i + 1) begin : GEN_SUM1
            assign sum_stage1[i] = sum_stage1[i-1] + pp[i];
        end
    endgenerate

    // ============================================================
    // Pipeline registers: sum_mid, upper partial products, valid
    // ============================================================
    reg [2*DATA_WIDTH-1:0] pp_hi   [0:HI_PP-1];
    reg [2*DATA_WIDTH-1:0] sum_mid;
    reg                    v_mid;
    reg                    v_out;

    integer j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_mid <= '0;
            v_mid   <= 1'b0;
            v_out   <= 1'b0;
            for (j = 0; j < HI_PP; j = j + 1)
                pp_hi[j] <= '0;
        end else begin
            sum_mid <= sum_stage1[SPLIT-1];
            v_mid   <= start;
            v_out   <= v_mid;
            for (j = 0; j < HI_PP; j = j + 1)
                pp_hi[j] <= pp[SPLIT + j];
        end
    end

    // ============================================================
    // Stage 2: accumulate upper half (SPLIT .. DATA_WIDTH-1)
    // ============================================================
    wire [2*DATA_WIDTH-1:0] sum_stage2 [0:HI_PP-1];

    assign sum_stage2[0] = sum_mid + pp_hi[0];

    generate
        for (i = 1; i < HI_PP; i = i + 1) begin : GEN_SUM2
            assign sum_stage2[i] = sum_stage2[i-1] + pp_hi[i];
        end
    endgenerate

    // ============================================================
    // Output register
    // ============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            P_out       <= '0;
            P_out_valid <= 1'b0;
        end else begin
            P_out       <= sum_stage2[HI_PP-1];
            P_out_valid <= v_out;
        end
    end

endmodule
