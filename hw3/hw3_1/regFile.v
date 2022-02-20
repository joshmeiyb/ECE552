/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   /* YOUR CODE HERE */
   assign err = 1'b0;

   wire [7:0] write_reg;
   
   assign write_reg[0] = (writeRegSel == 3'b000) & writeEn;
   assign write_reg[1] = (writeRegSel == 3'b001) & writeEn;
   assign write_reg[2] = (writeRegSel == 3'b010) & writeEn;
   assign write_reg[3] = (writeRegSel == 3'b011) & writeEn;
   assign write_reg[4] = (writeRegSel == 3'b100) & writeEn;
   assign write_reg[5] = (writeRegSel == 3'b101) & writeEn;
   assign write_reg[6] = (writeRegSel == 3'b110) & writeEn;
   assign write_reg[7] = (writeRegSel == 3'b111) & writeEn;

   wire [127:0] readData;

   reg16 reg16[7:0] (.clk(clk), .rst(rst), .write(write_reg), .wdata(writeData), .rdata(readData));
   
   assign read1Data = 	(read1RegSel == 3'b111) ? readData[127:112] :
	       			      (read1RegSel == 3'b110) ? readData[111:096] :	
                        (read1RegSel == 3'b101) ? readData[95 : 80] :	
                        (read1RegSel == 3'b100) ? readData[79 : 64] :	
                        (read1RegSel == 3'b011) ? readData[63 : 48] :	
                        (read1RegSel == 3'b010) ? readData[47 : 32] :	
                        (read1RegSel == 3'b001) ? readData[31 : 16] :	
	       						                       readData[15 : 0 ] ;	

	assign read2Data = 	(read2RegSel == 3'b111) ? readData[127:112] :
                        (read2RegSel == 3'b110) ? readData[111:096] :	
                        (read2RegSel == 3'b101) ? readData[95 : 80] :	
                        (read2RegSel == 3'b100) ? readData[79 : 64] :	
                        (read2RegSel == 3'b011) ? readData[63 : 48] :	
                        (read2RegSel == 3'b010) ? readData[47 : 32] :	
                        (read2RegSel == 3'b001) ? readData[31 : 16] :	
	       						                       readData[15 : 0 ] ;
			         


endmodule
