module IFID(
            input clk,
            input rst,          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
            input en,
            input [15:0] instruction,
            input [15:0] next_pc1,
            input stall,
            output [15:0] instruction_IFID,
            output [15:0] next_pc1_IFID      
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
    
    assign instruction_temp = (stall) ? 16'b0800 : instruction; //NOP when stall
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

endmodule