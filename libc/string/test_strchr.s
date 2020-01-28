start:  0x200
    loadl   sp,#stack
    loadl   r2,#'.'
    push    r2
    loadl   r2,#number
    push    r2
    call    #strchr
    mover   sp,sp,3 ; pop link and args
    loadl   r3,#result
    storl   r2,r3,0
    halt
    
    stackdef

number:
    byte0 "12.34" ;
result:
    long 0
