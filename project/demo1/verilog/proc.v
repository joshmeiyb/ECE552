/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */

   /*             Fetch          Decode			Execute			Memory			Writeback	*/

   wire [15:0]    instruction,          
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire
   wire

   fetch fetch(
               //Outputs
               .next_pc1(),
               .instruction(instruction),
               .err(),
               //Inputs
               .clk(),
               .rst(), 
               .pc(),
               .next_pc2(),
               .reg_to_pc(),
               .PCSrc(),
               .Halt()
   );

   decode decode(
               //Decode Outputs
               .read1Data(),
               .read2Data(),
               .err(),
               .extend_output(),
               //Control Outputs
               .Jump(),
               .Branch(),
               .MemtoReg(),
               .MemWrite(),
               .reg_to_pc(),
               .pc_to_reg(),
               .ALUOp(),
               .ALUSrc(),
               .ALU_invA(),
               .ALU_invB(),
               .ALU_Cin(),
               .Halt(),
               .SIIC(),
               .RTI(),
               //Inputs
               .instruction(),
               .writeback_data(),
               .clk(),
               .rst()
   );

   execute execute(
               //Outputs
               .next_pc2(),
               .ALU_Out(),
               .PCSrc(),
               .ALU_Zero(),         //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
               .ALU_Ofl(),          //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
               //Inputs
               .instruction(),
               .next_pc1(),
               .read1Data(),
               .read2Data(),
               .ALUSrc(),
               .ALU_Cin(),          //HOW TO CONNECT WITH OTHER MODULE?
               .ALUOp(),
               .ALU_invA(),
               .ALU_invB(),
               .ALU_sign(),
               .extend_output(),
               .Branch(),
               .Jump()
   );
   
   memory memory(
               //Outputs
               .mem_read_data(),
               //Inputs
               .clk(),
               .rst(),
               .mem_write_data(),
               .ALU_Out(),
               .MemRead(),
               .MemWrite(),
               .Halt()
   );

   wb wb(
               //Outputs
               .writeback_data(),
               //Inputs
               .mem_read_data(),
               .next_pc1(),
               .ALU_Out(),
               .MemtoReg(),
               .pc_to_reg()
   );
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
