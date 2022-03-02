/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (mem_read_data, clk, rst, mem_write_data, ALU_Out, MemRead, MemWrite, Halt);
   /* TODO: Add appropriate inputs/outputs for your memory stage here*/

   // TODO: Your code here
   output [15:0] mem_read_data;

   input clk, rst;
   input [15:0] mem_write_data;
   input [15:0] ALU_Out;
   input MemRead;
   input MemWrite;
   input Halt;

   memory2c Data_Memory(.data_out(mem_read_data), .data_in(mem_write_data), .addr(ALU_Out),
    .enable( MemRead | MemWrite), .wr(MemWrite), .createdump(Halt), .clk(clk), .rst(rst));
   
endmodule
