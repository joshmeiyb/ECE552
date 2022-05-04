module reg16(clk, rst, write, wdata, rdata);
    localparam bitwidth = 16;
    input clk;
    input rst;
    input write;
    input [bitwidth-1 : 0] wdata;
    output [bitwidth-1 : 0] rdata;

    wire [bitwidth-1 : 0] data_in;
    assign data_in = write ? wdata : rdata;

    dff bit[bitwidth-1 : 0] (.q(rdata), .d(data_in), .clk(clk), .rst(rst));


endmodule