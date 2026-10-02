`timescale 1ns/1ps

module fir_top (
    input  logic               clk,
    input  logic               rst,
    input  logic               in_valid,
    input  logic signed [15:0] x_in,

    output wire                in_ready,
    output logic               out_valid,
    output logic signed [34:0] y_out
);

    // Stored coefficient: 4096 / 32768 = 1/8.
    localparam logic signed [15:0] COEFF = 16'sd4096;

    // Internal connections between components.
    wire signed [15:0] samples [0:7];
    wire signed [34:0] mac_sum;

    wire       load_sample;
    wire       mac_clear;
    wire       mac_valid;
    wire       capture_result;
    wire [2:0] tap_index;

    // 1. Control the order of operations.
    fir_controller fir_ctrl (
        .clk(clk),
        .rst(rst),
        .start(in_valid),
        .ready(in_ready),
        .load_sample(load_sample),
        .mac_clear(mac_clear),
        .mac_valid(mac_valid),
        .capture_result(capture_result),
        .tap_index(tap_index)
    );

    // 2. Store the newest eight accepted samples.
    sample_delay_line delay_inst (
        .clk(clk),
        .rst(rst),
        .en(load_sample),
        .x_in(x_in),
        .samples(samples)
    );

    // 3. Process one stored sample per RUN cycle.
    mac_unit mac_inst (
        .clk(clk),
        .rst(rst),
        .clear(mac_clear),
        .in_valid(mac_valid),
        .a(samples[tap_index]),
        .b(COEFF),
        .sum(mac_sum)
    );

    // 4. Store the completed result and announce its availability.
    always_ff @(posedge clk) begin
        if (rst) begin
            y_out     <= '0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= capture_result;

            if (capture_result)
                y_out <= mac_sum;
        end
    end

endmodule