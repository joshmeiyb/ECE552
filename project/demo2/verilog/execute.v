/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (next_pc2, ALU_Out, PCSrc, ALU_Zero, ALU_Ofl,
               instruction, next_pc1, read1Data, read2Data, 
               ALUSrc, ALU_Cin, ALUOp, ALU_invA, ALU_invB,
               ALU_sign, extend_output, Branch, Jump, 
               stall, writeEn,
               //--------------hazard detection unit & forwarding -------//
               I_format, R_format,
               RegisterRd_IDEX, RegisterRd_EXMEM
               RegisterRs, RegisterRt,
               RegWrite_IDEX, RegWrite_EXMEM,
               //---------------------------------------------------------//
               //RegWrite_EXMEM, 
               RegWrite_MEMWB, 
               //RegisterRd_EXMEM, 
               RegisterRd_MEMWB,
               RegisterRs_IDEX, 
               RegisterRt_IDEX,
               ALU_Out_EXMEM, writeback_data
               //---------------------------------------------------------//
               );
   /* TODO: Add appropriate inputs/outputs for your execute stage here*/

   // TODO: Your code here
   output [15:0] next_pc2;
   output [15:0] ALU_Out;
   output PCSrc;
   output ALU_Zero;                 //DO WE NEED THIS SIGNAL?
   output ALU_Ofl;                  //DO WE NEED THIS SIGNAL?
   
   input [15:0] instruction;
   input [15:0] next_pc1;
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


   hazard_detection_unit HDU(
      //inputs
      .R_format(R_format),
      .I_format(I_format),
      .writeRegSel_IDEX(RegisterRd_IDEX),
      .writeRegSel_EXMEM(RegisterRd_EXMEM),     
      .read1RegSel_IFID(RegisterRs),      //RegisterRs_IFID
      .read2RegSel_IFID(RegisterRt),      //RegisterRt_IFID
      .RegWrite_IDEX(RegWrite_IDEX),
      .RegWrite_EXMEM(RegWrite_EXMEM),
      //.branch_taken(PCSrc),
      //outputs
      .stall(stall),
      .writeEn(writeEn)
   );

   wire forward_EX_to_EX, forward_MEM_to_EX;

   forwarding_unit FU(
      //inputs
      .RegWrite_EXMEM(RegWrite_EXMEM),
      .RegWrite_MEMWB(RegWrite_MEMWB),
      .RegisterRd_EXMEM(RegisterRd_EXMEM),
      .RegisterRd_MEMWB(RegisterRd_MEMWB),
      .RegisterRs_IDEX(RegisterRs_IDEX),
      .RegisterRt_IDEX(RegisterRt_IDEX),
      .I_format(I_format),
      .R_format(R_format),
      //outputs
      .forwardA(forwardA),
      .forwardB(forwardB)
   );

   //wire [15:0]addr_offset;
   //assign addr_offset = {extend_output[14:0], 1'b0}; //shift left 1 bit

   //Must not shift left by 1bit
   cla_16b PC_addr_adder2(.sum(next_pc2), .c_out(), .a(next_pc1), .b(extend_output), .c_in(1'b0));

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

   wire [1:0] forwardA, forwardB;
   wire [15:0] InA_forward, InB_forward;
   assign InA_forward = (forwardA == 2'b10) ? ALU_Out_EXMEM :
                        (forwardA == 2'b01) ? writeback_data :
                        read1Data;
                        
   assign InB_forward = (forwardB == 2'b10) ? ALU_Out_EXMEM :
                        (forwardB == 2'b01) ? writeback_data :
                        read2Data;

   alu alu(.InA(InA_forward), .InB(InB_forward), .Cin(ALU_Cin), 
   .Oper(ALUOp), .invA(ALU_invA), .invB(ALU_invB), .sign(ALU_sign),
   .Out(ALU_Out), .Zero(ALU_Zero), .Ofl(ALU_Ofl));
   /*
   wire [15:0] alu_input_mux;
   assign alu_input_mux =  ALUSrc ? extend_output : read2Data; 
   
   alu alu(.InA(read1Data), .InB(alu_input_mux), .Cin(ALU_Cin), 
   .Oper(ALUOp), .invA(ALU_invA), .invB(ALU_invB), .sign(ALU_sign),
   .Out(ALU_Out), .Zero(ALU_Zero), .Ofl(ALU_Ofl));
   */
   




endmodule
