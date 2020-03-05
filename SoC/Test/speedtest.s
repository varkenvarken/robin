start: 0x200
    loadl   r11,#dump
    mark    r2
    mark    r3 ; baseline , we do NOT check if counter rolls over
    move    r0,r0,r0
    mark    r4
    loadl   r6,#0x12345678
    mark    r5
    load    r13,#alu_sub
    loadl   r7,#0x12345600
    mark    r8
    alu     r7,r6,r7
    mark    r9
    storl   r7,r11,r0
    mark    r10
    beq     skip        ; this branch is not taken because of the subtraction
    mark    r11
skip:
    bra     skip2       ; this branch is always taken (although zero offset)
skip2:
    mark    r12
    sub     r12,r12,r11 ; r12 holds the cycles for a taken branch + mark
    sub     r11,r11,r10 ; r11 holds the cycles for a non taken branch + mark
    sub     r10,r10,r9  ; r9 holds the cycles for the storl + mark
    sub     r9,r9,r8    ; r9 holds the cycles for combinatorial alu + mark
    sub     r6,r3,r2    ; r6 holds the cycles for the mark instruction itself
    sub     r7,r4,r3    ; r7 holds the cycles for move + mark
    sub     r8,r5,r4    ; r8 holds the cycles for loadil + mark
    sub     r7,r7,r6    ; r7 now holds the cycles for just move
    sub     r8,r8,r6    ; r8 now holds the cycles for just loadil
    sub     r9,r9,r6    ; r9 now holds the cycles for just a combinatorial alu
    sub     r10,r10,r6  ; r10 now holds the cycles for just a storl
    sub     r11,r11,r6  ; r11 now holds the cycles for just a non taken branch
    sub     r12,r12,r6  ; r12 now holds the cycles for just a taken branch
    halt
dump:
    long    0
