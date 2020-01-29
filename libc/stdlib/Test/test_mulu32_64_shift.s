start:  0x200
    loadl   sp,#stack
    loadl   r2,#numbers
    push    r2
    loadl   r2,#4   ; shift right amount
    push    r2
    loadl   r2,#100000   ;b
    push    r2
    loadl   r2,#400000   ;a   expected result  00 00 00 00, 95 02 f9 00
    push    r2
    call    #_mulu32_64_shift
    mover   sp,sp,4 ; pop link and args
    halt
    
    stackdef
    
numbers:
    long 0x12345678,0x87654321    ; hi and lo placeholders

