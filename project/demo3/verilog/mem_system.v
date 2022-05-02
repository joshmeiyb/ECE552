/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;

   //------------------------cache datapath 0--------------------------//
   //inputs
   wire [15:0] cache_data_in;
   wire [2:0] cache_offset_in;
   //outputs
   wire cache_hit_out_0, cache_dirty_out_0;
   wire cache_valid_out_0;
   wire [4:0] cache_tag_out_0;
   wire [15:0] cache_data_out_0;
   wire cache_err_0;
   //------------------------cache datapath 1--------------------------//
   wire cache_hit_out_1, cache_dirty_out_1;
   wire cache_valid_out_1;
   wire [4:0] cache_tag_out_1;
   wire [15:0] cache_data_out_1;
   wire cache_err_1;
   //------------------------------------------------------------------//



   //------------------------four_bank mem---------------------------//
   //inputs
   wire [15:0] mem_addr;
   //wire [15:0] mem_data_in;
   //outputs
   wire [15:0] mem_data_out;
   wire mem_stall;
   wire [3:0] mem_busy;
   wire mem_err;
   //----------------------------------------------------------------//

   //------------------------cache controller------------------------//
   //outputs
   wire comp;
   wire cache_write;
   wire [2:0] cache_offset_out;
   wire cache_offset_select;
   wire cache_data_in_select;
   wire tag_select;
   wire [2:0] mem_offset;
   wire mem_wr, mem_rd;
   wire cache_valid_in;
   wire cache_ctrl_err;
   wire enable;
   wire cache_hit;
   
   wire done;
   //wire done_delay;

   wire stall_out;
   //-----------------------------------------------------------------//

   
   //--------------------victimway flipflop--------------------------//
   /* XOR GATE
      use flip_victimway as a input of XOR, 
      therefore, victimway will flip when flip_victimway triggered
      a   |   b   |   out 
      0       0       0
      0       1       1
      1       0       1
      1       1       0
   */
   wire victimway_in;
   wire victimway_out;  
   wire flip_victimway;    //On each read or write of the cache, invert the state of victimway
   assign victimway_in = flip_victimway ^ victimway_out;
   dff victimway (.q(victimway_out), .d(victimway_in), .clk(clk), .rst(rst));

   wire cache_way_select;
   assign cache_way_select =  (cache_hit_out_0 & cache_valid_out_0)     ? 1'b0 :
                              (cache_hit_out_1 & cache_valid_out_1)     ? 1'b1 :
                              (/*(~cache_hit_out_0 & ~cache_hit_out_1) & */(~cache_valid_out_0 & ~cache_valid_out_1)) ? 1'b0 :
                              (/*(~cache_hit_out_0 & ~cache_hit_out_1) & */(~cache_valid_out_0 & cache_valid_out_1))  ? 1'b0 : 
                              (/*(~cache_hit_out_0 & ~cache_hit_out_1) & */(cache_valid_out_0 & ~cache_valid_out_1))  ? 1'b1 :
                              /*(cache_valid_out_0 & cache_valid_out_1) ?*/ /*victimway_out*/victimway_in;  //FIXED THIS IN THE LAST STEP, ONE CYCLE LACK BEFORE

   //Implement a demux for enable signal for two-way cache
   
   
   wire cache_way_input;
   wire cache_way_output;
   assign cache_way_input = flip_victimway ? cache_way_select : cache_way_output;   //only happen in COMPARE states
   dff dff_enable(.q(cache_way_output), .d(cache_way_input), .clk(clk), .rst(rst));

   wire enable_0, enable_1;
   assign enable_0 = enable ? 1'b1 : ~cache_way_output; // enable & ~cache_way_output
   assign enable_1 = enable ? 1'b1 : cache_way_output; // enable & cache_way_output
   
   wire [15:0] DataOut_temp;
   wire [4:0] cache_tag_out_temp;
   wire cache_hit_out_temp, cache_dirty_out_temp, cache_valid_out_temp, cache_err_temp;
   
   //Top Level Outputs -- selecting signal cache_way_select is one cycle lack from cache_way_output
   //cache_way_output is the output of dff, we want this output signal to be the selecting signal for the TOP LEVEL SIGNALS
   assign DataOut_temp           = /*cache_way_select*/cache_way_output ? cache_data_out_1  : cache_data_out_0;     //top level output
   assign cache_tag_out_temp     = /*cache_way_select*/cache_way_output ? cache_tag_out_1   : cache_tag_out_0;      //used for mem address
   assign cache_err_temp         = /*cache_way_select*/cache_way_output ? cache_err_1       : cache_err_0;          //top level output 

   //FSM Inputs
   assign cache_hit_out_temp     = cache_way_select ? cache_hit_out_1   : cache_hit_out_0;      //input of FSM
   assign cache_dirty_out_temp   = cache_way_select ? cache_dirty_out_1 : cache_dirty_out_0;    //input of FSM
   assign cache_valid_out_temp   = cache_way_select ? cache_valid_out_1 : cache_valid_out_0;    //input of FSM
   
   
   assign cache_data_in = cache_data_in_select ? mem_data_out : DataIn;

   //---------------------------------------------------------------------------------------------//
   //Passing decimal 7 for no reason, which is 3'b111
   assign cache_offset_in = cache_offset_select ? cache_offset_out : (Addr[2:0] /*& (mem_rd | mem_wr)*/);
   //---------------------------------------------------------------------------------------------//
   
   assign mem_addr = tag_select ? {cache_tag_out_temp, Addr[10:3], mem_offset} : {Addr[15:3], mem_offset};
   //assign err = cache_err | mem_err | cache_ctrl_err;
   //assign DataOut = err ? 16'h0000 : cache_data_out;

   //err = 1'b0;
   assign err = cache_err_temp | mem_err | cache_ctrl_err;
   assign DataOut = DataOut_temp;
   assign CacheHit = cache_hit;
   assign Stall = stall_out;
   assign Done = done/*done_delay*/;
   //reg1 done_delay_reg(.clk(clk), .rst(rst), .write(1'b1), .wdata(done), .rdata(done_delay));
   
   
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (cache_tag_out_0),
                          .data_out             (cache_data_out_0/*DataOut*/),
                          .hit                  (cache_hit_out_0),
                          .dirty                (cache_dirty_out_0),
                          .valid                (cache_valid_out_0),
                          .err                  (cache_err_0),
                          // Inputs
                          .enable               (enable_0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (cache_offset_in),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (cache_write),
                          .valid_in             (cache_valid_in));

      cache #(2 + memtype) c1(// Outputs
                          .tag_out              (cache_tag_out_1),
                          .data_out             (cache_data_out_1),
                          .hit                  (cache_hit_out_1),
                          .dirty                (cache_dirty_out_1),
                          .valid                (cache_valid_out_1),
                          .err                  (cache_err_1),
                          // Inputs
                          .enable               (enable_1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (cache_offset_in),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (cache_write),
                          .valid_in             (cache_valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (mem_busy),
                     .err               (mem_err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (/*cache_data_out*/DataOut_temp),
                     .wr                (mem_wr),
                     .rd                (mem_rd));
   
   // your code here
   cache_controller cache_controller(
                     //Outputs
                     .comp                   (comp),
                     .cache_write            (cache_write),
                     .cache_offset           (cache_offset_out),
                     .cache_data_in_select   (cache_data_in_select),
                     .cache_offset_select    (cache_offset_select),
                     .tag_select             (tag_select),
                     .mem_offset             (mem_offset),
                     .mem_wr                 (mem_wr),
                     .mem_rd                 (mem_rd),
                     .cache_hit              (/*CacheHit*/cache_hit),             //top output
                     .stall_out              (/*Stall*/stall_out),                //top output
                     .done                   (/*Done*/done),                 //top output
                     .valid_in               (cache_valid_in),
                     .err                    (cache_ctrl_err),
                     .enable                 (enable),
                     .flip_victimway         (flip_victimway),
                     //.enable_vw              (enable_vw),
                     //Inputs
                     .clk                    (clk),
                     .rst                    (rst),
                     .Rd                     (Rd),
                     .Wr                     (Wr),
                     .valid                  (cache_valid_out_temp),
                     .dirty                  (cache_dirty_out_temp),
                     .mem_stall              (mem_stall),
                     .hit                    (cache_hit_out_temp));
   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
