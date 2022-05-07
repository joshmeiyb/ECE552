lbi r1, 0
lbi r3, 2
jr r3, 6 //should jump to add, skip one add instruction
add r2, r1, r3
add r3, r1, r3
lbi r4, 0
bnez .label1 //only flush the next add, jump to label1
add r4, r1, r3
add r5, r1, r3
halt



.label1:
add r6, r1, r3
halt
