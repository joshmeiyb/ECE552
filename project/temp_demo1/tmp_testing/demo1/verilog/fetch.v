/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, instruction, next_pc1, next_pc2, ALU_Out, err, reg_to_pc, PCSrc, Halt);
   /* TODO: Add appropriate inputs/outputs for your fetch stage here*/
   
   input clk,rst;
   input [15:0] ALU_Out;
   input [15:0] next_pc2;                                //calculated in execute stage
                                                         //next_pc2 = next_pc1 + extend_output
   input reg_to_pc;
   input PCSrc;
   input Halt;

   output [15:0] next_pc1;
   output [15:0] instruction;
   output err; 

   // TODO: Your code here

   wire [15:0] pcCurrent;                                //intermediate value before adding 2

   wire [15:0] pc_Halt;
   wire [15:0] new_pc;
   wire [15:0] next_pc;
   
     
   assign next_pc = PCSrc ? next_pc2 : next_pc1;         //PCSrc is the select signal to decide PC+2 or PC+2+address to be write into PC
   assign new_pc = reg_to_pc ? ALU_Out : next_pc;        //reg_to_pc is the control signal for instruction JR, JALR
   assign pc_Halt = Halt ? pcCurrent : new_pc;           //Halt signal decides if the instruction fetch need to stop
                                                         //pc_Halt is the input of PC_reg

   dff PC_reg[15:0](.q(pcCurrent), .d(pc_Halt), .clk(clk), .rst(rst));

   cla_16b PC_addr_adder1(.sum(next_pc1), .c_out(err), .a(pcCurrent), .b(16'h0002), .c_in(1'b0)); 
   //c_out is overflow port, when there is an overflow error, an error will be output

   memory2c Instruction_Memory(.data_out(instruction), .data_in(16'h0000), .addr(pcCurrent), 
   .enable(~rst), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst)); //enable port is read enable
   
endmodule
