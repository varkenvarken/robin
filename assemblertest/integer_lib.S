serial1: 0x100
serialstat1: 0x101

dividend: 0x80
divisor:  0x84
quotient: 0x88
remainder: 0x8c
 
start: 0x200
	load sp,#stack
	move r3,0,0
	load r3,#dividend
	loadl r2,r3,0
	load r3,#buffer
	call #uint_to_str
	pop link
	halt

readline:	; read characters until newline (10) into buffer pointer to by r2
	push r5
	move r4,r2,0
	move tmp,0,0
	move r5,0,0
	load r5,#10 ; newline
getcharloop:
	call #getchar
	pop link
	cmp tmp2,tmp,r5
	beq readlinedone
	stor tmp,r4,0
	move r4,r4,1
	bra getcharloop
readlinedone:
	move tmp,0,0
	stor tmp,r4,0
	pop r5
	return

print:		; print zero terminated string pointed to by r2
	move r4,r2,0
printloop:
	move tmp,0,0
	load tmp,r4,0
	test tmp
	beq printdone
	call #putchar
	pop link
	move r4,r4,1
	bra printloop
printdone:
	return

putchar:
	load tmp2,#serial1
	stor tmp,tmp2,0
	return

getchar:
	move tmp,0,0		; clear all bytes of tmp
	load tmp2,#serial1  ; serial base  register
	load tmp,tmp2,1		; load status register
	test tmp			; check status
	beq getchar			; zero bytes available, try again
	load tmp,tmp2,0		; get byte
	stor tmp,tmp2,1		; write back arbitray value to signal receipts
	return

divide_unsigned_32:		; divide r2 by r3, on return quotient will be in r4, remainder in r2
	push r6
	push r5
	test r3
	beq divide_unsigned_done
	move r4,0,1
d_000:					; shift left divisor until just smaller than dividend
	cmp r5,r2,r3
	brm d_100
	shiftleft r3
	shiftleft r4
	bra d_000
d_100:					; after overshoot, correct by shifting right
	shiftright r3
	shiftright r4		; at this point r3 is slightly less than r2, r4 represents the multiplied quotient
	beq divide_unsigned_done
	move r5,r4,0
	sub r2,r2,r3		; result will never be negative
	beq divide_unsigned_done
d_200:					; halve the divisor and the quotient part ...
	shiftright r3
	shiftright r5
	beq divide_unsigned_done ; ... until there is nothing to halve
	sub r6,r2,r3
	brm d_200				; if divisor doesn't fit, halve again
	move r4,r4,r5			; otherwise add quotient part to quotient
	move r2,r6,0				; keep the result
	bra d_200
divide_unsigned_done:
	pop r5
	pop r6
	return

uint_to_str: ; convert r2 to a string poined to by r3
	push r9
	push r8
	push r7
	push r6
	push r5
	move r9,0,1
	move r8,0,0
	load r8,#10
	move r6,0,0
	load r6,#'0'
	move r5,r3,0
	move r4,0,0
	load r3,#1000000000
	; at this point we have:
	; r2 = our number
	; r3 = trial divisor == 1000000000
	; r4 = 0
	; r5 = string pointer
	; r6 = the character '0'
	; r7 = not used
	; r8 = the number 10
	; r9 = 1 (we have not yet produced a non zero digit)
	test r2			; shortcut to print a single '0'
	beq store_char 
uint_to_str_loop:
	test r3
	beq write_nul
	move r7,r3,0
	call #divide_unsigned_32
	pop link
	move r3,r7,0
	test r4
	bne store_char  ; a non zero digit, proceed to store
	test r9			; do not store zero digits if we haven't
	bne next_division	; produced a non zero digit yet
store_char:
	move r9,r9,0	; indicate we have produced a digit 
	move r4,r4,r6	; add character '0' to quotient
	stor r4,r5,0	; store character at string pointer
	move r5,r5,1	; increment the string pointer
next_division:
	move r7,r2,0	; move remainder out of the way
	move r2,r3,0	; divide the trial divisor by 10
	move r3,r8,0
	call #divide_unsigned_32
	pop link
	move r3,r4,0	; get the result back as the new trial divisor
	move r2,r7,0	; get our remainder back
	bra uint_to_str_loop
write_nul:
	stor r3,r5,0
	pop r5
	pop r6
	pop r7
	pop r8
	pop r9
	return
jaapaap:
	byte0 "Jaap Aap rulez!"
buffer:
	byte0 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
stackbottom:
stack: 256*int((stackbottom + 256 + 256)/256)	; grows downward. size = 256 bytes. address round upward to next 256 multiple
