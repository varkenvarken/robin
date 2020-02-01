

;{ newton_raphson_inverse:div_f32.c:7:7
newton_raphson_inverse:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument a
        loadl   r10,frame,r4        
        load    r4,#12              ; init argument x
        loadl   r9,frame,r4         
        move    r2,r9,0             ; load x
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#_mul_f32_       ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        loadl   r2,#0x40000000      ; float: 2.0f
        push    r2                  
        push    link                
        loadl   r2,#_sub_f32_       ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r9,0             ; load x
        push    r2                  
        push    link                
        loadl   r2,#_mul_f32_       ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        load    r2,r2,0             
        bra     return_0001_d2852c14fc61
return_0001_d2852c14fc61:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}
;{ inverse:div_f32.c:11:7
inverse:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        mover   sp,sp,-1            ; add space for 1 auto variables
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument a
        loadl   r10,frame,r4        
        move    r2,0,0              ; missing initializer, default to 0
        mover   r4,0,-1             ; load value (id node)
        storl   r2,frame,r4         
        move    r2,r10,0            ; load a
        push    r2                  
        mover   r4,0,-1             ; load value (id node)
        loadl   r2,frame,r4         ; load value of auto variable for union
        pop     r3                  
        load    r4,#-4              
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-1             ; load value (id node)
        loadl   r2,frame,r4         ; load value of auto variable for union
        push    r2                  ; binop(&)
        loadl   r2,#0x7f800000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        push    r2                  ; binop(==)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0009_d2852c14fc61
        mover   r4,0,-1             ; load value (id node)
        loadl   r2,frame,r4         ; load value of auto variable for union
        push    r2                  ; binop(&)
        loadl   r2,#0x80000000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        push    r2                  ; binop(|)
        loadl   r2,#0x7f800000      ; int
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        bra     return_0002_d2852c14fc61
end_ifstmt_0009_d2852c14fc61:
        loadl   r2,#0x7EEEEEEE      ; int
        push    r2                  ; binop(-)
        mover   r4,0,-1             ; load value (id node)
        loadl   r2,frame,r4         ; load value of auto variable for union
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-1             ; load value (id node)
        loadl   r2,frame,r4         ; load value of auto variable for union
        pop     r3                  
        load    r4,#-4              
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-1             ; load value (id node)
        loadl   r2,frame,r4         ; load value of auto variable for union
        move    r9,r2,0             ; load x (id node)
        move    r2,r9,0             ; load x
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#newton_raphson_inverse; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r9,0             ; load x
        pop     r3                  
        move    r9,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r9,0             ; load x
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#newton_raphson_inverse; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r9,0             ; load x
        pop     r3                  
        move    r9,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r9,0             ; load x
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#newton_raphson_inverse; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r9,0             ; load x
        pop     r3                  
        move    r9,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r9,0             ; load x
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#newton_raphson_inverse; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r9,0             ; load x
        pop     r3                  
        move    r9,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r9,0             ; load x
        bra     return_0002_d2852c14fc61
return_0002_d2852c14fc61:
        pop     r10                 
        pop     r9                  
        mover   sp,sp,1             ; remove space for 1 auto variables
        pop     frame               ; old framepointer
        return 
;}
