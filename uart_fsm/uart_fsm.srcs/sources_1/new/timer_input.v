`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Generates a single clock pulse tick ("done") after a specified number of clock cycles (FINAL_VALUE)
//////////////////////////////////////////////////////////////////////////////////

module timer_input
    #(parameter BITS = 4)(
    input clk,
    input reset_n,
    input enable,
    input [BITS - 1:0] FINAL_VALUE,
    output reg done
    );

    reg [BITS - 1:0] Q_reg;

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            Q_reg <= 'b0;
            done <= 1'b0;
        end else if (enable) begin
            if (Q_reg == FINAL_VALUE) begin
                Q_reg <= 0;
                done <= 1'b1;  // Tick happens for 1 clock cycle
            end else begin
                Q_reg <= Q_reg + 1;
                done <= 1'b0;  // No tick
            end
        end else begin
            done <= 1'b0; // Disable mode
        end
    end
endmodule
