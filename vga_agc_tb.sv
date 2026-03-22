// -----------------------------------------------------------
//  Testbench
// -----------------------------------------------------------
`timescale 1ns/1ps

module tb_vga_agc;

    // ── DUT ports ──────────────────────────────────────────
    logic        clk;
    logic [7:0]  wave_raw;
    logic [7:0]  volume_raw;
    logic [7:0]  wave_out;

    // ── DUT instantiation ──────────────────────────────────
    vga_agc dut (
        .clk       (clk),
        .wave_raw  (wave_raw),
        .volume_raw(volume_raw),
        .wave_out  (wave_out)
    );

    // ── Clock: 10 ns period (100 MHz) ──────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Sine-wave LUT (256 samples, amp=80, offset=128) ────
    //    sample[n] = 128 + round(80 * sin(2*pi*n/256))
    logic [7:0] sine_lut [0:255];

    initial begin : build_lut
        integer n;
        real    v;
        for (n = 0; n < 256; n++) begin
            v = 128.0 + 80.0 * $sin(2.0 * 3.14159265358979 * n / 256.0);
            sine_lut[n] = $unsigned(integer'(v));
        end
    end

    // ── Stimulus ───────────────────────────────────────────
    integer lut_idx;
    integer cycle;
    initial begin
        $dumpfile("tb_vga_agc.vcd");
        $dumpvars(0, tb_vga_agc);
    end    
    initial begin
        // Initialise
        wave_raw   = 8'd128;
        volume_raw = 8'd50;
        lut_idx    = 0;
        cycle      = 0;

        $display("=== VGA-AGC Testbench Start ===");

        // ── Phase 1: vol=50, run 4 full sine waves (4×256 cycles)
        @(posedge clk);
        repeat (15 * 256) begin
            @(negedge clk);          // drive inputs between clock edges
            wave_raw = sine_lut[lut_idx];
            lut_idx  = (lut_idx + 1) % 256;
            cycle++;
        end

        $display("[cycle %0d] Switching volume 50 → 100", cycle);
        volume_raw = 8'd100;

        // ── Phase 2: vol=100, run 4 more full sine waves
        repeat (15 * 256) begin
            @(negedge clk);
            wave_raw = sine_lut[lut_idx];
            lut_idx  = (lut_idx + 1) % 256;
            cycle++;
        end

        $display("=== Simulation complete at cycle %0d ===", cycle);
        $finish;
    end
endmodule
