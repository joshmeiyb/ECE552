/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (clk, rst,
               ALU_Out, PCSrc, memWriteData, ALU_Zero, ALU_Ofl,
               instruction, read1Data, read2Data, 
               ALUSrc, ALU_Cin, ALUOp, ALU_invA, ALU_invB,
               ALU_sign, extend_output, Branch, Jump,
               reg_to_pc, pcAdd2, branch_jump_pc,

               //---------------------------------------------------------//
               forwardA, forwardB,
               RegisterRd_IDEX, RegisterRs_IFID,
               ALU_Out_EXMEM, 
               writeback_data
               //---------------------------------------------------------//
               
               );
   /* TODO: Add appropriate inputs/outputs for your execute stage here*/

   // TODO: Your code here
   //outputs
   output [15:0] branch_jump_pc;
   output [15:0] ALU_Out;
   output [15:0] memWriteData;
   output PCSrc;
   output ALU_Zero;                 //DO WE NEED THIS SIGNAL?
   output ALU_Ofl;                  //DO WE NEED THIS SIGNAL?
   //inputs

   //-----------------------------//
   //Synthesis STA
   input clk;
   input rst;
   //-----------------------------//

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
   input [2:0] RegisterRd_IDEX;
   input [2:0] RegisterRs_IFID;
   input [15:0] ALU_Out_EXMEM;
   input [15:0] writeback_data;

   //forwarding enable signal is generated by forwarding_unit.v, then forwarding logic solved in execution stage
   wire [15:0] InA_forward, InB_forward;
   wire [15:0] InA_forward_temp;
   
   //-------------------------------------------------------------------------------------------------------------//
   //Synthesis STA
   wire PCSrc_dff;
   wire [15:0] writeback_data_dff;  //input

   wire [15:0] InA_forward_dff, InB_forward_dff;

   reg1 PCSrc_delay_reg (.clk(clk), .rst(rst), .write(1'b1), .wdata(PCSrc_dff), .rdata(PCSrc));
   reg16 writeback_data_delay_reg (.clk(clk), .rst(rst), .write(1'b1), .wdata(writeback_data), .rdata(writeback_data_dff));
   reg16 InA_forward_delay_reg (.clk(clk), .rst(rst), .write(1'b1), .wdata(InA_forward), .rdata(InA_forward_dff));
   reg16 InB_forward_delay_reg (.clk(clk), .rst(rst), .write(1'b1), .wdata(InB_forward), .rdata(InB_forward_dff));

   //-------------------------------------------------------------------------------------------------------------//
   
   wire [15:0] InB_forward_noImm;
   wire [15:0] pcAdd2_add_extend_output;
   assign branch_jump_pc = reg_to_pc ? ALU_Out : pcAdd2_add_extend_output;
   //Must not shift left by 1bit
   cla_16b PC_addr_adder2(.sum(pcAdd2_add_extend_output), .c_out(), .a(pcAdd2), .b(extend_output), .c_in(1'b0));

   //-------------------------------------Branch Decesion Unit--------------------------------------//
   wire Branch_AND;
   reg Branch_condition;
   assign PCSrc_dff/*PCSrc*/ = ( Branch_AND | Jump );
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
   //----------------------------------------------------------------------------------------------//

   //--------------------------------Forwarding Logic in Execution Stage--------------------------------------//
   assign InA_forward = (forwardA == 2'b10)  ? ALU_Out_EXMEM   :  //EX-EX
                        (forwardA == 2'b01)  ? writeback_data_dff/*writeback_data*/  :  //MEM-EX
                        read1Data;
                        
   assign InB_forward = ALUSrc               ? extend_output   :
                        (forwardB == 2'b10)  ? ALU_Out_EXMEM   :  //EX-EX
                        (forwardB == 2'b01)  ? writeback_data_dff/*writeback_data*/  :  //MEM-EX
                        read2Data;

   // alu alu(.InA(InA_forward_dff/*InA_forward*/), .InB(InB_forward_dff/*InB_forward*/), .Cin(ALU_Cin), 
   // .Oper(ALUOp), .invA(ALU_invA), .invB(ALU_invB), .sign(ALU_sign),
   // .Out(ALU_Out), .Zero(ALU_Zero), .Ofl(ALU_Ofl));

   alu alu_dff(.clk(clk), .rst(rst), .InA(InA_forward_dff/*InA_forward*/), .InB(InB_forward_dff/*InB_forward*/), .Cin(ALU_Cin), 
               .Oper(ALUOp), .invA(ALU_invA), .invB(ALU_invB), .sign(ALU_sign),
               .Out(ALU_Out), .Zero(ALU_Zero), .Ofl(ALU_Ofl));

   
   //InB_forward_noImm creates an exception for ST forwarding which do not use extended_output to ALU input B
   //Since the InB_forward has the first priority MUX for extend_output
   assign InB_forward_noImm = (forwardB == 2'b10) ? ALU_Out_EXMEM  :  //EX-EX
                              (forwardB == 2'b01) ? writeback_data_dff/*writeback_data*/ :  //MEM-EX
                              read2Data;

   assign memWriteData = InB_forward_noImm;
   //----------------------------------------------------------------------------------------------------------//

endmodule
