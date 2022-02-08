/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    4-1 mux template
*/
module mux4_1(out, inA, inB, inC, inD, s);
    output       out;
    input        inA, inB, inC, inD;
    input [1:0]  s;

    // YOUR CODE HERE
    wire n1, n2;
    mux2_1 mux1(.out(n1), .inA(inA), .inB(inB), .s(s[0])); //A:00, B:01
    mux2_1 mux2(.out(n2), .inA(inC), .inB(inD), .s(s[0])); //C:10, D:11
    mux2_1 mux3(.out(out), .inA(n1), .inB(n2), .s(s[1]));
      
endmodule
