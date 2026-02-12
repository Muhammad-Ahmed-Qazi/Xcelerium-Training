module video_pattern (
    input  logic [10:0] pixel_x,
    input  logic [9:0]  pixel_y,
    input  logic        video_on,

    output logic [3:0]  red,
    output logic [3:0]  green,
    output logic [3:0]  blue
);
    // ─────────────────────────────────────
    // RGB Pattern Generator
    // ─────────────────────────────────────

    always_comb begin
        if (video_on) begin
            // Example: vertical colour bands (screen divided into thirds)
            if (pixel_x < 341) begin
                red   = 4'hF;
                green = 4'h0;
                blue  = 4'h0;
            end else if (pixel_x < 682) begin
                red   = 4'h0;
                green = 4'hF;
                blue  = 4'h0;
            end else begin
                red   = 4'h0;
                green = 4'h0;
                blue  = 4'hF;
            end
        end else begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h0;
        end
    end

endmodule
