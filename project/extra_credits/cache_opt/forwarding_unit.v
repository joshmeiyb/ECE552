module forwarding_unit(
    //inputs
    input RegWrite_EXMEM,
    input RegWrite_MEMWB,
    input [2:0] RegisterRd_EXMEM,
    input [2:0] RegisterRd_MEMWB,
    input [2:0] RegisterRs_IDEX,
    input [2:0] RegisterRt_IDEX,
    //input I_format_IDEX,
    //input R_format_IDEX,
    input MemWrite_EXMEM,
    input MemWrite_MEMWB,
    input [4:0] Opcode_IDEX,
    //outputs
    output [1:0] forwardA,
    output [1:0] forwardB
);
    
    wire forwardA_EXEX, forwardB_EXEX;
    wire forwardA_MEMEX, forwardB_MEMEX;


    wire IFormat_IDEX;
    wire RFormat_IDEX;
    //Iformat has no Rt
    assign IFormat_IDEX =   (Opcode_IDEX == 5'b01100) |   //check for BEQZ
                            (Opcode_IDEX == 5'b01101) |   //check for BNEZ
                            (Opcode_IDEX == 5'b01110) |   //check for BLTZ
                            (Opcode_IDEX == 5'b01111) |   //check for BGEZ
                            (Opcode_IDEX == 5'b10010) |   //check for SLBI
                            (Opcode_IDEX == 5'b00101) |   //check for JR
                            (Opcode_IDEX == 5'b00111) |   //check for JALR
                            (Opcode_IDEX == 5'b01000) |   //check for ADDI
                            (Opcode_IDEX == 5'b01001) |   //check for SUBI
                            (Opcode_IDEX == 5'b01010) |   //check for XORI
                            (Opcode_IDEX == 5'b01011) |   //check for ANDNI
                            (Opcode_IDEX == 5'b10100) |   //check for ROLI
                            (Opcode_IDEX == 5'b10101) |   //check for SLLI
                            (Opcode_IDEX == 5'b10110) |   //check for RORI
                            (Opcode_IDEX == 5'b10111) |   //check for SRLI
                            (Opcode_IDEX == 5'b10011) |   //check for STU
                            (Opcode_IDEX == 5'b10000) |   //check for ST
                            (Opcode_IDEX == 5'b10001) |   //check for LD
                            (Opcode_IDEX == 5'b11001);    //check for BTR

    assign RFormat_IDEX =   (Opcode_IDEX == 5'b11011) |     //ADD  11011 sss ttt ddd 00
                                                            //SUB  11011 sss ttt ddd 01
                                                            //XOR  11011 sss ttt ddd 10
                                                            //ANDN 11011 sss ttt ddd 11
                            (Opcode_IDEX == 5'b11010) |     //ROL 11010 sss ttt ddd 00
                                                            //SLL 11010 sss ttt ddd 01
                                                            //ROR 11010 sss ttt ddd 10
                                                            //SRL 11010 sss ttt ddd 11
                            (Opcode_IDEX == 5'b11100) |     //SEQ 11100 sss ttt ddd xx
                            (Opcode_IDEX == 5'b11101) |     //SLT
                            (Opcode_IDEX == 5'b11110) |     //SLE
                            (Opcode_IDEX == 5'b11111);      //SCO
 



    //EXEX forward
    assign forwardA_EXEX = (RegWrite_EXMEM & (RFormat_IDEX | IFormat_IDEX)
                            //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                            & (RegisterRd_EXMEM == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_EXEX = (RegWrite_EXMEM & ((RFormat_IDEX & ~IFormat_IDEX) | (Opcode_IDEX == 5'b10011) | (Opcode_IDEX == 5'b10000)) //Rt should be ignored when considering the I_format_instruction, 
                                                            //since it's all immediate number not register
                            //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                            & (RegisterRd_EXMEM == RegisterRt_IDEX)) ? 1'b1 : 1'b0;

    assign forwardA =   (forwardA_EXEX  /*| forward_ST_EXEX*/)  ?  2'b10 :
                        (forwardA_MEMEX /*| forward_ST_MEMEX*/) ?  2'b01 :
                                                               2'b00;

    //MEMEX forward
    assign forwardA_MEMEX =   (RegWrite_MEMWB & (RFormat_IDEX | IFormat_IDEX)
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM //& (RegisterRd_EXMEM != 0) // DO NOT DROP the $r0 register since it is used to store the datas based on WISC-SP22 ISA
                                & (RegisterRd_EXMEM == RegisterRs_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_MEMEX =   (RegWrite_MEMWB & ((RFormat_IDEX & ~IFormat_IDEX) | (Opcode_IDEX == 5'b10011) | (Opcode_IDEX == 5'b10000))
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