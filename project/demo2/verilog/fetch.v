/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, stall, 
               branch_jump_pc, PCSrc, 
               Halt_fetch, pcAdd2, 
               instruction, err
               );
   /* TODO: Add appropriate inputs/outputs for your fetch stage here*/
   
   input clk,rst;
   input stall;
   input [15:0] branch_jump_pc;  //used to be next_pc2
   input PCSrc;                  //branch_jump_taken signal
   input Halt_fetch;
   output [15:0] pcAdd2; //PC+2
   output [15:0] instruction;
   output err; 
   
   // TODO: Your code here

   wire [15:0] pcNew;      //input of PC_reg
   wire [15:0] pcCurrent;  //output of PC_reg,
                           //intermediate value before adding 2

   assign pcNew = (Halt_fetch | stall)    ?  pcCurrent        : 
                  PCSrc                   ?  branch_jump_pc   : 
                                             pcAdd2;

   cla_16b PC_addr_adder1(.sum(pcAdd2), .c_out(err), .a(pcCurrent), .b(16'h0002), .c_in(1'b0));        
                                                                                                   //c_out is overflow port, 
                                                                                                   //when there is an overflow error, an error will be output                               

   reg16 PC_reg (.clk(clk), .rst(rst), .write(1'b1), .wdata(pcNew), .rdata(pcCurrent));

   memory2c Instruction_Memory(.data_out(instruction), .data_in(16'h0000), .addr(pcCurrent), 
   .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst)); //enable port is read enable

   
   
endmodule
