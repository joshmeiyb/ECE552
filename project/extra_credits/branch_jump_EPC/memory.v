/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (mem_read_data, clk, rst, mem_write_data, ALU_Out, MemRead, MemWrite, Halt, data_mem_err, data_mem_stall, data_mem_done);
   /* TODO: Add appropriate inputs/outputs for your memory stage here*/

   // TODO: Your code here
   output [15:0] mem_read_data;
   output data_mem_err;             //phase 2.1 mem_align
   output data_mem_stall;           //phase 2.2 mem_stall
   output data_mem_done;

   input clk, rst;
   input [15:0] mem_write_data;
   input [15:0] ALU_Out;
   input MemRead;
   input MemWrite;
   input Halt;

   wire MemRead_in, MemWrite_in;    //This signal is the AND Gates output before writing or reading the data memory 
                                    //If WB is halting, don't read or write memory, 
                                    //this is only detected in the random tests in demo2, which is easy to be ignored
   
   assign MemRead_in = MemRead & ~Halt;
   assign MemWrite_in = MemWrite & ~Halt;

   wire data_mem_err_temp;

   mem_system Data_Memory(
      //Outputs
      .DataOut(mem_read_data), 
      .Done(data_mem_done),                  //NOT SURE HOW TO CONNECT DONE SIGNAL
      .Stall(data_mem_stall), 
      .CacheHit(), 
      .err(/*data_mem_err*/data_mem_err_temp), 
      //Inputs
      .Addr(ALU_Out /*& (MemRead_in | MemWrite_in)*/), 
      .DataIn(mem_write_data), 
      .Rd(MemRead_in & (~ALU_Out[0])), 
      .Wr(MemWrite_in & (~ALU_Out[0])), 
      .createdump(Halt), 
      .clk(clk), 
      .rst(rst)
   );


   //Not solve the problem, need to figure out why data_mem_err is 1'b1 
   assign data_mem_err = data_mem_err_temp & (MemRead_in | MemWrite_in);
   
endmodule
