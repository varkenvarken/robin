
;{ _mul_f32_:mul_f32.c:6:7
_mul_f32_:
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
        load    r4,#8               ; init argument a
        loadl   r10,frame,r4        
        load    r4,#12              ; init argument b
        loadl   r9,frame,r4         
        move    r2,r10,0            ; load a
        push    r2                  ; binop(&)
        loadl   r2,#0x80000000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        move    r8,r2,0             ; load signa (id node)
        move    r2,r10,0            ; load a
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
        move    r7,r2,0             ; load expa (id node)
        move    r2,r10,0            ; load a
        push    r2                  ; binop(&)
        loadl   r2,#0x007fffff      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        move    r6,r2,0             ; load mana (id node)
        move    r2,r9,0             ; load b
        push    r2                  ; binop(&)
        loadl   r2,#0x80000000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        move    r5,r2,0             ; load signb (id node)
        move    r2,r9,0             ; load b
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
        mover   r4,0,-1             ; load expb (id node)
        storl   r2,frame,r4         
        move    r2,r9,0             ; load b
        push    r2                  ; binop(&)
        loadl   r2,#0x007fffff      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        mover   r4,0,-2             ; load manb (id node)
        storl   r2,frame,r4         
        move    r2,r8,0             ; load signa
        push    r2                  ; binop(^)
        move    r2,r5,0             ; load signb
        pop     r3                  ; binop(^)
        load    flags,#alu_xor      ; binop(^)
        alu     r2,r3,r2            
        mover   r4,0,-3             ; load signc (id node)
        storl   r2,frame,r4         
        loadl   r2,#0               ; int
        mover   r4,0,-4             ; load expc (id node)
        storl   r2,frame,r4         

        move    r2,r7,0             ; load expa
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     end_ifstmt_0029_e798ccd7d6d2
        move    r2,r6,0             ; load mana
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     end_ifstmt_0030_e798ccd7d6d2
        loadl   r2,#0               ; int
        bra     return_0001_e798ccd7d6d2
end_ifstmt_0030_e798ccd7d6d2:
end_ifstmt_0029_e798ccd7d6d2:
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     end_ifstmt_0031_e798ccd7d6d2
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     end_ifstmt_0032_e798ccd7d6d2
        loadl   r2,#0               ; int
        bra     return_0001_e798ccd7d6d2
end_ifstmt_0032_e798ccd7d6d2:
end_ifstmt_0031_e798ccd7d6d2:
        move    r2,r7,0             ; load expa
        push    r2                  ; binop(+)
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  ; binop(-)
        loadl   r2,#0x7f            ; int
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(|)
        loadl   r2,#0x00800000      ; int
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        push    r2                  
        move    r2,r6,0             ; load mana
        pop     r3                  
        move    r6,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(|)
        loadl   r2,#0x00800000      ; int
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-8              
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-6             ; load fracpartc (id node)
        move    r2,frame,r4         ; load address of auto allocated array
        push    r2                  
        loadl   r2,#23              ; int
        push    r2                  
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        move    r2,r6,0             ; load mana
        push    r2                  
        push    link                
        loadl   r2,#_mulu32_64_shift; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,4             
        mover   r4,0,-6             ; load fracpartc (id node)
        move    r2,frame,r4         ; load address of auto allocated array
        push    r2                  
        loadl   r2,#1               ; int
        move    r2,r2,r2            ; multiply by 2
        move    r2,r2,r2            ; multiply by 2
        pop     r3                  
        move    r2,r2,r3            ; add index to base address
        loadl   r2,r2,0             ; deref array ref long assign rvalue
        mover   r4,0,-7             ; load manc (id node)
        storl   r2,frame,r4         
        mover   r4,0,-7             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(>=)
        loadl   r2,#0x01000000      ; int
        pop     r3                  ; binop(>=)
        load    flags,#alu_cmp      ; binop(>=)
        alu     r2,r3,r2            
        setpos  r2                  ; >=
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0048_e798ccd7d6d2
        loadl   r2,#1               ; int
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r3,r2,r3            ; assign long
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        loadl   r2,#1               ; int
        push    r2                  
        mover   r4,0,-7             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_shiftr   ; >>=
        alu     r3,r2,r3            ; assign long
        load    r4,#-28             
        storl   r3,frame,r4         ; assign byte/long to auto location
end_ifstmt_0048_e798ccd7d6d2:
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(|)
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(<<)
        loadl   r2,#23              ; int
        pop     r3                  ; binop(<<)
        load    flags,#alu_shiftl   ; binop(<<)
        alu     r2,r3,r2            
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        push    r2                  ; binop(|)
        mover   r4,0,-7             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(&)
        loadl   r2,#0x007fffff      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        bra     return_0001_e798ccd7d6d2
return_0001_e798ccd7d6d2:
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
