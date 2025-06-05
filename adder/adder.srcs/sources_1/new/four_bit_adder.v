`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 02:49:15 AM
// Design Name: 
// Module Name: four_bit_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module four_bit_adder(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] s,
    input cout
    );
    wire [3:1] c;

    FA stage0 (.a(a[0]), .b(b[0]), .cin(cin),  .cout(c[1]), .s(s[0]));
    FA stage1 (.a(a[1]), .b(b[1]), .cin(c[1]), .cout(c[2]), .s(s[1]));
    FA stage2 (.a(a[2]), .b(b[2]), .cin(c[2]), .cout(c[3]), .s(s[2]));
    FA stage3 (.a(a[3]), .b(b[3]), .cin(c[3]), .cout(cout), .s(s[3]));
endmodule

module FA (
    input  a,
    input  b,
    input  cin,
    output cout,
    output s
);
    assign s = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule