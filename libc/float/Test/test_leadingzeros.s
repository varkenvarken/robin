start:  0x200
    loadl   sp,#stack
    loadl   r5,#numbers
    loadl   r6,#tests
    loadl   r7,#(numbers-tests)//4
    loadl   r8,#-1

zerotestloop:
    test    r7
    beq     zerotestdone
    loadl   r2,r6,0
    push    r2
    call    #lz8
    mover   sp,sp,2 ; pop link and args
    storl   r2,r5,0
    mover   r5,r5,1
    mover   r6,r6,1
    move    r7,r7,r8 ; minus one
    bra     zerotestloop

zerotestdone:
    halt
    
    stackdef
tests:
    long 0x81,0x44,0x27,0x19,0x08,0x05,0x03,0x01,0x00 ; 0 to 8 leading zeros respectively (only looking at lower byte)
numbers:
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
    long 0xffffffff
