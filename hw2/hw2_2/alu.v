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
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
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

    //Opcode //Function     //Operation/
    //000    //rll          //Rotate left logical
    //001    //sll          //Shift left logical
    //010    //sra          //Shift right arithmetic
    //011    //srl          //Shift right logical
    //100    //ADD          //A + B
    //101    //AND          //A AND B
    //110    //OR           //A OR B
    //111    //XOR          //A XOR B


    wire [15:0] InAA; //
    wire [15:0] InBB;
    assign InAA = invA ? ~InA : InA;
    assign InBB = invB ? ~InB : InB;
    
    wire [15:0] shifter_out;
    wire [15:0] cla_16b_out;
    wire c_out;
    shifter shifter(.In(InAA), .ShAmt(InBB[3:0]), .Oper(Oper[1:0]), .Out(shifter_out));
    cla_16b cla_16b(.sum(cla_16b_out), .c_out(c_out), .a(InAA), .b(InBB), .c_in(Cin));

    wire Ofl_signed;
    wire Ofl_unsigned;
    assign Ofl_signed = ( (sign == 1'b1) & ( (InAA[15] == InBB[15]) & (InAA[15] != cla_16b_out[15]) ) );
    assign Ofl_unsigned = ( (c_out == 1'b1) & (sign == 1'b0) );
    assign Ofl = Ofl_signed ^ Ofl_unsigned;
    //assign Ofl =  ((sign == 1'b1) & ((InAA[15] == InBB[15]) & (InAA[15] != cla_16b_out[15]))) | ((c_out == 1'b1) & (sign == 1'b0));
    assign Zero = ~(|Out);

    assign Out = 
        (Oper[2] == 1'b0  ) ? shifter_out :
        (Oper    == 3'b100) ? cla_16b_out :
        (Oper    == 3'b101) ? InAA & InBB :
        (Oper    == 3'b110) ? InAA | InBB :
        (Oper    == 3'b111) ? InAA ^ InBB : InAA;

endmodule
