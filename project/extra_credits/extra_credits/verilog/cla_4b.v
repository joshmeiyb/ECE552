/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
module cla_4b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    // YOUR CODE HERE
    wire c0, c1, c2, c3, c4;
    wire [3:0] g, p;
    
    
    // =====================================================================
    // Possible Optimization in future demo, which save areas without Cout
    // =====================================================================
    adder adder1(.s(sum[0]), .a(a[0]), .b(b[0]), .c_in(c0));
    adder adder2(.s(sum[1]), .a(a[1]), .b(b[1]), .c_in(c1));
    adder adder3(.s(sum[2]), .a(a[2]), .b(b[2]), .c_in(c2));
    adder adder4(.s(sum[3]), .a(a[3]), .b(b[3]), .c_in(c3));
    // =====================================================================
    
    // fullAdder_1b fa1(.s(sum[0]), .c_out(), .a(a[0]), .b(b[0]), .c_in(c0));
    // fullAdder_1b fa2(.s(sum[1]), .c_out(), .a(a[1]), .b(b[1]), .c_in(c1));
    // fullAdder_1b fa3(.s(sum[2]), .c_out(), .a(a[2]), .b(b[2]), .c_in(c2));
    // fullAdder_1b fa4(.s(sum[3]), .c_out(), .a(a[3]), .b(b[3]), .c_in(c3));

    //Generate terms
    assign g[0] = a[0] & b[0];
    assign g[1] = a[1] & b[1];
    assign g[2] = a[2] & b[2];
    assign g[3] = a[3] & b[3];

    //Propagate terms
    assign p[0] = a[0] | b[0];
    assign p[1] = a[1] | b[1];
    assign p[2] = a[2] | b[2];
    assign p[3] = a[3] | b[3];

    //Carry terms
    assign c0    = c_in;
    assign c1    = g[0] | (p[0] & c0);
    assign c2    = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c0);
    assign c3    = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c0);
    assign c4    = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c0);
    assign c_out = c4;


endmodule
