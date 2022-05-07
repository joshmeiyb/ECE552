/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
module shifter (In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

    /* YOUR CODE HERE */
    
    //Opcode /Operation/
    //00    //Rotate left
    //01    //Shift left
    //10    //Rotate right
    //11    //Shift right logical

    //right: Oper[0] = 0 shift right arithmetic(consider sign bit); Oper[0] = 1 shift right logic(ignore sign bit)
    wire [15:0] r_shift0, r_shift1, r_shift2, r_shift4, r_shift8;
    assign r_shift0 = In; 
    assign r_shift1 = ShAmt[0] ? {Oper[0] ? 1'h0  : r_shift0[0],   r_shift0[15:1]} : r_shift0; 
    assign r_shift2 = ShAmt[1] ? {Oper[0] ? 2'h0  : r_shift1[1:0], r_shift1[15:2]} : r_shift1; 
    assign r_shift4 = ShAmt[2] ? {Oper[0] ? 4'h0  : r_shift2[3:0], r_shift2[15:4]} : r_shift2; 
    assign r_shift8 = ShAmt[3] ? {Oper[0] ? 8'h00 : r_shift4[7:0], r_shift4[15:8]} : r_shift4;

    //left: Oper[0] = 0 rotate left; Oper[0] = 1 shift left
    wire [15:0] l_shift0, l_shift1, l_shift2, l_shift4, l_shift8;
    assign l_shift0 = In;
    assign l_shift1 = ShAmt[0] ? {l_shift0[14:0], Oper[0] ? 1'h0  : l_shift0[15:15]} : l_shift0; 
    assign l_shift2 = ShAmt[1] ? {l_shift1[13:0], Oper[0] ? 2'h0  : l_shift1[15:14]} : l_shift1; 
    assign l_shift4 = ShAmt[2] ? {l_shift2[11:0], Oper[0] ? 4'h0  : l_shift2[15:12]} : l_shift2; 
    assign l_shift8 = ShAmt[3] ? {l_shift4[07:0], Oper[0] ? 8'h00 : l_shift4[15:08]} : l_shift4;

    assign Out = Oper[1] ? r_shift8 : l_shift8;
   
endmodule
