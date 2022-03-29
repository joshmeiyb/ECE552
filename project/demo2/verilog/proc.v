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
    /*             Fetch          Decode            Execute			   Memory			Writeback	*/

    wire           err_fetch,     err_decode;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Have not implemented these yet.
    wire                          Halt,             Halt_p2,           Halt_p3;
    
    wire                          SIIC,             SIIC_p2,           SIIC_p3,          SIIC_p4;
    
    wire                          RTI,              RTI_p2,            RTI_p3;
    /////////////////////////////////////////////////////////////////////////////////////////////////

    wire [15:0]    instruction,   instruction_p1,   instruction_p2; 
    wire [15:0]    next_pc1,      next_pc1_p1,      next_pc1_p2,       next_pc1_p3,      next_pc1_p4;
    wire [15:0]                                     next_pc2;
    wire [15:0]                                     ALU_Out,           ALU_Out_p3,       ALU_Out_p4;
    wire                                            PCSrc;
    wire                          reg_to_pc,        reg_to_pc_p2;
    wire                          pc_to_reg,        pc_to_reg_p2,      pc_to_reg_p3,     pc_to_reg_p4;
    wire [15:0]                   read1Data,        read1Data_p2;
    
    //There will be a MEM/EX forwarding for read2Data
    wire [15:0]                   read2Data,        read2Data_p2,      read2Data_p3;
    
    wire [15:0]                   extend_output,    extend_output_p2;
    //Edited at pipeline design
    wire [2:0]                    write_reg_addr,   write_reg_addr_p2, write_reg_addr_p3, write_reg_addr_p4;
    wire                          Jump,             Jump_p2;
    wire                          Branch,           Branch_p2;
    wire                          MemtoReg,         MemtoReg_p2,       MemtoReg_p3,       MemtoReg_p4;
    wire                          MemWrite,         MemWrite_p2,       MemWrite_p3;
    //Edited at pipeline design
    wire                          RegWrite,         RegWrite_p2,       RegWrite_p3,       RegWrite_p4;
    wire [3:0]                    ALUOp,            ALUOp_p2;                          
    wire                          ALUSrc,           ALUSrc_p2;
    wire                          ALU_invA,         ALU_invA_p2;
    wire                          ALU_invB,         ALU_invB_p2;
    wire                          ALU_Cin,          ALU_Cin_p2;
    wire [15:0]                                                                           writeback_data;
    
    //wire                          MemRead;                            //MemRead
    //Do not need MemRead, since it is only an enable signal which can be replaced by MemtoReg_p3   
    
    wire                                            ALU_Zero;
    wire                                            ALU_Ofl;
    wire                                            ALU_sign;
    
    //There will be a MEM/EX forwarding for mem_read_data, mem_read_data will be input to EX stage
    wire [15:0]                                                        mem_read_data,     mem_read_data_p4;                         

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
                .reg_to_pc(reg_to_pc_p2),
                .Halt(Halt_p3)                             //Halt will stop PC incrementing
                                                        //In this case, next instruction after "Halt instruction" 
                                                        //would not be accessed by processor
    );

    dff IFID[32:0] ( .clk(clk), .rst(rst | PCSrc),
        .d(instruction,         next_pc1), 
        .q(instruction_p1,      next_pc1_p1)              //next_pc1 to 
    );

    decode decode(
                //Decode Outputs
                .read1Data(read1Data),
                .read2Data(read2Data),
                .err(err_decode),
                .extend_output(extend_output),
                .write_reg_addr_out(write_reg_addr),
                //Control Outputs
                .Jump(Jump),
                .Branch(Branch),
                .MemtoReg(MemtoReg),                   //MUX select signal decide whether "mem_read_data" or "ALU_Out" to pass through
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
                //Inputs
                .instruction(instruction_p1),
                .writeback_data(writeback_data),
                .clk(clk),
                .rst(rst),
                .RegWrite_in(RegWrite_p4),
                .write_reg_addr_in(write_reg_addr_p4)
    );

    dff IDEX[101:0] ( .clk(clk), .rst(rst | PCSrc),
        .d({
            instruction_p1, //16-bit, propogate the IDEX pipline stage  
            next_pc1_p1     //16-bit, propogate the IDEX pipline stage
            read1Data,      //16-bit
            read2Data,      //16-bit
            extend_output,  //16-bit
            write_reg_addr, //3-bit
            Jump,           
            Branch,
            MemtoReg,
            //MemRead,
            MemWrite,
            RegWrite,
            reg_to_pc,
            pc_to_reg,
            ALUOp,          //4-bit
            ALUSrc,
            ALU_invA,
            ALU_invB,
            ALU_Cin,
            Halt,
            SIIC,
            RTI
        }),   
        .q({
            instruction_p2,     //propogate the IDEX pipline stage  
            next_pc1_p2,        //propogate the IDEX pipline stage
            read1Data_p2,
            read2Data_p2,
            extend_output_p2,
            write_reg_addr_p2,
            Jump_p2,
            Branch_p2,
            MemtoReg_p2,
            //MemRead_p2,
            MemWrite_p2,
            RegWrite_p2,
            reg_to_pc_p2,
            pc_to_reg_p2,
            ALUOp_p2,
            ALUSrc_p2,
            ALU_invA_p2,
            ALU_invB_p2,
            ALU_Cin_p2,
            Halt_p2,
            SIIC_p2,
            RTI_p2
        })
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
                .instruction(instruction_p2),
                .next_pc1(next_pc1_p2),
                .read1Data(read1Data_p2),
                .read2Data(read2Data_p2),
                .ALUSrc(ALUSrc_p2),
                .ALU_Cin(ALU_Cin_p2),                     //When doing subtraction, Cin would be need to implement 2's complement
                .ALUOp(ALUOp_p2),
                .ALU_invA(ALU_invA_p2),
                .ALU_invB(ALU_invB_p2),
                .ALU_sign(ALU_sign),                   //DO WE NEED THIS SIGNAL? HOW TO CONNECT WITH OTHER MODULE?
                .extend_output(extend_output_p2),
                .Branch(Branch_p2),
                .Jump(Jump_p2)
    );

    dff EXMEM[:0] ( .clk(clk), .rst(rst | PCSrc),
        .d({
            next_pc1_p2,
            ALU_Out,
            pc_to_reg_p2,
            read2Data_p2,
            write_reg_addr_p2,
            MemtoReg_p2,
            MemWrite_p2,
            RegWrite_p2,
            Halt_p2,
            SIIC_p2,
            RTI_p2
        }),   
        .q({
            next_pc1_p3,
            ALU_Out_p3,
            pc_to_reg_p3,
            read2Data_p3,
            write_reg_addr_p3,
            MemtoReg_p3,
            MemWrite_p3,
            RegWrite_p3,
            Halt_p3,
            SIIC_p3,
            RTI_p3
        })
    );
    
    memory memory(
                //Outputs
                .mem_read_data(mem_read_data),
                //Inputs
                .clk(clk),
                .rst(rst),
                .mem_write_data(read2Data_p3), //This is directly connected with regFile read2Data output
                .ALU_Out(ALU_Out_p3),
                .MemRead(MemtoReg_p3),
                //Do not need MemRead, since it is only an enable signal which can be replaced by MemtoReg_p3 
                .MemWrite(MemWrite_p3),
                .Halt(Halt_p3)          //createdump will write whatever in the datamemory into dumpfile(which is the file will be generated when Halt)
                                        //if (createdump) begin
                                        //    mcd = $fopen("dumpfile", "w");
                                        //    for (i=0; i<=largest+1; i=i+1) begin
                                        //       $fdisplay(mcd,"%4h %2h", i, mem[i]);
                                        //    end
                                        //    $fclose(mcd);
                                        //end
    );

    dff MEMWB[:0] ( .clk(clk), .rst(rst | PCSrc),
        .d({
            next_pc1_p3,
            ALU_Out_p3,
            pc_to_reg_p3,
            write_reg_addr_p3,
            MemtoReg_p3,
            RegWrite_p3,
            mem_read_data,
            SIIC_p3
        }),   
        .q({
            next_pc1_p4,
            ALU_Out_p4,
            pc_to_reg_p4,
            write_reg_addr_p4,
            MemtoReg_p4,
            RegWrite_p4,
            mem_read_data_p4,
            SIIC_p4
        })
    );

    wb wb(
                //Outputs
                .writeback_data(writeback_data),
                //Inputs
                .mem_read_data(mem_read_data),
                .next_pc1(next_pc1_p4),
                .ALU_Out(ALU_Out),
                .MemtoReg(MemtoReg_p4),
                .pc_to_reg(pc_to_reg)
    );
    endmodule // proc
    // DUMMY LINE FOR REV CONTROL :0:
