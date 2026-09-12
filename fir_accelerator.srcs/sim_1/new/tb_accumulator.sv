`timescale 1ns/1ps

module tb_accumulator;

    logic clk = 0;
    logic rst = 1;
    logic en = 1;
    logic signed [31:0] product = 32'sd12;
    logic signed [34:0] sum;

    accumulator dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .product(product),
        .sum(sum)
    );

    always #5 clk = ~clk;

    initial begin
        // Test 1: Reset overrides enable and a nonzero product.
        @(posedge clk);
        #1;
        if (sum !== 35'sd0)
            $fatal(1, "Reset failed: sum = %0d", sum);

        // Test 2: Add 12 to zero.
        @(negedge clk);
        rst = 0;

        @(posedge clk);
        #1;
        if (sum !== 35'sd12)
            $fatal(1, "Expected 12, got %0d", sum);

        // Test 3: Add -12 to 12.
        @(negedge clk);
        product = -32'sd12;

        @(posedge clk);
        #1;
        if (sum !== 35'sd0)
            $fatal(1, "Expected 0, got %0d", sum);

        // Test 4: Add 20.
        @(negedge clk);
        product = 32'sd20;

        @(posedge clk);
        #1;
        if (sum !== 35'sd20)
            $fatal(1, "Expected 20, got %0d", sum);

        // Test 5: Disable accumulation despite a new product.
        @(negedge clk);
        en = 0;
        product = 32'sd100;

        @(posedge clk);
        #1;
        if (sum !== 35'sd20)
            $fatal(1, "Enable hold failed: sum = %0d", sum);

        // Test 6: Re-enable and add 100 to the stored 20.
        @(negedge clk);
        en = 1;

        @(posedge clk);
        #1;
        if (sum !== 35'sd120)
            $fatal(1, "Expected 120, got %0d", sum);

        // Test 7: Reset clears an existing total.
        @(negedge clk);
        rst = 1;

        @(posedge clk);
        #1;
        if (sum !== 35'sd0)
            $fatal(1, "Reset during operation failed: sum = %0d", sum);

        $display("PASS: All seven accumulator checks passed.");
        $finish;
    end

endmodule