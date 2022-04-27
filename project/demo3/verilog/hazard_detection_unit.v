module hazard_detection_unit(
    //inputs
    input MemRead_IDEX,
    input [2:0] RegisterRd_IDEX,
    input [2:0] RegisterRs_IFID,
    input [2:0] RegisterRt_IFID,
    //outputs
    output stall
    
);
    //This is the only stall situation when forwarding is correctly implemented and forwarding decision is solved by Execution Stage
    assign stall = (MemRead_IDEX) & ((RegisterRd_IDEX == RegisterRs_IFID) | (RegisterRd_IDEX == RegisterRt_IFID));

endmodule