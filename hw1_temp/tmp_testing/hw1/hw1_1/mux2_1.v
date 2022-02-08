/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    2-1 mux template
*/
module mux2_1(out, inA, inB, s);
    output  out;
    input   inA, inB;
    input   s;

    // YOUR CODE HERE
    wire a, b, n;
    not1 n1(.out(n), .in1(s));
    nand2 na1(.out(a), .in1(inA), .in2(n));
    nand2 na2(.out(b), .in1(inB), .in2(s));
    nand2 na3(.out(out), .in1(a), .in2(b));
    
endmodule
