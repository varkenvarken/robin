start: 0x200
    ; wipe all registers except r0,r1,pc
    move    r2,r0,r0
    move    r3,r0,r0
    move    r4,r0,r0
    move    r5,r0,r0
    move    r6,r0,r0
    move    r7,r0,r0
    move    r8,r0,r0
    move    r9,r0,r0
    move    r10,r0,r0
    move    r11,r0,r0
    move    r12,r0,r0
    move    r13,r0,r0
    move    r14,r0,r0
    ; our operands
    loadl   r2,#12345678
    loadl   r3,#2222222
    ; base address of results
    loadl   r4,#results
    ; add
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_add
    alu     r5,r2,r3
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; sub
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_sub
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    halt
results: 0x400


