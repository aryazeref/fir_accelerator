`timescale 1ns/1ps

module accumulator (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    input  logic signed [31:0] product,
    output logic signed [34:0] sum
);

    always_ff @(posedge clk) begin
        if (rst) begin
            // TODO: Clear the running total.
            sum <= 0;
        end else if (en) begin
            // TODO: Add product to the previous running total.
            sum <= sum + product;
        end
    end

endmodule