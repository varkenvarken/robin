

;{ ftoa:ftoa.c:4:7
ftoa:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        mover   sp,sp,-7            ; add space for 7 auto variables
        push    r5                  
        push    r6                  
        push    r7                  
        push    r8                  
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument f
        loadl   r10,frame,r4        
        load    r4,#12              ; init argument str
        loadl   r9,frame,r4         
        move    r2,r9,0             ; load str
        move    r8,r2,0             ; load s (id node)
        move    r2,r10,0            ; load f
        push    r2                  ; binop(&)
        loadl   r2,#0x80000000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        move    r7,r2,0             ; load sign (id node)
        move    r2,r10,0            ; load f
        push    r2                  ; binop(&)
        loadl   r2,#0x7f800000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        push    r2                  ; binop(>>)
        loadl   r2,#23              ; int
        pop     r3                  ; binop(>>)
        load    flags,#alu_shiftr   ; binop(>>)
        alu     r2,r3,r2            
        move    r6,r2,0             ; load exp (id node)
        move    r2,r10,0            ; load f
        push    r2                  ; binop(&)
        loadl   r2,#0x007fffff      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        push    r2                  ; binop(|)
        loadl   r2,#0x00800000      ; int
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        move    r5,r2,0             ; load man (id node)
        loadl   r2,#127             ; int
        push    r2                  ; binop(-)
        move    r2,r6,0             ; load exp
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  ; binop(+)
        loadl   r2,#23              ; int
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        mover   r4,0,-1             ; load shift (id node)
        storl   r2,frame,r4         
        move    r2,r5,0             ; load man
        push    r2                  ; binop(>>)
        mover   r4,0,-1             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(>>)
        load    flags,#alu_shiftr   ; binop(>>)
        alu     r2,r3,r2            
        mover   r4,0,-2             ; load intpart (id node)
        storl   r2,frame,r4         
        move    r2,r5,0             ; load man
        push    r2                  ; binop(-)
        mover   r4,0,-2             ; load intpart (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(<<)
        mover   r4,0,-1             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(<<)
        load    flags,#alu_shiftl   ; binop(<<)
        alu     r2,r3,r2            
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        mover   r4,0,-3             ; load fracpart (id node)
        storl   r2,frame,r4         

        move    r2,r6,0             ; load exp
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     else_ifstmt_0033_d87fd8114e69
        loadl   r2,#0               ; int
        push    r2                  
        mover   r4,0,-2             ; load intpart (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-8              
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        loadl   r2,#0               ; int
        push    r2                  
        mover   r4,0,-5             ; load fracpartc (id node)
        move    r2,frame,r4         ; load address of auto allocated array
        push    r2                  
        loadl   r2,#1               ; int
        move    r2,r2,r2            ; multiply by 2
        move    r2,r2,r2            ; multiply by 2
        pop     r3                  
        move    r2,r2,r3            ; add index to base address
        pop     r3                  
        storl   r3,r2,0             
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0032_d87fd8114e69
else_ifstmt_0033_d87fd8114e69:
        mover   r4,0,-5             ; load fracpartc (id node)
        move    r2,frame,r4         ; load address of auto allocated array
        push    r2                  
        mover   r4,0,-1             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        loadl   r2,#100000          ; int
        push    r2                  
        mover   r4,0,-3             ; load fracpart (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#_mulu32_64_shift; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,4             
end_ifstmt_0032_d87fd8114e69:
        move    r2,r7,0             ; load sign
        push    r2                  ; binop(!=)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(!=)
        load    flags,#alu_cmp      ; binop(!=)
        alu     r2,r3,r2            
        setne   r2                  ; !=
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0037_d87fd8114e69
        loadl   r2,#'-'             ; char, but loaded as int
        push    r2                  
        move    r2,r8,0             ; load s
        move    r8,r8,1             ; postinc ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
end_ifstmt_0037_d87fd8114e69:
        move    r2,r8,0             ; load s
        push    r2                  
        mover   r4,0,-2             ; load intpart (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#itoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r8,0             ; load s
        pop     r3                  
        move    r8,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        loadl   r2,#'.'             ; char, but loaded as int
        push    r2                  
        move    r2,r8,0             ; load s
        move    r8,r8,1             ; postinc ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        move    r2,r8,0             ; load s
        push    r2                  
        mover   r4,0,-5             ; load fracpartc (id node)
        move    r2,frame,r4         ; load address of auto allocated array
        push    r2                  
        loadl   r2,#1               ; int
        move    r2,r2,r2            ; multiply by 2
        move    r2,r2,r2            ; multiply by 2
        pop     r3                  
        move    r2,r2,r3            ; add index to base address
        loadl   r2,r2,0             ; deref array ref long
        push    r2                  
        push    link                
        loadl   r2,#itoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        push    r2                  
        move    r2,r8,0             ; load s
        pop     r3                  
        move    r8,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        loadl   r2,#0               ; int
        push    r2                  
        move    r2,r8,0             ; load s
        pop     r3                  
        stor    r3,r2,0             ; store byte
        move    r2,0,0              ; missing initializer, default to 0
        mover   r4,0,-6             ; load lastzero (id node)
        storl   r2,frame,r4         
        move    r2,r8,0             ; load s
        load    r13,#alu_sub        ; predec value or pointer to size 1
        load    r3,#1               ; predec value or pointer to size 1
        alu     r2,r2,r3            ; predec value or pointer to size 1
        move    r8,r2,0             ; predec value or pointer to size 1
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  ; binop(==)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        push    r2                  
        mover   r4,0,-6             ; load lastzero (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-24             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
while_0041_d87fd8114e69:
        mover   r4,0,-6             ; load lastzero (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  
        beq     endwhile_0042_d87fd8114e69
        move    r2,r8,0             ; load s
        push    r2                  ; binop(-)
        loadl   r2,#1               ; int
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        mover   r4,0,-7             ; load c (id node)
        storl   r2,frame,r4         
        mover   r4,0,-7             ; load c (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(>=)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(>=)
        load    flags,#alu_cmp      ; binop(>=)
        alu     r2,r3,r2            
        setpos  r2                  ; >=
        test    r2                  ; setxxx does not alter flags
        test    r2                  ; && short circuit if left side is false
        setne   r2                  ; also normalize value to be used in bitwise and
        beq     binop_end_0054_d87fd8114e69
        push    r2                  ; binop(&&)
        mover   r4,0,-7             ; load c (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(<=)
        loadl   r2,#'9'             ; char, but loaded as int
        pop     r3                  ; binop(<=)
        load    flags,#alu_cmp      ; binop(<=)
        alu     r2,r2,r3            
        setpos  r2                  ; <= (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  ;
        setne   r2                  ; normalize value to be used in bitwise or/and
        pop     r3                  ; binop(&&)
        load    flags,#alu_and      ; binop(&&)
        alu     r2,r3,r2            
binop_end_0054_d87fd8114e69:
        test    r2                  
        beq     else_ifstmt_0056_d87fd8114e69
        loadl   r2,#0               ; int
        push    r2                  
        move    r2,r8,0             ; load s
        load    r13,#alu_sub        ; postdec ptr to byte or value
        alu     r8,r8,1             ; postdec ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        mover   r4,0,-7             ; load c (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(==)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        push    r2                  
        mover   r4,0,-6             ; load lastzero (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-24             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0055_d87fd8114e69
else_ifstmt_0056_d87fd8114e69:
        bra     endwhile_0042_d87fd8114e69; break
end_ifstmt_0055_d87fd8114e69:
        bra     while_0041_d87fd8114e69
endwhile_0042_d87fd8114e69:
        move    r2,r9,0             ; load str
        bra     return_0001_d87fd8114e69
return_0001_d87fd8114e69:
        pop     r10                 
        pop     r9                  
        pop     r8                  
        pop     r7                  
        pop     r6                  
        pop     r5                  
        mover   sp,sp,7             ; remove space for 7 auto variables
        pop     frame               ; old framepointer
        return 
;}
