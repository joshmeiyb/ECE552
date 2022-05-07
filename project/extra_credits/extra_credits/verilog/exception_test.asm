j .realstart
lbi r1, 0
lbi r4, 0x02
ld  r5, r4, 0
lbi r7, 0xBD
rti
halt

.realstart:
lbi r1,0
siic r6
lbi r4, 44
halt

