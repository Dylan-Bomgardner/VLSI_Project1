/* Variable Gain Amplifier with Automatic Gain Control */

module vga_agc(
    input logic unsigned [7:0] wave_raw,
    input logic clk,
    input logic [7:0] volume_raw,
    output logic unsigned [7:0] wave_out,
);
    logic unsigned [7:0] peak_raw;
    peak_detect(wave_raw, clk, peak_raw);
    scale_wave(wave_raw, peak_raw, volume_raw, wave_out);
endmodule

module peak_detect (
    input unsigned logic [7:0] wave_raw,
    input logic clk,
    output logic peak_raw
);
    logic slope_is_positive;
    logic unsigned [7:0] prev_wave;

    always_ff(@posedge clk) begin
        // check if 
        if (wave > prev_wave) begin
            slope_is_positive <= 1;
        end
        else begin
            // We have reached a peak (top)
            // Update Peak
            if (slope_is_positive) begin
                peak <= wave;
            end
            slope_is_positive <= 0;
        end

        prev_wave <= wave;
    end
endmodule

module scale_wave (
    input logic unsigned [7:0] wave_raw,
    input logic unsigned [7:0] peak_raw,
    input logic unsigned [7:0] volume_raw,
    output logic unsigned [7:0] wave_out
);
const logic [7:0] wave_half_point = 128;

// Shouldn't be too costly since it is a div by 2
logic [7:0] volume_scaled = volume_raw / 2;

always_ff(@posedge(clk)) begin
    wave_out = ((wave_raw - wave_half_point) * volume_scaled ) / (peak_raw - wave_half_point);
end

endmodule