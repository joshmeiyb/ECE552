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

   wire [7:0] write;
   
   assign write[0] = (writeRegSel == 3'b000) & writeEn;
   assign write[1] = (writeRegSel == 3'b001) & writeEn;
   assign write[2] = (writeRegSel == 3'b010) & writeEn;
   assign write[3] = (writeRegSel == 3'b011) & writeEn;
   assign write[4] = (writeRegSel == 3'b100) & writeEn;
   assign write[5] = (writeRegSel == 3'b101) & writeEn;
   assign write[6] = (writeRegSel == 3'b110) & writeEn;
   assign write[7] = (writeRegSel == 3'b111) & writeEn;

   wire [15:0] readData [0:7]; //width:16, depth:8

   reg16 reg16_1 (.clk(clk), .rst(rst), .write(write[0]), .wdata(writeData), .rdata(readData[0]));
   reg16 reg16_2 (.clk(clk), .rst(rst), .write(write[1]), .wdata(writeData), .rdata(readData[1]));
   reg16 reg16_3 (.clk(clk), .rst(rst), .write(write[2]), .wdata(writeData), .rdata(readData[2]));
   reg16 reg16_4 (.clk(clk), .rst(rst), .write(write[3]), .wdata(writeData), .rdata(readData[3]));
   reg16 reg16_5 (.clk(clk), .rst(rst), .write(write[4]), .wdata(writeData), .rdata(readData[4]));
   reg16 reg16_6 (.clk(clk), .rst(rst), .write(write[5]), .wdata(writeData), .rdata(readData[5]));
   reg16 reg16_7 (.clk(clk), .rst(rst), .write(write[6]), .wdata(writeData), .rdata(readData[6]));
   reg16 reg16_8 (.clk(clk), .rst(rst), .write(write[7]), .wdata(writeData), .rdata(readData[7]));
   
   assign read1Data = 	(read1RegSel == 3'b111) ? readData[7] :
	       			      (read1RegSel == 3'b110) ? readData[6] :	
                        (read1RegSel == 3'b101) ? readData[5] :	
                        (read1RegSel == 3'b100) ? readData[4] :	
                        (read1RegSel == 3'b011) ? readData[3] :	
                        (read1RegSel == 3'b010) ? readData[2] :	
                        (read1RegSel == 3'b001) ? readData[1] :	
	       						                       readData[0] ;	

	assign read2Data = 	(read2RegSel == 3'b111) ? readData[7] :
                        (read2RegSel == 3'b110) ? readData[6] :	
                        (read2RegSel == 3'b101) ? readData[5] :	
                        (read2RegSel == 3'b100) ? readData[4] :	
                        (read2RegSel == 3'b011) ? readData[3] :	
                        (read2RegSel == 3'b010) ? readData[2] :	
                        (read2RegSel == 3'b001) ? readData[1] :	
	       						                       readData[0] ;
			         


endmodule
