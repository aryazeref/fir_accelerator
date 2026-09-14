`timescale 1ns/1ps

module tb_sample_delay_line;

    logic clk = 0;
    logic rst = 1;
    logic en = 0;
    logic signed [15:0] x_in = 0;
    wire signed [15:0] samples [0:7];

    sample_delay_line dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .x_in(x_in),
        .samples(samples)
    );

    always #5 clk = ~clk;

    // Accept one sample and wait until its update is visible.
    task automatic push_sample(input logic signed [15:0] value);
        @(negedge clk);
        en = 1;
        x_in = value;
        @(posedge clk);
        #1;
    endtask

    initial begin
        // Test 1: Reset clears every position.
        @(posedge clk);
        #1;
        for (int i = 0; i < 8; i++) begin
            if (samples[i] !== 16'sd0)
                $fatal(1, "Reset failed at index %0d", i);
        end

        @(negedge clk);
        rst = 0;

        // Test 2: Accept 1 through 8.
        for (int n = 1; n <= 8; n++) begin
            push_sample(n);

            // Expected occupied positions: n, n-1, ..., 1.
            for (int i = 0; i < n; i++) begin
                if (samples[i] !== (n - i))
                    $fatal(1, "Order failed: index %0d, got %0d",
                           i, samples[i]);
            end

            // Positions not yet filled must remain zero.
            for (int i = n; i < 8; i++) begin
                if (samples[i] !== 16'sd0)
                    $fatal(1, "Unexpected value at index %0d", i);
            end
        end

        // Test 3: Disabled input must not change the history.
        @(negedge clk);
        en = 0;
        x_in = 16'sd20;

        repeat (2) begin
            @(posedge clk);
            #1;
            for (int i = 0; i < 8; i++) begin
                if (samples[i] !== (8 - i))
                    $fatal(1, "Hold failed at index %0d", i);
            end
        end

        // Test 4: Accept -3 and discard the oldest sample, 1.
        push_sample(-16'sd3);

        if (samples[0] !== -16'sd3)
            $fatal(1, "Newest sample should be -3");

        for (int i = 1; i < 8; i++) begin
            if (samples[i] !== (9 - i))
                $fatal(1, "Shift failed at index %0d", i);
        end

        // Test 5: Reset clears populated history, even with en = 1.
        @(negedge clk);
        rst = 1;

        @(posedge clk);
        #1;
        for (int i = 0; i < 8; i++) begin
            if (samples[i] !== 16'sd0)
                $fatal(1, "Reset during operation failed at index %0d", i);
        end

        $display("PASS: All delay-line checks passed.");
        $finish;
    end

endmodule