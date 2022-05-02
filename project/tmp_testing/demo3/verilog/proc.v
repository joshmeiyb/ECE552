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

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*             Fetch          Decode            Execute	             Memory		  Writeback	*/

wire           inst_mem_err,  inst_mem_err_IFID, inst_mem_err_IDEX,  inst_mem_err_EXMEM,  inst_mem_err_MEMWB;
wire                                                                 data_mem_err,        data_mem_err_MEMWB;
wire           /*err_fetch*/  err_decode,       err_decode_IDEX,     err_decode_EXMEM,    err_decode_MEMWB;



wire                          Halt_decode,      Halt_IDEX,           Halt_EXMEM,          Halt_MEMWB;
//----------------------------Have not implemented SIIC and RTI yet.---------------------------//
wire                          SIIC,             SIIC_IDEX,           SIIC_EXMEM,          SIIC_MEMWB;
wire                          RTI,              RTI_IDEX,            RTI_EXMEM;
/////////////////////////////////////////////////////////////////////////////////////////////////
wire [15:0]    instruction,   instruction_IFID, instruction_IDEX,    instruction_EXMEM,   instruction_MEMWB; 
wire [15:0]    pcAdd2,        pcAdd2_IFID,      pcAdd2_IDEX,         pcAdd2_EXMEM,        pcAdd2_MEMWB;

wire [15:0]                                     branch_jump_pc;
wire [15:0]                                     ALU_Out,             ALU_Out_EXMEM,       ALU_Out_MEMWB;
wire                                            PCSrc;
wire                          reg_to_pc,        reg_to_pc_IDEX;
wire                          pc_to_reg,        pc_to_reg_IDEX,      pc_to_reg_EXMEM,     pc_to_reg_MEMWB;
wire [15:0]                   read1Data,        read1Data_IDEX;

//There will be a MEM/EX forwarding for read2Data
wire [15:0]                   read2Data,        read2Data_IDEX,      read2Data_EXMEM;
//memWriteData_EX, this is almost the last steps fixed for demo1 pipelined version simple_inst_test!
wire [15:0]                                     memWriteData_EX;        
wire [15:0]                   extend_output,    extend_output_IDEX;
wire [2:0]                    RegisterRd,       RegisterRd_IDEX,     RegisterRd_EXMEM,     RegisterRd_MEMWB;
//--------------------------------------------added for forwarding--------------------------------------------//
wire [2:0]                    RegisterRs,       RegisterRs_IDEX;
wire [2:0]                    RegisterRt,       RegisterRt_IDEX;
//--------------------------------------------added for forwarding--------------------------------------------//
wire                          Jump,             Jump_IDEX,           Jump_EXMEM;
wire                          Branch,           Branch_IDEX;
wire                          MemtoReg,         MemtoReg_IDEX,       MemtoReg_EXMEM,       MemtoReg_MEMWB;
wire                          MemWrite,         MemWrite_IDEX,       MemWrite_EXMEM,       MemWrite_MEMWB;
wire                          RegWrite,         RegWrite_IDEX,       RegWrite_EXMEM,       RegWrite_MEMWB;
wire [3:0]                    ALUOp,            ALUOp_IDEX;                          
wire                          ALUSrc,           ALUSrc_IDEX;
wire                          ALU_invA,         ALU_invA_IDEX;
wire                          ALU_invB,         ALU_invB_IDEX;
wire                          ALU_Cin,          ALU_Cin_IDEX;
wire [15:0]                                                                                writeback_data;

wire                          MemRead,          MemRead_IDEX,        MemRead_EXMEM,        MemRead_MEMWB;      
wire                                            ALU_Zero;
wire                                            ALU_Ofl;
wire                                            ALU_sign;
wire [15:0]                                                          mem_read_data,        mem_read_data_MEMWB;                         


//-----------------------------hazard_detection_unit & forwarding unit---------------------------------------//
wire stall;
//wire R_format, R_format_IDEX;
//wire I_format, I_format_IDEX;
wire [1:0] forwardA, forwardB;
wire forward_MEM_to_EX;
wire forward_LBI_ST, forward_LBI_ST_EXMEM;
//-----------------------------------------------------------------------------------------------------------//

