module IFID(
            input clk,
            input rst,          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
            input en,
            input [15:0] instruction,
            input [15:0] pcAdd2,    //pcAdd2 used to be next_pc1
            input stall,

            input Halt_IFID,

            output [15:0] instruction_IFID,
            output [15:0] pcAdd2_IFID
        );
    
    wire [15:0] instruction_temp;
    assign instruction_temp =   (rst)   ?   16'h0800 :
                                (stall) ?   instruction_IFID : 
                                            instruction;

    reg16 reg_instruction(
        .clk(clk), 
        .rst(1'b0),
        .write(1'b1),     
        .wdata(instruction_temp), //stall will freeze the input of instruction register
        .rdata(instruction_IFID)
    );

    reg16 reg_pcAdd2(
        .clk(clk), 
        //.rst(rst), 
        .rst(rst | Halt_IFID),
        .write(en),     //connected to stall in proc.v
        .wdata(pcAdd2), 
        .rdata(pcAdd2_IFID) 
    );


endmodule