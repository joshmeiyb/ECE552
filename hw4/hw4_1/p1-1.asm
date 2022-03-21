// Write your assembly program for Problem 1 (a) #1 here.

//Test seq instruction
//11100 sss ttt ddd xx | SEQ Rd, Rs, Rt | if (Rs == Rt) then Rd <- 1 else Rd <- 0

lbi r1, 0
lbi r2, 0
seq r3, r1, r2  //r3 should be 1
halt
