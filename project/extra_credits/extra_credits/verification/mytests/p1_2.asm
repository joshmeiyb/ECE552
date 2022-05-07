// Write your assembly program for Problem 1 (a) #2 here.

//Test seq instruction
//11100 sss ttt ddd xx | SEQ Rd, Rs, Rt | if (Rs == Rt) then Rd <- 1 else Rd <- 0

lbi r1, 2
lbi r2, 1
ld  r2, r2, 1
seq r3, r1, r2 
halt