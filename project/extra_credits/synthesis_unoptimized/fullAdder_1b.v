/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
    output s;
    output c_out;
    input   a, b;
    input  c_in;

    // YOUR CODE HERE
    wire n1, n2, n3;

    xor2 XO1(.out(n1), .in1(a), .in2(b));
    xor2 XO2(.out(s), .in1(n1), .in2(c_in));

    nand2 NA1(.out(n2), .in1(n1), .in2(c_in));
    nand2 NA2(.out(n3), .in1(a), .in2(b));
    nand2 NA3(.out(c_out), .in1(n2), .in2(n3));

endmodule
