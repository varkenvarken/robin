start: 0x200
    loadl   r2,#0x00110003
    loadl   r3,#0x00220004
    load    flags,#alu_add
    alu     r4,r2,r3
    load    flags,#alu_sub
    alu     r5,r2,r3
    halt
stack: 0x400
    long 0,0,0,0

