start: 0x200
    loadl   r14,#dump   ; stack grows down
    loadl   r11,#dump   ; results are stored upwards
    mark    r2
    mark    r3       ; baseline , we do NOT check if counter rolls over
    sub     r2,r3,r2 ; r2 holds cycles for the mark instruction itself
    stor   r2,r11,r0
    move    r11,r11,r1
    ; move
    mark    r3
    move    r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor   r4,r11,r0
    move    r11,r11,r1
    ; mover
    mark    r3
    mover   r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; load
    mark    r3
    load    r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; load long
    mark    r3
    loadl   r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; load #
    mark    r3
    load    r0,#77
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; load long #
    mark    r3
    loadl   r0,#77
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; stor
    mark    r3
    stor    r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; stor long
    mark    r3
    storl   r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; push
    mark    r3
    push    r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; pop
    mark    r3
    pop     r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; jal
    loadl   r5,#jumptarget
    mark    r3
    jal     r0,r5,r0
jumptarget:
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; setbra taken
    test    r0
    mark    r3
    beq     branchtarget1
branchtarget1:
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; setbra not taken
    test    r0
    mark    r3
    bne     branchtarget2
branchtarget2:
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; alu (combinatorial, w.o. preload)
    mark    r3
    alu     r0,r0,r0
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    ; alu (division, w.o. preload)
    loadl   r5,#0x7fffffff
    loadl   r6,#1
divloop:
    load    r13,#alu_divs
    mark    r3
    alu     r7,r5,r6
    mark    r4
    sub     r4,r4,r3
    alu     r4,r4,r2
    stor    r4,r11,r0
    move    r11,r11,r1
    shiftleft  r6,r6,r1
    brp     divloop     ; repeat until r6 high bit is set

    halt
dump: 0x400
    byte    0   ;
