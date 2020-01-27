start:  0x200
    loadl   sp,#stack
    loadl   r2,#test
    push    r2
    call    #strlen
    mover   sp,sp,2 ; pop link and arg
    halt
    
    stackdef
test:
    byte0 "Jaap Aap rulez!" ; 15 characters
