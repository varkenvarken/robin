; dump r0 - r13 + sp to address 0x80
firmwarestart= 0x2000 ; a definition, not a label becase this block will be moved
dumpaddress= 0x80
dumpregisters:
	storl sp,0,0
	loadl sp,#dumpaddress ; stack will grow downwards from dumpaddresses
	push r3
	push r2
	move r2,0,0
	load r2,#dumpaddress
	storl r0,r2,0
	mover r2,r2,1
	storl r1,r2,0
	mover r2,r2,1
	pop r3			; r2
	storl r3,r2,0
	mover r2,r2,1
	pop r3			; r3
	storl r3,r2,0
	mover r2,r2,1
	storl r4,r2,0
	mover r2,r2,1
	storl r5,r2,0
	mover r2,r2,1
	storl r6,r2,0
	mover r2,r2,1
	storl r7,r2,0
	mover r2,r2,1
	storl r8,r2,0
	mover r2,r2,1
	storl r9,r2,0
	mover r2,r2,1
	storl r10,r2,0
	mover r2,r2,1
	storl r11,r2,0
	mover r2,r2,1
	storl r12,r2,0
	mover r2,r2,1
	storl r13,r2,0
	mover r2,r2,1
	loadl r3,0,0    ; original stackpointer was saved to address 0
	storl r3,r2,0
	halt
