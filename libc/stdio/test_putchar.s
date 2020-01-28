start: 0x200
	loadl	sp,#stack
	loadl	r2,#'!'
	push	r2
	call	#putchar
	pop		link
	mover	sp,sp,1 ; pop argument
	halt


	stackdef
