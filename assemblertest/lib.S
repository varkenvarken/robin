#define jump x
	load link,${x}
	jal link,link,0
#end

#define call x
	push link
	jump ${x}
#end

#define return
	jal 0,link,0
#end

#define push x
	mover sp,sp,-1
	storl ${x},sp,0
#end

#define pop x
	loadl ${x},sp,0
	mover sp,sp,1
#end

#define sub z,x,y
	load aluop,#alu_sub
	alu ${z},${x},${y}
#end

#define mul16 z,x,y
	load aluop,#alu_mul16
	alu ${z},${x},${y}
#end

#define and z,x,y
	load aluop,#alu_and
	alu ${z},${x},${y}
#end

#define test x
	load aluop,#alu_tst
	alu ${x},${x},0
#end

#define cmp s,x,y
	load aluop,#alu_cmp
	alu ${s},${x},${y}
#end

#define shiftright x
	load aluop,#alu_shiftr
	alu ${x},${x},1
#end

#define shiftleft x
	load aluop,#alu_shiftl
	alu ${x},${x},1
#end
