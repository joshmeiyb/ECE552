/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/

module decode (instruction, writeback_data, clk, rst,
               read1Data, read2Data, extend_output, Jump, Branch, 
               MemtoReg, ALUOp, ALU_invA, ALU_invB, ALU_Cin, 
               MemRead, MemWrite, ALUSrc, reg_to_pc, pc_to_reg,
               Halt, err, SIIC, RTI);
   /* TODO: Add appropriate inputs/outputs for your decode stage here*/
   // TODO: Your code here

   //Inputs
   input [15:0] instruction;
   input [15:0] writeback_data;
   input clk, rst;
   
   //Decode Outputs
   output wire [15:0] read1Data, read2Data;
   output wire err;
   output wire [15:0] extend_output;
   //Control Outputs
   output wire Jump;
   output wire Branch;
   output wire MemtoReg;            //control signal in wb stage
   output wire MemRead;
   output wire MemWrite;
   output wire reg_to_pc;           //MUX select signal in fetch stage
   output wire pc_to_reg;           //MUX select signal in writeback stage
   output wire [3:0] ALUOp;
   output wire ALUSrc;
   output wire ALU_invA, ALU_invB;  //connect to ALU ports invA, invB
   output wire ALU_Cin;
   output wire Halt;
   output wire SIIC;
   output wire RTI;
    
   
   wire control_err, regFile_err;
   assign err = control_err | regFile_err;

   //------------4:1 MUX write address selecting write registers-----------------//
   wire [2:0] write_reg_addr;       //3-bit control signal select the write back address of regFile
   wire [1:0] RegDst;               //2-bit control signal for write_reg_addr
   assign write_reg_addr =    (RegDst == 2'b11) ?  3'h7 :                //write to R7, hard coded 3'b111
                              (RegDst == 2'b10) ?  instruction[4:2] :    //write to Rd, xxxxx sss ttt ddd xx, bit[4:2]
                              (RegDst == 2'b01) ?  instruction[7:5] :    //write to Rd, xxxxx sss ddd iiiii, bit[7:5], 5-bit immediate number
                                                   instruction[10:8];    //write to Rs, bit[10:8]
   ////////////////////////////////////////////////////////////////////////////////

   //-------------------------Register File--------------------------------------//
   wire RegWrite;            //regFile write enable signal
   regFile regFile( 
                  //Outputs
                  .read1Data(read1Data), .read2Data(read2Data), .err(regFile_err),
                  //Inputs
                  .clk(clk), .rst(rst), .read1RegSel(instruction[10:8]), .read2RegSel(instruction[7:5]), 
                  .writeRegSel(write_reg_addr), .writeData(writeback_data), .writeEn(RegWrite));
   ////////////////////////////////////////////////////////////////////////////////


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
                  .RegWrite(RegWrite), 
                  .reg_to_pc(reg_to_pc),
                  .pc_to_reg(pc_to_reg),
                  .Halt(Halt), 
                  .err(control_err),
                  .SIIC(SIIC),
                  .RTI(RTI)
                  );

endmodule
