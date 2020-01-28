; extern void _mulu32_64_shift(int a, int b, int shift, int *result);
;
; multiply a x b -> 64 bit result, shift result right by shift positions, store hi part in result[0], lowpart in result[1]
;
_mulu32_64_shift:
    push    r5

    mover   r2,sp,2 ; a
    loadl   r2,r2,0
    mover   r3,sp,3 ; b
    loadl   r3,r3,0
    load    r13,#alu_mulhi
    alu     r4,r2,r3
    load    r13,#alu_mullo
    alu     r3,r2,r3
    ; at this point hi=r4, lo=r3
    load    r13,#alu_sub
    mover   r2,sp,4 ; shift
    loadl   r2,r2,0
    loadl   r5,#32
    alu     r2,r5,r2; shifting right by shifting left
    load    r13,#alu_shiftl
    alu     r5,r4,r2; r5 now contains the *right* shift parts of hi that will go into lo
    mover   r2,sp,4 ; shift
    loadl   r2,r2,0
    load    r13,#alu_shiftr
    alu     r3,r3,r2
    load    r13,#alu_or
    alu     r3,r5,r3; add in right shift part from hi part
    load    r13,#alu_shiftr
    alu     r4,r4,r2
    ; at this point hi=r4, lo=r3 shifted by shift places to the right
    mover   r2,sp,5 ; result ptr
    loadl   r2,r2,0
    storl   r4,r2,0
    mover   r2,r2,1
    storl   r3,r2,0

    pop     r5
    return
