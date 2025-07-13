`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//Test bench for uart module, transmits a message and receives the message via loopback
//////////////////////////////////////////////////////////////////////////////////

module uart_tb;

    // Clock and Reset parameters
    parameter CLK_PERIOD = 10; // 10 ns for 100 MHz clock
    parameter BAUD_RATE = 9600; // Common baud rate

    // UART Parameters (must match uart.v parameters)
    parameter DBIT = 8;        // Data bits
    parameter SB_TICK = 16;    // Stop bit ticks (assuming 16x oversampling)

    // Calculate TIMER_FINAL_VALUE for baud rate generator
    parameter SYSTEM_CLK_FREQ = 1_000_000_000 / CLK_PERIOD; // Hz
    parameter BAUD_RATE_TICKS_PER_SEC = BAUD_RATE * 16;
    parameter TIMER_FINAL_VAL = (SYSTEM_CLK_FREQ / BAUD_RATE_TICKS_PER_SEC) - 1;

    // Inputs
    reg clk;
    reg reset_n;
    reg rd_uart;
    reg rx; // Serial data input for receiver
    reg [DBIT - 1:0] w_data;
    reg wr_uart;
    reg [10:0] TIMER_FINAL_VALUE_tb; // To connect to DUT's TIMER_FINAL_VALUE

    // Outputs
    wire [DBIT - 1:0] r_data;
    wire rx_empty;
    wire tx_full;
    wire tx; // Serial data output from transmitter

    // Internal testbench signals
    reg [7:0] tx_data_array [0:9]; // Array to hold test data for transmission
    reg [7:0] rx_expected_data_array [0:9]; // Array to hold expected data for reception
    integer tx_idx; // Index for transmitting data
    integer rx_idx; // Index for receiving data
    integer errors; // Error counter
    integer i; // Loop variable for initial block (Verilog-2001 requires declaration outside loop)


    uart #(.DBIT(DBIT), .SB_TICK(SB_TICK)) dut (
        .clk(clk),
        .reset_n(reset_n),
        .r_data(r_data),
        .rd_uart(rd_uart),
        .rx_empty(rx_empty),
        .rx(tx), // CREATES A LOOPBACK by connecting tx to uart's rx
        .w_data(w_data),
        .wr_uart(wr_uart),
        .tx_full(tx_full),
        .tx(tx),
        .TIMER_FINAL_VALUE(TIMER_FINAL_VAL) // Use the calculated value
    );


    always #((CLK_PERIOD / 2)) clk = ~clk;
    initial begin
        // Initialize signals
        clk = 1'b0;
        reset_n = 1'b0;
        rd_uart = 1'b0;
        w_data = 8'h00;
        wr_uart = 1'b0;
        tx_idx = 0;
        rx_idx = 0;
        errors = 0;

        tx_data_array[0] = 8'h55;
        tx_data_array[1] = 8'hAA; 
        tx_data_array[2] = 8'h0F;
        tx_data_array[3] = 8'hF0;
        tx_data_array[4] = 8'h3C;
        tx_data_array[5] = 8'hC3;
        tx_data_array[6] = 8'h12;
        tx_data_array[7] = 8'h34;
        tx_data_array[8] = 8'h56;
        tx_data_array[9] = 8'h78;
        for(i=0; i<10; i=i+1) begin
            rx_expected_data_array[i] = tx_data_array[i];
        end

        // De-assert reset after a few clock cycles
        # (CLK_PERIOD * 5);
        reset_n = 1'b1;
        $display("[%0t] Reset de-asserted. Starting test.", $time);

        // Write data to the transmit FIFO
        for (tx_idx = 0; tx_idx < 10; tx_idx = tx_idx + 1) begin
            @(posedge clk); // Wait for clock edge before checking full
            while(tx_full) @(posedge clk); // Wait if transmit FIFO is full 
            w_data = tx_data_array[tx_idx];
            wr_uart = 1'b1;
            $display("[%0t] Writing 0x%H to TX FIFO.", $time, w_data);
            @(posedge clk);
            wr_uart = 1'b0; // De-assert write enable
        end
        $display("[%0t] All data written to TX FIFO. Waiting for transmission to complete.", $time); 

        // Wait for TX FIFO to become empty, indicating all data has been transmitted
        @(posedge clk); 
        while(!dut.tx_FIFO.empty) @(posedge clk); // Wait for TX FIFO to be empty
        $display("[%0t] TX FIFO is empty. All data transmitted.", $time);

        # (CLK_PERIOD * 500); // Wait for 500 clock cycles (e.g., 5us), usually enough for 1-2 bytes.
        
        // Read data from the receive FIFO and verify
        rx_idx = 0;
        while (rx_idx < 10) begin // Loop until all 10 expected bytes are received
            @(posedge clk); // Wait for clock edge
            while (rx_empty) begin // Wait until RX FIFO is not empty
                @(posedge clk); 
            end
            // Now FIFO is not empty, so read data
            rd_uart = 1'b1; // Assert read enable
            @(posedge clk);
            rd_uart = 1'b0; // De-assert read enable
            $display("[%0t] Reading 0x%H from RX FIFO. Expected 0x%H", $time, r_data, rx_expected_data_array[rx_idx]);

            if (r_data !== rx_expected_data_array[rx_idx]) begin
                $display("ERROR: Received 0x%H, expected 0x%H for byte %0d.", r_data, rx_expected_data_array[rx_idx], rx_idx); 
                errors = errors + 1;
            end
            rx_idx = rx_idx + 1;
        end
        $display("[%0t] All expected bytes (total %0d) processed from RX FIFO.", $time, rx_idx);

// Not sure why first two bytes are received as 00
//[8332855000] TX FIFO is empty. All data transmitted.
//[8337865000] Reading 0x00 from RX FIFO. Expected 0x55
//ERROR: Received 0x00, expected 0x55 for byte 0.
//[8337885000] Reading 0x00 from RX FIFO. Expected 0xaa
//ERROR: Received 0x00, expected 0xaa for byte 1.
//[8337905000] Reading 0x0f from RX FIFO. Expected 0x0f
//[8337925000] Reading 0xf0 from RX FIFO. Expected 0xf0
//[8337945000] Reading 0x3c from RX FIFO. Expected 0x3c
//[8337965000] Reading 0xc3 from RX FIFO. Expected 0xc3
//[8337985000] Reading 0x12 from RX FIFO. Expected 0x12
//[8338005000] Reading 0x34 from RX FIFO. Expected 0x34
        // Final check and simulation end
        if (errors == 0 && rx_idx == 10) begin
            $display("--------------------------------------------------");
            $display("           TEST PASSED: No errors found.          ");
            $display("--------------------------------------------------");
        end else begin
            $display("--------------------------------------------------");
            $display("           TEST FAILED: %0d errors found.         ", errors);
            $display("--------------------------------------------------");
        end

        # (CLK_PERIOD * 10); // Hold simulation for a bit before finishing
        $finish;
    end

endmodule