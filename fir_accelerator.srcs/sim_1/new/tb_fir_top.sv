`timescale 1ns/1ps

module tb_fir_top;

    logic clk = 0;
    logic rst = 1;
    logic in_valid = 0;
    logic signed [15:0] x_in = 0;

    wire in_ready;
    wire out_valid;
    wire signed [34:0] y_out;

    fir_top dut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .x_in(x_in),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .y_out(y_out)
    );

    always #5 clk = ~clk;

    // Stop the simulation if the controller gets stuck.
    initial begin
        #10000;
        $fatal(1, "Timeout: filter did not complete the tests");
    end

    task automatic send_and_check(
        input logic signed [15:0] value,
        input logic signed [34:0] expected
    );
        // Wait until the filter can accept a new sample.
        @(negedge clk);
        while (in_ready !== 1'b1)
            @(negedge clk);

        x_in = value;
        in_valid = 1'b1;

        // The next rising edge accepts this sample.
        @(posedge clk);

        // Remove valid away from the sampling edge.
        @(negedge clk);
        in_valid = 1'b0;

        // Wait for the completed output.
        // Check after nonblocking assignments have taken effect.
        @(posedge clk);
        #1;
        while (out_valid !== 1'b1) begin
            @(posedge clk);
            #1;
        end

        if (y_out !== expected)
            $fatal(1,
                "Input %0d: expected scaled output %0d, got %0d",
                value, expected, y_out);

        $display(
            "PASS: input=%0d, scaled output=%0d, average=%0.3f",
            value, y_out, $itor(y_out) / 32768.0
        );

        // The output-valid indication must last one cycle.
        @(posedge clk);
        #1;
        if (out_valid !== 1'b0)
            $fatal(1, "out_valid remained high for more than one cycle");

        if (y_out !== expected)
            $fatal(1, "Output did not hold its saved value");
    endtask

    initial begin
        // Apply synchronous reset.
        repeat (2) @(posedge clk);
        #1;

        if (y_out !== 35'sd0 || out_valid !== 1'b0)
            $fatal(1, "Reset failed");

        @(negedge clk);
        rst = 0;

        // An impulse: 80 followed by zeros.
        send_and_check(16'sd80, 35'sd327680);

        // 80 remains within the eight-sample history.
        repeat (7)
            send_and_check(16'sd0, 35'sd327680);

        // The oldest sample, 80, now leaves the history.
        send_and_check(16'sd0, 35'sd0);

        // Check negative and fractional output: -20 / 8 = -2.5.
        send_and_check(-16'sd20, -35'sd81920);

        $display("PASS: All full-filter checks passed.");
        $finish;
    end

endmodule