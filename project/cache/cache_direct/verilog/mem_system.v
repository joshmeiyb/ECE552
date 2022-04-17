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
   
   output reg [15:0] DataOut;
   output reg        Done;
   output reg        Stall;
   output reg        CacheHit;
   output reg        err;

   //------------------------cache datapath--------------------------//
   //inputs
   wire [15:0] cache_data_in;
   wire [2:0] cache_offset_in;
   //outputs
   wire cache_hit_out, cache_dirty_out;
   wire cache_valid_out;
   wire [4:0] cache_tag_out;
   wire [3:0] cache_data_out;
   wire cache_err;
   //------------------------cache datapath--------------------------//

   //------------------------four_bank mem---------------------------//
   //inputs
   wire [15:0] mem_addr;
   //wire [15:0] mem_data_in;
   //outputs
   wire [15:0] mem_data_out;
   wire mem_stall;
   wire mem_busy;
   wire mem_err;
   //------------------------four_bank mem---------------------------//

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
   //------------------------cache controller------------------------//

   assign cache_data_in = cache_data_in_select ? mem_data_out : DataIn;
   assign cache_offset_in = cache_offset_select ? cache_offset_out : Addr[2:0];
   assign mem_addr = tag_select ? {cache_tag_out, Addr[10:3], mem_offset} : {Addr[15:3], mem_offset};
   assign err = cache_err | mem_err | cache_ctrl_err;

   assign DataOut = err ? 16'h0000 : cache_data_out;


   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (cache_tag_out),
                          .data_out             (cache_data_out),
                          .hit                  (cache_hit_out),
                          .dirty                (cache_dirty_out),
                          .valid                (cache_valid_out),
                          .err                  (cache_err),
                          // Inputs
                          .enable               (enable),
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
                     .data_in           (cache_data_out),
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
                     .cache_hit              (CacheHit),             //top output
                     .stall_out              (Stall),                //top output
                     .done                   (Done),                 //top output
                     .valid_in               (cache_valid_in),
                     .err                    (cache_ctrl_err),
                     .enable                 (enable),
                     //Inputs
                     .clk                    (clk),
                     .rst                    (rst),
                     .Rd                     (Rd),
                     .Wr                     (Wr),
                     .valid                  (cache_valid_out),
                     .dirty                  (cache_dirty_out),
                     .mem_stall              (mem_stall),
                     .hit                    (cache_hit_out));
   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
