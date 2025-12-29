//------------------------------------------------------------------------------
// Module: adder_tree_multiplier
// Description:
//   Implements a 8x8 combinational multiplier using an adder-tree architecture.
//   Partial products are generated in parallel and reduced through staged
//   additions for improved performance.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-26
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

module adder_tree_multiplier_top #(
    parameter integer DATA_WIDTH = 8
)(
    input wire                     clk,
    input wire                     rst_n,

    // Input side
    input wire                     EA,     // Enable A register
    input wire                     EB,     // Enable B register
    input wire [DATA_WIDTH-1:0]    A_in,
    input wire [DATA_WIDTH-1:0]    B_in,

    // Output side
    output reg  [2*DATA_WIDTH-1:0]  P_out   
);

    // Input registers
    reg [DATA_WIDTH-1:0] A_reg;
    reg [DATA_WIDTH-1:0] B_reg;

    // Combinational multiplier output
    wire [2*DATA_WIDTH-1:0] product_wire;

    // Input registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg <= {DATA_WIDTH{1'b0}};
            B_reg <= {DATA_WIDTH{1'b0}};
        end else begin
            if (EA)
                A_reg <= A_in;
            if (EB)
                B_reg <= B_in;
        end
    end

    // Adder-tree multiplier instance
    adder_tree_multiplier #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_adder_tree_multiplier (
        .a(A_reg),
        .b(B_reg),
        .product(product_wire)
    );

    // Output register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            P_out <= {(2*DATA_WIDTH){1'b0}};
        end else begin
            P_out <= product_wire;
        end
    end

endmodule

module adder_tree_multiplier #(
    // Parameter declarations
    parameter integer DATA_WIDTH = 8
)(
    // Port declarations
    input  wire [DATA_WIDTH-1:0]    a,
    input  wire [DATA_WIDTH-1:0]    b,
    output wire [2*DATA_WIDTH-1:0]  product
);

    // Partial product (extended to 2N)
    wire [2*DATA_WIDTH-1:0] pp [DATA_WIDTH-1:0];

    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : GEN_PP
            assign pp[i] = b[i] ? ({{DATA_WIDTH{1'b0}}, a} << i)
                                : {2*DATA_WIDTH{1'b0}};

        end
    endgenerate

    // Product calculation using adder tree
    wire [2*DATA_WIDTH-1:0] sum_stage1 [((DATA_WIDTH+1)/2)-1:0];
    wire [2*DATA_WIDTH-1:0] sum_stage2 [((DATA_WIDTH+3)/4)-1:0];

    // First stage of addition
    assign sum_stage1[0] = pp[0] + pp[1];
    assign sum_stage1[1] = pp[2] + pp[3];
    assign sum_stage1[2] = pp[4] + pp[5];
    assign sum_stage1[3] = pp[6] + pp[7];

    // Second stage of addition
    assign sum_stage2[0] = sum_stage1[0] + sum_stage1[1];
    assign sum_stage2[1] = sum_stage1[2] + sum_stage1[3];

    // Final addition to get the product
    assign product = sum_stage2[0] + sum_stage2[1];

endmodule
