/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (writeback_data, mem_read_data, next_pc1, ALU_Out, MemtoReg, pc_to_reg);
   /* TODO: Add appropriate inputs/outputs for your WB stage here*/

   // TODO: Your code here
   output wire [15:0] writeback_data;
   input wire [15:0] mem_read_data;
   input wire [15:0] next_pc1; //PC + 2
   input wire [15:0] ALU_Out;
   input wire MemtoReg;
   input wire pc_to_reg; //PC to Reg control

   assign writeback_data = pc_to_reg   ?  next_pc1 :
                           MemtoReg    ?  mem_read_data : 
                                          ALU_Out;
   
endmodule
