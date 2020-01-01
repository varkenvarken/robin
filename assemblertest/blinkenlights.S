sequence: 0x80
	byte 0,4,8,0,2,0,0,0,1

serial1: 0x100
serialstat1: 0x101
leds: 0x1ff
ledtop= 2
ledright= 8
ledbot= 1
ledleft= 4

blinkenlights: 0x200
	load r5,#leds
	move r7,0,1
	move r8,0,0
	load r8,#sequence
loop:
	move r2,0,0		; make sure whole word is cleared
	stor r2,r5,0	; all leds off
	loadw r2,0,0	; get word value from memory address 0
	call #wait
	pop link
	stor r7,r5,0	; led on
	move r2,0,0		; make sure whole word is cleared
	loadw r2,0,0	; get word value from memory address 0
	call #wait
	pop link
	load r7,r8,r7
	call #getchar_nonblock
	pop link
	beq loop
	halt

getchar_nonblock:	; returns a character if available. Flags: z=1 if not available
	move tmp,0,0		; clear all bytes of tmp
	load tmp2,#serial1  ; serial base  register
	load tmp,tmp2,1		; load status register
	test tmp			; check status
	beq not_available			; zero bytes available, try again
	load tmp,tmp2,0		; get byte
	stor tmp,tmp2,1		; write back arbitray value to signal receipts
not_available:
	return

wait:	; wait a number of milliseconds specified in r2
	load r3,#12000	; cycles per milliseconds on a 12 MHz clock
	mul16 r2,r3,r2	; total number of cycles to wait
	mark r3			; get cycle counter
wait_loop:
	mark r4
	test r4
	brm old_new
new_old:
	sub r3,r4,r3
	sub r2,r2,r3
	move r3,r4,0
	beq do_return
	brp wait_loop
do_return:
	return
old_new:
	sub r3,r3,r4
	sub r2,r2,r3
	move r3,r4,0
	beq do_return
	brp wait_loop
	return
