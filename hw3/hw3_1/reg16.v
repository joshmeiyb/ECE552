module reg16(clk, rst, write, wdata, rdata);
    localparam bitwidth = 16;
    input wire clk;
    input wire rst;
    input wire write;
    input wire [bitwidth-1 : 0] wdata;
    output wire [bitwidth-1 : 0] rdata;

    wire [bitwidth-1 : 0] data_in;
    assign data_in = write ? wdata : rdata;

    dff registers[bitwidth-1 : 0] (.q(wdata), .d(rdata), .clk(clk), .rst(rst));


endmodule