module forwarding_unit(
    
    //input Jump_EXMEM,

    //input MemRead_MEMWB,

    input RegWrite_EXMEM,
    input RegWrite_MEMWB,
    input [2:0] RegisterRd_EXMEM,
    input [2:0] RegisterRd_MEMWB,
    input [2:0] RegisterRs_IDEX,
    input [2:0] RegisterRt_IDEX,
    input I_format_IDEX,
    input R_format_IDEX,

    //input MemWrite_IDEX,
    input MemWrite_EXMEM,
    input MemWrite_MEMWB,

    //input [2:0] RegisterRs_EXMEM,
    //input [2:0] read1Data_IFID,
    //input [2:0] read2Data_IFID,
    //input [2:0] RegisterRd_IDEX,
    //input [2:0] RegisterRs_IDEX,
    //input [2:0] RegisterRt_IDEX,
    //output forward_LBI_ST,

    //output forward_EX_to_EX,
    //output forward_MEM_to_EX
    
    //output forward_MEM_to_EX;   //only when MemRead_MEMWB is 1'b1

    output [1:0] forwardA,
    output [1:0] forwardB
);
    
    wire forwardA_EXEX, forwardB_EXEX;
    wire forwardA_MEMEX, forwardB_MEMEX;
    //wire forward_ST_EXEX, forward_ST_MEMEX;

    /*
    assign forward_MEM_to_EX = (MemRead_MEMWB 
                                & (RegWrite_EXMEM == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    */
    
    //EXEX forward
    assign forwardA_EXEX = (RegWrite_EXMEM /*& ~R_format_IDEX & ~I_format_IDEX*/
                            //& (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRs_IDEX)) ? 1'b1 : 1'b0;

    assign forwardB_EXEX = (RegWrite_EXMEM & ~I_format_IDEX //Rt should be ignored when considering the I_format_instruction, since it's all immediate number not register
                            //& (RegisterRd_EXMEM != 0)
                            & (RegisterRd_EXMEM == RegisterRt_IDEX)) ? 1'b1 : 1'b0;

    assign forwardA =   (forwardA_EXEX  /*| forward_ST_EXEX*/)  ?  2'b10 :
                        (forwardA_MEMEX /*| forward_ST_MEMEX*/) ?  2'b01 :
                                                               2'b00;

    //MEMEX forward
    assign forwardA_MEMEX =   (RegWrite_MEMWB /*& ~R_format_IDEX & ~I_format_IDEX*/
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                                & (RegisterRd_EXMEM == RegisterRs_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRs_IDEX)
                            /*| Jump_EXMEM*/) ? 1'b1 : 1'b0;

                            //if instruction before Jump, and after jump has a RAW, use MEM-EX forwarding,
                            //j_4.asm 
                            /*
                            // j test 2
                            // Jump instruction should cause looping to earlier portion of program
                                lbi r1, 0xfd
                                addi r1, r1, 0x01
                                bgez r1, .done          //after 3 total executions of add, go to halt
                                j 0x7fa
                                .done:
                                halt

                            */
    assign forwardB_MEMEX =   (RegWrite_MEMWB & ~I_format_IDEX
                            //& (RegisterRd_MEMWB != 0)
                            & (~(RegWrite_EXMEM & (RegisterRd_EXMEM != 0)
                                & (RegisterRd_EXMEM == RegisterRt_IDEX)))
                            & (RegisterRd_MEMWB == RegisterRt_IDEX)) ? 1'b1 : 1'b0;                 
    
    assign forwardB =   (forwardB_EXEX ) ?  2'b10 :
                        (forwardB_MEMEX) ?  2'b01 :
                                            2'b00;

    //forwarding case for ST after LBI: EX-EX forwarding
    //  3   4   5   6   7   8
    //  F   D   X   M   W
    //           \     
    //            \
    //      F   D   X   M   W
    //if actually writing mem & (wrinting addr == reading addr), EX-EX forward 
    //forwarding data from ALU_Out_EXMEM to ALU_Out(execution)   
    
    //assign forward_ST_EXEX = (MemWrite_EXMEM/*MemWrite_IDEX*/ & (RegisterRs_IDEX == RegisterRd_EXMEM)) ? 1'b1 : 1'b0;

    //forwarding case for ST after LBI: MEM-EX forwarding
    //  3   4   5   6   7   8   9
    //  F   D   X   M   W
    //               \     
    //                \
    //          F   D   X   M   W
    //if actually writing mem & (wrinting addr == reading addr), EX-EX forward 
    //forwarding data from ALU_Out_EXMEM to ALU_Out(execution)

    //assign forward_ST_MEMEX = (MemWrite_MEMWB/*MemWrite_IDEX*/ & (RegisterRs_IDEX == RegisterRd_MEMWB)) ? 1'b1 : 1'b0;


    /*
    NEED TO BE NOTICED:
    ST never write to register, so RAW hazard can just be detected by register.read and register.write
    */

    
    
    //assign forward_LBI_ST = (MemWrite_IDEX 
    //                        & (read1Data_IFID == RegisterRd_IDEX) /*| (read2Data_IFID == RegisterRd_IDEX)*/) ? 1'b1 : 1'b0;
   

endmodule