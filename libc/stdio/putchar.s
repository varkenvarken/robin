;{ putchar:putchar.c:2:5
putchar:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument c
        loadl   r10,frame,r4        
        loadl   r2,#0x100           ; int
        move    r9,r2,0             ; load out (id node)
        move    r2,r10,0            ; load c
        push    r2                  
        move    r2,r9,0             ; load out
        pop     r3
        stor    r3,r2,0             ; store byte
        move    r2,r10,0            ; load c
        bra     return_0001_61a317928791
return_0001_61a317928791:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}
