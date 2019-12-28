start: 0x200
	move r3,r4,r5
	move r6,r7,r8
	load r9,r10,r11
	load r12, #40+2
	stor pc,sp,0
	bra start
	jal link,r7,0
	mark r7
	halt
