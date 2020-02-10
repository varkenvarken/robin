
;{ wait:print.c:3:6
wait:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r10                 
        load    r4,#8               ; init argument n
        loadl   r10,frame,r4        
while_0002_c224f8ae5c90:
        move    r2,r10,0            ; load n
        push    r2                  ; binop(>)
        loadl   r2,#0               ; int
        pop     r3                  ; binop(>)
        load    flags,#alu_cmp      ; binop(>)
        alu     r2,r2,r3            
        setmin  r2                  ; > (reversed operands)
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     endwhile_0003_c224f8ae5c90
        move    r2,r10,0            ; load n
        load    r13,#alu_sub        ; postdec ptr to byte or value
        alu     r10,r10,1           ; postdec ptr to byte or value
        bra     while_0002_c224f8ae5c90
endwhile_0003_c224f8ae5c90:
return_0001_c224f8ae5c90:
        pop     r10                 
        pop     frame               ; old framepointer
        return 
;}
;{ print:print.c:7:6
print:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r10                 
        load    r4,#8               ; init argument s
        loadl   r10,frame,r4        
while_0008_c224f8ae5c90:
        move    r2,r10,0            ; load s
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        test    r2                  
        beq     endwhile_0009_c224f8ae5c90
        move    r2,r10,0            ; load s
        move    r10,r10,1           ; postinc ptr to byte or value
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  
        push    link                
        loadl   r2,#putchar         ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        loadl   r2,#1000            ; int
        push    r2                  
        push    link                
        loadl   r2,#wait            ; load adddress of global symbol
        jal     link,r2,0           
        pop     link                
        mover   sp,sp,1             
        bra     while_0008_c224f8ae5c90
endwhile_0009_c224f8ae5c90:
return_0007_c224f8ae5c90:
        pop     r10                 
        pop     frame               ; old framepointer
        return 
;}
