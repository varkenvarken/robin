

;{ atof:atof.c:4:7
atof:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        mover   sp,sp,-4            ; add space for 4 auto variables
        push    r5                  
        push    r6                  
        push    r7                  
        push    r8                  
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument str
        loadl   r10,frame,r4        
        move    r2,r10,0            ; load str
        push    r2                  
        push    link                
        loadl   r2,#atoi            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        move    r9,r2,0             ; load intpart (id node)
        move    r2,r9,0             ; load intpart
        push    r2                  ; binop(<)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(<)
        load    flags,#alu_cmp      ; binop(<)
        alu     r2,r3,r2            
        setmin  r2                  ; <
        test    r2                  ; setxxx does not alter flags
        move    r8,r2,0             ; load sign (id node)
        move    r2,r8,0             ; load sign
        test    r2                  
        beq     end_ifstmt_0005_55fee688216b
        move    r2,r9,0             ; load intpart
        load    r13,#alu_sub        ; unary -
        alu     r2,0,r2             
        push    r2                  
        move    r2,r9,0             ; load intpart
        pop     r3                  
        move    r9,r3,0             ; assign long from register
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0005_55fee688216b:
        loadl   r2,#'.'             ; char, but loaded as int
        push    r2                  
        move    r2,r10,0            ; load str
        push    r2                  
        push    link                
        loadl   r2,#strchr          ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        move    r7,r2,0             ; load point (id node)
        loadl   r2,#0               ; int
        move    r6,r2,0             ; load shift (id node)
        move    r2,r7,0             ; load point
        test    r2                  
        beq     end_ifstmt_0006_55fee688216b
        move    r2,r7,0             ; load point
        move    r7,r7,1             ; postinc ptr to byte or value
        loadl   r2,#0               ; int
        move    r5,r2,0             ; load fracpart (id node)
        loadl   r2,#5               ; int
        mover   r4,0,-1             ; load fraction (id node)
        storl   r2,frame,r4         
while_0007_55fee688216b:
        move    r2,r9,0             ; load intpart
        push    r2                  ; binop(<)
        loadl   r2,#1000000000      ; int
        pop     r3                  ; binop(<)
        load    flags,#alu_cmp      ; binop(<)
        alu     r2,r3,r2            
        setmin  r2                  ; <
        test    r2                  ; setxxx does not alter flags
        test    r2                  ; && short circuit if left side is false
        setne   r2                  ; also normalize value to be used in bitwise and
        beq     binop_end_0019_55fee688216b
        push    r2                  ; binop(&&)
        move    r2,r6,0             ; load shift
        push    r2                  ; binop(<)
        loadl   r2,#20              ; int
        pop     r3                  ; binop(<)
        load    flags,#alu_cmp      ; binop(<)
        alu     r2,r3,r2            
        setmin  r2                  ; <
        test    r2                  ; setxxx does not alter flags
        test    r2                  ;
        setne   r2                  ; normalize value to be used in bitwise or/and
        pop     r3                  ; binop(&&)
        load    flags,#alu_and      ; binop(&&)
        alu     r2,r3,r2            
binop_end_0019_55fee688216b:
        test    r2                  ; && short circuit if left side is false
        setne   r2                  ; also normalize value to be used in bitwise and
        beq     binop_end_0020_55fee688216b
        push    r2                  ; binop(&&)
        move    r2,r7,0             ; load point
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        test    r2                  ;
        setne   r2                  ; normalize value to be used in bitwise or/and
        pop     r3                  ; binop(&&)
        load    flags,#alu_and      ; binop(&&)
        alu     r2,r3,r2            
binop_end_0020_55fee688216b:
        test    r2                  
        beq     endwhile_0008_55fee688216b
        loadl   r2,#10              ; int
        push    r2                  
        move    r2,r5,0             ; load fracpart
        pop     r3                  
        load    aluop,#alu_mullo    ; *=
        alu     r5,r5,r3            ; assign long
        move    r2,r5,0             ; result of assignment is rvalue to be reused
        move    r2,r7,0             ; load point
        move    r7,r7,1             ; postinc ptr to byte or value
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  ; binop(-)
        loadl   r2,#'0'             ; char, but loaded as int
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        move    r2,r5,0             ; load fracpart
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r5,r5,r3            ; assign long
        move    r2,r5,0             ; result of assignment is rvalue to be reused
        loadl   r2,#1               ; int
        push    r2                  
        move    r2,r9,0             ; load intpart
        pop     r3                  
        load    aluop,#alu_shiftl   ; <<=
        alu     r9,r9,r3            ; assign long
        move    r2,r9,0             ; result of assignment is rvalue to be reused
        move    r2,r6,0             ; load shift
        move    r6,r6,1             ; postinc ptr to byte or value
        move    r2,r5,0             ; load fracpart
        push    r2                  ; binop(>=)
        mover   r4,0,-1             ; load fraction (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(>=)
        load    flags,#alu_cmp      ; binop(>=)
        alu     r2,r3,r2            
        setpos  r2                  ; >=
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0027_55fee688216b
        mover   r4,0,-1             ; load fraction (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        move    r2,r5,0             ; load fracpart
        pop     r3                  
        load    aluop,#alu_sub      ; -=
        alu     r5,r5,r3            ; assign long
        move    r2,r5,0             ; result of assignment is rvalue to be reused
        move    r2,r9,0             ; load intpart
        move    r9,r9,1             ; postinc ptr to byte or value
end_ifstmt_0027_55fee688216b:
        loadl   r2,#5               ; int
        push    r2                  
        mover   r4,0,-1             ; load fraction (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_mullo    ; *=
        alu     r3,r2,r3            ; assign long
        load    r4,#-4              
        storl   r3,frame,r4         ; assign byte/long to auto location
        bra     while_0007_55fee688216b
endwhile_0008_55fee688216b:
end_ifstmt_0006_55fee688216b:
        loadl   r2,#0               ; int
        mover   r4,0,-2             ; load shiftup (id node)
        storl   r2,frame,r4         
        move    r2,r9,0             ; load intpart
        push    r2                  ; binop(!=)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(!=)
        load    flags,#alu_cmp      ; binop(!=)
        alu     r2,r3,r2            
        setne   r2                  ; !=
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0031_55fee688216b
while_0032_55fee688216b:
        move    r2,r9,0             ; load intpart
        push    r2                  ; binop(&)
        loadl   r2,#0x00800000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     endwhile_0033_55fee688216b
        loadl   r2,#1               ; int
        push    r2                  
        move    r2,r9,0             ; load intpart
        pop     r3                  
        load    aluop,#alu_shiftl   ; <<=
        alu     r9,r9,r3            ; assign long
        move    r2,r9,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-2             ; load shiftup (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        mover   r4,0,-2             ; load p++ (id node)
        loadl   r2,frame,r4         ; p++ auto var size 1
        move    r3,r2,1             
        storl   r3,frame,r4         ;
        bra     while_0032_55fee688216b
endwhile_0033_55fee688216b:
        loadl   r2,#0               ; int
        mover   r4,0,-3             ; load f (id node)
        storl   r2,frame,r4         
        move    r2,r9,0             ; load intpart
        push    r2                  ; binop(&)
        loadl   r2,#0x007fffff      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-3             ; load f (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_or       ; |=
        alu     r3,r2,r3            ; assign long
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        loadl   r2,#127             ; int
        push    r2                  ; binop(+)
        loadl   r2,#23              ; int
        push    r2                  ; binop(-)
        mover   r4,0,-2             ; load shiftup (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  ; binop(-)
        move    r2,r6,0             ; load shift
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        mover   r4,0,-4             ; load exp (id node)
        storl   r2,frame,r4         
        mover   r4,0,-4             ; load exp (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(<<)
        loadl   r2,#23              ; int
        pop     r3                  ; binop(<<)
        load    flags,#alu_shiftl   ; binop(<<)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-3             ; load f (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_or       ; |=
        alu     r3,r2,r3            ; assign long
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r8,0             ; load sign
        test    r2                  
        beq     else_condop_0053_55fee688216b
        loadl   r2,#0x80000000      ; int
        bra     end_condop_0052_55fee688216b
else_condop_0053_55fee688216b:
        loadl   r2,#0               ; int
end_condop_0052_55fee688216b:
        push    r2                  
        mover   r4,0,-3             ; load f (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_or       ; |=
        alu     r3,r2,r3            ; assign long
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        mover   r4,0,-3             ; load f (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        bra     return_0001_55fee688216b
end_ifstmt_0031_55fee688216b:
        loadl   r2,#0               ; int
        bra     return_0001_55fee688216b
return_0001_55fee688216b:
        pop     r10                 
        pop     r9                  
        pop     r8                  
        pop     r7                  
        pop     r6                  
        pop     r5                  
        mover   sp,sp,4             ; remove space for 4 auto variables
        pop     frame               ; old framepointer
        return 
;}
