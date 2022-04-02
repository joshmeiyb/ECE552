module MEMWB(
    //inputs
    input clk,
    input rst,
    input en,
    input next_pc1_EXMEM,      //16-bit
    input ALU_Out_EXMEM,       //16-bit
    input pc_to_reg_EXMEM,
    input RegisterRd_EXMEM, //3-bit   
    input MemtoReg_EXMEM,
    input RegWrite_EXMEM,
    input mem_read_data,    //16-bit
    input Halt_EXMEM,
    input SIIC_EXMEM,
    //outputs
    output next_pc1_MEMWB,
    output ALU_Out_MEMWB,
    output pc_to_reg_MEMWB,
    output RegisterRd_MEMWB,
    output MemtoReg_MEMWB,
    output RegWrite_MEMWB,
    output mem_read_data_MEMWB,
    output Halt_MEMWB,
    output SIIC_MEMWB
);
    reg16 reg_next_pc1_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(next_pc1_EXMEM), 
        .rdata(next_pc1_MEMWB)
    );
    reg16 reg_ALU_Out_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(ALU_Out_EXMEM), 
        .rdata(ALU_Out_MEMWB)
    );
    reg1 reg_pc_to_reg_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(pc_to_reg_EXMEM), 
        .rdata(pc_to_reg_MEMWB)
    );

    reg3 reg_RegisterRd_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(RegisterRd_EXMEM), 
        .rdata(RegisterRd_MEMWB)
    );
    reg1 reg_MemtoReg_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(MemtoReg_EXMEM), 
        .rdata(MemtoReg_MEMWB)
    );
    reg1 reg_RegWrite_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(RegWrite_EXMEM), 
        .rdata(RegWrite_MEMWB)
    );
    reg1 reg_mem_read_data (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(mem_read_data), 
        .rdata(mem_read_data_MEMWB)
    );
    reg1 reg_Halt_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(Halt_EXMEM), 
        .rdata(Halt_MEMWB)
    );
    reg1 reg_SIIC_EXMEM (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(SIIC_EXMEM), 
        .rdata(SIIC_MEMWB)
    );

endmodule