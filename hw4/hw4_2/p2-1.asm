// Write your assembly program for Problem 2 (a) #1 here.

        lbi r2, 1
        lbi r4, 1
        addi r1, r2, 1
        beqz r1, 2
        addi r3, r4, 2
        xor  r1, r2, r3 //target

