;{ atoi:atoi.c:1:5
atoi:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r8                  
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument str
        loadl   r10,frame,r4        
        loadl   r2,#0               ; int
        move    r9,r2,0             ; load sign (id node)
        loadl   r2,#0               ; int
        move    r8,r2,0             ; load n (id node)
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  ; binop(==)
        loadl   r2,#'-'             ; char, but loaded as int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0005_896324d78d99
        loadl   r2,#1               ; int
        push    r2                  
        move    r2,r9,0             ; load sign
        pop     r3                  
        move    r9,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r10,0            ; load str
        move    r10,r10,1           ; postinc ptr to byte or value
end_ifstmt_0005_896324d78d99:
while_0006_896324d78d99:
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        test    r2                  ; && short circuit if left side is false
        setne   r2                  ; also normalize value to be used in bitwise and
        beq     binop_end_0015_896324d78d99
        push    r2                  ; binop(&&)
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  ; binop(>=)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(>=)
        load    flags,#alu_cmp      ; binop(>=)
        alu     r2,r3,r2            
        setpos  r2                  ; >=
        test    r2                  ; setxxx does not alter flags
        test    r2                  ;
        setne   r2                  ; normalize value to be used in bitwise or/and
        pop     r3                  ; binop(&&)
        load    flags,#alu_and      ; binop(&&)
        alu     r2,r3,r2            
binop_end_0015_896324d78d99:
        test    r2                  ; && short circuit if left side is false
        setne   r2                  ; also normalize value to be used in bitwise and
        beq     binop_end_0019_896324d78d99
        push    r2                  ; binop(&&)
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
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
binop_end_0019_896324d78d99:
        test    r2                  
        beq     endwhile_0007_896324d78d99
        loadl   r2,#10              ; int
        push    r2                  
        move    r2,r8,0             ; load n
        pop     r3                  
        load    aluop,#alu_mullo    ; *=
        alu     r8,r8,r3            ; assign long
        move    r2,r8,0             ; result of assignment is rvalue to be reused
        move    r2,r10,0            ; load str
        move    r10,r10,1           ; postinc ptr to byte or value
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  ; binop(-)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        move    r2,r8,0             ; load n
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r8,r8,r3            ; assign long
        move    r2,r8,0             ; result of assignment is rvalue to be reused
        bra     while_0006_896324d78d99
endwhile_0007_896324d78d99:
        move    r2,r9,0             ; load sign
        test    r2                  
        beq     end_ifstmt_0023_896324d78d99
        move    r2,r8,0             ; load n
        load    r13,#alu_sub        ; unary -
        alu     r2,0,r2             
        push    r2                  
        move    r2,r8,0             ; load n
        pop     r3                  
        move    r8,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0023_896324d78d99:
        move    r2,r8,0             ; load n
        bra     return_0001_896324d78d99
return_0001_896324d78d99:
        pop     r10                 
        pop     r9                  
        pop     r8                  
        pop     frame               ; old framepointer
        return 
;}
