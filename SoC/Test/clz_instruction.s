start: 0x200
    ; base address of results
    loadl   r4,#results
    loadl   r5,#32
    loadl   r2,#1
loop:
    storl   r0,r4,r0        ; wipe result
    ; the clz operation
    load    r13,#10
    alu     r3,r2,r0
    storl   r3,r4,r0
    mover   r4,r4,1         ; add 4 to baseaddress
    move    r2,r2,r2        ; double it
    sub     r5,r5,r1
    bne     loop
    halt
results: 0x400


