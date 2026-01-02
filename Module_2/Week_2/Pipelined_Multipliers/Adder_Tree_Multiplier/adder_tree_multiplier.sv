//------------------------------------------------------------------------------
// Module: adder_tree_multiplier
// Description:
//   Implements a 8x8 pipelined combinational multiplier using an adder-tree architecture.
//   Partial products are generated in parallel and reduced through staged additions.
//   2-stage pipeline is employed for improved throughput.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2026-01-02
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

module adder_tree_multiplier #(
    // Parameter declarations
    parameter integer DATA_WIDTH = 8
)(
    // Port declarations


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
    // Partial product (extended to 2N)
    wire [2*DATA_WIDTH-1:0] pp [DATA_WIDTH-1:0];

    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : GEN_PP
            assign pp[i] = b_reg[i] ? ({{DATA_WIDTH{1'b0}}, a_reg} << i)
                                    : {2*DATA_WIDTH{1'b0}};

        end
    endgenerate

    // ============================================================
    // Stage 1: First level of addition
    // ============================================================
    wire [2*DATA_WIDTH-1:0] sum_stage1 [((DATA_WIDTH+1)/2)-1:0];

    assign sum_stage1[0] = pp[0] + pp[1];
    assign sum_stage1[1] = pp[2] + pp[3];
    assign sum_stage1[2] = pp[4] + pp[5];
    assign sum_stage1[3] = pp[6] + pp[7];

    // ============================================================
    // Pipeline registers: sum_mid, valid_mid
    // ============================================================
    reg [2*DATA_WIDTH-1:0] sum_mid [((DATA_WIDTH+1)/2)-1:0];
    reg                    valid_mid;
    reg                    valid_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_mid[0] <= '0;
            sum_mid[1] <= '0;
            sum_mid[2] <= '0;
            sum_mid[3] <= '0;
            valid_mid  <= 1'b0;
            valid_out  <= 1'b0;
        end else begin
            sum_mid[0] <= sum_stage1[0];
            sum_mid[1] <= sum_stage1[1];
            sum_mid[2] <= sum_stage1[2];
            sum_mid[3] <= sum_stage1[3];
            valid_mid  <= start;
            valid_out  <= valid_mid;
        end
    end

    // ============================================================
    // Stage 2: Second level of addition
    // ============================================================
    wire [2*DATA_WIDTH-1:0] sum_stage2 [((DATA_WIDTH+3)/4)-1:0];

    assign sum_stage2[0] = sum_mid[0] + sum_mid[1];
    assign sum_stage2[1] = sum_mid[2] + sum_mid[3];

    // ============================================================
    // Output registers
    // ============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            P_out       <= '0;
            P_out_valid <= 1'b0;
        end else begin
            P_out       <= sum_stage2[0] + sum_stage2[1];
            P_out_valid <= valid_out;
        end
    end

endmodule
