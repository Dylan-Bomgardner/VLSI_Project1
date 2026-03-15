`timescale 1ns/1ps

module tb_my_module;

    // Parameters
    localparam int CLK_PERIOD = 10;
    localparam int RST_CYCLES = 5;

    // DUT signals
    logic clk;
    logic rst_n;
    logic [7:0] data_in;
    logic [7:0] data_out;

    // DUT instantiation
    my_module u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Reset and stimulus
    initial begin
        rst_n = 1'b0;
        data_in = 8'h0;

        // Hold reset for 5 clock cycles
        #50;
        rst_n = 1'b1;

        // TODO: add stimulus here
        // Example task call:
        // send_data(8'hAB);

        #200;
        $display("Simulation complete");
        $finish;
    end
endmodule