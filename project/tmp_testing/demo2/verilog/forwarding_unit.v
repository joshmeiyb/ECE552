module forwarding_unit(
    //inputs
    input RegWrite_EXMEM,
    input RegWrite_MEMWB,
    input [2:0] RegisterRd_EXMEM,
    input [2:0] RegisterRd_MEMWB,
    input [2:0] RegisterRs_IDEX,
    input [2:0] RegisterRt_IDEX,
    input I_format_IDEX,
    input R_format_IDEX,
    input MemWrite_EXMEM,
    input MemWrite_MEMWB,
    //outputs
    output [1:0] forwardA,
    output [1:0] forwardB
);
    
    wire forwardA_EXEX, forwardB_EXEX;
    wire forwardA_MEMEX, forwardB_MEMEX;

    //EXEX forward
    assign forwardA_EXEX = (RegWrite_EXMEM 
                            //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                            & (RegisterRd_EXMEM == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_EXEX = (RegWrite_EXMEM & ~I_format_IDEX //Rt should be ignored when considering the I_format_instruction, 
                                                            //since it's all immediate number not register
                            //& (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRt_IDEX)) ? 1'b1 : 1'b0;

    assign forwardA =   (forwardA_EXEX  /*| forward_ST_EXEX*/)  ?  2'b10 :
                        (forwardA_MEMEX /*| forward_ST_MEMEX*/) ?  2'b01 :
                                                               2'b00;

    //MEMEX forward
    assign forwardA_MEMEX =   (RegWrite_MEMWB
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                                & (RegisterRd_EXMEM == RegisterRs_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_MEMEX =   (RegWrite_MEMWB & ~I_format_IDEX
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                                & (RegisterRd_EXMEM == RegisterRt_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRt_IDEX)) ? 1'b1 : 1'b0;                 
    
    assign forwardB =   (forwardB_EXEX ) ?  2'b10 :
                        (forwardB_MEMEX) ?  2'b01 :
                                            2'b00;

    /*
    ==============================================================================================================
    NEED TO BE NOTICED:
    ST never write to register, so RAW hazard can BOTH be detected by register.read and register.write

    In this case, we use InB_forward_noImm for the ST forwarding, which handles the forwarding to alu input B cases
    ===============================================================================================================
    InB_forward_noImm creates an exception for ST forwarding which do not use extended_output to ALU input B
    Since the InB_forward has the first priority MUX for extend_output
    ===============================================================================================================
    */
   

endmodule