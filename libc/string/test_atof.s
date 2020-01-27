start:  0x200
    loadl   sp,#stack
    loadl   r2,#test0
    push    r2
    call    #atof
    mover   sp,sp,2 ; pop link and arg
    loadl   r3,#result0
    storl   r2,r3,0

    loadl   sp,#stack
    loadl   r2,#test1
    push    r2
    call    #atof
    mover   sp,sp,2 ; pop link and arg
    loadl   r3,#result1
    storl   r2,r3,0

    loadl   r2,#test2
    push    r2
    call    #atof
    mover   sp,sp,2 ; pop link and arg
    loadl   r3,#result2
    storl   r2,r3,0
    halt
    
    stackdef

test0:
    byte0 "1.0" 
test1:
    byte0 "1."
test2:
    byte0 "-3.5"
result0:
    long 0
result1:
    long 0
result2:
    long 0
