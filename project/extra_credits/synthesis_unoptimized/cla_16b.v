/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
module cla_16b(clk, rst,
                sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;
    
    input clk, rst;

    // YOUR CODE HERE
    //-----------------------------//
    //Synthesis STA
    wire [15:0] sum_dff;
    reg16 sum_delay_reg (.clk(clk), .rst(rst), .write(1'b1), .wdata(sum_dff), .rdata(sum));
    //-----------------------------//
    
    wire c1, c2, c3, c4;
    cla_4b cla1(.sum(sum_dff[3:0]/*sum[3:0]*/), .c_out(c1), .a(a[3:0]), .b(b[3:0]), .c_in(c_in));
    cla_4b cla2(.sum(sum_dff[7:4]/*sum[7:4]*/), .c_out(c2), .a(a[7:4]), .b(b[7:4]), .c_in(c1));
    cla_4b cla3(.sum(sum_dff[11:8]/*sum[11:8]*/), .c_out(c3), .a(a[11:8]), .b(b[11:8]), .c_in(c2));
    cla_4b cla4(.sum(sum_dff[15:12]/*sum[15:12]*/), .c_out(c4), .a(a[15:12]), .b(b[15:12]), .c_in(c3));

    assign c_out = c4;

endmodule
