module MEMWB(
    //inputs
    input clk,
    input rst,

    input [15:0] read2Data_EXMEM,

    input [15:0] instruction_EXMEM,

    input data_mem_stall,
    input data_mem_done,

    input err_decode_EXMEM,
    input inst_mem_err_EXMEM,
    input data_mem_err,

    input en,
    input [15:0] pcAdd2_EXMEM,      //16-bit
    input [15:0] ALU_Out_EXMEM,     //16-bit
    input pc_to_reg_EXMEM,
    input [2:0] RegisterRd_EXMEM,   //3-bit   
    input MemtoReg_EXMEM,
    input RegWrite_EXMEM,
    input MemWrite_EXMEM,
    input MemRead_EXMEM,
    input [15:0] mem_read_data,     //16-bit
    input Halt_EXMEM,
    // input SIIC_EXMEM,
    //outputs

    output [15:0] read2Data_MEMWB,

    output [15:0] instruction_MEMWB,
    
    output data_mem_stall_MEMWB,
    output data_mem_done_MEMWB,

    output err_decode_MEMWB,
    output inst_mem_err_MEMWB,
    output data_mem_err_MEMWB,

    output [15:0] pcAdd2_MEMWB,
    output [15:0] ALU_Out_MEMWB,
    output pc_to_reg_MEMWB,
    output [2:0] RegisterRd_MEMWB,
    output MemtoReg_MEMWB,
    output RegWrite_MEMWB,
    output MemWrite_MEMWB,
    output MemRead_MEMWB,
    output [15:0] mem_read_data_MEMWB,
    output Halt_MEMWB
    // output SIIC_MEMWB
);

    reg16 reg_read2Data_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(read2Data_EXMEM), 
        .rdata(read2Data_MEMWB)
    );


    reg16 reg_instruction_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(instruction_EXMEM), 
        .rdata(instruction_MEMWB)
    );

    reg1 reg_data_mem_stall (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(data_mem_stall), 
        .rdata(data_mem_stall_MEMWB)
    );

    reg1 reg_data_mem_done (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(data_mem_done), 
        .rdata(data_mem_done_MEMWB)
    );
    
    reg1 reg_err_decode_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(err_decode_EXMEM), 
        .rdata(err_decode_MEMWB)
    );
    
    reg1 reg_inst_mem_err_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(inst_mem_err_EXMEM), 
        .rdata(inst_mem_err_MEMWB)
    );

    reg1 reg_data_mem_err (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(data_mem_err), 
        .rdata(data_mem_err_MEMWB)
    );

    
    reg16 reg_pcAdd2_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(pcAdd2_EXMEM), 
        .rdata(pcAdd2_MEMWB)
    );
    reg16 reg_ALU_Out_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(ALU_Out_EXMEM), 
        .rdata(ALU_Out_MEMWB)
    );
    reg1 reg_pc_to_reg_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(pc_to_reg_EXMEM), 
        .rdata(pc_to_reg_MEMWB)
    );

    reg3 reg_RegisterRd_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(RegisterRd_EXMEM), 
        .rdata(RegisterRd_MEMWB)
    );
    reg1 reg_MemtoReg_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(MemtoReg_EXMEM), 
        .rdata(MemtoReg_MEMWB)
    );
    reg1 reg_RegWrite_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(RegWrite_EXMEM), 
        .rdata(RegWrite_MEMWB)
    );

    reg1 reg_MemWrite_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(MemWrite_EXMEM), 
        .rdata(MemWrite_MEMWB)
    );

    reg1 reg_MemRead_EXMEM (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
        .write(en), 
        .wdata(MemRead_EXMEM), 
        .rdata(MemRead_MEMWB)
    );

    reg16 reg_mem_read_data (
        .clk(clk), 
        .rst(rst /*| Halt_EXMEM*/), 
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
    
    // reg1 reg_SIIC_EXMEM (
    //     .clk(clk), 
    //     .rst(rst /*| Halt_EXMEM*/), 
    //     .write(en), 
    //     .wdata(SIIC_EXMEM), 
    //     .rdata(SIIC_MEMWB)
    // );

endmodule
