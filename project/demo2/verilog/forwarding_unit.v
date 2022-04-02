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
    
    //wire [1:0] forwardA, forwardB;
    
    //EXEX forward
    assign forwardA = (RegWrite_EXMEM
                        & (RegisterRd_EXMEM != 0)
                        & (RegisterRd_EXMEM == RegisterRs_IDEX)) ? 2'b10 : 2'b00;

    assign forwardB = (RegWrite_EXMEM
                        & (RegisterRd_EXMEM != 0)
                        & (RegisterRd_EXMEM == RegisterRt_IDEX)) ? 2'b10 : 2'b00;

    //assign forward_EX_to_EX = (forwardA == 2'b10) | (forwardB == 2'b10);

    //MEMEX forward
    assign forwardA =   (RegWrite_MEMWB
                        & (RegisterRd_MEMWB != 0)
                        & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRs_IDEX)))
                        & (RegisterRd_MEMWB == RegisterRs_IDEX)) ? 2'b01 : 2'b00;

    assign forwardB =   (RegWrite_MEMWB
                        & (RegisterRd_MEMWB != 0)
                        & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRt_IDEX)))
                        & (RegisterRd_MEMWB == RegisterRt_IDEX)) ? 2'b01 : 2'b00;                  
    
    //assign forward_MEM_to_EX = (forwardA == 2'b01) | (forwardB == 2'b01);


endmodule