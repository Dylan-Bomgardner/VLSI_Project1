/* Variable Gain Amplifier with Automatic Gain Control */
`timescale 1ns/1ps
module vga_agc(
    input logic unsigned [7:0] wave_raw,
    input logic clk,
    input logic [7:0] volume_raw,
    output logic unsigned [7:0] wave_out
);
    logic unsigned [7:0] peak_raw;
    peak_detect peak (wave_raw, clk, peak_raw);
    scale_wave scale (wave_raw, peak_raw, volume_raw, clk, wave_out);
endmodule

`timescale 1ns/1ps
module peak_detect (
    input logic unsigned [7:0] wave_raw,
    input logic clk,
    output logic unsigned [7:0] peak_raw
);
    logic slope_is_positive;
    logic unsigned [7:0] prev_wave;

    always_ff @(posedge clk) begin
        // check if 
        if (wave_raw > prev_wave) begin
            slope_is_positive <= 1;
        end
        else if (wave_raw < prev_wave ) begin
            // We have reached a peak (top)
            // Update Peak
            if (slope_is_positive) begin
                peak_raw <= prev_wave;
            end
            slope_is_positive <= 0;
        end

        prev_wave <= wave_raw;
    end
endmodule

`timescale 1ns/1ps
module scale_wave (
    input logic unsigned [7:0] wave_raw,
    input logic unsigned [7:0] peak_raw,
    input logic unsigned [7:0] volume_raw,
    input logic clk,
    output logic unsigned [7:0] wave_out
);
localparam logic [7:0] wave_half_point = 8'd128;

// Shouldn't be too costly since it is a div by 2
logic signed [17:0] scaled_num;
logic signed  [17:0] result;
logic signed [8:0] centered;
logic signed [8:0] peak_centered;
logic signed [8:0] volume_scaled_signed;


logic [7:0] volume_scaled;
always_comb volume_scaled = volume_raw >> 1;

always_ff @(posedge(clk)) begin
    centered <= $signed({1'b0, wave_raw}) - 9'sd128;
    peak_centered <= $signed({1'b0, peak_raw}) - 9'sd128;
    volume_scaled_signed <= $signed({1'b0, volume_scaled});

    if (peak_raw - wave_half_point == 0) begin
        wave_out <= wave_half_point;
    end
    else begin
	scaled_num = centered * volume_scaled_signed;
        result = scaled_num / peak_centered;
        wave_out = 8'(9'sd128 + result);
    end
end

endmodule
