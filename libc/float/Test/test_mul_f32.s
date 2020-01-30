start:  0x200
    loadl   sp,#stack
    loadl   r2,#0x3f9e0419  ; 1.2345
    push    r2
    loadl   r2,#0xc0600000  ; -3.5
    push    r2
    call    #_mul_f32_
    mover   sp,sp,3 ; pop link and args
    loadl   r3,#number_1
    storl   r2,r3,0

    halt
    
    stackdef
    
number_1:
    long 0
