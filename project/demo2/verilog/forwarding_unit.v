module forwarding_unit(
    input RegWrite_EXMEM,
    input RegWrite_MEMWB,
    
    input [2:0] RegisterRd_EXMEM,
    input [2:0] RegisterRd_MEMWB,
    input [2:0] RegisterRs_IDEX,
    input [2:0] RegisterRt_IDEX,
    input I_format,
    input R_format,
    //output forward_EX_to_EX,
    //output forward_MEM_to_EX
    output [1:0] forwardA,
    output [1:0] forwardB
);
    
    wire forwardA_EXEX, forwardB_EXEX;
    wire forwardA_MEMEX, forwardB_MEMEX;
    
    //EXEX forward
    assign forwardA_EXEX = (RegWrite_EXMEM
                            & (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_EXEX = (RegWrite_EXMEM
                            & (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRt_IDEX)) ? 1'b1 : 1'b0;

    assign forwardA =   (forwardA_EXEX)  ?  2'b10 :
                        (forwardA_MEMEX) ?  2'b01 :
                                            2'b00;

    //MEMEX forward
    assign forwardA_MEMEX =   (RegWrite_MEMWB
                            & (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                                & (RegisterRd_EXMEM == RegisterRs_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_MEMEX =   (RegWrite_MEMWB
                            & (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                                & (RegisterRd_EXMEM == RegisterRt_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRt_IDEX)) ? 1'b1 : 1'b0;                 
    
    assign forwardB =   (forwardB_EXEX ) ?  2'b10 :
                        (forwardB_MEMEX) ?  2'b01 :
                                            2'b00;


endmodule