/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/


/*
Optimization TODO list
1. move jump decision to decode
2. create PCSrc_jump for jump instructions
3. delete the IDEX flush signal for jump instructions
4. implementing siic/rti as special jump case
5. move branch decision to decode, creating partial ALU for branch in decode.(copy and paste)
*/

module decode (
               //Inputs
               input [15:0] instruction, 
               input clk, 
               input rst,
               input wire RegWrite_in,               //Edited at pipeline design
               input wire [2:0] RegisterRd_in,        //Edited at pipeline design
               input [15:0] writeback_data,
               //Decode Outputs
               output wire [15:0] read1Data, 
               output wire [15:0] read2Data,
               output wire err,
               output wire [15:0] extend_output,
               output wire [2:0] RegisterRd_out,      //Edited at pipeline design
               output wire [2:0] RegisterRs_out,
               output wire [2:0] RegisterRt_out,
               //Control Outputs
               output wire MemtoReg,                  //control signal in wb stage
               output wire MemRead,
               output wire MemWrite,
               output wire RegWrite_out,              //Edited at pipeline design
               output wire [3:0] ALUOp,
               output wire ALUSrc,
               output wire ALU_invA, ALU_invB,        //connect to ALU ports invA, invB
               output wire ALU_Cin,
               output wire Halt_decode,
               output wire SIIC,
               output wire RTI,
               output wire [15:0] EPC_out,
               //output wire R_format,
               //output wire I_format,
               //----------------------------------Branch/Jump----------------------------------//
               output wire reg_to_pc,                 //For J, JR
               output wire pc_to_reg,                 //For JAL, JALR
               input [15:0] pcAdd2,
               input forwardA_MEMID, 
               input forwardB_MEMID, 
               //output wire [15:0] jump_pc,
               //output wire [15:0] branch_pc,
               output [15:0] branch_jump_pc,
               output PCSrc
               //output wire Jump, 
               //output wire Branch,
               
               //output wire PCSrc_jump
               //-------------------------------------------------------------------------------//
               );
   /* TODO: Add appropriate inputs/outputs for your decode stage here*/
   // TODO: Your code here

   //--------------------EPC------------------------------//
   reg16 EPC_reg(.clk(clk), .rst(rst), .write(/*1'b1*/SIIC), .wdata(pcAdd2/*EPC_in*/), .rdata(EPC_out));
   //-----------------------------------------------------//

   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   //-------------------------------------Branch/Jump Decesion Unit--------------------------------------//
   /////////////////////////////////////////////////////////////////////////
   //J      PC <- PC + 2 + D(sign ext.)
   //JAL    PC <- PC + 2 + D(sign ext.)         R7 <- PC + 2,  
   
   /////////////////////////////////////////////////////////////////////////
   //------------------THIS SHOULD BE SOLVED IN EXECUTE-------------------//
   //Need ALU
   //JR     PC <- Rs + I(sign ext.)
   //JALR   PC <- Rs + I(sign ext.)             R7 <- PC + 2, 
   /////////////////////////////////////////////////////////////////////////

   wire Jump;
   wire Branch;
   wire [15:0] InA_forward, InB_forward;
   wire [15:0] ALU_Out;
   //wire [15:0] jump_pc_new;
   //wire [15:0] branch_pc_new; 
   wire [15:0] branch_jump_pc_new; 
   wire [15:0] jump_pc_addr_adder_input_a;
   wire [15:0] branch_pc_addr_adder_input_a;
   wire [15:0] pc_addr_adder_input_a;
   wire Branch_AND;
   reg Branch_condition;

   //MEM-ID forwarding
   assign InA_forward = (forwardA_MEMID) ?   writeback_data : read1Data;     
   
   assign InB_forward = ALUSrc           ?   extend_output  :
                        (forwardB_MEMID) ?   writeback_data : 
                                             read2Data;          
   
   alu_branch_jump alu_branch_jump(
                                    .InA(InA_forward), 
                                    .InB(InB_forward), 
                                    .Cin(1'b0), 
                                    .Oper(ALUOp), 
                                    .invA(1'b0), 
                                    .invB(1'b0), 
                                    .sign(1'b0),
                                    .Out(ALU_Out),
                                    .Zero(),
                                    .Ofl());

   // assign PCSrc_jump = ( /*Branch_AND |*/ Jump );
   // assign PCSrc_branch = ( Branch_AND /*| Jump*/ );
   assign Branch_AND = Branch & Branch_condition;
   assign PCSrc = ( Branch_AND | Jump );
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

   //For JR, JALR, PC <- Rs + I(sign ext.)
   //assign jump_pc_addr_adder_input_a = ( (instruction[15:11] == 5'b00101) | (instruction[15:11] == 5'b00111) ) ? ALU_Out : pcAdd2;
   //assign branch_pc_addr_adder_input_a = pcAdd2;
   assign pc_addr_adder_input_a = ( (instruction[15:11] == 5'b00101) | (instruction[15:11] == 5'b00111) ) ? ALU_Out : pcAdd2;

   cla_16b jump_pc_addr_adder(.sum(branch_jump_pc_new), .c_out(), .a(pc_addr_adder_input_a/*jump_pc_addr_adder_input_a*//*pcAdd2*/), .b(extend_output), .c_in(1'b0));
   assign branch_jump_pc =  reg_to_pc ? ALU_Out : branch_jump_pc_new;
   //----------------------------------------------------------------------------------------------------//
   ////////////////////////////////////////////////////////////////////////////////////////////////////////


   wire control_err, regFile_err;
   assign err = control_err | regFile_err;

   //------------4:1 MUX write address selecting write registers-----------------//
   //wire [2:0] RegisterRd;         //3-bit control signal select the write back address of regFile
   wire [1:0] RegDst;               //2-bit control signal for RegisterRd
   
   //Edited at pipeline design
   assign RegisterRd_out =    (RegDst == 2'b11) ?  3'h7 :                //write to R7, hard coded 3'b111
                              (RegDst == 2'b10) ?  instruction[4:2] :    //write to Rd, xxxxx sss ttt ddd xx, bit[4:2]
                              (RegDst == 2'b01) ?  instruction[7:5] :    //write to Rd, xxxxx sss ddd iiiii, bit[7:5], 5-bit immediate number
                                                   instruction[10:8];    //write to Rs, bit[10:8]
   assign RegisterRs_out = instruction[10:8];
   assign RegisterRt_out = instruction[7:5]; 
   
   //-------------------------------------------------Register File module with bypassing-----------------------------------------------//
   //Register File with bypass to read/write same data concurrently
   regFile_bypass regFile( 
                           //Outputs
                           .read1Data(read1Data), .read2Data(read2Data), .err(regFile_err),
                           //Inputs
                           .clk(clk), .rst(rst), .read1RegSel(instruction[10:8]), .read2RegSel(instruction[7:5]), 
                           .writeRegSel(RegisterRd_in), .writeData(writeback_data), .writeEn(RegWrite_in)); //Edited at pipeline design
   //-----------------------------------------------------------------------------------------------------------------------------------//


   //Jump: signed extended, instr[5:0], instr[7:0], instr[10:0]
   //zero extended: instr[4:0], instr[7:0]
   wire [15:0] sign_ext_11bit, sign_ext_8bit, sign_ext_5bit;
   wire [15:0] zero_ext_8bit, zero_ext_5bit;
   assign sign_ext_11bit = { {5{instruction[10]}}, instruction[10:0] };
   assign sign_ext_8bit = { {8{instruction[7]}}, instruction[7:0] };
   assign sign_ext_5bit = { {11{instruction[4]}}, instruction[4:0] };
   assign zero_ext_8bit = { {8{1'b0}}, instruction[7:0] };
   assign zero_ext_5bit = { {11{1'b0}}, instruction[4:0] };
   
   wire [2:0] ext_select; //select sign extend or zero extend
   
   assign extend_output =  (ext_select == 3'b000) ? sign_ext_5bit  :
                           (ext_select == 3'b001) ? sign_ext_8bit  :
                           (ext_select == 3'b010) ? sign_ext_11bit :
                           (ext_select == 3'b011) ? zero_ext_5bit  :
                                                    zero_ext_8bit;
   
   control control(
                  //Inputs
                  .Opcode(instruction[15:11]),  
                  .four_mode(instruction[1:0]),
                  //Outputs
                  .RegDst(RegDst),     //internal selecting signal between "control unit" and "write_addr MUX" in execute
                  .Jump(Jump), 
                  .Branch(Branch), 
                  .ext_select(ext_select),
                  .MemtoReg(MemtoReg), 
                  .ALUOp(ALUOp), 
                  .ALU_invA(ALU_invA), 
                  .ALU_invB(ALU_invB), 
                  .ALU_Cin(ALU_Cin),
                  .MemRead(MemRead),
                  .MemWrite(MemWrite), 
                  .ALUSrc(ALUSrc), 
                  .RegWrite(RegWrite_out), 
                  .reg_to_pc(reg_to_pc),
                  .pc_to_reg(pc_to_reg),
                  .Halt(Halt_decode), 
                  .err(control_err),
                  .SIIC(SIIC),
                  .RTI(RTI)
                  //.R_format(R_format),
                  //.I_format(I_format)
                  );

   

endmodule
