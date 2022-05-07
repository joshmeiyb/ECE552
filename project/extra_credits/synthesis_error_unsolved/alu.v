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

    //Opcode    //Function     //Operation/
    //0000      //rll          //Rotate left logical
    //0001      //sll          //Shift left logical
    //0010      //sra          //rotate right logical
    //0011      //srl          //Shift right logical
    //0100      //ADD          //A + B
    //0101      //AND          //A AND B
    //0110      //OR           //A OR B
    //0111      //XOR          //A XOR B
    //1000      //BTR          //bit reversal
    //1001      //SEQ
    //1010      //SLT
    //1011      //SLE
    //1100      //SCO


    wire [15:0] InAA; 
    wire [15:0] InBB;
    assign InAA = invA ? ~InA : InA;    //if invA is 1'b1, all the bits of InA would be flipped, which is 1's complement
    assign InBB = invB ? ~InB : InB;    //if invB is 1'b1, all the bits of InB would be flipped, which is 1's complement

    //Implementing the BTR instruction
    wire [15:0] InAA_reversed;
    assign InAA_reversed = {InAA[0], InAA[1], InAA[2], InAA[3], InAA[4], InAA[5], InAA[6], InAA[7],
	InAA[8], InAA[9], InAA[10], InAA[11], InAA[12], InAA[13], InAA[14], InAA[15] };
    
    wire [15:0] shifter_out;
    wire [15:0] cla_16b_out;
    wire c_out;
    shifter shifter(.In(InAA), .ShAmt(InBB[3:0]), .Oper(Oper[1:0]), .Out(shifter_out));
    cla_16b cla_16b(.sum(cla_16b_out), .c_out(c_out), .a(InAA), .b(InBB), .c_in(Cin));

    wire Ofl_signed;
    wire Ofl_unsigned;
    assign Ofl_signed = ( (sign == 1'b1) & ( (InAA[15] == InBB[15]) & (InAA[15] != cla_16b_out[15]) ) );    //two positive number, negative result
                                                                                                            //two negative number, positive result
    assign Ofl_unsigned = ( (c_out == 1'b1) & (sign == 1'b0) );
    assign Ofl = Ofl_signed | Ofl_unsigned;
    //Therefore, overflow combines with signed overflow and unsigned overflow
    //assign Ofl =  ((sign == 1'b1) & ((InAA[15] == InBB[15]) & (InAA[15] != cla_16b_out[15]))) | ((c_out == 1'b1) & (sign == 1'b0));
    
    assign Zero = ~(|Out);

    wire SEQ, SLT, SLE, SCO;
    assign Out = 
        (Oper[3:2] == 2'b00  ) ? shifter_out    :
        (Oper      == 4'b0100) ? cla_16b_out    :
        (Oper      == 4'b0101) ? InAA & InBB    :
        (Oper      == 4'b0110) ? InAA | InBB    :
        (Oper      == 4'b0111) ? InAA ^ InBB    : 
        (Oper      == 4'b1000) ? InAA_reversed  :
        (Oper      == 4'b1001) ? SEQ            :
        (Oper      == 4'b1010) ? SLT            :
        (Oper      == 4'b1011) ? SLE            :
        (Oper      == 4'b1100) ? SCO            :
        (Oper      == 4'b1101) ? InBB           :
        (Oper      == 4'b1110) ? (InAA << 8) | InBB : // SLBI 10010 sss iiiiiiii | Rs <- (Rs << 8) | I(zero ext.)
                                 InAA;

    //SEQ 11100 sss ttt ddd xx | if (Rs == Rt) then Rd <- 1 else Rd <- 0
    //wire ofl;
    //assign ofl = ((InAA[15] == InBB[15]) & (InAA[15] != cla_16b_out[15]));    //two positive number, negative result
                                                                                //two negative number, positive result
    
    assign SEQ = ~|cla_16b_out;                     //every bit of cla_16b_out equals zero, then SEQ will be asserted
    
    //SLT checked
    wire Ofl_SLT;   
    assign Ofl_SLT = ( (InAA[15] == InBB[15]) & (InAA[15] != cla_16b_out[15]) );
    //NOT SURE WHY I NEED TO IMPLEMENT SPECIFIC "Ofl_SLT" FOR SLT INSTRUCTION AGAIN
    //BUT THIS HELPED ME PASSED THE RANDOM TEST!!!

    assign SLT = cla_16b_out[15] ^ Ofl_SLT;     //when cla_16b_out is positive(sign bit is 0), has a overflow
                                                //when cla_16b_out is negative(sign bit is 1), has no overflow
                                                //
                                                //Subtraction
                                                //Case              RS         Rt             Result              Sign-bit        Overflow        Rs less than Rt?        SLT
                                                //1                 positive - positive   =   positive/negative                   0                                  
                                                //1.1               small - large         =   negative            1               0               Yes                     1
                                                //1.2               large - small         =   positive            0               0               No                      0
                                                //
                                                //
                                                //2                 positive - negative   =   positive            0(flip to 1)    1               No                      0
                                                //3                 negative - positive   =   negative            1(flip to 0)    1               Yes                     1
                                                //                                                                (in random case, if we have an overflow, sign bit would flip,
                                                //                                                                 if the no.15 bit is different from the MSB)
                                                //                                                                                
                                                //
                                                //4                 negative - negative   =   positive/negative                   0                                  
                                                //4.1               small - large         =   positive            0               0               No                      0
                                                //4.2               large - small         =   negative            1               0               Yes                     1
                                                //
    //assign SLT = cla_16b_out[15];             //Proved to be wrong!
    

    assign SLE = SEQ | SLT;
    assign SCO = c_out;

endmodule
