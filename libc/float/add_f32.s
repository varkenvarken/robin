n:
        byte    4                   
        byte    3                   
        byte    2                   
        byte    2                   
        byte    1                   
        byte    1                   
        byte    1                   
        byte    1                   
        byte    0                   
        byte    0                   
        byte    0                   
        byte    0                   
        byte    0                   
        byte    0                   
        byte    0                   
        byte    0                   
;{ lz8:add_f32.c:3:5
lz8:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument a
        loadl   r10,frame,r4        
        loadl   r2,#0xff            ; int
        push    r2                  
        move    r2,r10,0            ; load a
        pop     r3                  
        load    aluop,#alu_and      ; &=
        alu     r10,r10,r3          ; assign long
        move    r2,r10,0            ; result of assignment is rvalue to be reused
        loadl   r2,#n               ; load adddress of global symbol
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  ; binop(>>)
        loadl   r2,#4               ; int
        pop     r3                  ; binop(>>)
        load    flags,#alu_shiftr   ; binop(>>)
        alu     r2,r3,r2            
        pop     r3                  
        move    r2,r2,r3            ; add index to base address
        move    r3,0,0              ; deref array ref byte assign rvalue
        load    r3,r2,0             ; deref array ref byte assign rvalue
        move    r2,r3,0             ; deref array ref byte assign rvalue
        move    r9,r2,0             ; load c (id node)
        move    r2,r9,0             ; load c
        push    r2                  ; binop(==)
        loadl   r2,#4               ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0008_c9162444869c
        loadl   r2,#n               ; load adddress of global symbol
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  ; binop(&)
        loadl   r2,#0x0f            ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        pop     r3                  
        move    r2,r2,r3            ; add index to base address
        move    r3,0,0              ; deref array ref byte assign rvalue
        load    r3,r2,0             ; deref array ref byte assign rvalue
        move    r2,r3,0             ; deref array ref byte assign rvalue
        push    r2                  
        move    r2,r9,0             ; load c
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r9,r9,r3            ; assign long
        move    r2,r9,0             ; result of assignment is rvalue to be reused
end_ifstmt_0008_c9162444869c:
        move    r2,r9,0             ; load c
        bra     return_0001_c9162444869c
return_0001_c9162444869c:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}
;{ leadingzeros:add_f32.c:10:5
leadingzeros:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument a
        loadl   r10,frame,r4        
        move    r2,r10,0            ; load a
        push    r2                  ; binop(>>)
        loadl   r2,#24              ; int
        pop     r3                  ; binop(>>)
        load    flags,#alu_shiftr   ; binop(>>)
        alu     r2,r3,r2            
        push    r2                  
        push    link                
        loadl   r2,#lz8             ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        move    r9,r2,0             ; load n (id node)
        move    r2,r9,0             ; load n
        push    r2                  ; binop(==)
        loadl   r2,#8               ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0019_c9162444869c
        move    r2,r10,0            ; load a
        push    r2                  ; binop(>>)
        loadl   r2,#16              ; int
        pop     r3                  ; binop(>>)
        load    flags,#alu_shiftr   ; binop(>>)
        alu     r2,r3,r2            
        push    r2                  
        push    link                
        loadl   r2,#lz8             ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        push    r2                  
        move    r2,r9,0             ; load n
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r9,r9,r3            ; assign long
        move    r2,r9,0             ; result of assignment is rvalue to be reused
end_ifstmt_0019_c9162444869c:
        move    r2,r9,0             ; load n
        push    r2                  ; binop(==)
        loadl   r2,#16              ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0026_c9162444869c
        move    r2,r10,0            ; load a
        push    r2                  ; binop(<<)
        loadl   r2,#8               ; int
        pop     r3                  ; binop(<<)
        load    flags,#alu_shiftl   ; binop(<<)
        alu     r2,r3,r2            
        push    r2                  
        push    link                
        loadl   r2,#lz8             ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        push    r2                  
        move    r2,r9,0             ; load n
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r9,r9,r3            ; assign long
        move    r2,r9,0             ; result of assignment is rvalue to be reused
end_ifstmt_0026_c9162444869c:
        move    r2,r9,0             ; load n
        push    r2                  ; binop(==)
        loadl   r2,#24              ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0033_c9162444869c
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#lz8             ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        push    r2                  
        move    r2,r9,0             ; load n
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r9,r9,r3            ; assign long
        move    r2,r9,0             ; result of assignment is rvalue to be reused
end_ifstmt_0033_c9162444869c:
        move    r2,r9,0             ; load n
        bra     return_0012_c9162444869c
return_0012_c9162444869c:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}
;{ _add_f32_:add_f32.c:18:7
_add_f32_:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        mover   sp,sp,-6            ; add space for 6 auto variables
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
        move    r2,r7,0             ; load expa
        push    r2                  ; binop(-)
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        mover   r4,0,-4             ; load expc (id node)
        storl   r2,frame,r4         
        move    r2,0,0              ; missing initializer, default to 0
        mover   r4,0,-5             ; load manc (id node)
        storl   r2,frame,r4         
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
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     else_ifstmt_0072_c9162444869c
        move    r2,r8,0             ; load signa
        push    r2                  
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r7,0             ; load expa
        push    r2                  ; binop(>)
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(>)
        load    flags,#alu_cmp      ; binop(>)
        alu     r2,r2,r3            
        setmin  r2                  ; > (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     else_ifstmt_0077_c9162444869c
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_shiftr   ; >>=
        alu     r3,r2,r3            ; assign long
        load    r4,#-8              
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(+)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r7,0             ; load expa
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0076_c9162444869c
else_ifstmt_0077_c9162444869c:
        move    r2,r7,0             ; load expa
        push    r2                  ; binop(<)
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(<)
        load    flags,#alu_cmp      ; binop(<)
        alu     r2,r3,r2            
        setmin  r2                  ; <
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     else_ifstmt_0085_c9162444869c
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        load    r13,#alu_sub        ; unary -
        alu     r2,0,r2             
        push    r2                  
        move    r2,r6,0             ; load mana
        pop     r3                  
        load    aluop,#alu_shiftr   ; >>=
        alu     r6,r6,r3            ; assign long
        move    r2,r6,0             ; result of assignment is rvalue to be reused
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(+)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0084_c9162444869c
else_ifstmt_0085_c9162444869c:
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(+)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(+)
        load    flags,#alu_add      ; binop(+)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r7,0             ; load expa
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0084_c9162444869c:
end_ifstmt_0076_c9162444869c:
        loadl   r2,#1               ; int
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_shiftr   ; >>=
        alu     r3,r2,r3            ; assign long
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        bra     end_ifstmt_0071_c9162444869c
else_ifstmt_0072_c9162444869c:
        move    r2,r7,0             ; load expa
        push    r2                  ; binop(>)
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(>)
        load    flags,#alu_cmp      ; binop(>)
        alu     r2,r2,r3            
        setmin  r2                  ; > (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     else_ifstmt_0096_c9162444869c
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_shiftl   ; <<=
        alu     r3,r2,r3            ; assign long
        load    r4,#-8              
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(-)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r7,0             ; load expa
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r8,0             ; load signa
        push    r2                  
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0095_c9162444869c
else_ifstmt_0096_c9162444869c:
        move    r2,r7,0             ; load expa
        push    r2                  ; binop(<)
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(<)
        load    flags,#alu_cmp      ; binop(<)
        alu     r2,r3,r2            
        setmin  r2                  ; <
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     else_ifstmt_0104_c9162444869c
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        load    r13,#alu_sub        ; unary -
        alu     r2,0,r2             
        push    r2                  
        move    r2,r6,0             ; load mana
        pop     r3                  
        load    aluop,#alu_shiftl   ; <<=
        alu     r6,r6,r3            ; assign long
        move    r2,r6,0             ; result of assignment is rvalue to be reused
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(-)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r5,0             ; load signb
        push    r2                  
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0103_c9162444869c
else_ifstmt_0104_c9162444869c:
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(-)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r7,0             ; load expa
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        move    r2,r6,0             ; load mana
        push    r2                  ; binop(>)
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  ; binop(>)
        load    flags,#alu_cmp      ; binop(>)
        alu     r2,r2,r3            
        setmin  r2                  ; > (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     else_condop_0115_c9162444869c
        move    r2,r8,0             ; load signa
        bra     end_condop_0114_c9162444869c
else_condop_0115_c9162444869c:
        move    r2,r5,0             ; load signb
end_condop_0114_c9162444869c:
        push    r2                  
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0103_c9162444869c:
end_ifstmt_0095_c9162444869c:
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     else_ifstmt_0117_c9162444869c
        loadl   r2,#0               ; int
        push    r2                  
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        loadl   r2,#0               ; int
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0116_c9162444869c
else_ifstmt_0117_c9162444869c:
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(&)
        loadl   r2,#0x00800000      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     end_ifstmt_0121_c9162444869c
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#leadingzeros    ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        push    r2                  ; binop(-)
        loadl   r2,#8               ; int
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        mover   r4,0,-6             ; load shift (id node)
        storl   r2,frame,r4         
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_shiftl   ; <<=
        alu     r3,r2,r3            ; assign long
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_sub      ; -=
        alu     r3,r2,r3            ; assign long
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
end_ifstmt_0121_c9162444869c:
end_ifstmt_0116_c9162444869c:
end_ifstmt_0071_c9162444869c:
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
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(&)
        loadl   r2,#0x007fffff      ; int
        pop     r3                  ; binop(&)
        load    flags,#alu_and      ; binop(&)
        alu     r2,r3,r2            
        pop     r3                  ; binop(|)
        load    flags,#alu_or       ; binop(|)
        alu     r2,r3,r2            
        bra     return_0034_c9162444869c
return_0034_c9162444869c:
        pop     r10                 
        pop     r9                  
        pop     r8                  
        pop     r7                  
        pop     r6                  
        pop     r5                  
        mover   sp,sp,6             ; remove space for 6 auto variables
        pop     frame               ; old framepointer
        return 
;}
