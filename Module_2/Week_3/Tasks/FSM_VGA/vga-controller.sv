module vga_controller (
    input  logic clk_50mhz,    // 50 MHz reference clock
    input  logic raw_reset,        // external reset (active high)
    output logic [10:0] pixel_x,
    output logic [9:0]  pixel_y,
    output logic hsync, vsync, video_on,
    output logic [3:0] red, green, blue,
    output logic clk_65mhz
);

    // ─────────────────────────────────────
    // Intermediate Signals
    // ─────────────────────────────────────
    logic video_on_h, video_on_v;
    logic line_done;

    // Reset logic
    logic reset;
    assign reset = ~raw_reset; // pressed = 1, released = 0

    // PLL outputs
    logic pix_clk;
    logic pll_locked;

    // Instantiate the PLL
    vga_pll pll_inst (
        .refclk    (clk_50mhz),
        .rst       (1'b0),       // PLL reset tied low
        .outclk_0  (pix_clk),    // Pixel clock output
        .locked    (pll_locked)  // Lock status
    );

    // Internal reset logic: hold VGA in reset until PLL locks
    logic internal_reset;
    assign internal_reset = reset | ~pll_locked;

    // ─────────────────────────────────────
    // HSYNC Controller Instance
    // ─────────────────────────────────────
    fsm_hsync hsync_inst (
        .clk        (pix_clk),
        .reset      (internal_reset),
        .pixel_x    (pixel_x),
        .hsync      (hsync),
        .video_on_h (video_on_h),
        .line_done  (line_done)
    );

    // ─────────────────────────────────────
    // VSYNC Controller Instance
    // ─────────────────────────────────────
    fsm_vsync vsync_inst (
        .clk        (pix_clk),
        .reset      (internal_reset),
        .line_done  (line_done),
        .pixel_y    (pixel_y),
        .vsync      (vsync),
        .video_on_v (video_on_v)
    );
	 
	 // ─────────────────────────────────────
	 // Instantiate RGB pattern generator
    // ─────────────────────────────────────
	 video_pattern pattern_inst (
		.pixel_x  (pixel_x),
		.pixel_y  (pixel_y),
		.video_on (video_on),
		.red      (red),
		.green    (green),
		.blue     (blue)
    );
	 
    // ─────────────────────────────────────
    // Final Output Logic
    // ─────────────────────────────────────
    assign video_on = video_on_h && video_on_v;

	 
endmodule