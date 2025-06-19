`timescale 1ns / 1ps

module counter(
    input clk,reset,mode,
    output reg [7:0] count
    );
    
    always@(posedge clk)
    begin
        if (reset == 1)
            count <= 0;
        else
        begin
            if (mode == 1)
                count <= count + 1;
            else
                count <= count - 1;
        end
    end
endmodule
