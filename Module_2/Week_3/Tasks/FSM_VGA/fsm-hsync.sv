module fsm_hsync (
    input  logic        clk,
    input  logic        reset,
    output logic [10:0] pixel_x,
    output logic        hsync,
    output logic        video_on_h,
    output logic        line_done
);

    // ─────────────────────────────────────
    // Parameters and State Encoding
    // ─────────────────────────────────────
    typedef enum logic [1:0] {
        H0      = 2'd0,
        H1      = 2'd1,
        H2      = 2'd2,
        H3      = 2'd3
    } state_t;

    state_t state, next_state;

    // ─────────────────────────────────────
    // Pixel Counter (0 to 1343)
    // ─────────────────────────────────────
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pixel_x <= 11'd0;
        else if (pixel_x == 11'd1343)
            pixel_x <= 11'd0;
        else
            pixel_x <= pixel_x + 1;
    end

    // ─────────────────────────────────────
    // Horizontal Timing ROM
    // Stores pixel_x end values for each state
    // ─────────────────────────────────────
    logic [10:0] hsync_rom [0:3];

    initial begin
        hsync_rom[0] = 11'd1023;   // End of visible
        hsync_rom[1] = 11'd1047;   // End of front porch
        hsync_rom[2] = 11'd1183;   // End of sync
        hsync_rom[3] = 11'd1343;   // End of back porch
    end

    // ─────────────────────────────────────
    // FSM State Register
    // ─────────────────────────────────────
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= H0;
        else
            state <= next_state;
    end

    // ─────────────────────────────────────
    // FSM Next-State Logic
    // ─────────────────────────────────────
    always_comb begin
        next_state = state;
        case (state)
            H0:      if (pixel_x == hsync_rom[0]) next_state = H1;
            H1:      if (pixel_x == hsync_rom[1]) next_state = H2;
            H2:      if (pixel_x == hsync_rom[2]) next_state = H3;
            H3:      if (pixel_x == hsync_rom[3]) next_state = H0;
        endcase
    end

    // ─────────────────────────────────────
    // Output Logic (Moore-style)
    // ─────────────────────────────────────
    assign video_on_h = (state == H0);
    assign hsync      = (state == H2) ? 1'b0 : 1'b1; // Active-low sync

    // line_done: High for 1 cycle at end of back porch (S3 to S0)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            line_done <= 1'b0;
        else
            line_done <= (state == H3 && pixel_x == hsync_rom[3]);
    end

endmodule
