module hazard_detection_unit(
    //inputs
    input MemRead_IDEX,
    input [2:0] RegisterRd_IDEX,
    input [2:0] RegisterRs_IFID,
    input [2:0] RegisterRt_IFID,
    input [15:0] Instr_IFID,
    //outputs
    output stall
    
);
    
    //In phase 2.2, when stall_memory in fetch, every time fetching a new instruction, the inst_mem_stall will interact with "hazard stall"
    //Since in phase 2, we have a perfect memory which has no stall
    //Therefore, we should remove I/J format from phase 2 HDU detection
    wire JFormat_IFID, IFormat_no_Rs_Rt_IFID, IFormat_no_Rt_IFID;
    //Jformat has no Rs and Rt
    assign JFormat_IFID =   (Instr_IFID[15:11] == 5'b00000) |   //check for HALT
                            (Instr_IFID[15:11] == 5'b00001) |   //check for NOP
                            (Instr_IFID[15:11] == 5'b00100) |   //check for J
                            (Instr_IFID[15:11] == 5'b00110) |   //check for JAL
                            (Instr_IFID[15:11] == 5'b00010) |   //check for SIIC
                            (Instr_IFID[15:11] == 5'b00011);    //check for RTI

    //Iformat has no Rt
    assign IFormat_no_Rs_Rt_IFID =      (Instr_IFID[15:11] == 5'b01100) |   //check for BEQZ
                                        (Instr_IFID[15:11] == 5'b01101) |   //check for BNEZ
                                        (Instr_IFID[15:11] == 5'b01110) |   //check for BLTZ
                                        (Instr_IFID[15:11] == 5'b01111) |   //check for BGEZ
                                        (Instr_IFID[15:11] == 5'b11000) |   //check for LBI
                                        (Instr_IFID[15:11] == 5'b10010) |   //check for SLBI
                                        (Instr_IFID[15:11] == 5'b00101) |   //check for JR
                                        (Instr_IFID[15:11] == 5'b00111);    //check for JALR

    assign IFormat_no_Rt_IFID =         (Instr_IFID[15:11] == 5'b01000) |   //check for ADDI
                                        (Instr_IFID[15:11] == 5'b01001) |   //check for SUBI
                                        (Instr_IFID[15:11] == 5'b01010) |   //check for XORI
                                        (Instr_IFID[15:11] == 5'b01011) |   //check for ANDNI
                                        (Instr_IFID[15:11] == 5'b10100) |   //check for ROLI
                                        (Instr_IFID[15:11] == 5'b10101) |   //check for SLLI
                                        (Instr_IFID[15:11] == 5'b10110) |   //check for RORI
                                        (Instr_IFID[15:11] == 5'b10111) |   //check for SRLI
                                        (Instr_IFID[15:11] == 5'b10000) |   //check for ST
                                        (Instr_IFID[15:11] == 5'b10001) |   //check for LD
                                        (Instr_IFID[15:11] == 5'b10011);    //check for STu        
    
    //This is the only stall situation when forwarding is correctly implemented and forwarding decision is solved by Execution Stage
    assign stall =  (MemRead_IDEX)  & 
                    ~JFormat_IFID   & 
                    ~IFormat_no_Rs_Rt_IFID  &
                    ( (RegisterRd_IDEX == RegisterRs_IFID) | ((RegisterRd_IDEX == RegisterRt_IFID) & ~IFormat_no_Rt_IFID) );

endmodule