//Phase 2.1 aligned memory, Phase 2.2 stall memory
//wire inst_mem_err, data_mem_err;             
wire inst_mem_stall, data_mem_stall;
wire inst_mem_done, data_mem_done;  
wire data_mem_stall_MEMWB, data_mem_done_MEMWB;  

assign err = /*err_fetch | */err_decode_MEMWB | inst_mem_err_MEMWB | data_mem_err_MEMWB;        
                                                //pipeline this err in decode, combined with memory err, then output err_MEMWB

                                                //err used to be output from c_out, but we no longer need err in demo2
                                                //In future demo, we may need to reconider the err signal!!

hazard_detection_unit HDU(
        //inputs
        .MemRead_IDEX(MemRead_IDEX),
        .RegisterRd_IDEX(RegisterRd_IDEX),
        .RegisterRs_IFID(instruction_IFID[10:8]),
        .RegisterRt_IFID(instruction_IFID[7:5]),
        .Opcode_IFID(instruction_IFID[15:11]),          //IFormat, RFormat
        //outputs
        .stall(stall)
);
forwarding_unit FU(
        //inputs
        .RegWrite_EXMEM(RegWrite_EXMEM),
        .RegWrite_MEMWB(RegWrite_MEMWB),
        .RegisterRd_EXMEM(RegisterRd_EXMEM),
        .RegisterRd_MEMWB(RegisterRd_MEMWB),
        .RegisterRs_IDEX(RegisterRs_IDEX),
        .RegisterRt_IDEX(RegisterRt_IDEX),
        .MemWrite_EXMEM(MemWrite_EXMEM),
        .MemWrite_MEMWB(MemWrite_MEMWB),   
        //.I_format_IDEX(I_format_IDEX),
        //.R_format_IDEX(R_format_IDEX),
        .Opcode_IDEX(instruction_IDEX[15:11]),          //IFormat, RFormat
        //outputs
        .forwardA(forwardA),    //input of execute stage
        .forwardB(forwardB)     //input of execute stage
);

//--------------------------------------//

fetch fetch(
        //Inputs
        .clk(clk),
        .rst(rst),
        
        //rand_complex t_2_all.asm debug
        .stall((stall & ~data_mem_stall) | data_mem_stall/*data_mem_done*/),

        .branch_jump_pc(branch_jump_pc),
        .PCSrc(PCSrc),
        .Jump_IDEX(Jump_IDEX),
        .Halt_fetch(Halt_decode | data_mem_err),        //Halt will stop PC incrementing
                                                        //.Halt_fetch(Halt_decode | Halt_IDEX | Halt_EXMEM | Halt_MEMWB),
                                                        //In this case, next instruction after "Halt instruction" 
                                                        //would not be accessed by processor
        //.Halt_fetch(Halt_decode | Halt_IDEX | Halt_EXMEM | Halt_MEMWB | data_mem_err),                                        
        //Outputs
        .pcAdd2(pcAdd2),
        .inst_mem_err(inst_mem_err),
        .inst_mem_stall(inst_mem_stall),
        .inst_mem_done(inst_mem_done),
        .instruction(instruction),
        .PCSrc_temp(PCSrc_temp)
);

