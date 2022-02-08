module cla_4b_bench;
   reg [4:0] A;
   reg [4:0] B;
   reg [4:0] Sumcalc;
   reg        C_in;
   wire [3:0] SUM;
   wire        CO;
   wire        clk;
   //2 dummy wires
   wire        rst;
   wire        err;

   clkrst my_clkrst( .clk(clk), .rst(rst), .err(err));
   cla_4b DUT (.sum(SUM), .c_out(CO), .a(A[3:0]), .b(B[3:0]), .c_in(C_in));

   initial begin
      A = 5'b0_0000;
      B = 5'b0_0000;
      C_in = 1'b0;
      #3200 $finish;
   end
   
   always@(posedge clk) begin
      A[3:0] = $random;
      B[3:0] = $random;
      C_in = $random;
   end
   
   always@(negedge clk) begin
      Sumcalc = A+B+C_in;
      $display("A: %x, B: %x, Sum: %x, Golden Sum: %x", A, B, SUM, Sumcalc);

      if (Sumcalc[3:0] !== SUM) $display ("ERRORCHECK Sum error");
      if (Sumcalc[4] !== CO) $display ("ERRORCHECK CO error");
   end
endmodule