module control( Opcode, four_mode, RegDst, Jump, Branch, ext_select, MemtoReg, 
                ALUOp, ALU_invA, ALU_invB, ALU_Cin, MemRead, MemWrite, ALUSrc, RegWrite,
                reg_to_pc, pc_to_reg, Halt, err, SIIC, RTI
                //LD,
                //R_format, I_format
                );

    //inputs
    input [4:0] Opcode;
    input [1:0] four_mode; //instruction[1:0], selecting mode
    //outputs
    output reg [1:0] RegDst;
    output reg Jump;
    output reg Branch;
    output reg [2:0] ext_select;
    output reg MemtoReg;
    output reg [3:0] ALUOp;
    output reg ALU_invA;
    output reg ALU_invB;
    output reg ALU_Cin;
    output reg MemRead;
    output reg MemWrite;
    output reg ALUSrc;
    output reg RegWrite;
    output reg pc_to_reg;
    output reg reg_to_pc;
    output reg Halt;
    output reg err;
    output reg SIIC;
    output reg RTI;  
    //output reg R_format;
    //output reg I_format;

    reg [3:0] shared_opcode; //ADD, SUB, XOR, ANDN
    reg alu_inva, alu_invb; //intermediate values for ALU_invA, ALU_invB
    //reg alu_cin;
    always @(*) begin
        alu_inva = 1'b0;
        alu_invb = 1'b0;
        //alu_cin = 1'b0;
        case(four_mode)
            2'b00 : begin //ADD
                shared_opcode = 4'b0100;
            end
            2'b01 : begin //SUB
                shared_opcode = 4'b0100;
                alu_inva = 1'b1;    //Rd <- Rt - Rs
                                    //Rs is from instr[10:8], output of read1Data
                //alu_cin = 1'b1;   //four_mode[0] can be ALU_Cin which is 1, for 2's complement
            end
            2'b10 : begin //XOR
                shared_opcode = 4'b0111;
            end
            2'b11 : begin //AND
                shared_opcode = 4'b0101;
                alu_invb = 1'b1;    //Rd <- Rs AND ~Rt
                                    //Rt is from instr[7:5], output of read2Data
            end
            default: begin
                shared_opcode = 4'b0100;
            end
        endcase
    end

    always @(*)begin
        RegDst = 2'b00;
        //RS_sel = 1'b0;
        Jump = 1'b0;
        Branch = 1'b0;
        ext_select = 3'b000;
        MemtoReg = 1'b0;
        ALUOp = 4'b0000;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        MemRead = 1'b0;
        RegWrite = 1'b0;
        reg_to_pc = 1'b0;
        pc_to_reg = 1'b0;
        Halt = 1'b0;
        err = 1'b0;
        SIIC = 1'b0;
        RTI = 1'b0;
        ALU_invA = 1'b0;
        ALU_invB = 1'b0;
        ALU_Cin = 1'b0;
        //R_format = 1'b0;
        //I_format = 1'b0;

        //LD = 1'b0;

        case (Opcode)

            5'b00000: begin //HALT 00000 xxxxxxxxxxx
                Halt = 1'b1;
            end

            5'b00001: begin //NOP  00001 xxxxxxxxxxx
                
            end

            //////////////////////////////////////////////////////////////////////////////
		    // I format 1 Instructions 				                                    //
		    // ----------------------------------------------------------               //
		    // It is characteristic that these instructions		                        //
		    // have RegDst = 2'b01 to get the Dest Reg Rd in instr[7:5], except STU	    //
		    // have ALUSrc = 1'b1 to use immediate in ALU		                        //
		    //////////////////////////////////////////////////////////////////////////////

            //ADDI 01000 sss ddd iiiii | Rd <- Rs + I(sign ext.)
            5'b01000: begin 
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0100;        //ALU add
                ALUSrc = 1'b1;          //use immediate as another operand in ALU
                ext_select = 3'b000;    //sign_ext_5bit
                RegWrite = 1'b1;        //RegisterFIle writing enable signal
                //I_format = 1'b1;
            end

            //SUBI 01001 sss ddd iiiii | Rd <- I(sign ext.) - Rs
            5'b01001: begin 
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0100;        //ALU add
                ALU_invA = 1'b1;        
                ALU_Cin = 1'b1;         //~InA + 1, 2's complement
                ALUSrc = 1'b1;
                ext_select = 3'b000;    //sign_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            //XORI 01010 sss ddd iiiii | Rd <- Rs XOR I(zero ext.)
            5'b01010: begin 
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0111;        //ALU XOR
                ALUSrc = 1'b1;
                ext_select = 3'b011;    //zero_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            //ANDNI 01011 sss ddd iiiii | Rd <- Rs AND ~I(zero ext.)
            5'b01011: begin
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0101;        //ALU AND
                ALU_invB = 1'b1;
                ALUSrc = 1'b1;
                ext_select = 3'b011;    //zero_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            //ROLI 10100 sss ddd iiiii | Rd <- Rs <<(rotate) I(lowest 4 bits)
            5'b10100: begin
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0000;        //ALU rotate left
                ALUSrc = 1'b1;
                ext_select = 3'b011;    //zero_ext_5bit, this will be the ShAmt into shifter, which is already set to lowest 4bit of ALU InB
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            //SLLI 10101 sss ddd iiiii | Rd <- Rs << I(lowest 4 bits)
            5'b10101: begin
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0001;        //ALU shift left
                ALUSrc = 1'b1;
                ext_select = 3'b011;    //zero_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            //RORI 10110 sss ddd iiiii | Rd <- Rs >>(rotate) I(lowest 4 bits)
            5'b10110: begin
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0010;        //ALU rotate right
                ALUSrc = 1'b1;
                ext_select = 3'b011;    //zero_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1; 
            end
            
            //SRLI 10111 sss ddd iiiii | Rd <- Rs >> I(lowest 4 bits)
            5'b10111: begin
                RegDst = 2'b01;         //select write register as instr[7:5], 5bit immediate
                ALUOp = 4'b0011;        //ALU shift right logical, ignore sign bit
                ALUSrc = 1'b1;
                ext_select = 3'b011;    //zero_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            //ST 10000 sss ddd iiiii | Mem[Rs + I(sign ext.)] <- Rd
            5'b10000: begin             
                //No write back, no RegDst signal asserted
                ALUOp = 4'b0100;        //ALU add
                ALUSrc = 1'b1;
                ext_select = 3'b000;    //sign_ext_5bit
                MemWrite = 1'b1;
                //I_format = 1'b1;
            end

            //LD 10001 sss ddd iiiii | Rd <- Mem[Rs + I(sign ext.)]
            5'b10001: begin
                RegDst = 2'b01;
                MemRead = 1'b1;
                MemtoReg = 1'b1;        //Read data memory, then write back to regFile
                ALUOp = 4'b0100;        //ALU add
                ALUSrc = 1'b1;
                ext_select = 3'b000;    //sign_ext_5bit
                RegWrite = 1'b1;
                //I_format = 1'b1;
                //LD = 1'b1;
            end

            //STU 10011 sss ddd iiiii | Mem[Rs + I(sign ext.)] <- Rd
            //                        | Rs <- Rs + I(sign ext.)
            //This is basically doing the same thing as a store, but with 
            //a writeback to a register with the ALU result
            5'b10011: begin
                RegDst = 2'b00;         //write back to Rs, which addr is in instr[10:8]
                ALUOp = 4'b0100;        //ALU add
                ALUSrc = 1'b1;
                ext_select = 3'b000;    //sign_ext_5bit
                MemWrite = 1'b1;
                RegWrite = 1'b1;
                //I_format = 1'b1;
            end

            ///////////////////////////////////////////////////////////////
		    // R format Instructions 				                     //
		    // ----------------------------------------------------------//
		    // It is characteristic that these instructions		         //
		    // have RegDst = 2'b10 to get the Dest Reg in instr[4:2], Rd would be the write address of regFile	 //
            // have RegWrite = 1'b1 as they are always writing regFile   //
		    // have ALUSrc = 1'b0 (except unary operation like BTR)      //
		    ///////////////////////////////////////////////////////////////

            //BTR 11001 sss xxx ddd xx | Rd[bit i] <- Rs[bit 15-i] for i=0..15
            //Bit reversal done by ALU 
            5'b11001: begin
                RegDst = 2'b10;
                ALUOp = 4'b1000;
                //Rs is read from read1Data which is instr[10:8],
                //we don't care about ALUSrc, since we don't need to read Rd in instr[7:5]
                //MemtoReg is default set to 1'b0, therefore ALU_Out will be written back to regFile
                RegWrite = 1'b1;
            end

            //ALU Control differentiates by instr[1:0]
            //ADD  11011 sss ttt ddd 00 | Rd <- Rs + Rt
            //SUB  11011 sss ttt ddd 01 | Rd <- Rt - Rs
            //XOR  11011 sss ttt ddd 10 | Rd <- Rs XOR Rt
            //ANDN 11011 sss ttt ddd 11 | Rd <- Rs AND ~Rt
            5'b11011: begin
                RegDst = 2'b10;
                ALUOp = shared_opcode;           
                //shared_opcode is the output of four_mode case block
                //instr[1:0]     //Operation
                //2'b00          //ADD
                //2'b01          //SUB
                //2'b10          //XOR
                //2'b11          //ANDN
                ALU_invA = alu_inva;
                ALU_invB = alu_invb;
                ALU_Cin = four_mode[0]; //If instr[0] is 1, there will be a Cin
                                        //When instr[0] is 1, instruction would be SUB or ANDN
                                        //Cin does not affect AND operation
                                        //Therefore, only SUB will accept the Cin = 1
                                        //When doing subtraction, Cin required to be 1 to implement 2's complement
                                        //A - B = A + (-B) = A + ((~InB) + 1)
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
                //R_format = 1'b1;
            end

            //ROL 11010 sss ttt ddd 00 | Rd <- Rs << (rotate) Rt (lowest 4 bits)
            //SLL 11010 sss ttt ddd 01 | Rd <- Rs << Rt (lowest 4 bits)
            //ROR 11010 sss ttt ddd 10 | Rd <- Rs >> (rotate) Rt (lowest 4 bits)
            //SRL 11010 sss ttt ddd 11 | Rd <- Rs >> Rt (lowest 4 bits)
            5'b11010: begin
                RegDst = 2'b10;
                ALUOp = {2'b00, four_mode};
                //Opcode  //Operation
                //0000    //Rotate left
                //0001    //Shift left
                //0010    //Rotate right
                //0011    //Shift right logical
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
                //R_format = 1'b1;
            end

            //SEQ 11100 sss ttt ddd xx | if (Rs == Rt) then Rd <- 1 else Rd <- 0
            5'b11100: begin
                RegDst = 2'b10;
                ALUOp = 4'b1001;        //ALU_Out would be SEQ = ~|cla_16b_out
                ALUSrc = 1'b0;
                ALU_invB = 1'b1;        //1's complement implementation
                ALU_Cin = 1'b1;         //2's complement implementation, adding 1'b1 to ~InB
                                        //A - B = A + (-B) = A + ((~InB) + 1)
                RegWrite = 1'b1;
                //R_format = 1'b1;
            end

            //SLT 11101 sss ttt ddd xx | if (Rs < Rt) then Rd <- 1 else Rd <- 0
            5'b11101: begin
                RegDst = 2'b10;
                ALUOp = 4'b1010;
                ALUSrc = 1'b0;
                ALU_invB = 1'b1;        //1's complement implementation
                ALU_Cin = 1'b1;         //2's complement implementation, adding 1'b1 to ~InB
                                        //A - B = A + (-B) = A + ((~InB) + 1)
                RegWrite = 1'b1;
                //R_format = 1'b1;
            end

            //SLE 11110 sss ttt ddd xx | if (Rs <= Rt) then Rd <- 1 else Rd <- 0
            5'b11110: begin
                RegDst = 2'b10;
                ALUOp = 4'b1011;
                ALUSrc = 1'b0;
                ALU_invB = 1'b1;        //1's complement implementation
                ALU_Cin = 1'b1;         //2's complement implementation, adding 1'b1 to ~InB
                                        //A - B = A + (-B) = A + ((~InB) + 1)
                RegWrite = 1'b1;
                //R_format = 1'b1;
            end

            //SCO 11111 sss ttt ddd xx | if (Rs + Rt) generates carry out
            //                           then Rd <- 1 else Rd <- 0
            5'b11111: begin
                RegDst = 2'b10;         //write address would be instr[4:2], which is Rd's address
                ALUOp = 4'b1100;
                ALUSrc = 1'b0;
                RegWrite = 1'b1;
                //R_format = 1'b1;

            end
            
            ///////////////////////////////////////////////////////////////
		    // I format 2 Instructions 				                     //
            // Does not care about RegDst, since disable write to regFile//                             //
            // Unary operation, ALUSrc does not matter                   //
		    ///////////////////////////////////////////////////////////////

            //BEQZ 01100 sss iiiiiiii | if (Rs == 0) then
            //                          PC <- PC + 2 + I(sign ext.)
            5'b01100: begin
                Branch = 1'b1;
                ALUOp = 4'b1111;        //ALU output equals InAA, which is value of Rs
                ext_select = 3'b001;    //sign_ext_8bit
                //I_format = 1'b1;
            end

            //BNEZ 01101 sss iiiiiiii | if (Rs != 0) then
            //                          PC <- PC + 2 + I(sign ext.)
            5'b01101: begin
                Branch = 1'b1;
                ALUOp = 4'b1111;        //ALU output equals InAA, which is value of Rs
                ext_select = 3'b001;    //sign_ext_8bit
                //I_format = 1'b1;
            end

            //BLTZ 01110 sss iiiiiiii | if (Rs < 0) then
            //                          PC <- PC + 2 + I(sign ext.)
            5'b01110: begin
                Branch = 1'b1;
                ALUOp = 4'b1111;        //ALU output equals InAA, which is value of Rs
                ext_select = 3'b001;    //sign_ext_8bit
                //I_format = 1'b1;
            end

            //BGEZ 01111 sss iiiiiiii | if (Rs >= 0) then
            //                          PC <- PC + 2 + I(sign ext.)
            5'b01111: begin
                Branch = 1'b1;
                ALUOp = 4'b1111;        //ALU output equals InAA, which is value of Rs
                ext_select = 3'b001;    //sign_ext_8bit
                //I_format = 1'b1;
            end
            
            /////////////////////////////////////////////////////////
            //LBI 11000 sss iiiiiiii | Rs <- I(sign ext.)
            5'b11000 : begin
			    RegDst = 2'b00;	
			    ALUOp = 4'b1101;        //ALU output equals InBB
			    ALUSrc = 1'b1;	        //Set InBB = immediate
                ext_select = 3'b001;    //sign_ext_8bit
			    RegWrite = 1'b1;
                //I_format = 1'b1;
		    end
            
            //SLBI 10010 sss iiiiiiii | Rs <- (Rs << //A + B8) | I(zero ext.)
		    5'b10010 : begin
			    RegDst = 2'b00;	
			    ALUOp = 4'b1110;        //ALU Specific Operation 
			    ALUSrc = 1'b1;	        //Use immediate as other operand in ALU
                ext_select = 3'b100;    //zero_ext_8bit
			    RegWrite = 1'b1;
                //I_format = 1'b1;
		    end
            //////////////////////////////////////////////////////////


            //////////////////////////////////
		    // J Format Instructions        //
            // RegDst occur in JAL, JALR    //
		    //////////////////////////////////

            //J displacement 00100 ddddddddddd | PC <- PC + 2 + D(sign ext.)
            5'b00100: begin
                Jump = 1'b1;
                ext_select = 3'b010;    //sign_ext_11bit
            end

            //JR 00101 sss iiiiiiii | PC <- Rs + I(sign ext.)
            5'b00101: begin
                Jump = 1'b1;
                ext_select = 3'b001;    //sign_ext_8bit
                ALUOp = 4'b0100;        //ALU add
                ALUSrc = 1'b1;
                reg_to_pc = 1'b1;
                //I_format = 1'b1;
            end

            //JAL displacement 00110 ddddddddddd | R7 <- PC + 2
            //                                     PC <- PC + 2 + D(sign ext.)
            5'b00110: begin
                RegDst = 2'b11;         //write register address is hard coded 3'h7
                RegWrite = 1'b1;        //Enable writeback, write data "PC+2" back to R7
                pc_to_reg = 1'b1;
                Jump = 1'b1;
                ext_select = 3'b010;    //sign_ext_11bit
            end

            //JALR 00111 sss iiiiiiii | R7 <- PC + 2
            //                          PC <- Rs + I(sign ext.)
            5'b00111: begin
                RegDst = 2'b11;         //write register address is hard coded 3'h7
                RegWrite = 1'b1;        //Enable writeback, write data "PC+2" back to R7
                pc_to_reg = 1'b1;
                Jump = 1'b1;
                ext_select = 3'b001;    //sign_ext_8bit
                ALUOp = 4'b0100;        //ALU add
                ALUSrc = 1'b1;
                reg_to_pc = 1'b1;
                //I_format = 1'b1;
                
            end

            /////////////////////////////////
		    // Bonus strange instructions //
		    ///////////////////////////////

            //siic 00010                | produce IllegalOp exception. Must provide one source register.
            5'b00010: begin
            //extra credit, implement later
                SIIC = 1'b1;
                //Jump = 1'b1;  //Don't jump while SIIC
                ALUSrc = 1'b1;
                ALUOp = 4'b1111;
                pc_to_reg = 1'b1;

            end

            //NOP/RTI 00011 xxxxxxxxxxx | PC <- EPC
            5'b00011: begin
            //extra credit, implement later
                RTI = 1'b1;
                reg_to_pc = 1'b1;
                ALUOp = 4'b1111;    //ALU A
            end

            default: begin
                err = 1'b1;             //Unknown Opcode
            end
        endcase
    end

endmodule