IFID IFID(
        //inputs
        .clk(clk),
        
        //----------------------------------------------------------------------------------//
        //Phase 2 - Perfect Memory
        //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
        //When data_mem_err is 1'b1, flush this pipeline
        //----------------------------------------------------------------------------------//
        //Phase 2.2 - Stall Memory
        //When fetch stall and memory stall happen at same time,
        //don't flush the IFID registers, let data_mem_stall cover inst_mem_stall
        //----------------------------------------------------------------------------------//
        .rst(rst | PCSrc 
                        | inst_mem_err | data_mem_err 
                        | (inst_mem_stall & ~data_mem_stall) | (PCSrc_temp & ~inst_mem_stall) /*| ~inst_mem_done*/),  

        .inst_mem_done(inst_mem_done),                          //NOT SURE ON THIS SIGNAL                                                                                                              
        .inst_mem_err(inst_mem_err),
        .en(~stall & (~data_mem_stall)),                        // & (~data_mem_stall) & (~inst_mem_stall)
        .instruction(instruction),
        
        .Halt_IFID( (Halt_decode | Halt_IDEX | Halt_EXMEM | Halt_MEMWB ) /*& ~inst_mem_stall & ~data_mem_stall*/),

        .pcAdd2(pcAdd2),
        .stall((stall & ~data_mem_stall)),                      // | data_mem_stall | inst_mem_stall
        //outputs
        .inst_mem_err_IFID(inst_mem_err_IFID),
        .instruction_IFID(instruction_IFID),
        .pcAdd2_IFID(pcAdd2_IFID)
);


decode decode(
        //Decode Outputs
        .read1Data(read1Data),
        .read2Data(read2Data),
        .err(err_decode),
        .extend_output(extend_output),
        .RegisterRd_out(RegisterRd),
        .RegisterRs_out(RegisterRs),
        .RegisterRt_out(RegisterRt),
        //Control Outputs
        .Jump(Jump),
        .Branch(Branch),
        .MemtoReg(MemtoReg),                    //MUX select signal decide whether "mem_read_data" or "ALU_Out" to pass through
        .MemRead(MemRead),
        .MemWrite(MemWrite),            
        .RegWrite_out(RegWrite),                //Reg write enable signal
        .reg_to_pc(reg_to_pc),
        .pc_to_reg(pc_to_reg),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .ALU_invA(ALU_invA),
        .ALU_invB(ALU_invB),
        .ALU_Cin(ALU_Cin),                      //Cin will be adding 1 to ~InAA in SUBI, to operate 2's complement
        .Halt_decode(Halt_decode),              //CHECK IF HALT IS IMPLEMENTED CORRECT HERE!
        .SIIC(SIIC),
        .RTI(RTI),
        //.R_format(R_format),
        //.I_format(I_format),
        //Inputs
        .instruction(instruction_IFID),
        .writeback_data(writeback_data),
        .clk(clk),
        .rst(rst),
        .RegWrite_in(RegWrite_MEMWB),           //DO NOT FLUSH THE DECODE WHEN BRANCH OR JUMP IS TAKEN !
                                                //Do not &(~PCSrc) with RegWrite_MEMWB
                                                //SINCE IN DECODE WE ARE TRYING TO WRITE BACK TO RegFile
        .RegisterRd_in(RegisterRd_MEMWB)                //3-bit, for the register writing address
);


// wire [15:0] read1Data_temp, read2Data_temp;
// assign read1Data_temp = (forwardA == 2'b01 /*& data_mem_stall*/)    ?   ALU_Out_EXMEM : 
//                         (data_mem_stall /*& forwardA == 2'b01*/)    ?   read1Data_IDEX :
//                                                                         read1Data;
// assign read2Data_temp = (forwardB == 2'b01 /*& data_mem_stall*/)    ?   ALU_Out_EXMEM : 
//                         (data_mem_stall /*& forwardB == 2'b01*/)    ?   read2Data_IDEX :
//                                                                         read2Data;    


