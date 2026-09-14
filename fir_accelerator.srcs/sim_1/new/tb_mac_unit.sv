`timescale 1ns/1ps

module tb_mac_unit;

    logic clk = 0;
    logic rst = 1;
    logic in_valid = 0;
    logic signed [15:0] a = 0;
    logic signed [15:0] b = 0;
    wire signed [34:0] sum;

    mac_unit dut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .a(a),
        .b(b),
        .sum(sum)
    );

    always #5 clk = ~clk;

    initial begin
        // Reset both arithmetic blocks and the valid register.
        @(posedge clk);
        #1;
        if (sum !== 35'sd0)
            $fatal(1, "Reset failed");

        // First valid pair: 3 * 4 = 12.
        @(negedge clk);
        rst = 0;
        in_valid = 1;
        a = 16'sd3;
        b = 16'sd4;

        @(posedge clk);
        #1;
        if (sum !== 35'sd0)
            $fatal(1, "Product accumulated too early");

        // Insert an invalid pair: its product must be ignored.
        @(negedge clk);
        in_valid = 0;
        a = 16'sd100;
        b = 16'sd100;

        @(posedge clk);
        #1;
        if (sum !== 35'sd12)
            $fatal(1, "Expected 12, got %0d", sum);

        // Second valid pair: -2 * 5 = -10.
        @(negedge clk);
        in_valid = 1;
        a = -16'sd2;
        b = 16'sd5;

        @(posedge clk);
        #1;
        if (sum !== 35'sd12)
            $fatal(1, "Invalid product was accumulated");

        // Third valid pair, immediately afterward: 7 * 2 = 14.
        @(negedge clk);
        a = 16'sd7;
        b = 16'sd2;

        @(posedge clk);
        #1;
        if (sum !== 35'sd2)
            $fatal(1, "Expected 2, got %0d", sum);

        // Stop submitting inputs; the last product is still pending.
        @(negedge clk);
        in_valid = 0;

        @(posedge clk);
        #1;
        if (sum !== 35'sd16)
            $fatal(1, "Expected final sum 16, got %0d", sum);

        // Leave the input values unchanged during idle cycles.
        // Their product must not be added again.
        repeat (2) begin
            @(posedge clk);
            #1;
            if (sum !== 35'sd16)
                $fatal(1, "Sum changed during idle cycles");
        end

        $display("PASS: MAC arithmetic and valid timing passed.");
        $finish;
    end

endmodule