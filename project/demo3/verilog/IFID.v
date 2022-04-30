module IFID(
            //inputs
            input clk,
            input rst,          //When branch is taken, we flush the instruction by rst IF/ID and ID/EX 
                                //In proc.v, we connect the "rst" of IFID to "rst | PCSrc"
            input inst_mem_err,

            input inst_mem_done,    //NOT SURE ON THIS SIGNAL

            input en,
            input [15:0] instruction,
            input [15:0] pcAdd2,    //pcAdd2 used to be next_pc1
            input stall,
            input Halt_IFID,
            //outputs
            output inst_mem_err_IFID,

            output [15:0] instruction_IFID,
            output [15:0] pcAdd2_IFID
        );
    
    wire [15:0] instruction_temp;
    assign instruction_temp =   (rst)   ?   16'h0800 :
                                (stall) ?   instruction_IFID : 
                                            instruction;            //When hazard stall, loop the old instruction to the new one

    reg1 reg_inst_mem_err(
        .clk(clk), 
        .rst(rst | Halt_IFID),
        .write(en),                 //connected to stall in proc.v
        .wdata(inst_mem_err), 
        .rdata(inst_mem_err_IFID) 
    );
    
    reg16 reg_instruction(
        .clk(clk), 
        .rst(1'b0),                 //Unique rst signal only for instruction fetching, 
                                    //we do not want to stop fetching instrcution when "branch/jump is taken" or when "halt is happened"
        .write(en),     
        .wdata(instruction_temp),   //stall will freeze the input of instruction register
        .rdata(instruction_IFID)
    );

    reg16 reg_pcAdd2(
        .clk(clk), 
        .rst(rst | Halt_IFID),
        .write(en),                 //connected to stall in proc.v
        .wdata(pcAdd2), 
        .rdata(pcAdd2_IFID) 
    );


endmodule