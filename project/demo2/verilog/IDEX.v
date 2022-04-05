module IDEX(
    //inputs
    input clk, 
    input rst,          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
    input en,
    input [15:0] instruction_IFID,          //16-bit        
    input [15:0] pcAdd2_IFID,             //16-bit 
    input [15:0] read1Data,                 //16-bit        
    input [15:0] read2Data,                 //16-bit
    input [15:0] extend_output,             //16-bit
    input [2:0] RegisterRd,     //3-bit
    input [2:0] RegisterRs,
    input [2:0] RegisterRt,

    input Jump,
    input Branch,
    input MemtoReg,
    input MemRead,
    input MemWrite,
    input RegWrite,
    input reg_to_pc,
    input pc_to_reg,
    input [3:0] ALUOp,          //4-bit
    input ALUSrc,
    input ALU_invA,
    input ALU_invB,
    input ALU_Cin,
    
    input PCSrc,
    input Halt_decode,

    input SIIC,
    input RTI,
    //outputs
    output [15:0] instruction_IDEX,        //propogate the IDEX pipline stage  
    output [15:0] pcAdd2_IDEX,              //propogate the IDEX pipline stage
    output [15:0] read1Data_IDEX,            
    output [15:0] read2Data_IDEX,
    output [15:0] extend_output_IDEX,
    output [2:0] RegisterRd_IDEX,
    output [2:0] RegisterRs_IDEX,
    output [2:0] RegisterRt_IDEX,
    output Jump_IDEX,
    output Branch_IDEX,
    output MemtoReg_IDEX,
    output MemRead_IDEX,
    output MemWrite_IDEX,
    output RegWrite_IDEX,
    output reg_to_pc_IDEX,
    output pc_to_reg_IDEX,
    output [3:0] ALUOp_IDEX,
    output ALUSrc_IDEX,
    output ALU_invA_IDEX,
    output ALU_invB_IDEX,
    output ALU_Cin_IDEX,

    output Halt_IDEX,
    output SIIC_IDEX,
    output RTI_IDEX

);
    
    reg16 reg_instruction_IFID (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(instruction_IFID), 
        .rdata(instruction_IDEX)
    );

    //don't flush pc when branch is taken
    reg16 reg_pcAdd2_IFID (
        .clk(clk), 
        .rst(rst | Halt_decode), 
        .write(en), 
        .wdata(pcAdd2_IFID), 
        .rdata(pcAdd2_IDEX)
    );
    
    reg16 reg_read1Data (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(read1Data), 
        .rdata(read1Data_IDEX)
    ); 
    
    //wire rst_reg_read2Data;
    //assign rst_reg_read2Data = MemRead ? 1'b0 : (rst | Halt_decode | PCSrc);
    
    reg16 reg_read2Data (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        //.rst(rst_reg_read2Data),
        .write(en), 
        .wdata(read2Data), 
        .rdata(read2Data_IDEX)
    );
    reg16 reg_extend_output (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(extend_output), 
        .rdata(extend_output_IDEX)
    );


    reg3 reg_RegisterRd (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(RegisterRd), 
        .rdata(RegisterRd_IDEX)
    );
    
    reg3 reg_RegisterRs (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(RegisterRs), 
        .rdata(RegisterRs_IDEX)
    );
    reg3 reg_RegisterRt_from_decode (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(RegisterRt), 
        .rdata(RegisterRt_IDEX)
    );

    reg1 reg_Jump (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(Jump), 
        .rdata(Jump_IDEX)
    );
    reg1 reg_Branch (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(Branch), 
        .rdata(Branch_IDEX)
    );
    reg1 reg_MemtoReg (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(MemtoReg), 
        .rdata(MemtoReg_IDEX)
    );
    reg1 reg_MemRead (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(MemRead), 
        .rdata(MemRead_IDEX)
    );
    reg1 reg_MemWrite (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(MemWrite), 
        .rdata(MemWrite_IDEX)
    );
    reg1 reg_RegWrite (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(RegWrite), 
        .rdata(RegWrite_IDEX)
    );
    reg1 reg_reg_to_pc (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(reg_to_pc), 
        .rdata(reg_to_pc_IDEX)
    );
    reg1 reg_pc_to_reg (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(pc_to_reg), 
        .rdata(pc_to_reg_IDEX)
    );
    reg4 reg_ALUOp (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(ALUOp), 
        .rdata(ALUOp_IDEX)
    );
    
    reg1 reg_ALUSrc (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(ALUSrc), 
        .rdata(ALUSrc_IDEX)
    );
    reg1 reg_ALU_invA (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(ALU_invA), 
        .rdata(ALU_invA_IDEX)
    );
    reg1 reg_ALU_invB (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(ALU_invB), 
        .rdata(ALU_invB_IDEX)
    );
    reg1 reg_ALU_Cin (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(ALU_Cin), 
        .rdata(ALU_Cin_IDEX)
    );
    
    reg1 reg_Halt_decode (
        .clk(clk), 
        .rst(rst | PCSrc), 
        .write(en), 
        .wdata(Halt_decode), 
        .rdata(Halt_IDEX)
    );
    
    reg1 reg_SIIC (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(SIIC), 
        .rdata(SIIC_IDEX)
    );
    reg1 reg_RTI (
        .clk(clk), 
        .rst(rst | Halt_decode | PCSrc), 
        .write(en), 
        .wdata(RTI), 
        .rdata(RTI_IDEX)
    );

endmodule
