start: 0x200
	loadl	sp,#stack
	loadl	r2,#text
	push	r2
	call	#print
	pop		link
	mover	sp,sp,1 ; pop argument
	halt

	stackdef

text:
	byte0 "Jaap Aap rulez!\n"

