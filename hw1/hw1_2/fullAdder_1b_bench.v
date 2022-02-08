module fullAdder_1b_bench();
    reg a,b;
    reg c_in;
    wire s;
    wire c_out;

    wire clk;
    wire rst;
    wire err;

    clkrst my_clkrst( .clk(clk), .rst(rst), .err(err));
    fullAdder_1b iDUT(.s(s), .c_out(c_out), .a(a), .b(b), .c_in(c_in));

    initial begin
        a = 1'b0;
        b = 1'b0;
        c_in = 1'b0;
        #3200 $finish;
    end

    always@(posedge clk)begin
        a = $random;
        b = $random;
        c_in = $random;
    end

    always@(negedge clk)begin
        $display ("a: %x, b: %x, c_in: %x", a, b, c_in);
        if({c_out, s} !== (a + b + c_in)) begin
            $display ("ERRORCHECK sum/carry out error");
            $stop;
        end
    end

endmodule