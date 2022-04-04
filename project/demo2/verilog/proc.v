//<<<<<<< HEAD
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
        /*             Fetch          Decode            Execute	       Memory		Writeback	*/

        wire                          rst_IFID;
        wire           err_fetch,     err_decode;
        
        /////////////////////////////////////////////////////////////////////////////////////////////////
        //Have not implemented these yet.
        wire                          Halt_decode,      Halt_IDEX,           Halt_EXMEM,          Halt_MEMWB;
        
        wire                          SIIC,             SIIC_IDEX,           SIIC_EXMEM,          SIIC_MEMWB;
        
        wire                          RTI,              RTI_IDEX,            RTI_EXMEM;
        /////////////////////////////////////////////////////////////////////////////////////////////////

        wire [15:0]    instruction,   instruction_IFID, instruction_IDEX; 
        wire [15:0]    pcAdd2,        pcAdd2_IFID,      pcAdd2_IDEX,         pcAdd2_EXMEM,        pcAdd2_MEMWB;

        wire [15:0]                                     branch_jump_pc;
        wire [15:0]                                     ALU_Out,             ALU_Out_EXMEM,       ALU_Out_MEMWB;
        wire                                            PCSrc;
        wire                          reg_to_pc,        reg_to_pc_IDEX;
        wire                          pc_to_reg,        pc_to_reg_IDEX,      pc_to_reg_EXMEM,     pc_to_reg_MEMWB;
        wire [15:0]                   read1Data,        read1Data_IDEX;
        
        //There will be a MEM/EX forwarding for read2Data
        wire [15:0]                   read2Data,        read2Data_IDEX,      read2Data_EXMEM;
        
        wire [15:0]                   extend_output,    extend_output_IDEX;
        //wire [2:0]                    ext_select,       ext_select_IDEX,     ext_select_EXMEM,     ext_select_MEMWB;
        
        //Edited at pipeline design
        wire [2:0]   RegisterRd_IFID, RegisterRd,       RegisterRd_IDEX,     RegisterRd_EXMEM,     RegisterRd_MEMWB;
        //--------------------------------------------added for forwarding--------------------------------------------//
        wire [2:0]   RegisterRs_IFID, RegisterRs,       RegisterRs_IDEX;
        wire [2:0]   RegisterRt_IFID, RegisterRt,       RegisterRt_IDEX;
        //--------------------------------------------added for forwarding--------------------------------------------//
        wire                          Jump,             Jump_IDEX;
        wire                          Branch,           Branch_IDEX;
        wire                          MemtoReg,         MemtoReg_IDEX,       MemtoReg_EXMEM,       MemtoReg_MEMWB;
        wire                          MemWrite,         MemWrite_IDEX,       MemWrite_EXMEM;
        //Edited at pipeline design
        wire          RegWrite_IFID,  RegWrite,         RegWrite_IDEX,       RegWrite_EXMEM,       RegWrite_MEMWB;
        wire [3:0]                    ALUOp,            ALUOp_IDEX;                          
        wire                          ALUSrc,           ALUSrc_IDEX;
        wire                          ALU_invA,         ALU_invA_IDEX;
        wire                          ALU_invB,         ALU_invB_IDEX;
        wire                          ALU_Cin,          ALU_Cin_IDEX;
        wire [15:0]   /*writeback_data_IFID,*/                                                     writeback_data;
        
        wire                          MemRead,          MemRead_IDEX,        MemRead_EXMEM;
        //Do not need MemRead, since it is only an enable signal which can be replaced by MemtoReg_EXMEM   
        
        wire                                            ALU_Zero;
        wire                                            ALU_Ofl;
        wire                                            ALU_sign;
        
        //There will be a MEM/EX forwarding for mem_read_data, mem_read_data will be input to EX stage
        wire [15:0]                                                        mem_read_data,     mem_read_data_MEMWB;                         
        

        //hazard_detection_unit & forwarding unit
        wire stall;
        // wire writeEn_PC_reg;
        wire R_format;
        wire I_format;
        wire [1:0] forwardA, forwardB;
        //-------------------------------------//


        hazard_detection_unit HDU(
                //inputs
                /*
                .R_format(R_format),
                .I_format(I_format),
                .writeRegSel_IDEX(RegisterRd_IDEX),
                .writeRegSel_EXMEM(RegisterRd_EXMEM),     
                .read1RegSel_IFID(RegisterRs),      //RegisterRs_IFID
                .read2RegSel_IFID(RegisterRt),      //RegisterRt_IFID
                .RegWrite_IDEX(RegWrite_IDEX),
                .RegWrite_EXMEM(RegWrite_EXMEM),
                //.branch_taken(PCSrc),
                */
                .MemRead_IDEX(MemRead_IDEX),
                .writeRegSel_IDEX(RegisterRd_IDEX),
                .RegisterRs_IFID(RegisterRs_IFID),
                .RegisterRt_IFID(RegisterRt_IFID),
                //outputs
                //.writeEn_PC_reg(writeEn_PC_reg)
                .stall(stall)   //only go to fetch
        
        );
        
           
        forwarding_unit FU(
                //inputs
                .RegWrite_EXMEM(RegWrite_EXMEM),
                .RegWrite_MEMWB(RegWrite_MEMWB),
                .RegisterRd_EXMEM(RegisterRd_EXMEM),
                .RegisterRd_MEMWB(RegisterRd_MEMWB),
                .RegisterRs_IDEX(RegisterRs_IDEX),
                .RegisterRt_IDEX(RegisterRt_IDEX),
                .I_format(I_format),
                .R_format(R_format),
                //outputs
                .forwardA(forwardA),    //input of EX stage
                .forwardB(forwardB)     //input of EX stage
        );

        //--------------------------------------//

        assign err = err_fetch | err_decode;

        fetch fetch(
                //Inputs
                .clk(clk),
                .rst(rst),
                .stall(stall),
                .branch_jump_pc(branch_jump_pc),
                .PCSrc(PCSrc),
                .Halt_fetch(Halt_decode | Halt_IDEX | Halt_EXMEM | Halt_MEMWB),              //Halt will stop PC incrementing
                                                //In this case, next instruction after "Halt instruction" 
                                                //would not be accessed by processor
                
                //Outputs
                .pcAdd2(pcAdd2),
                .instruction(instruction),
                .err(err_fetch)
        );
        
        IFID IFID(
                //inputs
                .clk(clk),
                .rst(rst | PCSrc),          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
                
                .en(~stall),
                .instruction(instruction),
                .pcAdd2(pcAdd2),
                .stall(stall),
                //outputs
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
                .MemtoReg(MemtoReg),                   //MUX select signal decide whether "mem_read_data" or "ALU_Out" to pass through

                .MemRead(MemRead),

                .MemWrite(MemWrite),            
                .RegWrite_out(RegWrite),        //Reg write enable signal

                .reg_to_pc(reg_to_pc),
                .pc_to_reg(pc_to_reg),
                .ALUOp(ALUOp),
                .ALUSrc(ALUSrc),
                .ALU_invA(ALU_invA),
                .ALU_invB(ALU_invB),
                .ALU_Cin(ALU_Cin),                      //Cin will be adding 1 to ~InAA in SUBI, to operate 2's complement
                                                        //
                .Halt_decode(Halt_decode),              //CHECK IF HALT IS IMPLEMENTED CORRECT HERE!
                .SIIC(SIIC),
                .RTI(RTI),
                .R_format(R_format),
                .I_format(I_format),
                //Inputs
                .instruction(instruction_IFID),
                .writeback_data(writeback_data),
                .clk(clk),
                .rst(rst),
                .RegWrite_in(RegWrite_MEMWB & (~PCSrc)),         //When branch-taken, PCSrc goes high, 
                                                                //set RegWrite to zero, stop writing anything into regFile
                .RegisterRd_in(RegisterRd_MEMWB)                //3-bit, for the register writing address
        );

        IDEX IDEX(
                //input
                .clk(clk), 
                .rst(rst /*| (Halt_decode | Halt_EXMEM | Halt_MEMWB)*/ /*| stall*/ | PCSrc),                                           
                //if halt happened in later stage, stop the IDEX, which means rst it
                //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
                .en(1'b1),
                .instruction_IFID(instruction_IFID),        //16-bit        
                .pcAdd2_IFID(pcAdd2_IFID),              //16-bit 
                .read1Data(read1Data),                      //16-bit        
                .read2Data(read2Data),                      //16-bit
                .extend_output(extend_output),              //16-bit
                .RegisterRd(RegisterRd),        //3-bit
                .RegisterRs(RegisterRs),        //3-bit
                .RegisterRt(RegisterRt),        //3-bit
                .Jump(Jump),
                .Branch(Branch),
                .MemtoReg(MemtoReg),
                .MemRead(MemRead),
                .MemWrite(MemWrite),
                .RegWrite(RegWrite),
                .reg_to_pc(reg_to_pc),
                .pc_to_reg(pc_to_reg),
                .ALUOp(ALUOp),          //4-bit
                .ALUSrc(ALUSrc),
                .ALU_invA(ALU_invA),
                .ALU_invB(ALU_invB),
                .ALU_Cin(ALU_Cin),
                .Halt_decode(Halt_decode | Halt_EXMEM | Halt_MEMWB),
                .SIIC(SIIC),
                .RTI(RTI),

                //outputs
                .instruction_IDEX(instruction_IDEX),        //propogate the IDEX pipline stage  
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
                .branch_jump_pc(branch_jump_pc),    //Don't need pipeline for this signal?
                .ALU_Out(ALU_Out),
                .PCSrc(PCSrc),
                .ALU_Zero(ALU_Zero),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE? Seems we do not need ALU_Zero, therefore let it float
                .ALU_Ofl(ALU_Ofl),                     //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
                //Inputs
                .reg_to_pc(reg_to_pc_IDEX),
                .pcAdd2(pcAdd2_IDEX),
                .instruction(instruction_IDEX),
                .read1Data(read1Data_IDEX),
                .read2Data(read2Data_IDEX),
                .ALUSrc(ALUSrc_IDEX),
                .ALU_Cin(ALU_Cin_IDEX),                     //When doing subtraction, Cin would be need to implement 2's complement
                .ALUOp(ALUOp_IDEX),
                .ALU_invA(ALU_invA_IDEX),
                .ALU_invB(ALU_invB_IDEX),
                .ALU_sign(ALU_sign),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
                .extend_output(extend_output_IDEX),
                .Branch(Branch_IDEX),
                .Jump(Jump_IDEX),
                //--------------hazard detection unit & forwarding -------//

                .forwardA(forwardA),
                .forwardB(forwardB),
                .ALU_Out_EXMEM(ALU_Out_EXMEM),
                .writeback_data(writeback_data)
                //---------------------------------------------------------//
    );

    EXMEM EXMEM(
        //inputs
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .pcAdd2_IDEX(pcAdd2_IDEX),                  //16-bit
        .ALU_Out(ALU_Out),                              //16-bit
        .pc_to_reg_IDEX(pc_to_reg_IDEX),
        .read2Data_IDEX(read2Data_IDEX),                //16-bit
        .RegisterRd_IDEX(RegisterRd_IDEX),              //3-bit
        .MemtoReg_IDEX(MemtoReg_IDEX),
        .MemRead_IDEX(MemRead_IDEX),
        .MemWrite_IDEX(MemWrite_IDEX),
        .RegWrite_IDEX(RegWrite_IDEX),

        
        //.ext_select_IDEX(ext_select_IDEX),
        //.LD_IDEX(LD_IDEX),

        .Halt_IDEX(Halt_IDEX | Halt_MEMWB),
        .SIIC_IDEX(SIIC_IDEX),
        .RTI_IDEX(RTI_IDEX),
        //outputs
        .pcAdd2_EXMEM(pcAdd2_EXMEM),
        .ALU_Out_EXMEM(ALU_Out_EXMEM),
        .pc_to_reg_EXMEM(pc_to_reg_EXMEM),
        .read2Data_EXMEM(read2Data_EXMEM),
        .RegisterRd_EXMEM(RegisterRd_EXMEM),
        .MemtoReg_EXMEM(MemtoReg_EXMEM),
        .MemRead_EXMEM(MemRead_EXMEM),
        .MemWrite_EXMEM(MemWrite_EXMEM),
        .RegWrite_EXMEM(RegWrite_EXMEM),

        //.ext_select_EXMEM(ext_select_EXMEM),
        //.LD_EXMEM(LD_EXMEM),

        .Halt_EXMEM(Halt_EXMEM),
        .SIIC_EXMEM(SIIC_EXMEM),
        .RTI_EXMEM(RTI_EXMEM)
    );
    
    memory memory(
                //Outputs
                .mem_read_data(mem_read_data),
                //Inputs
                .clk(clk),
                .rst(rst),
                .mem_write_data(read2Data_EXMEM), //This is directly connected with regFile read2Data output
                .ALU_Out(ALU_Out_EXMEM),
                .MemRead(MemRead_EXMEM),
                //Do not need MemRead, since it is only an enable signal which can be replaced by MemtoReg_EXMEM 
                
                .MemWrite(MemWrite_EXMEM & (~PCSrc)),        //When branch-taken, PCSrc goes high, set MemWrite to zero, stop writing anything into data memory
                
                .Halt(Halt_EXMEM)       //createdump will write whatever in the datamemory into dumpfile(which is the file will be generated when Halt)
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
        .rst(rst),
        .en(1'b1),
        .pcAdd2_EXMEM(pcAdd2_EXMEM),      //16-bit
        .ALU_Out_EXMEM(ALU_Out_EXMEM),       //16-bit
        .pc_to_reg_EXMEM(pc_to_reg_EXMEM),
        .RegisterRd_EXMEM(RegisterRd_EXMEM), //3-bit   
        .MemtoReg_EXMEM(MemtoReg_EXMEM),
        .RegWrite_EXMEM(RegWrite_EXMEM),
        
        //.ext_select_EXMEM(ext_select_EXMEM),
        
        .mem_read_data(mem_read_data),    //16-bit
        .Halt_EXMEM(Halt_EXMEM),
        .SIIC_EXMEM(SIIC_EXMEM),
        //outputs
        .pcAdd2_MEMWB(pcAdd2_MEMWB),
        .ALU_Out_MEMWB(ALU_Out_MEMWB),
        .pc_to_reg_MEMWB(pc_to_reg_MEMWB),
        .RegisterRd_MEMWB(RegisterRd_MEMWB),
        .MemtoReg_MEMWB(MemtoReg_MEMWB),
        .RegWrite_MEMWB(RegWrite_MEMWB),

        //.ext_select_MEMWB(ext_select_MEMWB),

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
