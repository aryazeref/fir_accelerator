`timescale 1ns/1ps

module tb_registered_mult;
    
    logic clk = 0;
    logic rst = 1;
    logic signed [15:0] a = 16'sd3; // 0000 0000 0000 0011
    logic signed [15:0] b = 16'sd4; // 0000 0000 0000 0100
    logic signed [31:0] p;
    
    registered_mult dut(
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .p(p)
    );
    
    // Toggle every 5 ns: a complete clock cycle takes 10ns
    always #5 clk = ~clk;
    initial begin
        // Test 1: Reset must override the nonzero inputs.
        @(posedge clk);
        #1;
        if (p !== 32'sd0)
            $fatal(1, "Reset failed: p = %0d", p);
            
        // Release reset away from the sampling edge.
        @(negedge clk);
        rst = 0;
        
        // Test 2: Capture 3*4
        @(posedge clk);
        #1;
        if(p!==32'sd12)
            $fatal(1, "Expected 12, got %0d", p);
            
        // Test 3: Changing an input must not immediately change p.
        @(negedge clk);
        a = -16'sd3;
        #1;
        if(p !== 32'sd12)
            $fatal(1, "Output changed before the rising edge");
        
        // Test 4: Capture -3 * 4 at the next rising edge.
        @(posedge clk);
        #1;
        if (p !== -32'sd12)
            $fatal(1, "Expected -12, got %0d", p);
            
         // Test 5: Largest positive inputs.
        @(negedge clk);
        a = 16'sh7FFF;  //  32767
        b = 16'sh7FFF;  //  32767

        @(posedge clk);
        #1;
        if (p !== 32'sd1073676289)
            $fatal(1, "Maximum positive inputs failed: p = %0d", p);

        // Test 6: Most negative inputs.
        @(negedge clk);
        a = 16'sh8000;  // -32768
        b = 16'sh8000;  // -32768

        @(posedge clk);
        #1;
        if (p !== 32'sd1073741824)
            $fatal(1, "Two negative inputs failed: p = %0d", p);

        // Test 7: Opposite signs at the numerical limits.
        @(negedge clk);
        a = 16'sh8000;  // -32768
        b = 16'sh7FFF;  //  32767

        @(posedge clk);
        #1;
        if (p !== -32'sd1073709056)
            $fatal(1, "Mixed-sign inputs failed: p = %0d", p);
        // Test 8: Multiplication by zero.
        @(negedge clk);
        a = 16'sh8000;
        b = 16'sd0;

        @(posedge clk);
        #1;
        if (p !== 32'sd0)
            $fatal(1, "Multiplication by zero failed: p = %0d", p);
         $display("PASS: ALL eight checks passed.");
         $finish;
    end

endmodule