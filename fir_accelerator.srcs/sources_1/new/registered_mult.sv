module registered_mult (
    input  logic               clk,
    input  logic               rst,
    input  logic signed [15:0] a,
    input  logic signed [15:0] b,
    output logic signed [31:0] p
);

    always_ff @(posedge clk) begin
        if (rst) begin
            p <= 0;
        end else begin
            p <= a * b;
        end
    end

endmodule