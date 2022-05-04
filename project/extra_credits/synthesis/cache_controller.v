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
    output wire enable,
    //output reg enable_0,
    //output reg enable_1,
    output reg flip_victimway,
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
    
    parameter IDLE          = 5'h00;
    parameter COMPARE_RD    = 5'h01;
    parameter COMPARE_WR    = 5'h02;
    parameter ALLOC_0       = 5'h03;
    parameter ALLOC_1       = 5'h04;
    parameter ALLOC_2       = 5'h05;
    parameter ALLOC_3       = 5'h06;
    parameter ALLOC_4       = 5'h07;
    parameter ALLOC_5       = 5'h08;
    parameter ALLOC_6       = 5'h09;
    parameter WB_0          = 5'h0a;
    parameter WB_1          = 5'h0b;
    parameter WB_2          = 5'h0c;
    parameter WB_3          = 5'h0d;
    parameter HIT_DONE      = 5'h0e;
    parameter MISS_DONE     = 5'h0f;
    parameter ERROR         = 5'h10;
    
    
    wire [4:0] curr_state;      //17 states
    reg [4:0] next_state;       //17 states

    dff statereg[4:0] (.q(curr_state), .d(next_state), .clk(clk), .rst(rst));

    //assign enable = (curr_state != IDLE) && (curr_state != ERROR);
    assign enable = ((curr_state == COMPARE_RD) | (curr_state == COMPARE_WR));
    //assign enable = ((curr_state == IDLE) | (curr_state == COMPARE_RD) | (curr_state == COMPARE_WR));
    //In IDLE state or COMPARE states, we keep the enable signal of cache high, to let the data into the cache

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
        //stall_out               = 1'b0;
        done                    = 1'b0;
        valid_in                = 1'b0;
        err                     = 1'b0;
        //enable                  = 1'b1;       //always enable cache, this used to be high in direct mapped cache
                                                //In 2 ways assoc-mapped cache, we do not always enable one cache, 
                                                //we want to flip between two caches
        next_state              = IDLE;
        flip_victimway          = 1'b0;     //DON't KNOW IF THIS TRIGGERED CORRECTLY

        case(curr_state)
            //5'h00
            IDLE: begin
                //When there is a new Rd or Wr signal, stall the cache     
                stall_out = (Rd | Wr);
                //stall_out = 1'b0;
                next_state = (~Rd & ~Wr) ? IDLE       :
                             (Rd  & ~Wr) ? COMPARE_RD : 
                             (~Rd & Wr)  ? COMPARE_WR :
                                                ERROR ;
            end
            //5'h01
            COMPARE_RD: begin
                //stall_out = 1'b0;
                comp = 1'b1;
                cache_write = 1'b0;
                flip_victimway = 1'b1;
                next_state = (hit & valid)             ? HIT_DONE:
                             (~(hit & valid) & ~dirty) ? ALLOC_0 : 
                             (~(hit & valid) & dirty)  ? WB_0    :
                                                         ERROR   ;
            end
            //5'h02
            COMPARE_WR: begin
                //stall_out = 1'b0;
                comp = 1'b1;
                cache_write = 1'b1;
                flip_victimway = 1'b1;
                next_state = (hit & valid)             ? HIT_DONE:
                             (~(hit & valid) & ~dirty) ? ALLOC_0 : 
                             (~(hit & valid) & dirty)  ? WB_0    :
                                                         ERROR   ;
            end
            //5'h03
            ALLOC_0: begin
                //valid_in = 1'b1;
                mem_rd = 1'b1;
                mem_offset = 3'b000;
                next_state = mem_stall ? ALLOC_0 : ALLOC_1; //if main memory is stall, wait for main memory
            end
            //5'h04
            ALLOC_1: begin
                //valid_in = 1'b1;
                mem_rd = 1'b1;
                mem_offset = 3'b010;
                next_state = mem_stall ? ALLOC_1 : ALLOC_2; //if main memory is stall, wait for main memory
            end
            //5'h05
            ALLOC_2: begin
                valid_in = 1'b1;                            //when write in cache, set valid to 1'b1
                mem_rd = 1'b1;                              
                mem_offset = 3'b100;
                cache_write = 1'b1;
                //flip_victimway = 1'b1;
                cache_offset = 3'b000;
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = mem_stall ? ALLOC_2 : ALLOC_3; //if main memory is stall, wait for main memory
            end
            //5'h06
            ALLOC_3: begin
                valid_in = 1'b1;                            //when write in cache, set valid to 1'b1
                mem_rd = 1'b1;
                mem_offset = 3'b110;
                cache_write = 1'b1;
                //flip_victimway = 1'b1;
                cache_offset = 3'b010;          
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = mem_stall ? ALLOC_3 : ALLOC_4; //if main memory is stall, wait for main memory
            end
            //5'h07
            ALLOC_4: begin
                valid_in = 1'b1;                            //when write in cache, set valid to 1'b1
                cache_write = 1'b1;
                //flip_victimway = 1'b1;
                cache_offset = 3'b100;          
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = ALLOC_5;
            end
            //5'h08
            ALLOC_5: begin
                valid_in = 1'b1;                            //when write in cache, set valid to 1'b1
                cache_write = 1'b1;
                //flip_victimway = 1'b1;
                cache_offset = 3'b110;          
                cache_offset_select = 1'b1;                 //cache offset from cache controller
                cache_data_in_select = 1'b1;                //cache input date from main memory
                next_state = (~Wr & Rd)     ? MISS_DONE :
                             (Wr & ~Rd)     ? ALLOC_6   :
                             //(~Wr & ~Rd)    ? IDLE      :
                                              ERROR;   
            end
            //5'h09
            ALLOC_6: begin
                valid_in = 1'b1;                            //when write in cache, set valid to 1'b1
                cache_write = 1'b1;
                //flip_victimway = 1'b1; 
                comp = 1'b1;                                //when comp = 1, write = 1, the dirty bit of the cache line will be written to "1"
                                                            //since ALLOC_6 is used in write cache, the data be written is not existed in memory

                cache_offset_select = 1'b0;                 //cache offset from cpu
                cache_data_in_select = 1'b0;                //cache input date from CPU
                next_state = MISS_DONE;
            end
            //5'h0a
            WB_0: begin
                mem_wr = 1'b1;
                cache_offset = 3'b000;                      //write back to bank0
                cache_offset_select = 1'b1;                 //cache offset from cache
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b000;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_0 : WB_1;
            end
            //5'h0b
            WB_1: begin
                mem_wr = 1'b1;
                cache_offset = 3'b010;                      //write back to bank1
                cache_offset_select = 1'b1;                 //cache offset from cache
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b010;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_1 : WB_2;
            end
            //5'h0c
            WB_2: begin
                mem_wr = 1'b1;
                cache_offset = 3'b100;                      //write back to bank2
                cache_offset_select = 1'b1;                 //cache offset from cache
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b100;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_2 : WB_3;
            end
            //5'h0d
            WB_3: begin
                mem_wr = 1'b1;
                cache_offset = 3'b110;                      //write back to bank3
                cache_offset_select = 1'b1;                 //cache offset from cache
                tag_select = 1'b1;                          //tag from cache
                mem_offset = 3'b110;                        //mem address is combined with mem_offset determined by cache controller
                next_state = mem_stall ? WB_3 : ALLOC_0;
            end
            //5'h0e
            HIT_DONE: begin
                //valid_in = 1'b1;
                stall_out = 1'b0;                           //deassert Stall
                done = 1'b1;
                cache_hit = 1'b1;                           //When hit, hit = 1   
                next_state = IDLE;
                // next_state = (~Wr & Rd)  ?  COMPARE_RD :
                //              (Wr & ~Rd)  ?  COMPARE_WR :
                //              (~Wr & ~Rd) ?  IDLE       :
                //                             ERROR;
            end
            //5'h0f
            MISS_DONE: begin
                //valid_in = 1'b1;
                stall_out = 1'b0;                           //deassert Stall
                done = 1'b1;                                //When miss, do not assert cache_hit
                next_state = IDLE;
                // next_state = (~Wr & Rd)  ?  COMPARE_RD :
                //              (Wr & ~Rd)  ?  COMPARE_WR :
                //              (~Wr & ~Rd) ?  IDLE       :
                //                             ERROR;
            end
            //5'h10
            ERROR: begin
                err = 1'b1;
                next_state = IDLE;                          //Not sure what is next to error state 
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule