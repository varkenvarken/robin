start: 0x200
    mark    r2
    mark    r3 ; baseline , we do NOT check if counter rolls over
    move    r0,r0,r0
    mark    r4
    loadl   r6,#0x12345678
    mark    r5
    sub     r6,r3,r2 ; r6 holds the cycles for the mark instruction itself
    sub     r7,r4,r3 ; r7 holds the cycles for move + mark
    sub     r8,r5,r4 ; r8 holds the cycles for loadil + mark
    sub     r7,r7,r6 ; r7 now holds the cycles for just move
    sub     r8,r8,r6 ; r8 now holds the cycles for just loadil
    halt
