;{ strchr:strchr.c:1:7
strchr:
        push    frame               ; old frame pointer
        move    frame,sp,0          ; new frame pointer
        move    r4,0,0              ; zero out index
        push    r9                  
        push    r10                 
        load    r4,#8               ; init argument str
        loadl   r10,frame,r4        
        load    r4,#12              ; init argument c
        loadl   r9,frame,r4         
while_0002_f4e780621a32:
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        test    r2                  
        beq     endwhile_0003_f4e780621a32
        move    r2,r10,0            ; load str
        move    r3,0,0              
        load    r3,r2,0             ; deref byte
        move    r2,r3,0             
        push    r2                  ; binop(==)
        move    r2,r9,0             ; load c
        pop     r3                  ; binop(==)
        load    flags,#alu_cmp      ; binop(==)
        alu     r2,r3,r2            
        seteq   r2                  ; ==
        test    r2                  ; setxxx does not alter flags
        test    r2                  
        beq     end_ifstmt_0007_f4e780621a32
        move    r2,r10,0            ; load str
        bra     return_0001_f4e780621a32
end_ifstmt_0007_f4e780621a32:
        move    r2,r10,0            ; load str
        move    r10,r10,1           ; postinc ptr to byte or value
        bra     while_0002_f4e780621a32
endwhile_0003_f4e780621a32:
        loadl   r2,#0               ; int
        bra     return_0001_f4e780621a32
return_0001_f4e780621a32:
        pop     r10                 
        pop     r9                  
        pop     frame               ; old framepointer
        return 
;}