IDEX IDEX(
        //input
        .clk(clk), 
        .rst(rst | (stall & ~data_mem_stall) 
                        | data_mem_err 
                        | (PCSrc_temp & ~inst_mem_stall)),     //When stall the decode stage, while mem stall is not happening
                                                        //rst the IDEX registers, stop instruction propagate through
                                                        //(PCSrc_temp & ~inst_mem_stall) is the last change help me pass
                                                        //the last relax-pass in test
        //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
        .PCSrc(PCSrc),                           
        
        //if halt happened in later stage, stop the IDEX, which means rst it
        //but we don't want to rst the Halt itself from propagating through the next stage
        .Halt_decode(Halt_decode | Halt_EXMEM | Halt_MEMWB),                                                                    
                                                                
        .en(1'b1 & (~data_mem_stall)),  // (~inst_mem_stall) & (~data_mem_stall)
        .err_decode(err_decode),
        .inst_mem_err_IFID(inst_mem_err_IFID),
        //.R_format(R_format),
        //.I_format(I_format),
        .instruction_IFID(instruction_IFID),    //16-bit        
        .pcAdd2_IFID(pcAdd2_IFID),              //16-bit 
        
        //-------------------------------------------------------------------------//
        //MEM - EX forwarding decision happens with stall signal at the same time
        .read1Data(read1Data),                  //16-bit        
        .read2Data(read2Data),                  //16-bit
        .fwdA_m_x((forwardA == 2'b01) & data_mem_stall),
        .fwdB_m_x((forwardB == 2'b01) & data_mem_stall),
        .readData_m_x(writeback_data),
        //-------------------------------------------------------------------------//

        .extend_output(extend_output),          //16-bit
        .RegisterRd(RegisterRd),                //3-bit
        .RegisterRs(RegisterRs),                //3-bit
        .RegisterRt(RegisterRt),                //3-bit
        .Jump(Jump),
        .Branch(Branch),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .RegWrite(RegWrite),
        .reg_to_pc(reg_to_pc),
        .pc_to_reg(pc_to_reg),
        .ALUOp(ALUOp),                                  //4-bit
        .ALUSrc(ALUSrc),
        .ALU_invA(ALU_invA),
        .ALU_invB(ALU_invB),
        .ALU_Cin(ALU_Cin),
        .SIIC(SIIC),
        .RTI(RTI),
        //outputs
        .err_decode_IDEX(err_decode_IDEX),
        .inst_mem_err_IDEX(inst_mem_err_IDEX),
        //.R_format_IDEX(R_format_IDEX),
        //.I_format_IDEX(I_format_IDEX),
        .instruction_IDEX(instruction_IDEX),    //propogate the IDEX pipline stage  
        .pcAdd2_IDEX(pcAdd2_IDEX),              //propogate the IDEX pipline stage
        .read1Data_IDEX(read1Data_IDEX),            
        .read2Data_IDEX(read2Data_IDEX),
        .extend_output_IDEX(extend_output_IDEX),
        .RegisterRd_IDEX(RegisterRd_IDEX),
        .RegisterRs_IDEX(RegisterRs_IDEX),
        .RegisterRt_IDEX(RegisterRt_IDEX),
        .Jump_IDEX(Jump_IDEX),
        .Branch_IDEX(Branch_IDEX),
        .MemtoReg_IDEX(MemtoReg_IDEX),
        .MemRead_IDEX(MemRead_IDEX),
        .MemWrite_IDEX(MemWrite_IDEX),
        .RegWrite_IDEX(RegWrite_IDEX),
        .reg_to_pc_IDEX(reg_to_pc_IDEX),
        .pc_to_reg_IDEX(pc_to_reg_IDEX),
        .ALUOp_IDEX(ALUOp_IDEX),
        .ALUSrc_IDEX(ALUSrc_IDEX),
        .ALU_invA_IDEX(ALU_invA_IDEX),
        .ALU_invB_IDEX(ALU_invB_IDEX),
        .ALU_Cin_IDEX(ALU_Cin_IDEX),
        .Halt_IDEX(Halt_IDEX),
        .SIIC_IDEX(SIIC_IDEX),
        .RTI_IDEX(RTI_IDEX)
);


execute execute(
        //Outputs
        .branch_jump_pc(branch_jump_pc),        //Don't need pipeline for this signal?
        .ALU_Out(ALU_Out),
        .PCSrc(PCSrc),
        .ALU_Zero(ALU_Zero),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE? Seems we do not need ALU_Zero, therefore let it float
        .ALU_Ofl(ALU_Ofl),                     //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
        .memWriteData(memWriteData_EX),
        //Inputs
        .reg_to_pc(reg_to_pc_IDEX),
        .pcAdd2(pcAdd2_IDEX),
        .instruction(instruction_IDEX),
        .read1Data(read1Data_IDEX),
        .read2Data(read2Data_IDEX),
        .ALUSrc(ALUSrc_IDEX),
        .ALU_Cin(ALU_Cin_IDEX),                 //When doing subtraction, Cin would be need to implement 2's complement
        .ALUOp(ALUOp_IDEX),
        .ALU_invA(ALU_invA_IDEX),
        .ALU_invB(ALU_invB_IDEX),
        .ALU_sign(ALU_sign),                    //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
        .extend_output(extend_output_IDEX),
        .Branch(Branch_IDEX),
        .Jump(Jump_IDEX),
        //--------------hazard detection unit & forwarding -------//
        .forwardA(forwardA),
        .forwardB(forwardB),
        .RegisterRd_IDEX(RegisterRd_IDEX),
        .RegisterRs_IFID(instruction_IFID[10:8]),
        .ALU_Out_EXMEM(ALU_Out_EXMEM),
        .writeback_data(writeback_data)
        //---------------------------------------------------------//
);


EXMEM EXMEM(
        //inputs
        .clk(clk),
        .rst(rst | data_mem_err),               //When data_mem_err is 1'b1, flush EXMEM registers
                                                //When data_mem_stall is 1'b1, flush EXMEM registers
        .instruction_IDEX(instruction_IDEX),

        .err_decode_IDEX(err_decode_IDEX),
        .inst_mem_err_IDEX(inst_mem_err_IDEX),
        
        .en(1'b1 & (~data_mem_stall)),                                      // 1'b1 (~inst_mem_stall) & (~data_mem_stall)
        .pcAdd2_IDEX(pcAdd2_IDEX),                      //16-bit
        .ALU_Out(ALU_Out),                              //16-bit
        .pc_to_reg_IDEX(pc_to_reg_IDEX),
        .read2Data_IDEX(memWriteData_EX),               //16-bit
        .RegisterRd_IDEX(RegisterRd_IDEX),              //3-bit
        .MemtoReg_IDEX(MemtoReg_IDEX),
        .MemRead_IDEX(MemRead_IDEX),
        .MemWrite_IDEX(MemWrite_IDEX),
        .RegWrite_IDEX(RegWrite_IDEX),
        .Jump_IDEX(Jump_IDEX),                          //for j_4.asm
        .Halt_IDEX(Halt_IDEX | Halt_MEMWB),
        .SIIC_IDEX(SIIC_IDEX),
        .RTI_IDEX(RTI_IDEX),
        //outputs
        
        .instruction_EXMEM(instruction_EXMEM),

        .err_decode_EXMEM(err_decode_EXMEM),
        .inst_mem_err_EXMEM(inst_mem_err_EXMEM),
        
        .pcAdd2_EXMEM(pcAdd2_EXMEM),
        .ALU_Out_EXMEM(ALU_Out_EXMEM),
        .pc_to_reg_EXMEM(pc_to_reg_EXMEM),
        .read2Data_EXMEM(read2Data_EXMEM),
        .RegisterRd_EXMEM(RegisterRd_EXMEM),
        .MemtoReg_EXMEM(MemtoReg_EXMEM),
        .MemRead_EXMEM(MemRead_EXMEM),
        .MemWrite_EXMEM(MemWrite_EXMEM),
        .RegWrite_EXMEM(RegWrite_EXMEM),
        .Jump_EXMEM(Jump_EXMEM),                        //for j_4.asm
        .Halt_EXMEM(Halt_EXMEM),
        .SIIC_EXMEM(SIIC_EXMEM),
        .RTI_EXMEM(RTI_EXMEM)
);

memory memory(
        //Outputs
        .mem_read_data(mem_read_data),
        .data_mem_err(data_mem_err),            //When memory address is not aligned, data_mem_err will be 1'b1
        .data_mem_stall(data_mem_stall),
        .data_mem_done(data_mem_done),
        //Inputs
        .clk(clk),
        .rst(rst),
        .mem_write_data(read2Data_EXMEM), //This is directly connected with regFile read2Data output
        .ALU_Out(ALU_Out_EXMEM),
        .MemRead(MemRead_EXMEM),
        .MemWrite(MemWrite_EXMEM),      //CAUTION: DO NOT PUT PCSrc HERE
                                        //Branch/Jump_taken is solved at execution stage, but memory is after execution,
                                        //We only want to flush IFID and IDEX, stopping fetching new instruction (only 3 place where PCSrc should exist) 
        .Halt(Halt_MEMWB)       //CAUTION: USE the Halt_MEMWB, DO NOT USE Halt_EXMEM,
                                //or it will halt too early when testing in random tests
        
                                //createdump will write whatever in the datamemory into dumpfile(which is the file will be generated when Halt)
                                //if (createdump) begin
                                //    mcd = $fopen("dumpfile", "w");
                                //    for (i=0; i<=largest+1; i=i+1) begin
                                //       $fdisplay(mcd,"%4h %2h", i, mem[i]);
                                //    end
                                //    $fclose(mcd);
                                //end
);

MEMWB MEMWB(
        //inputs
        .clk(clk),
        .rst(rst | data_mem_stall),                              // | ~data_mem_done
                                                //When data_mem_stall is 1'b1, flush MEMWB registers
        
        .instruction_EXMEM(instruction_EXMEM),

        .data_mem_stall(data_mem_stall),
        .data_mem_done(data_mem_done),
        
        .err_decode_EXMEM(err_decode_EXMEM),
        .inst_mem_err_EXMEM(inst_mem_err_EXMEM),
        .data_mem_err(data_mem_err),
        
        .en(1'b1),
        .pcAdd2_EXMEM(pcAdd2_EXMEM),            //16-bit
        .ALU_Out_EXMEM(ALU_Out_EXMEM),          //16-bit
        .pc_to_reg_EXMEM(pc_to_reg_EXMEM),
        .RegisterRd_EXMEM(RegisterRd_EXMEM),    //3-bit   
        .MemtoReg_EXMEM(MemtoReg_EXMEM),
        .RegWrite_EXMEM(RegWrite_EXMEM),
        .MemWrite_EXMEM(MemWrite_EXMEM),
        .MemRead_EXMEM(MemRead_EXMEM),
        .mem_read_data(mem_read_data),    //16-bit
        .Halt_EXMEM(Halt_EXMEM),
        .SIIC_EXMEM(SIIC_EXMEM),
        //outputs

        .instruction_MEMWB(instruction_MEMWB),

        .data_mem_stall_MEMWB(data_mem_stall_MEMWB),            //HAVE NOT USE THIS ONE
        .data_mem_done_MEMWB(data_mem_done_MEMWB),

        .err_decode_MEMWB(err_decode_MEMWB),
        .inst_mem_err_MEMWB(inst_mem_err_MEMWB),
        .data_mem_err_MEMWB(data_mem_err_MEMWB),

        .pcAdd2_MEMWB(pcAdd2_MEMWB),
        .ALU_Out_MEMWB(ALU_Out_MEMWB),
        .pc_to_reg_MEMWB(pc_to_reg_MEMWB),
        .RegisterRd_MEMWB(RegisterRd_MEMWB),
        .MemtoReg_MEMWB(MemtoReg_MEMWB),
        .RegWrite_MEMWB(RegWrite_MEMWB),
        .MemWrite_MEMWB(MemWrite_MEMWB),
        .MemRead_MEMWB(MemRead_MEMWB),
        .mem_read_data_MEMWB(mem_read_data_MEMWB),
        .Halt_MEMWB(Halt_MEMWB),
        .SIIC_MEMWB(SIIC_MEMWB)
);

wb wb(
        //Outputs
        .writeback_data(writeback_data),
        //Inputs
        .Halt_MEMWB(Halt_MEMWB),
        .mem_read_data(mem_read_data_MEMWB),
        .pcAdd2(pcAdd2_MEMWB),
        .ALU_Out(ALU_Out_MEMWB),
        .MemtoReg(MemtoReg_MEMWB),
        .pc_to_reg(pc_to_reg_MEMWB)
);
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
