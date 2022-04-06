/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (ALU_Out, PCSrc, memWriteData, ALU_Zero, ALU_Ofl,
               instruction, read1Data, read2Data, 
               ALUSrc, ALU_Cin, ALUOp, ALU_invA, ALU_invB,
               ALU_sign, extend_output, Branch, Jump,
               reg_to_pc, pcAdd2, branch_jump_pc,
               /*forward_MEM_to_EX,*/ forwardA, forwardB,
               /*MemRead_MEMWB,*/ 
               /*mem_read_data_MEMWB,*/ RegisterRd_IDEX, RegisterRs_IFID, /*stall_EX_to_MEMEX_forwarding*//*mem_read_data,*/
               ALU_Out_EXMEM, writeback_data
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

   //output stall_EX_to_MEMEX_forwarding;

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
   
   //input forward_MEM_to_EX;
   input [1:0] forwardA, forwardB;
   //input [15:0] mem_read_data_MEMWB;
   //input MemRead_MEMWB;
   //input [15:0] mem_read_data;
   input [2:0] RegisterRd_IDEX;
   input [2:0] RegisterRs_IFID;
   input [15:0] ALU_Out_EXMEM;
   input [15:0] writeback_data;

   wire [15:0] InB_forward_noImm;
   wire [15:0] pcAdd2_add_extend_output;
   //assign Rs_or_pcAdd2 = reg_to_pc ? ALU_Out : pcAdd2;

   assign branch_jump_pc = reg_to_pc ? ALU_Out : pcAdd2_add_extend_output;

   //Must not shift left by 1bit
   //cla_16b PC_addr_adder2(.sum(next_pc2), .c_out(), .a(next_pc1), .b(extend_output), .c_in(1'b0));
   cla_16b PC_addr_adder2(.sum(/*branch_jump_pc*/pcAdd2_add_extend_output), .c_out(), .a(pcAdd2), .b(extend_output), .c_in(1'b0));

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
   wire [15:0] InA_forward_temp;
   
   /*
   assign InA_forward = (MemRead_IDEX & (RegisterRd_IDEX == RegisterRs_IFID))  ?  stall_EX_to_MEMEX_forwarding :     //mem_read_data
                        (forwardA == 2'b10)                                    ?  ALU_Out_EXMEM :  //EX-EX
                        (forwardA == 2'b01)                                    ?  writeback_data : //MEM-EX
                                                                                  read1Data;
                                                                                  
   */

   //wire [1:0] forwardA_temp;
   //assign forwardA_temp = (MemRead_MEMWB) ? 2'b01 : forwardA;   //exeception case for MEM-EX to Rs, when LD has the RAW hazard, need MEM-EX forwarding rather than EX-EX forwarding
   
   //assign forwardA_temp = (MemRead_MEMWB /*& (instruction[15:11] == 5'b10001)*/) ? 2'b01 : forwardA;
   

   assign InA_forward = (forwardA/*_temp*/ == 2'b10) ? ALU_Out_EXMEM :  //EX-EX
                        (forwardA/*_temp*/ == 2'b01) ? writeback_data : //MEM-EX
                        read1Data;
                        
   assign InB_forward = ALUSrc ? extend_output :
                        (forwardB == 2'b10) ? ALU_Out_EXMEM :  //EX-EX
                        (forwardB == 2'b01) ? writeback_data : //MEM-EX
                        read2Data;

   /*assign InA_forward_temp = forward_MEM_to_EX ? mem_read_data_MEMWB : //MEM-EX prior to EX-EX only for LD instruction 
                             InA_forward;
   */

   alu alu(.InA(InA_forward/*InA_forward_temp*/), .InB(InB_forward), .Cin(ALU_Cin), 
   .Oper(ALUOp), .invA(ALU_invA), .invB(ALU_invB), .sign(ALU_sign),
   .Out(ALU_Out), .Zero(ALU_Zero), .Ofl(ALU_Ofl));

   assign InB_forward_noImm = (forwardB == 2'b10) ? ALU_Out_EXMEM :  //EX-EX
                              (forwardB == 2'b01) ? writeback_data : //MEM-EX
                              read2Data;

   assign memWriteData = InB_forward_noImm;

endmodule
