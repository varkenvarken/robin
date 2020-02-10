;{ strlen:strlen.c:1:5
strlen:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument str
        loadl   r10,frame,r4        
        loadl   r2,#0               ; int
        move    r9,r2,0             ; load n (id node)
while_0002_bfb5cfe26f34:
        move    r2,r10,0            ; load str
        move    r10,r10,1           ; postinc ptr to byte or value
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        test    r2                  
        beq     endwhile_0003_bfb5cfe26f34
        move    r2,r9,0             ; load n
        move    r9,r9,1             ; postinc ptr to byte or value
        bra     while_0002_bfb5cfe26f34
endwhile_0003_bfb5cfe26f34:
        move    r2,r9,0             ; load n
        bra     return_0001_bfb5cfe26f34
return_0001_bfb5cfe26f34:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}
