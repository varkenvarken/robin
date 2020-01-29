start:  0x200
    loadl   sp,#stack
    loadl   r2,#number_1
    push    r2
    loadl   r2,#0x3f800000  ; 1.0
    push    r2
    call    #ftoa
    mover   sp,sp,3 ; pop link and args

    loadl   r2,#number_2
    push    r2
    loadl   r2,#0xc0600000  ; -3.5
    push    r2
    call    #ftoa
    mover   sp,sp,3 ; pop link and args

    loadl   r2,#number_3
    push    r2
    loadl   r2,#0x3f9e0419  ; 1.2345
    push    r2
    call    #ftoa
    mover   sp,sp,3 ; pop link and args

    halt
    
    stackdef
    
number_1:
    byte0 "               " ; 15 spaces + \0
number_2:
    byte0 "               " ; 15 spaces + \0
number_3:
    byte0 "               " ; 15 spaces + \0
