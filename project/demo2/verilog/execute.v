/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (ALU_Out, PCSrc, ALU_Zero, ALU_Ofl,
               instruction, read1Data, read2Data, 
               ALUSrc, ALU_Cin, ALUOp, ALU_invA, ALU_invB,
               ALU_sign, extend_output, Branch, Jump,
               reg_to_pc, pcAdd2, branch_jump_pc,
               forwardA, forwardB,
               ALU_Out_EXMEM, writeback_data
               //---------------------------------------------------------//
               
               );
   /* TODO: Add appropriate inputs/outputs for your execute stage here*/

   // TODO: Your code here
   //outputs
   output [15:0] branch_jump_pc;
   output [15:0] ALU_Out;
   output PCSrc;
   output ALU_Zero;                 //DO WE NEED THIS SIGNAL?
   output ALU_Ofl;                  //DO WE NEED THIS SIGNAL?

   //inputs
   input [15:0] instruction;
   input reg_to_pc;
   input [15:0] pcAdd2;
   input [15:0] read1Data;
   input [15:0] read2Data;
   input ALUSrc;
   input ALU_Cin;
   input [3:0] ALUOp;
   input ALU_invA, ALU_invB;
   input ALU_sign;
   input [15:0] extend_output;      //5:1 extend MUX output at decode stage
                                    //This provides: 1. the addr_offset added to next_pc1
                                    //               2. the InB of ALU
   input Branch;
   input Jump;
   input [1:0] forwardA, forwardB;
   input [15:0] ALU_Out_EXMEM;
   input [15:0] writeback_data;

   
   wire [15:0] Rs_or_pcAdd2;
   assign Rs_or_pcAdd2 = reg_to_pc ? ALU_Out : pcAdd2;

   //Must not shift left by 1bit
   //cla_16b PC_addr_adder2(.sum(next_pc2), .c_out(), .a(next_pc1), .b(extend_output), .c_in(1'b0));
   cla_16b PC_addr_adder2(.sum(branch_jump_pc), .c_out(), .a(Rs_or_pcAdd2), .b(extend_output), .c_in(1'b0));

   //To branch or not branch
   wire Branch_AND;
   reg Branch_condition;
   assign PCSrc = ( Branch_AND | Jump );
   assign Branch_AND = Branch & Branch_condition;
   always @(*) begin
      case(instruction[15:11])
         5'b01100 : begin //BEQZ
            Branch_condition = ~|ALU_Out;    //ALU_Out is zero, ALU_Out is InAA (Oper == 4'b1111)
         end
         5'b01101 : begin //BNEZ
            Branch_condition = |ALU_Out;     //ALU_Out is non-zero, ALU_Out is InAA (Oper == 4'b1111)
         end
         5'b01110 : begin //BLTZ
            Branch_condition = ALU_Out[15];  //MSB of ALU_Out is 1, negative number
         end
         5'b01111 : begin //BGEZ
            Branch_condition = ~ALU_Out[15];  //MSB of ALU_Out is 0, positive number
         end
         default : begin
            Branch_condition = 1'b0;
         end
      endcase
   end

   wire [15:0] InA_forward, InB_forward;
   assign InA_forward = (forwardA == 2'b10) ? ALU_Out_EXMEM :
                        (forwardA == 2'b01) ? writeback_data :
                        read1Data;
                        
   assign InB_forward = ALUSrc ? extend_output :
                        (forwardB == 2'b10) ? ALU_Out_EXMEM :
                        (forwardB == 2'b01) ? writeback_data :
                        read2Data;

   alu alu(.InA(InA_forward), .InB(InB_forward), .Cin(ALU_Cin), 
   .Oper(ALUOp), .invA(ALU_invA), .invB(ALU_invB), .sign(ALU_sign),
   .Out(ALU_Out), .Zero(ALU_Zero), .Ofl(ALU_Ofl));




endmodule
