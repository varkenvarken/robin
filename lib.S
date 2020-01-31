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

#define sub z,x,y
	load aluop,#alu_sub
	alu ${z},${x},${y}
#end

#define mul16 z,x,y
	load aluop,#alu_mul16
	alu ${z},${x},${y}
#end

#define mullo z,x,y
	load aluop,#alu_mullo
	alu ${z},${x},${y}
#end

#define mulhi z,x,y
	load aluop,#alu_mulhi
	alu ${z},${x},${y}
#end

#define divu z,x,y
	load aluop,#alu_divu
	alu ${z},${x},${y}
#end

#define divs z,x,y
	load aluop,#alu_divs
	alu ${z},${x},${y}
#end

#define remu z,x,y
	load aluop,#alu_remu
	alu ${z},${x},${y}
#end

#define rems z,x,y
	load aluop,#alu_rems
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

#define shiftright r,x,n
	load aluop,#alu_shiftr
	alu ${r},${x},${n}
#end

#define shiftleft r,x,n
	load aluop,#alu_shiftl
	alu ${r},${x},${n}
#end

#define stackdef
stackbottom:
stack: 256*(stackbottom//256 + 2)	; grows downward. size = 256 bytes. address round upward to next 256 multiple
#end
