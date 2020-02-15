start: 0x200
    ; opcodes 1,5,9,11 are unused
    ; move, opcode 0
    move    r2,r1,r0            ; r2 <- r1 + r0  (1)
    ; loadil, opcode 7 
    loadl   r3,#0x12345678      ; load long immediate
    ; loadi, opcode 12
    load    r3,#0x44            ; load byte immediate
    ; alu, opcode 2
    load    flags,#alu_add      ; just test addition for now
    alu     r4,r2,r3            ; r4 <- r2 + r3 (0x12345645)
    ; mover, opcode 3
    mover   r5,r4,1             ; r5 <- r4 + 4 * 1  (0x12345649)
    ; stor, opcode 8
    load    r6,#0x20
    stor    r5,r6,r0            ; r5 -> address 0x20 (a byte, so just 0x49)
    ; storl, opcode 10
    storl   r5,r6,r1            ; r5 -> address 0x21 ( a long, so 0x12345649)
    ; load, opcode 4
    move    r7,r0,r0
    load    r7,r6,r0
    ; loadl, opcode 6
    loadl   r8,r6,r1
    ; branch, opcode 13
    ; jal, opcode 14
    ; specials, opcode 15
    halt
