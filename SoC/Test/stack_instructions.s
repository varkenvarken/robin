start: 0x200
    loadl   r2,#0x12345678
    move    r3,r0,r0
    push    r2
    pop     r3
    halt
stack: 0x400
    long 0,0,0,0

