start:  0x200
    loadl   sp,#stack
    loadl   r2,#test1
    push    r2
    call    #atoi
    mover   sp,sp,2 ; pop link and arg
    loadl   r3,#result1
    storl   r2,r3,0

    loadl   r2,#test2
    push    r2
    call    #atoi
    mover   sp,sp,2 ; pop link and arg
    loadl   r3,#result2
    storl   r2,r3,0
    halt
    
    stackdef
    
test1:
    byte0 "42.0" ;
test2:
    byte0 "-666" ;
result1:
    long 0
result2:
    long 0
