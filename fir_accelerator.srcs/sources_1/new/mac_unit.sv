`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 10:40:21 PM
// Design Name: 
// Module Name: mac_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mac_unit(
    input logic clk,
    input logic rst,
    input logic in_valid,
    input logic signed [15:0] a,
    input logic signed [15:0] b,
    output wire signed [34:0] sum
    );
    wire signed [31:0] product;
    logic product_valid;
    
    registered_mult mult_inst (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .p(product)
    );
    
    // Delay the validity indication to match the multiplier.
    always_ff @(posedge clk) begin
        if (rst) begin
            // TODO: Mark the product as invalid after reset.
            product_valid <= 0;
        end else begin
            // TODO: Capture whether this edge accepted valid inputs.
            product_valid <= in_valid;
        end
    end
    
    accumulator acc_inst (
        .clk(clk),
        .rst(rst),
        .en(product_valid),
        .product(product),
        .sum(sum)
    );
endmodule
