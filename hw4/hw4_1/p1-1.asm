// Write your assembly program for Problem 1 (a) #1 here.

//Test seq instruction
//11100 sss ttt ddd xx | SEQ Rd, Rs, Rt | if (Rs == Rt) then Rd <- 1 else Rd <- 0

lbi r1, 1
lbi r2, 1
lbi r3, 2
add r4, r1, r2
seq r5, r3, r4
halt
