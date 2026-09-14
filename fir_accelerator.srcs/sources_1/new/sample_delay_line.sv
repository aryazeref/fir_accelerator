`timescale 1ns/1ps

module sample_delay_line (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    input  logic signed [15:0] x_in,
    output logic signed [15:0] samples [0:7]
);

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 8; i++) begin
                samples[i] <= '0;
            end
        end else if (en) begin
            for (int i = 7; i > 0; i--) begin
                // TODO: Copy the previous sample into samples[i].
                samples[i] <= samples[i-1];
            end

            // TODO: Store x_in in the newest position.
            samples[0] = x_in;
        end
    end

endmodule