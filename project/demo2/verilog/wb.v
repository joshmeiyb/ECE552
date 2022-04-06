/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb ( writeback_data,
            Halt_MEMWB,
            mem_read_data, pcAdd2, ALU_Out, MemtoReg, pc_to_reg);
   /* TODO: Add appropriate inputs/outputs for your WB stage here*/

   // TODO: Your code here
   
   //outputs
   output wire [15:0] writeback_data;
   //inputs
   input wire Halt_MEMWB;
   input wire [15:0] mem_read_data;
   input wire [15:0] pcAdd2;           //PC + 2
   input wire [15:0] ALU_Out;
   input wire MemtoReg;
   input wire pc_to_reg;               //PC to Reg control
   
   assign writeback_data = Halt_MEMWB  ?  16'h0000 :
                           pc_to_reg   ?  pcAdd2 :
                           MemtoReg    ?  mem_read_data : 
                                          ALU_Out;
   
endmodule
