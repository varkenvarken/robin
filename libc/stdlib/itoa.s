
;{ itoa:itoa.c:3:7
itoa:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r7                  
        push    r8                  
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument i
        loadl   r10,frame,r4        
        load    r4,#12              ; init argument s
        loadl   r9,frame,r4         
        move    r2,r10,0            ; load i
        push    r2                  ; binop(<)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(<)
        load    flags,#alu_cmp      ; binop(<)
        alu     r2,r3,r2            
        setmin  r2                  ; <
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0005_a9e651f7e273
        loadl   r2,#'-'             ; char, but loaded as int
        push    r2                  
        move    r2,r9,0             ; load s
        move    r9,r9,1             ; postinc ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        move    r2,r10,0            ; load i
        load    r13,#alu_sub        ; unary -
        alu     r2,0,r2             
        push    r2                  
        move    r2,r10,0            ; load i
        pop     r3                  
        move    r10,r3,0            ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0005_a9e651f7e273:
        move    r2,r9,0             ; load s
        move    r8,r2,0             ; load start (id node)
        move    r2,r10,0            ; load i
        push    r2                  ; binop(==)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     else_ifstmt_0010_a9e651f7e273
        loadl   r2,#'0'             ; char, but loaded as int
        push    r2                  
        move    r2,r9,0             ; load s
        move    r9,r9,1             ; postinc ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        bra     end_ifstmt_0009_a9e651f7e273
else_ifstmt_0010_a9e651f7e273:
while_0011_a9e651f7e273:
        move    r2,r10,0            ; load i
        push    r2                  ; binop(>)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(>)
        load    flags,#alu_cmp      ; binop(>)
        alu     r2,r2,r3            
        setmin  r2                  ; > (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     endwhile_0012_a9e651f7e273
        move    r2,r10,0            ; load i
        push    r2                  ; binop(%)
        loadl   r2,#10              ; int
        pop     r3                  ; binop(%)
        load    flags,#alu_rems     ; binop(%)
        alu     r2,r3,r2            
        move    r7,r2,0             ; load d (id node)
        move    r2,r7,0             ; load d
        push    r2                  ; binop(+)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  
        move    r2,r9,0             ; load s
        move    r9,r9,1             ; postinc ptr to byte or value
        pop     r3                  
        stor    r3,r2,0             ; store byte
        loadl   r2,#10              ; int
        push    r2                  
        move    r2,r10,0            ; load i
        pop     r3                  
        load    aluop,#alu_divs     ; /=
        alu     r10,r10,r3          ; assign long
        move    r2,r10,0            ; result of assignment is rvalue to be reused
        bra     while_0011_a9e651f7e273
endwhile_0012_a9e651f7e273:
end_ifstmt_0009_a9e651f7e273:
        loadl   r2,#0               ; int
        push    r2                  
        move    r2,r9,0             ; load s
        pop     r3                  
        stor    r3,r2,0             ; store byte
        move    r2,r8,0             ; load start
        push    r2                  
        push    link                
        loadl   r2,#strreverse      ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        move    r2,r9,0             ; load s
        bra     return_0001_a9e651f7e273
return_0001_a9e651f7e273:
        pop     r10                 
        pop     r9                  
        pop     r8                  
        pop     r7                  
        pop     frame               ; old framepointer
        return 
;}
