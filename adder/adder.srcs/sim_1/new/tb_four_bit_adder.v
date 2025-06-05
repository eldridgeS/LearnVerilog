`timescale 1ns / 1ps

module tb_four_bit_adder;

    // Testbench signals
    reg [3:0] a;
    reg [3:0] b;
    reg cin;
    wire [3:0] s;
    wire cout;

    // Instantiate the Unit Under Test (UUT)
    four_bit_adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        // Print header
        $display("Time\tcin\ta\tb\tsum\tcout");
        $monitor("%4t\t%b\t%b\t%b\t%b\t%b", $time, cin, a, b, s, cout);

        // Test 0 + 0
        a = 4'b0000; b = 4'b0000; cin = 1'b0; #10;

        // Test 5 + 3
        a = 4'b0101; b = 4'b0011; cin = 1'b0; #10;

        // Test 15 + 1 (overflow)
        a = 4'b1111; b = 4'b0001; cin = 1'b0; #10;

        // Test 8 + 8
        a = 4'b1000; b = 4'b1000; cin = 1'b0; #10;

        // Test with carry-in
        a = 4'b0011; b = 4'b0001; cin = 1'b1; #10;

        // Test all 1s + all 1s with carry-in
        a = 4'b1111; b = 4'b1111; cin = 1'b1; #10;

        // Test alternating bits
        a = 4'b1010; b = 4'b0101; cin = 1'b0; #10;

        // Test 0 + 0 with carry-in
        a = 4'b0000; b = 4'b0000; cin = 1'b1; #10;

        // End simulation
        $finish;
    end

endmodule
