module IFID(
            input clk,
            input rst,          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
            input en,
            input [15:0] instruction,
            input [15:0] next_pc1,
            input stall,

            output [15:0] instruction_IFID,
            output [15:0] next_pc1_IFID

            //input [15:0] writeback_data,
            //input RegWrite_MEMWB,
            //input [2:0] RegisterRd_MEMWB,
            //output [15:0] writeback_data_IFID,
            //output RegWrite_IFID,
            //output [2:0] RegisterRd_IFID
               
        );
    
    /*
    reg reg_ (
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(), 
        .rdata()
    );
    */

    wire [15:0] instruction_temp;
    //assign instruction_temp = (stall | rst) ? 16'h0800 : instruction; //NOP when stall

    //When stall happen, generate the NOP in IDEX. Fetch the "instruction reg output" if IFID to the "instruction reg input"

    
    //which one is prior?
    //What if branch taken, want to flush, meanwhile RAW hazard happens, want to stall

    //rst goes first, flush anyway when branch is taken even if RAW hazard to branch instruction
    assign instruction_temp =   (rst)   ?   16'h0800 :
                                (stall) ?   instruction_IFID : 
                                            instruction;

    reg16 reg_instruction(
        .clk(clk), 
        .rst(1'b0), 
        .write(en), 
        .wdata(instruction_temp), 
        .rdata(instruction_IFID)
    );

    reg16 reg_next_pc1(
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(next_pc1), 
        .rdata(next_pc1_IFID) 
    );

    /*
    reg16 reg_writeback_data(
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(writeback_data), 
        .rdata(writeback_data_IFID) 
    );
    */
    
    /*
    reg1 reg_RegWrite_MEMWB(
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(RegWrite_MEMWB), 
        .rdata(RegWrite_IFID) 
    );

    reg3 reg_RegisterRd_MEMWB(
        .clk(clk), 
        .rst(rst), 
        .write(en), 
        .wdata(RegisterRd_MEMWB), 
        .rdata(RegisterRd_IFID) 
    );
    */

endmodule