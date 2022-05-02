module hazard_detection_unit(
    //inputs
    input MemRead_IDEX,
    input [2:0] RegisterRd_IDEX,
    input [2:0] RegisterRs_IFID,
    input [2:0] RegisterRt_IFID,
    input [4:0] Opcode_IFID,
    //outputs
    output stall
);
    
    //In phase 2.2, when stall_memory in fetch, every time fetching a new instruction, the inst_mem_stall will interact with "hazard stall"
    //Since in phase 2, we have a perfect memory which has no stall
    //Therefore, we should remove I/J format from phase 2 HDU detection
    wire JFormat_IFID, IFormat_no_Rs_Rt_IFID, IFormat_no_Rt_IFID;
    //Jformat has no Rs and Rt
    assign JFormat_IFID =   (Opcode_IFID == 5'b00000) |   //check for HALT
                            (Opcode_IFID == 5'b00001) |   //check for NOP
                            (Opcode_IFID == 5'b00100) |   //check for J
                            (Opcode_IFID == 5'b00110) |   //check for JAL
                            (Opcode_IFID == 5'b11000) |   //check for LBI, write to Rs, no reading from registers
                            //extra credits
                            (Opcode_IFID == 5'b00010) |   //check for SIIC
                            (Opcode_IFID == 5'b00011);    //check for RTI

    //Iformat has no Rt
    assign IFormat_IFID =   //01100 sss iiiiiiii
                            (Opcode_IFID == 5'b01100) |   //check for BEQZ
                            (Opcode_IFID == 5'b01101) |   //check for BNEZ
                            (Opcode_IFID == 5'b01110) |   //check for BLTZ
                            (Opcode_IFID == 5'b01111) |   //check for BGEZ
                            (Opcode_IFID == 5'b10010) |   //check for SLBI, reading and writing Rs
                            (Opcode_IFID == 5'b00101) |   //check for JR
                            (Opcode_IFID == 5'b00111) |   //check for JALR
                            //-------------------------------------------------------------------------//
                            //01000 sss ddd iiiii
                            (Opcode_IFID == 5'b01000) |   //check for ADDI
                            (Opcode_IFID == 5'b01001) |   //check for SUBI
                            (Opcode_IFID == 5'b01010) |   //check for XORI
                            (Opcode_IFID == 5'b01011) |   //check for ANDNI
                            (Opcode_IFID == 5'b10100) |   //check for ROLI
                            (Opcode_IFID == 5'b10101) |   //check for SLLI
                            (Opcode_IFID == 5'b10110) |   //check for RORI
                            (Opcode_IFID == 5'b10111) |   //check for SRLI
                            //(Opcode_IFID == 5'b10000) |   //check for ST, reading from Rs, Rd
                            (Opcode_IFID == 5'b10001) |   //check for LD
                            //(Opcode_IFID == 5'b10011) |   //check for STu, reading from Rs, Rd
                            //BTR 11001 sss xxx ddd xx
                            (Opcode_IFID == 5'b11001);    //check for BTR
                            //-------------------------------------------------------------------------//
                            
    //This is the only stall situation when forwarding is correctly implemented and forwarding decision is solved by Execution Stage
    assign stall =  (MemRead_IDEX)  & 
                    ~JFormat_IFID   & 
                    //~IFormat_no_Rs_Rt_IFID  &
                    ( (RegisterRd_IDEX == RegisterRs_IFID) | ((RegisterRd_IDEX == RegisterRt_IFID) & ~IFormat_IFID) );

endmodule