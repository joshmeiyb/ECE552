// Write your assembly program for Problem 2 (a) #2 here.

        lbi r2, 1
        lbi r4, 1
        subi r1, r2, 1
        bnez r1, 2
        subi r3, r4, 2
        xor  r1, r2, r3 //target