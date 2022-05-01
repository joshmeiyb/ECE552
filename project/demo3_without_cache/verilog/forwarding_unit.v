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
    input [15:0] Instr_IDEX,
    //outputs
    output [1:0] forwardA,
    output [1:0] forwardB
);
    
    wire forwardA_EXEX, forwardB_EXEX;
    wire forwardA_MEMEX, forwardB_MEMEX;


    wire IFormat_IDEX;
    //Iformat has no Rt
    assign IFormat_IDEX =   (Instr_IDEX[15:11] == 5'b01100) |   //check for BEQZ
                            (Instr_IDEX[15:11] == 5'b01101) |   //check for BNEZ
                            (Instr_IDEX[15:11] == 5'b01110) |   //check for BLTZ
                            (Instr_IDEX[15:11] == 5'b01111) |   //check for BGEZ
                            (Instr_IDEX[15:11] == 5'b10010) |   //check for SLBI
                            (Instr_IDEX[15:11] == 5'b00101) |   //check for JR
                            (Instr_IDEX[15:11] == 5'b00111) |   //check for JALR
                            (Instr_IDEX[15:11] == 5'b01000) |   //check for ADDI
                            (Instr_IDEX[15:11] == 5'b01001) |   //check for SUBI
                            (Instr_IDEX[15:11] == 5'b01010) |   //check for XORI
                            (Instr_IDEX[15:11] == 5'b01011) |   //check for ANDNI
                            (Instr_IDEX[15:11] == 5'b10100) |   //check for ROLI
                            (Instr_IDEX[15:11] == 5'b10101) |   //check for SLLI
                            (Instr_IDEX[15:11] == 5'b10110) |   //check for RORI
                            (Instr_IDEX[15:11] == 5'b10111) |   //check for SRLI
                            (Instr_IDEX[15:11] == 5'b10011) |   //check for STU
                            (Instr_IDEX[15:11] == 5'b10000) |   //check for ST
                            (Instr_IDEX[15:11] == 5'b10001) |   //check for LD
                            (Instr_IDEX[15:11] == 5'b11001);    //check for BTR



    //EXEX forward
    assign forwardA_EXEX = (RegWrite_EXMEM & (R_format_IDEX | IFormat_IDEX)
                            //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                            & (RegisterRd_EXMEM == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_EXEX = (RegWrite_EXMEM & ((R_format_IDEX & ~IFormat_IDEX) | (Instr_IDEX[15:11] == 5'b10011) | (Instr_IDEX[15:11] == 5'b10000)) //Rt should be ignored when considering the I_format_instruction, 
                                                            //since it's all immediate number not register
                            //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                            & (RegisterRd_EXMEM == RegisterRt_IDEX)) ? 1'b1 : 1'b0;

    assign forwardA =   (forwardA_EXEX  /*| forward_ST_EXEX*/)  ?  2'b10 :
                        (forwardA_MEMEX /*| forward_ST_MEMEX*/) ?  2'b01 :
                                                               2'b00;

    //MEMEX forward
    assign forwardA_MEMEX =   (RegWrite_MEMWB & (R_format_IDEX | IFormat_IDEX)
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                                & (RegisterRd_EXMEM == RegisterRs_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_MEMEX =   (RegWrite_MEMWB & ((R_format_IDEX & ~IFormat_IDEX) | (Instr_IDEX[15:11] == 5'b10011) | (Instr_IDEX[15:11] == 5'b10000))
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
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