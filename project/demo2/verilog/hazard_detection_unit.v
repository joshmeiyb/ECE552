module hazard_detection_unit(
    input R_format,
    input I_format,
    input [2:0] writeRegSel_IDEX,
    input [2:0] writeRegSel_EXMEM,
    input [2:0] read1RegSel_IFID, //instruction [10:8]
    input [2:0] read2RegSel_IFID, //instruction [7:5]
    input RegWrite_IDEX,
    input RegWrite_EXMEM,
    //input branch_taken,
    output stall,
    output writeEn_PC_reg
);

/*
                //inputs
                .R_format(R_format),
                .I_format(I_format),
                .writeRegSel_IDEX(RegisterRd_IDEX),
                .writeRegSel_EXMEM(RegisterRd_EXMEM),
                                                        //.read1RegSel_IFID(instruction_IFID[10:8]),
                                                        //.read2RegSel_IFID(instruction_IFID[7:5]),
                .read1RegSel_IFID(RegisterRs),
                .read2RegSel_IFID(RegisterRt),
                .RegWrite_IDEX(RegWrite_IDEX),
                .RegWrite_EXMEM(RegWrite_EXMEM),
                .branch_taken(PCSrc),

                //outputs
                .stall(stall), 
                .writeEn_PC_reg(writeEn_PC_reg)
*/
    wire raw1, raw2, raw3, raw4;

    wire hazard_IDEX, hazard_EXMEM;
    //I_format: read1RegSel_IFID == writeRegSel_IDEX, read1RegSel_IFID == writeRegSel_EXMEM
    //R_format: (read1RegSel_IFID | read2RegSel_IFID) == writeRegSel_IDEX, 
    //          (read1RegSel_IFID | read2RegSel_IFID) == writeRegSel_EXMEM

    assign raw1 = I_format & (read1RegSel_IFID == writeRegSel_IDEX) & RegWrite_IDEX;
    assign raw2 = I_format & (read1RegSel_IFID == writeRegSel_EXMEM) & RegWrite_IDEX;
    
    assign raw3 = R_format & ((read1RegSel_IFID | read2RegSel_IFID) == writeRegSel_IDEX) & RegWrite_IDEX;
    assign raw4 = R_format & ((read1RegSel_IFID | read2RegSel_IFID) == writeRegSel_EXMEM) & RegWrite_IDEX;

    assign hazard_IDEX = raw1 | raw3;
    assign hazard_EXMEM = raw2 | raw4;
    
    assign stall = hazard_IDEX | hazard_EXMEM;
    //if stall, disable the pipeline flops
    assign writeEn_PC_reg = stall ? 1'b0 : 1'b1;


endmodule