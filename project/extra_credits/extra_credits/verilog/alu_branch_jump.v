/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 2

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
module alu_branch_jump (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output                      Zero; // Signal if Out is 0

    /* YOUR CODE HERE */

    //Opcode    //Function      //Operation/
    //0100      //ADD           //A + B, JR, JALR, Branch
    //1111      //InA           //J, JAL


    wire [15:0] cla_16b_out;
    wire c_out;
    cla_16b cla_16b(.sum(cla_16b_out), .c_out(c_out), .a(InA), .b(InB), .c_in(Cin));

    assign Out =    (Oper == 4'b0100) ? cla_16b_out :
                    (Oper == 4'b1111) ? InA         : 
                                        16'h0000;

endmodule
