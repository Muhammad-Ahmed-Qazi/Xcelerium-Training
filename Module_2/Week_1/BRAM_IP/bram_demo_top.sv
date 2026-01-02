module bram_demo_top (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        we,
    input  wire        re,
    input  wire [7:0]  addr,
    input  wire [7:0]  din,
    output reg  [7:0]  dout
);

    wire [7:0] ram_q;

    // BRAM IP instance
    ram_256x8 u_bram (
        .clock   (clk),
        .address (addr),
        .data    (din),
        .wren    (we),
        .rden    (re),
        .q       (ram_q)
    );

    // Output register (explicit pipeline stage)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= 8'd0;
        else
            dout <= ram_q;
    end

endmodule
