`timescale 1ns / 1ps

module tb_eight_bit_counter;

    reg clk;
    reg reset;
    reg mode;
    wire [7:0] count;

    parameter CLK_PERIOD = 10; // 10ns period -> 100 MHz clock

    counter uut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .count(count)
    );

    initial begin
        clk = 0; // Initialize clock to 0
        forever #(CLK_PERIOD / 2) clk = ~clk; // Toggle every half period
    end

    initial begin
        $display("Time: %0t -- Starting Testbench -- Initializing inputs", $time);
        reset = 1;  // Assert reset
        mode = 0;   // Initial mode (can be anything, reset overrides)
        # (CLK_PERIOD * 2); // Hold reset for a couple of clock cycles to ensure synchronous reset is effective

        $display("Time: %0t -- De-asserting reset -- Setting mode to increment", $time);
        reset = 0;  // De-assert reset
        mode = 1;   // Set mode to increment
        # (CLK_PERIOD * 50); // Let it count up for 300 clock cycles (e.g., 300 * 10ns = 3us)
                             // This allows 'count' to increment multiple times (0 -> 299 or wrap around)

        $display("Time: %0t -- Changing mode to decrement", $time);
        mode = 0;   // Set mode to decrement
        # (CLK_PERIOD * 20); // Let it count down for 200 clock cycles

        $display("Time: %0t -- Re-asserting reset briefly", $time);
        reset = 1;
        # (CLK_PERIOD * 2);
        reset = 0;

        $display("Time: %0t -- Counting down", $time);
        mode = 1;
        # (CLK_PERIOD * 30);


        $display("Time: %0t -- Finishing Simulation", $time);
        # (CLK_PERIOD * 10); 
        $finish; 
    end

    always @(posedge clk) begin
        if (reset) begin
            $display("Time: %0t -- CLK_EDGE: Reset Active, count = %0d", $time, count);
        end else begin
            if (mode == 1) begin
                $display("Time: %0t -- CLK_EDGE: Mode UP, count = %0d", $time, count);
            end else begin
                $display("Time: %0t -- CLK_EDGE: Mode DOWN, count = %0d", $time, count);
            end
        end
    end

endmodule