`timescale 1ns/1ps

module fir_controller (
    input  logic       clk,
    input  logic       rst,
    input  logic       start,

    output logic       ready,
    output logic       load_sample,
    output logic       mac_clear,
    output logic       mac_valid,
    output logic       capture_result,
    output logic [2:0] tap_index
);

    typedef enum logic [2:0] {
        IDLE, CLEAR, RUN, DRAIN, SAVE
    } state_t;

    state_t state;

    // Registers: current state and sample index.
    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            tap_index <= 3'd0;
        end else begin
            case (state)

                IDLE: begin
                    if (start)
                        state <= CLEAR;
                end

                CLEAR: begin
                    tap_index <= 3'd0;
                    state     <= RUN;
                end

                RUN: begin
                    if (tap_index == 3'd7) begin
                        // TODO: Move to the state that drains the pipeline.
                        state <= DRAIN;
                    end else begin
                        // TODO: Advance to the next sample index.
                        tap_index <= tap_index + 3'd1;
                    end
                end

                DRAIN: begin
                    // TODO: Move to the result-saving state.
                    state <= SAVE;
                end

                SAVE: begin
                    // TODO: Return to waiting for a new sample.
                    state <= IDLE;
                end

                default: begin
                    state     <= IDLE;
                    tap_index <= 3'd0;
                end
            endcase
        end
    end

    // Combinational logic: controls for the current state.
    always_comb begin
        ready          = 1'b0;
        load_sample    = 1'b0;
        mac_clear      = 1'b0;
        mac_valid      = 1'b0;
        capture_result = 1'b0;

        if (!rst) begin
            case (state)
                IDLE: begin
                    ready       = 1'b1;
                    load_sample = start;
                end

                CLEAR: mac_clear      = 1'b1;
                RUN:   mac_valid      = 1'b1;
                SAVE:  capture_result = 1'b1;

                default: begin
                    // All controls retain their default zero values.
                end
            endcase
        end
    end

endmodule