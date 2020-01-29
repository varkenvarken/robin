start:  0x200
    loadl   sp,#stack
    loadl   r2,#number_1
    push    r2
    loadl   r2,#123456
    push    r2
    call    #itoa
    mover   sp,sp,3 ; pop link and args
    loadl   r2,#number_2
    push    r2
    loadl   r2,#-666
    push    r2
    call    #itoa
    mover   sp,sp,3 ; pop link and args
    halt
    
    stackdef
    
number_1:
    byte0 "               " ; 15 spaces + \0
number_2:
    byte0 "               " ; 15 spaces + \0
