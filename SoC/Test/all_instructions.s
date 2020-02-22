start: 0x200
    ; wipe all registers except r0,r1,pc
    move r2,r0,r0
    move r3,r0,r0
    move r4,r0,r0
    move r5,r0,r0
    move r6,r0,r0
    move r7,r0,r0
    move r8,r0,r0
    move r9,r0,r0
    move r10,r0,r0
    move r11,r0,r0
    move r12,r0,r0
    move r13,r0,r0
    move r14,r0,r0
    ; opcode 11 is unused
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
    bra     always
    loadl   r9,#0xdeadbeef
always:
    loadl   r9,#0xabacadab
    ; beq
    load    flags,#alu_tst
    alu     r0,r0,r0            ; should set zero flag
    beq     isequal
    loadl   r10,#0xdeadbeef
isequal:
    loadl   r10,#0xabacadab
    ; jal, opcode 14
    loadl   r11,#jumptarget
    jal     r11,r11,r0
    loadl   r12,#0xdeadbeef
jumptarget:
    loadl   r12,#0xabacadab
    ; pop and push
    loadl   sp,#stack+4*4       ; 0x410
    push    r2                  ; contains 1
    move    r2,r0,r0
    pop     r2
    ; setxxx are actually macros using the setbra instruction
    load    flags,#alu_tst
    alu     r0,r0,r0            ; sets z=1, n=0
    setne   r2                  ; r2 <- 0
    setpos  r2                  ; r2 <- 1
    setmin  r2                  ; r2 <- 0
    seteq   r2                  ; r2 <- 1   
    halt
stack: 0x400
    long 0,0,0,0

