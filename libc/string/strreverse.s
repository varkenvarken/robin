
;{ strreverse:strreverse.c:3:6
strreverse:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r8                  
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument str
        loadl   r10,frame,r4        
        move    r2,r10,0            ; load str
        push    r2                  ; binop(+)
        move    r2,r10,0            ; load str
        push    r2                  
        push    link                
        loadl   r2,#strlen          ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  ; binop(-)
        loadl   r2,#1               ; int
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        move    r9,r2,0             ; load end (id node)
while_0008_a4c0ab4b9b68:
        move    r2,r9,0             ; load end
        push    r2                  ; binop(>)
        move    r2,r10,0            ; load str
        pop     r3                  ; binop(>)
        load    flags,#alu_cmp      ; binop(>)
        alu     r2,r2,r3            
        setmin  r2                  ; > (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     endwhile_0009_a4c0ab4b9b68
        move    r2,r9,0             ; load end
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        move    r8,r2,0             ; load c (id node)
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  
        move    r2,r9,0             ; load end
        load    r13,#alu_sub        ; postdec ptr to byte or value
        alu     r9,r9,1             ; postdec ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        move    r2,r8,0             ; load c
        push    r2                  
        move    r2,r10,0            ; load str
        move    r10,r10,1           ; postinc ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        bra     while_0008_a4c0ab4b9b68
endwhile_0009_a4c0ab4b9b68:
return_0001_a4c0ab4b9b68:
        pop     r10                 
        pop     r9                  
        pop     r8                  
        pop     frame               ; old framepointer
        return 
;}
