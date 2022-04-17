module cache_controller (
    //Outputs
    output reg comp,
    output reg cache_write,
    output reg [2:0] cache_offset,
    output reg cache_data_in_select,
    output reg cache_offset_select,
    output reg tag_select,
    output reg [2:0] mem_offset,
    output reg mem_wr,
    output reg mem_rd,
    output reg cache_hit,            //top output
    output reg stall_out,            //top output
    output reg done,                 //top output
    output reg valid_in,
    output reg err,
    output reg enable
    //Inputs
    input wire clk,
    input wire rst,
    input wire Rd,
    input wire Wr,
    input wire valid,
    input wire dirty,
    input wire mem_stall,
    input wire hit

);
    wire [3:0] curr_state;      //16 states
    reg [3:0] next_state;       //16 states

    parameter IDLE          = 4'h0;
    parameter COMPARE_RD    = 4'h1;
    parameter COMPARE_WR    = 4'h2;
    parameter ALLOC_0       = 4'h3;
    parameter ALLOC_1       = 4'h4;
    parameter ALLOC_2       = 4'h5;
    parameter ALLOC_3       = 4'h6;
    parameter ALLOC_4       = 4'h7;
    parameter ALLOC_5       = 4'h8;
    parameter ALLOC_6       = 4'h9;
    parameter WB_0          = 4'ha;
    parameter WB_1          = 4'hb;
    parameter WB_2          = 4'hc;
    parameter WB_3          = 4'hd;
    parameter DONE          = 4'he;
    parameter ERROR         = 4'hf;

    dff statereg[3:0] (.q(next_state), .d(curr_state), .clk(clk), .rst(rst));

    always @(*) begin

        comp                    = 1'b0;
        cache_write             = 1'b0;
        cache_offset            = 3'b000;
        cache_data_in_select    = 1'b0;
        cache_offset_select     = 1'b0;
        tag_select              = 1'b0;
        mem_offset              = 3'b000;
        mem_wr                  = 1'b0;
        mem_rd                  = 1'b0;
        cache_hit               = 1'b0;
        stall_out               = 1'b1;     //stall_out will keep being one, until the current data is consumed by memory
        done                    = 1'b0;
        valid_in                = 1'b0
        err                     = 1'b0;
        enable                  = 1'b0;

        case(curr_state)
            IDLE: begin
                next_state = (~Rd & ~Wr) ? IDLE       :
                             (Rd  & ~Wr) ? COMPARE_RD : 
                             (~Rd & Wr)  ? COMPARE_WR :
                                                ERROR ;
            end
            COMPARE_RD: begin
                comp = 1'b1;
                cache_write = 1'b0;
                next_state = (hit & valid)             ? DONE    :
                             (~(hit & valid) & ~dirty) ? ALLOC_0 : 
                             (~(hit & valid) & dirty)  ? WB_0    :
                                                         ERROR   ;
            end
            COMPARE_WR: begin
                comp = 1'b1;
                cache_write = 1'b0;
                next_state = (hit & valid)             ? DONE    :
                             (~(hit & valid) & ~dirty) ? ALLOC_0 : 
                             (~(hit & valid) & dirty)  ? WB_0    :
                                                         ERROR   ;
            end
            ALLOC_0: begin
                mem_rd = 1'b1;
                mem_offset = 3'b000;
                next_state = mem_stall ? ALLOC_0 : ALLOC_1; //if main memory is stall, wait for main memory
            end
            ALLOC_1: begin
                mem_rd = 1'b1;
                mem_offset = 3'b010;
                next_state = mem_stall ? ALLOC_1 : ALLOC_2; //if main memory is stall, wait for main memory
            end
            ALLOC_2: begin
                mem_rd = 1'b1;
                mem_offset = 3'b100;
                cache_write = 1'b1;
                cache_offset = 3'b000;
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = mem_stall ? ALLOC_2 : ALLOC_3; //if main memory is stall, wait for main memory
            end
            ALLOC_3: begin
                mem_rd = 1'b1;
                mem_offset = 3'b110;
                cache_write = 1'b1;
                cache_offset = 3'b010;          
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = mem_stall ? ALLOC_3 : ALLOC_4; //if main memory is stall, wait for main memory
            end
            ALLOC_4: begin
                cache_write = 1'b1;
                cache_offset = 3'b100;          
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = ALLOC_5;
            end
            ALLOC_5: begin
                cache_write = 1'b1;
                cache_offset = 3'b110;          
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = (~Wr & Rd) ? DONE : ALLOC_6;   
            end
            ALLOC_6: begin
                cache_write = 1'b1;          
                cache_offset_select = 1'b0;                 //cache offset from cpu
                cache_data_in_select = 1'b0;                //cache input date from CPU
                next_state = DONE;
            end
            WB_0: begin
                mem_wr = 1'b1;
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b000;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_0 : WB_1;
            end
            WB_1: begin
                mem_wr = 1'b1;
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b010;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_1 : WB_2;
            end
            WB_2: begin
                mem_wr = 1'b1;
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b100;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_2 : WB_3;
            end
            WB_3: begin
                mem_wr = 1'b1;
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b110;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_3 : ALLOC_0;
            end
            DONE: begin
                valid_in = 1'b1;
                done = 1'b1;
                cache_hit = 1'b1;
                stall_out = 1'b0;                           //deassert Stall
                next_state = IDLE;
            end
            ERROR: begin
                err = 1'b1;
                next_state = IDLE;  //Not sure what is next to error state 
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule