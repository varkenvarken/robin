start:  0x200
    loadl   sp,#stack
    loadl   r5,#numbers
    loadl   r6,#results
    loadl   r7,#(results-numbers)//4
    loadl   r8,#-1

test_inverse_loop:
    test    r7
    beq     test_inverse_done

    loadl   r2,r5,0
    push    r2
    mover   r5,r5,1
    call    #inverse
    mover   sp,sp,2  ; pop link and 1 arg
    storl   r2,r6,0
    mover   r6,r6,1
    move    r7,r7,r8 ; subtract 1
    
    bra     test_inverse_loop

test_inverse_done:
    
    halt

    stackdef
    
numbers:
    long 0x3f800000 ; 1.0
    long 0x40000000 ; 2.0
    long 0x447a0000 ; 1000.0
    long 0x3e99999a ; 0.3
    long 0xbe99999a ; -0.3
    long 0xc47a0000 ; -1000.0
    long 0x00000000 ; 0.0
results:
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
