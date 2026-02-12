module fsm_vsync (
    input  logic        clk,
    input  logic        reset,
    input  logic        line_done,         // 1 cycle pulse from HSYNC controller

    output logic [9:0]  pixel_y,           // Vertical line number
    output logic        vsync,
    output logic        video_on_v,
    output logic        frame_done         // Optional: high when pixel_y rolls over
);

    // ─────────────────────────────────────
    // State Encoding
    // ─────────────────────────────────────
    typedef enum logic [1:0] {
        V0      = 2'd0,
        V1      = 2'd1,
        V2      = 2'd2,
        V3      = 2'd3
    } state_t;

    state_t state, next_state;

    // ─────────────────────────────────────
    // Vertical Line Counter (0 to 805)
    // ─────────────────────────────────────
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pixel_y <= 10'd0;
        else if (line_done) begin
            if (pixel_y == 10'd805)
                pixel_y <= 10'd0;
            else
                pixel_y <= pixel_y + 1;
        end
    end

    // ─────────────────────────────────────
    // ROM for Vertical Timing Boundaries
    // ─────────────────────────────────────
    logic [9:0] vsync_rom [0:3];

    initial begin
        vsync_rom[0] = 10'd767;   // End of visible
        vsync_rom[1] = 10'd770;   // End of front porch
        vsync_rom[2] = 10'd776;   // End of sync
        vsync_rom[3] = 10'd805;   // End of back porch
    end

    // ─────────────────────────────────────
    // FSM State Register
    // ─────────────────────────────────────
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= V0;
        else if (line_done)
            state <= next_state;
    end

    // ─────────────────────────────────────
    // FSM Next-State Logic
    // ─────────────────────────────────────
    always_comb begin
        next_state = state;
        case (state)
            V0:      if (pixel_y == vsync_rom[0]) next_state = V1;
            V1:      if (pixel_y == vsync_rom[1]) next_state = V2;
            V2:      if (pixel_y == vsync_rom[2]) next_state = V3;
            V3:      if (pixel_y == vsync_rom[3]) next_state = V0;
        endcase
    end

    // ─────────────────────────────────────
    // Output Logic
    // ─────────────────────────────────────
    assign video_on_v = (state == V0);
    assign vsync      = (state == V2) ? 1'b0 : 1'b1;  // active-low

    // Optional frame_done signal (1 clock pulse at end of frame)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            frame_done <= 1'b0;
        else
            frame_done <= (state == V3 && pixel_y == vsync_rom[3] && line_done);
    end

endmodule
