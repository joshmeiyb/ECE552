module hazard_detection_unit(
    /*
    input R_format,
    input I_format,
    input [2:0] writeRegSel_IDEX,
    input [2:0] writeRegSel_EXMEM,
    input [2:0] read1RegSel_IFID, //instruction [10:8]
    input [2:0] read2RegSel_IFID, //instruction [7:5]
    input RegWrite_IDEX,
    input RegWrite_EXMEM,
    */
    //input branch_taken,
    //output writeEn_PC_reg
    
    //input rst,
    
    //input RegWrite_IDEX,
    //input RegWrite_EXMEM,

    input MemRead_IDEX,
    //input [2:0] RegisterRd_EXMEM,
    //input [2:0] RegisterRd_IDEX,
    input [2:0] RegisterRd_IDEX,
    //input [4:0] Opcode_IDEX,
    input [2:0] RegisterRs_IFID,
    input [2:0] RegisterRt_IFID,
    //input [2:0] RegisterRt_IDEX,
    output stall
    
);

    //wire if_LD;
    //assign if_LD = (Opcode_IDEX == 5'b10001) ? 1'b1 : 1'b0;


    assign stall = (MemRead_IDEX) & ((RegisterRd_IDEX == RegisterRs_IFID) | (RegisterRd_IDEX == RegisterRt_IFID));
    //assign stall = (MemRead_IDEX /*& ~if_LD*/) & ((RegisterRt_IDEX == RegisterRs_IFID) | (RegisterRt_IDEX == RegisterRt_IFID));
    /*
    assign stall =  rst ? 1'b0 : 
                    ((RegWrite_IDEX | MemRead_IDEX) & ((RegisterRs_IFID == RegisterRd_IDEX)  
                    | (RegisterRs_IFID == RegisterRd_IDEX))) |

                    ((RegWrite_EXMEM | MemRead_IDEX) & ((RegisterRs_IFID == RegisterRd_EXMEM)  
                    | (RegisterRt_IFID == RegisterRd_EXMEM)));
    */




    //wire raw1, raw2, raw3, raw4;

    //wire hazard_IDEX, hazard_EXMEM;
    //I_format: read1RegSel_IFID == writeRegSel_IDEX, read1RegSel_IFID == writeRegSel_EXMEM
    //R_format: (read1RegSel_IFID == writeRegSel_IDEX)  | (read2RegSel_IFID == writeRegSel_IDEX), 
    //          (read1RegSel_IFID == writeRegSel_EXMEM) | (read2RegSel_IFID == writeRegSel_EXMEM)

    
    
    
    
    /*
    assign raw1 = I_format & (read1RegSel_IFID == writeRegSel_IDEX) & RegWrite_IDEX;
    assign raw2 = I_format & (read1RegSel_IFID == writeRegSel_EXMEM) & RegWrite_IDEX;
    
    assign raw3 = R_format & ((read1RegSel_IFID == writeRegSel_IDEX)  | (read2RegSel_IFID == writeRegSel_IDEX))  & RegWrite_IDEX;
    assign raw4 = R_format & ((read1RegSel_IFID == writeRegSel_EXMEM) | (read2RegSel_IFID == writeRegSel_EXMEM)) & RegWrite_IDEX;

    assign hazard_IDEX = raw1 | raw3;
    assign hazard_EXMEM = raw2 | raw4;
    
    assign stall = hazard_IDEX | hazard_EXMEM;
    //if stall, disable the pipeline flops
    */
    
    //assign writeEn_PC_reg = stall ? 1'b0 : 1'b1;


endmodule