module EXMEM (
    //inputs
    input clk,
    input rst,
    input en,
    input [15:0] pcAdd2_IDEX,  //16-bit
    input [15:0] ALU_Out,  //16-bit
    input pc_to_reg_IDEX,
    input [15:0] read2Data_IDEX,//16-bit

    input [2:0] RegisterRd_IDEX,  //3-bit
    //input [2:0] RegisterRs_IDEX,
    //input [2:0] RegisterRt_IDEX,

    input MemtoReg_IDEX,
    input MemRead_IDEX,
    input MemWrite_IDEX,
    input RegWrite_IDEX,
    //input forward_LBI_ST,

    input Jump_IDEX,

    //input [2:0] ext_select_IDEX,
    //input LD_IDEX,

    input Halt_IDEX,
    input SIIC_IDEX,
    input RTI_IDEX,
    //outputs
    output [15:0] pcAdd2_EXMEM,
    output [15:0] ALU_Out_EXMEM,
    output pc_to_reg_EXMEM,
    output [15:0] read2Data_EXMEM,

    output [2:0] RegisterRd_EXMEM,
    //output [2:0] RegisterRs_EXMEM,
    //output [2:0] RegisterRt_EXMEM,

    output MemtoReg_EXMEM,
    output MemRead_EXMEM,
    output MemWrite_EXMEM,
    output RegWrite_EXMEM,
    //output forward_LBI_ST_EXMEM,


    output Jump_EXMEM,

    //output [2:0] ext_select_EXMEM,
    //output LD_EXMEM,

    output Halt_EXMEM,
    output SIIC_EXMEM,
    output RTI_EXMEM
);
    reg16 reg_pcAdd2_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(pcAdd2_IDEX), 
        .rdata(pcAdd2_EXMEM)
    );
    reg16 reg_ALU_Out (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(ALU_Out), 
        .rdata(ALU_Out_EXMEM)
    );
    reg1 reg_pc_to_reg_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(pc_to_reg_IDEX), 
        .rdata(pc_to_reg_EXMEM)
    );
    reg16 reg_read2Data_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(read2Data_IDEX), 
        .rdata(read2Data_EXMEM)
    );


    reg3 reg_RegisterRd_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(RegisterRd_IDEX), 
        .rdata(RegisterRd_EXMEM)
    );
    
    /*
    reg3 reg_RegisterRs_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(RegisterRs_IDEX), 
        .rdata(RegisterRs_EXMEM)
    );
    reg3 reg_RegisterRt_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(RegisterRt_IDEX), 
        .rdata(RegisterRt_EXMEM)
    );
    */

    reg1 reg_MemtoReg_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(MemtoReg_IDEX), 
        .rdata(MemtoReg_EXMEM)
    );


    reg1 reg_MemRead_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(MemRead_IDEX), 
        .rdata(MemRead_EXMEM)
    );
    reg1 reg_MemWrite_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(MemWrite_IDEX), 
        .rdata(MemWrite_EXMEM)
    );
    reg1 reg_RegWrite_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(RegWrite_IDEX), 
        .rdata(RegWrite_EXMEM)
    );
    
    /*
    reg1 reg_forward_LBI_ST (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(forward_LBI_ST), 
        .rdata(forward_LBI_ST_EXMEM)
    );
    */

    reg1 reg_Jump_IDEX(
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(Jump_IDEX), 
        .rdata(Jump_EXMEM)
    );

    reg1 reg_Halt_IDEX (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(Halt_IDEX), 
        .rdata(Halt_EXMEM)
    );
    reg1 reg_SIIC_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(SIIC_IDEX), 
        .rdata(SIIC_EXMEM)
    );
    reg1 reg_RTI_IDEX (
        .clk(clk), 
        .rst(rst | Halt_IDEX), 
        .write(en), 
        .wdata(RTI_IDEX), 
        .rdata(RTI_IDEX)
    );
    
endmodule
