start: 0x200
    loadl   r2,#0x12345678
    shiftright r4,r2,r0  ; r5 = r2 >> 0
    shiftright r5,r2,r1  ; r5 = r2 >> 1
    move    r3,r1,r1
    move    r3,r1,r1
    shiftright r6,r2,r3  ; r6 = r2 >> 2
    move    r3,r3,r3
    shiftright r7,r2,r3  ; r7 = r2 >> 4
    move    r3,r3,r3
    shiftright r8,r2,r3  ; r8 = r2 >> 8
    move    r3,r3,r3
    shiftright r9,r2,r3  ; r9 = r2 >> 16
    move    r3,r3,r3
    shiftright r10,r2,r3  ; r10 = r2 >> 32
    loadl   r3,#31
    shiftright r11,r2,r3  ; r11 = r2 >> 31
    halt
