//------------------------------------------------------------------------------
// Module: array_multiplier
// Description:
//   Implements a NxN combinational array multiplier using shift-and-add
//   partial products. Partial products are accumulated sequentially through
//   a structured addition network.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-24
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

module array_multiplier_top #(
    parameter integer DATA_WIDTH = 8
)(
    input  wire                     clk,
    input  wire                     rst_n,

    // Input side
    input  wire                     EA,     // Enable A register
    input  wire                     EB,     // Enable B register
    input  wire [DATA_WIDTH-1:0]    A_in,
    input  wire [DATA_WIDTH-1:0]    B_in,

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

    // Array multiplier instance
    array_multiplier #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_array_multiplier (
        .a(A_reg),
        .b(B_reg),
        .product(product_wire)
    );

    // Output register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            P_out <= {2*DATA_WIDTH{1'b0}};
        else
            P_out <= product_wire;
    end

endmodule


module array_multiplier #(
    // Parameter declarations
    parameter integer DATA_WIDTH = 8
)(
    input   wire [DATA_WIDTH-1: 0]   a,
    input   wire [DATA_WIDTH-1: 0]   b,
    output  wire [2*DATA_WIDTH-1: 0] product
);

    // Partial products (extended to 2N bits)
    wire [2*DATA_WIDTH-1: 0] pp [DATA_WIDTH-1:0];

    // Sum between stages
    wire [2*DATA_WIDTH-1: 0] sum [DATA_WIDTH-1:0];
l
    genvar i;
    // Generate partial products
    generate
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : GEN_PP
            assign pp[i] = b[i] ? ({{DATA_WIDTH{1'b0}}, a} << i) : {2*DATA_WIDTH{1'b0}};
        end
    endgenerate

    // First sum is first partial product
    assign sum[0] = pp[0];

    // Add remaining partial products
    generate
        for (i = 1; i < DATA_WIDTH; i = i + 1) begin : GEN_SUM
            assign sum[i] = sum[i-1] + pp[i];
        end
    endgenerate

    // Final product output
    assign product = sum[DATA_WIDTH-1];

endmodule
