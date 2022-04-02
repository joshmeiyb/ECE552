<<<<<<< HEAD
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
        wire                          Halt,             Halt_IDEX,           Halt_EXMEM,          Halt_MEMWB;
        
        wire                          SIIC,             SIIC_IDEX,           SIIC_EXMEM,          SIIC_MEMWB;
        
        wire                          RTI,              RTI_IDEX,            RTI_EXMEM;
        /////////////////////////////////////////////////////////////////////////////////////////////////

        wire [15:0]    instruction,   instruction_IFID,   instruction_IDEX; 
        wire [15:0]    next_pc1,      next_pc1_IFID,      next_pc1_IDEX,     next_pc1_EXMEM,      next_pc1_MEMWB;
        wire [15:0]                                     next_pc2;
        wire [15:0]                                     ALU_Out,             ALU_Out_EXMEM,       ALU_Out_MEMWB;
        wire                                            PCSrc;
        wire                          reg_to_pc,        reg_to_pc_IDEX;
        wire                          pc_to_reg,        pc_to_reg_IDEX,      pc_to_reg_EXMEM,     pc_to_reg_MEMWB;
        wire [15:0]                   read1Data,        read1Data_IDEX;
        
        //There will be a MEM/EX forwarding for read2Data
        wire [15:0]                   read2Data,        read2Data_IDEX,      read2Data_EXMEM;
        
        wire [15:0]                   extend_output,    extend_output_IDEX;
        //Edited at pipeline design
        wire [2:0]                    RegisterRd,       RegisterRd_IDEX,     RegisterRd_EXMEM,     RegisterRd_MEMWB;
        //--------------------------------------------added for forwarding--------------------------------------------//
        wire [2:0]                    RegisterRs,       RegisterRs_IDEX;
        wire [2:0]                    RegisterRt,       RegisterRt_IDEX;
        //--------------------------------------------added for forwarding--------------------------------------------//
        wire                          Jump,             Jump_IDEX;
        wire                          Branch,           Branch_IDEX;
        wire                          MemtoReg,         MemtoReg_IDEX,       MemtoReg_EXMEM,       MemtoReg_MEMWB;
        wire                          MemWrite,         MemWrite_IDEX,       MemWrite_EXMEM;
        //Edited at pipeline design
        wire                          RegWrite,         RegWrite_IDEX,       RegWrite_EXMEM,       RegWrite_MEMWB;
        wire [3:0]                    ALUOp,            ALUOp_IDEX;                          
        wire                          ALUSrc,           ALUSrc_IDEX;
        wire                          ALU_invA,         ALU_invA_IDEX;
        wire                          ALU_invB,         ALU_invB_IDEX;
        wire                          ALU_Cin,          ALU_Cin_IDEX;
        wire [15:0]                                                                           writeback_data;
        
        wire                          MemRead,          MemRead_IDEX,        MemRead_EXMEM;
        //Do not need MemRead, since it is only an enable signal which can be replaced by MemtoReg_EXMEM   
        
        wire                                            ALU_Zero;
        wire                                            ALU_Ofl;
        wire                                            ALU_sign;
        
        //There will be a MEM/EX forwarding for mem_read_data, mem_read_data will be input to EX stage
        wire [15:0]                                                        mem_read_data,     mem_read_data_MEMWB;                         

        //wire IFID_en;
        //wire IDEX_en;
        //wire EXMEM_en;
        //wire MEMWB_en;
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /*
        p1: IFID
        p2: IDEX
        p3: EXMEM
        p4: MEMWB
        */
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////



        //hazard_detection_unit
        wire stall;
        wire enablePC;

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
<<<<<<< HEAD
                .reg_to_pc(reg_to_pc_IDEX),
                .Halt(Halt_MEMWB),                             //Halt will stop PC incrementing
                                                                //In this case, next instruction after "Halt instruction" 
                                                                //would not be accessed by processor
                .stall(stall),
                .writeEn(writeEn)
        );
        
        IFID IFID(
                //inputs
                .clk(clk),
                .rst(rst | PCSrc),          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
                .en(writeEn),
                .instruction(instruction),
                .next_pc1(next_pc1),
                .stall(stall),
                //outputs
                .instruction_IFID(instruction_IFID),
                .next_pc1_IFID(next_pc1_IFID)          
        );

        wire R_format;
        wire I_format;
        decode decode(

                //Decode Outputs
                .read1Data(read1Data),
                .read2Data(read2Data),
                .err(err_decode),
                .extend_output(extend_output),

                .RegisterRd_out(RegisterRd),
                .RegisterRs_out(RegisterRs),
                .RegisterRt_out(RegisterRt),

                .write_reg_addr_out(write_reg_addr),

                //Control Outputs
                .Jump(Jump),
                .Branch(Branch),
                .MemtoReg(MemtoReg),                   //MUX select signal decide whether "mem_read_data" or "ALU_Out" to pass through

                
                .MemRead(MemRead),

                .MemWrite(MemWrite),            
                .RegWrite_out(RegWrite),        

                //.MemRead(MemRead),
                .MemWrite(MemWrite),
                .RegWrite_out(RegWrite)

                .reg_to_pc(reg_to_pc),
                .pc_to_reg(pc_to_reg),
                .ALUOp(ALUOp),
                .ALUSrc(ALUSrc),
                .ALU_invA(ALU_invA),
                .ALU_invB(ALU_invB),
                .ALU_Cin(ALU_Cin),                      //Cin will be adding 1 to ~InAA in SUBI, to operate 2's complement
                                                        //
                .Halt(Halt),                            //CHECK IF HALT IS IMPLEMENTED CORRECT HERE!
                .SIIC(SIIC),
                .RTI(RTI),

                .R_format(R_format),
                .I_format(I_format),
                //Inputs
                .instruction(instruction_IFID),
                .writeback_data(writeback_data),
                .clk(clk),
                .rst(rst),
                .RegWrite_in(RegWrite_MEMWB & (~PCSrc)),           //When branch-taken, PCSrc goes high, set RegWrite to zero, stop writing anything into regFile
                .RegisterRd_in(RegisterRd_MEMWB)
        );

    
        hazard_detection_unit HDU(
                .R_format(R_format),
                .I_format(I_format),
                .writeRegSel_IDEX(RegisterRd_IDEX),
                .writeRegSel_EXMEM(RegisterRd_EXMEM),
                .read1RegSel_IFID(instruction_IFID[10:8]),
                .read2RegSel_IFID(instruction_IFID[7:5]),
                .RegWrite_IDEX(RegWrite_IDEX),
                .RegWrite_EXMEM(RegWrite_EXMEM),
                .branch_taken(PCSrc),
                .stall(stall),
                .writeEn(writeEn)
        );

        IDEX IDEX(
                //input
                .clk(clk), 
                .rst(rst | PCSrc),          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
                .en(1'b1),
                .instruction_IFID(instruction_IFID),        //16-bit        
                .next_pc1_IFID(next_pc1_IFID),              //16-bit 
                .read1Data(read1Data),                      //16-bit        
                .read2Data(read2Data),                      //16-bit
                .extend_output(extend_output),              //16-bit
                .RegisterRd(RegisterRd),     //3-bit
                .RegisterRs(RegisterRs),
                .RegisterRt(RegisterRt),
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
                .Halt(Halt),
                .SIIC(SIIC),
                .RTI(RTI),
                
                //.stall(1'b0),

                //outputs
                .instruction_IDEX(instruction_IDEX),        //propogate the IDEX pipline stage  
                .next_pc1_IDEX(next_pc1_IDEX),              //propogate the IDEX pipline stage
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
                .next_pc2(next_pc2),    //Don't need pipeline for this signal?
                .ALU_Out(ALU_Out),
                .PCSrc(PCSrc),
                .ALU_Zero(ALU_Zero),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
                                                        //Seems we do not need ALU_Zero, therefore let it float
                .ALU_Ofl(ALU_Ofl),                     //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
                //Inputs
                .instruction(instruction_IDEX),
                .next_pc1(next_pc1_IDEX),
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
                //---------------forwarding-----------------//
                .RegWrite_MEMWB(RegWrite_MEMWB), 
                .RegWrite_EXMEM(RegWrite_EXMEM),
                .RegisterRd_EXMEM(RegisterRd_EXMEM), 
                .RegisterRd_MEMWB(RegisterRd_MEMWB),
                .RegisterRs_IDEX(RegisterRs_IDEX), 
                .RegisterRt_IDEX(RegisterRt_IDEX),
                .I_format(I_format),
                .R_format(R_format),
                .ALU_Out_EXMEM(ALU_Out_EXMEM),
                .writeback_data(writeback_data)
                //---------------forwarding-----------------//
    );

    EXMEM EXMEM(
        //inputs
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .next_pc1_IDEX(next_pc1_IDEX),                  //16-bit
        .ALU_Out(ALU_Out),                              //16-bit
        .pc_to_reg_IDEX(pc_to_reg_IDEX),
        .read2Data_IDEX(read2Data_IDEX),                //16-bit
        .RegisterRd_IDEX(RegisterRd_IDEX),              //3-bit
        .MemtoReg_IDEX(MemtoReg_IDEX),
        .MemRead_IDEX(MemRead_IDEX),
        .MemWrite_IDEX(MemWrite_IDEX),
        .RegWrite_IDEX(RegWrite_IDEX),
        .Halt_IDEX(Halt_IDEX),
        .SIIC_IDEX(SIIC_IDEX),
        .RTI_IDEX(RTI_IDEX),
        //outputs
        .next_pc1_EXMEM(next_pc1_EXMEM),
        .ALU_Out_EXMEM(ALU_Out_EXMEM),
        .pc_to_reg_EXMEM(pc_to_reg_EXMEM),
        .read2Data_EXMEM(read2Data_EXMEM),
        .RegisterRd_EXMEM(RegisterRd_EXMEM),
        .MemtoReg_EXMEM(MemtoReg_EXMEM),
        .MemRead_EXMEM(MemRead_EXMEM),
        .MemWrite_EXMEM(MemWrite_EXMEM),
        .RegWrite_EXMEM(RegWrite_EXMEM),
        .Halt_EXMEM(Halt_EXMEM),
        .SIIC_EXMEM(SIIC_EXMEM),
        .RTI_EXMEM(RTI_EXMEM)

    );


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
                
                .Halt(Halt_EXMEM)          //createdump will write whatever in the datamemory into dumpfile(which is the file will be generated when Halt)

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
        .next_pc1_EXMEM(next_pc1_EXMEM),      //16-bit
        .ALU_Out_EXMEM(ALU_Out_EXMEM),       //16-bit
        .pc_to_reg_EXMEM(pc_to_reg_EXMEM),
        .RegisterRd_EXMEM(RegisterRd_EXMEM), //3-bit   
        .MemtoReg_EXMEM(MemtoReg_EXMEM),
        .RegWrite_EXMEM(RegWrite_EXMEM),
        .mem_read_data(mem_read_data),    //16-bit
        .Halt_EXMEM(Halt_EXMEM),
        .SIIC_EXMEM(SIIC_EXMEM),
        //outputs
        .next_pc1_MEMWB(next_pc1_MEMWB),
        .ALU_Out_MEMWB(ALU_Out_MEMWB),
        .pc_to_reg_MEMWB(pc_to_reg_MEMWB),
        .RegisterRd_MEMWB(RegisterRd_MEMWB),
        .MemtoReg_MEMWB(MemtoReg_MEMWB),
        .RegWrite_MEMWB(RegWrite_MEMWB),
        .mem_read_data_MEMWB(mem_read_data_MEMWB),
        .Halt_MEMWB(Halt_MEMWB),
        .SIIC_MEMWB(SIIC_MEMWB)

    );

    wb wb(
                //Outputs
                .writeback_data(writeback_data),
                //Inputs
                .mem_read_data(mem_read_data_MEMWB),
                .next_pc1(next_pc1_MEMWB),
                .ALU_Out(ALU_Out_MEMWB),
                .MemtoReg(MemtoReg_MEMWB),
                .pc_to_reg(pc_to_reg_MEMWB)
                .mem_read_data(mem_read_data),
                .next_pc1(next_pc1_p4),
                .ALU_Out(ALU_Out),
                .MemtoReg(MemtoReg_p4),
                .pc_to_reg(pc_to_reg)

    );
    endmodule // proc
    // DUMMY LINE FOR REV CONTROL :0:
