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
    ; bitwise logic ops
    loadl   r2,#0x77777777    ; 0111 0111 ...
    loadl   r3,#0xaaaaaaaa    ; 1010 1010 ...
    ; or
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_or
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; and
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_and
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; xor
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_xor
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; not
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_not
    alu     r5,r3,r2        ; 2nd operand is irrelevant
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; comparison ops
    ; cmp
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_cmp
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; test
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_tst
    alu     r5,r3,r2        ; 2nd operand is irrelevant
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; multiplication ops
    ; mul16 no longer supported, extraneous, so we simply write 0
    storl   r0,r4,r0        ; wipe result
    move    r5,r0,r0
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; mulhi
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_mulhi
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; mullo
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_mullo
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; shift instructions
    ; shiftl
    loadl   r6,#2
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_shiftl
    alu     r5,r3,r6
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; shiftr
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_shiftr
    alu     r5,r3,r6
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; division operations
    ; divu
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_divu
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; remu
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_remu
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; divs 
    ; two positive numbers
    loadl   r2,#0x77777777
    loadl   r3,#0x7aaaaaaa
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_divs
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; rems
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_rems
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; negative divided by positive
    loadl   r2,#0x77777777
    loadl   r3,#0xaaaaaaaa
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_divs
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    ; rems
    storl   r0,r4,r0        ; wipe result
    load    flags,#alu_rems
    alu     r5,r3,r2
    storl   r5,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress


    halt
results: 0x400


