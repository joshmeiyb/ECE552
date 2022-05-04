
module adder(
            input a, 
            input b, 
            input c_in, 
            output s
            );

	assign s = a ^ b ^ c_in;
	// Use this adder for CLA

endmodule