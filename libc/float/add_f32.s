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
        beq     end_ifstmt_0008_12f90c3ccccc
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
end_ifstmt_0008_12f90c3ccccc:
        move    r2,r9,0             ; load c
        bra     return_0001_12f90c3ccccc
return_0001_12f90c3ccccc:
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
        beq     end_ifstmt_0019_12f90c3ccccc
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
end_ifstmt_0019_12f90c3ccccc:
        move    r2,r9,0             ; load n
        push    r2                  ; binop(==)
        loadl   r2,#16              ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0026_12f90c3ccccc
        move    r2,r10,0            ; load a
        push    r2                  ; binop(>>)
        loadl   r2,#8               ; int
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
end_ifstmt_0026_12f90c3ccccc:
        move    r2,r9,0             ; load n
        push    r2                  ; binop(==)
        loadl   r2,#24              ; int
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0033_12f90c3ccccc
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
end_ifstmt_0033_12f90c3ccccc:
        move    r2,r9,0             ; load n
        bra     return_0012_12f90c3ccccc
return_0012_12f90c3ccccc:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}



buffer:
        byte    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
;{ _add_f32_:add_f32.c:24:7
_add_f32_:
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
        move    r2,0,0              ; missing initializer, default to 0
        mover   r4,0,-6             ; load shift (id node)
        storl   r2,frame,r4         
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        move    r2,r10,0            ; load a
        push    r2                  
        push    link                
        loadl   r2,#ftoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0066_12f90c3ccccc
string_0065_12f90c3ccccc:
        byte0   "    "              
endstring_0066_12f90c3ccccc:
        loadl   r2,#string_0065_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        move    r2,r9,0             ; load b
        push    r2                  
        push    link                
        loadl   r2,#ftoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0068_12f90c3ccccc
string_0067_12f90c3ccccc:
        byte0   "\n"                
endstring_0068_12f90c3ccccc:
        loadl   r2,#string_0067_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
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
        beq     else_ifstmt_0076_12f90c3ccccc
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
        beq     else_ifstmt_0081_12f90c3ccccc
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
        move    r2,r7,0             ; load expa
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0080_12f90c3ccccc
else_ifstmt_0081_12f90c3ccccc:
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
        beq     else_ifstmt_0086_12f90c3ccccc
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
        mover   r4,0,-1             ; load expb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        bra     end_ifstmt_0085_12f90c3ccccc
else_ifstmt_0086_12f90c3ccccc:
        move    r2,r7,0             ; load expa
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0085_12f90c3ccccc:
end_ifstmt_0080_12f90c3ccccc:
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
        loadl   r2,#8               ; int
        push    r2                  ; binop(-)
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#leadingzeros    ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        pop     r3                  ; binop(-)
        load    flags,#alu_sub      ; binop(-)
        alu     r2,r3,r2            
        push    r2                  
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-24             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  
        beq     end_ifstmt_0093_12f90c3ccccc
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_shiftr   ; >>=
        alu     r3,r2,r3            ; assign long
        load    r4,#-20             
        storl   r3,frame,r4         ; assign byte/long to auto location
end_ifstmt_0093_12f90c3ccccc:
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        mover   r4,0,-4             ; load expc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    aluop,#alu_add      ; +=
        alu     r3,r2,r3            ; assign long
        load    r4,#-16             
        storl   r3,frame,r4         ; assign byte/long to auto location
        bra     end_ifstmt_0075_12f90c3ccccc
else_ifstmt_0076_12f90c3ccccc:
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
        beq     else_ifstmt_0098_12f90c3ccccc
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
        bra     end_ifstmt_0097_12f90c3ccccc
else_ifstmt_0098_12f90c3ccccc:
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
        beq     else_ifstmt_0106_12f90c3ccccc
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        move    r2,r6,0             ; load mana
        push    r2                  
        push    link                
        loadl   r2,#itoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0108_12f90c3ccccc
string_0107_12f90c3ccccc:
        byte0   "  "                
endstring_0108_12f90c3ccccc:
        loadl   r2,#string_0107_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
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
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  ; binop(-)
        move    r2,r6,0             ; load mana
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
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        move    r2,r6,0             ; load mana
        push    r2                  
        push    link                
        loadl   r2,#itoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0113_12f90c3ccccc
string_0112_12f90c3ccccc:
        byte0   "  "                
endstring_0113_12f90c3ccccc:
        loadl   r2,#string_0112_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        mover   r4,0,-2             ; load manb (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#itoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0115_12f90c3ccccc
string_0114_12f90c3ccccc:
        byte0   "  "                
endstring_0115_12f90c3ccccc:
        loadl   r2,#string_0114_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#itoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0117_12f90c3ccccc
string_0116_12f90c3ccccc:
        byte0   "\n"                
endstring_0117_12f90c3ccccc:
        loadl   r2,#string_0116_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     end_ifstmt_0105_12f90c3ccccc
else_ifstmt_0106_12f90c3ccccc:
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
        beq     else_condop_0125_12f90c3ccccc
        move    r2,r8,0             ; load signa
        bra     end_condop_0124_12f90c3ccccc
else_condop_0125_12f90c3ccccc:
        move    r2,r5,0             ; load signb
end_condop_0124_12f90c3ccccc:
        push    r2                  
        mover   r4,0,-3             ; load signc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-12             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
end_ifstmt_0105_12f90c3ccccc:
end_ifstmt_0097_12f90c3ccccc:
        mover   r4,0,-5             ; load manc (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        test    r2                  ; unary !
        seteq   r2                  ; unary !
        test    r2                  
        beq     else_ifstmt_0127_12f90c3ccccc
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
        bra     end_ifstmt_0126_12f90c3ccccc
else_ifstmt_0127_12f90c3ccccc:
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
        beq     end_ifstmt_0131_12f90c3ccccc
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
        push    r2                  
        mover   r4,0,-6             ; load shift (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        pop     r3                  
        load    r4,#-24             
        storl   r3,frame,r4         ; assign byte/long to auto location
        move    r2,r3,0             ; result of assignment is rvalue to be reused
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
end_ifstmt_0131_12f90c3ccccc:
end_ifstmt_0126_12f90c3ccccc:
end_ifstmt_0075_12f90c3ccccc:
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
        mover   r4,0,-7             ; load result (id node)
        storl   r2,frame,r4         
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        mover   r4,0,-7             ; load result (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        push    r2                  
        push    link                
        loadl   r2,#ftoa            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,2             
        loadl   r2,#buffer          ; load adddress of global symbol
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     endstring_0148_12f90c3ccccc
string_0147_12f90c3ccccc:
        byte0   "\n"                
endstring_0148_12f90c3ccccc:
        loadl   r2,#string_0147_12f90c3ccccc
        push    r2                  
        push    link                
        loadl   r2,#print           ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        mover   r4,0,-7             ; load result (id node)
        loadl   r2,frame,r4         ; load value of auto variable
        bra     return_0034_12f90c3ccccc
return_0034_12f90c3ccccc:
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
