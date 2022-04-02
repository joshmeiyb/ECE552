/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc_unpipelined (/*AUTOARG*/
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

   /*             Fetch          Decode            Execute			   Memory			Writeback	*/

   wire           err_fetch,     err_decode;
   wire           Halt;          //Halt                                             //Halt
   wire                          SIIC;
   wire                          RTI;
   wire [15:0]    instruction;   //instruction     //instruction 
   wire [15:0]    next_pc1;                        //next_pc1                       //next_pc1
   wire [15:0]    next_pc2;                        //next_pc2
   wire [15:0]    ALU_Out;                         //ALU_Out         //ALU_Out      //ALU_Out
   wire           PCSrc;                           //PCSrc
   wire           reg_to_pc;     //reg_to_pc
   wire                          pc_to_reg;                                         //pc_to_reg
   wire [15:0]                   read1Data;        //read1Data
   wire [15:0]                   read2Data;        //read2Data       //read2Data                          
   wire [15:0]                   extend_output;    //extend_output
   wire                          Jump;             //Jump
   wire                          Branch;           //Branch
   wire                          MemtoReg;                                          //MemtoReg
   wire                          MemWrite;                           //MemWrite
   wire [3:0]                    ALUOp;            //ALUOp                          
   wire                          ALUSrc;           //ALUSrc
   wire                          ALU_invA;         //ALU_invA
   wire                          ALU_invB;         //ALU_invB
   wire                          ALU_Cin;          //ALU_Cin
   wire [15:0]                   writeback_data;                                    //writeback_data
   wire                          MemRead;                            //MemRead 
   wire                                            ALU_Zero;
   wire                                            ALU_Ofl;
   wire                                            ALU_sign;
   wire [15:0]                                                       mem_read_data; //mem_read_data                         

   assign err = err_fetch | err_decode;

   fetch fetch(
               //Outputs
               .next_pc1(next_pc1),
               .instruction(instruction),
               .err(err_fetch),
               //Inputs
               .clk(clk),
               .rst(rst), 
               .next_pc2(next_pc2),
               .ALU_Out(ALU_Out),
               .PCSrc(PCSrc),
               .reg_to_pc(reg_to_pc),
               .Halt(Halt)                            //Halt will stop PC incrementing
                                                      //In this case, next instruction after "Halt instruction" 
                                                      //would not be accessed by processor
   );

   decode decode(
               //Decode Outputs
               .read1Data(read1Data),
               .read2Data(read2Data),
               .err(err_decode),
               .extend_output(extend_output),
               //Control Outputs
               .Jump(Jump),
               .Branch(Branch),
               .MemtoReg(MemtoReg),                   //MUX select signal decide whether "mem_read_data" or "ALU_Out" to pass through
               .MemRead(MemRead),
               .MemWrite(MemWrite),
               .reg_to_pc(reg_to_pc),
               .pc_to_reg(pc_to_reg),
               .ALUOp(ALUOp),
               .ALUSrc(ALUSrc),
               .ALU_invA(ALU_invA),
               .ALU_invB(ALU_invB),
               .ALU_Cin(ALU_Cin),                     //Cin will be adding 1 to ~InAA in SUBI, to operate 2's complement
                                                      //
               .Halt(Halt),                           //CHECK IF HALT IS IMPLEMENTED CORRECT HERE!
               .SIIC(SIIC),
               .RTI(RTI),
               //Inputs
               .instruction(instruction),
               .writeback_data(writeback_data),
               .clk(clk),
               .rst(rst)
   );

   execute execute(
               //Outputs
               .next_pc2(next_pc2),
               .ALU_Out(ALU_Out),
               .PCSrc(PCSrc),
               .ALU_Zero(ALU_Zero),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
                                                      //Seems we do not need ALU_Zero, therefore let it float
               .ALU_Ofl(ALU_Ofl),                     //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
               //Inputs
               .instruction(instruction),
               .next_pc1(next_pc1),
               .read1Data(read1Data),
               .read2Data(read2Data),
               .ALUSrc(ALUSrc),
               .ALU_Cin(ALU_Cin),                     //When doing subtraction, Cin would be need to implement 2's complement
               .ALUOp(ALUOp),
               .ALU_invA(ALU_invA),
               .ALU_invB(ALU_invB),
               .ALU_sign(ALU_sign),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
               .extend_output(extend_output),
               .Branch(Branch),
               .Jump(Jump)
   );
   
   memory memory(
               //Outputs
               .mem_read_data(mem_read_data),
               //Inputs
               .clk(clk),
               .rst(rst),
               .mem_write_data(read2Data), //This is directly connected with regFile read2Data output
               .ALU_Out(ALU_Out),
               .MemRead(MemRead),
               .MemWrite(MemWrite),
               .Halt(Halt)          //createdump will write whatever in the datamemory into dumpfile(which is the file will be generated when Halt)
                                    //if (createdump) begin
                                    //    mcd = $fopen("dumpfile", "w");
                                    //    for (i=0; i<=largest+1; i=i+1) begin
                                    //       $fdisplay(mcd,"%4h %2h", i, mem[i]);
                                    //    end
                                    //    $fclose(mcd);
                                    //end
   );

   wb wb(
               //Outputs
               .writeback_data(writeback_data),
               //Inputs
               .mem_read_data(mem_read_data),
               .next_pc1(next_pc1),
               .ALU_Out(ALU_Out),
               .MemtoReg(MemtoReg),
               .pc_to_reg(pc_to_reg)
   );
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
