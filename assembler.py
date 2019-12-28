#  An assembler for the robin cpu  (c) 2019 Michel Anders
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

from argparse import ArgumentParser
import fileinput
import sys

# MOVE  R2,R1,R0     registers
# LOADB R2,R1,R0     registers
# LOADW R2,R1,R0     registers
# LOADL R2,R1,R0     registers
# STORB R2,R1,R0     registers
# STORW R2,R1,R0     registers
# STORL R2,R1,R0     registers
# LOAD  R2,#expr     immediate, longimmediate (LOADI and LOADLI)
# BRA address	     relative
# JUMP  R2,R1,R0     registers
# HALT               implied
# MARK  R2           register

class Opcode:
	def __init__(self, name, desc='',
			registers=None, register=None, implied=None, immediate=None, relative=None, 
			data=False, bytes=True, words=False, longs=False, addzero=True,
			compound=None, userdefined=None):
		 self.name = name.upper()
		 self.desc = desc
		 self.registers = registers
		 self.register = register
		 self.implied = implied
		 self.immediate = immediate
		 self.relative = relative
		 self.data = data
		 self.bytes = bytes
		 self.words = words
		 self.longs = longs
		 self.addzero = addzero
		 self.compound = compound
		 self.userdefined = userdefined

	def code(self, operand, address, labels):
		immediate = False
		if operand == '':
			values = None
		else:
			values = [op.strip() for op in operand.split(',')]
			if len(values) > 1 and values[1].startswith('#'):
			    immediate = True
			    values[1] = values[1][1:]
			values = [eval(op,globals(),labels) for op in values]
		if immediate:
			if self.immediate is None: raise NotImplementedError("%s does not support an immediate mode"%self.name)
			if(len(values) != 2): raise ValueError("immediate mode takes 2 arguments")
			if values[0] < 0 or values[0] > 15: raise ValueError("register not in range [0:15]")
			return (self.immediate * 256 + values[0] * 256 + self.bytevalue_int(values[1]) ).to_bytes(2,'big')# checks if value fits 8 bit -128 : 255
		elif self.implied is not None:
			if values is not None: raise NotImplementedError("%s is implied and does not take an operand"%self.name)
			return self.implied.to_bytes(2,'big')
		elif self.relative is not None:
			if(len(values)>1): raise ValueError("relative mode takes 1 value only") 
			return self.relative.to_bytes(1,'big') + self.signedbytevalue(values[0] - (address+2)).to_bytes(1,'big', signed=True)  # checks if value fits 8 bit  -128 : 127
		elif self.registers is not None:
			if(len(values) != 3): raise ValueError("registers mode takes 3 values")
			for v in values:
			    if v<0 or v>15: raise ValueError("register not in range [0:15]") 
			return (self.registers * 256 + values[0]*256 + values[1]*16 + values[2] ).to_bytes(2,'big')
		elif self.register is not None:
			if(len(values) != 1): raise ValueError("register mode takes 1 value")
			for v in values:
			    if v<0 or v>15: raise ValueError("register not in range [0:15]") 
			return (self.register * 256 + values[0]*256).to_bytes(2,'big')
		elif self.data:
			if type(value) == str and self.bytes:
				values = bytes(value,'UTF-8')
				if self.addzero:
					values += b'\0'
				return values
			else:
				values = [eval(v, globals(), labels) for v in operand.split(',')]
				if self.addzero:
					values.append(0)
				if self.bytes:
					return b''.join(self.bytevalue(v) for v in values)
				elif self.words:
					return b''.join(self.wordvalue(v) for v in values)
				elif self.longs:
					return b''.join(self.longvalue(v) for v in values)
		else:
			raise NotImplementedError("%s no valid mode defined"%self.name)

	@staticmethod
	def bytes_or(a,b):
		return bytes(ba|bb for ba,bb in zip(a,b))

	@staticmethod
	def bytevalue_int(v):
		if type(v) == str:
			v = ord(v)
		if v < -128 or v > 255:
			raise ValueError()
		return v if v >= 0 else 256 + v

	@staticmethod
	def bytevalue(v):
		if type(v) == str:
			v = ord(v)
		if v < -128 or v > 255:
			raise ValueError()
		return v.to_bytes(1, 'big', signed=v<0)


	@staticmethod
	def wordvalue(v):
		if v < -2**15 or v > 2**16-1:
			raise ValueError()
		return v.to_bytes(2, 'big', signed=v<0)

	@staticmethod
	def longvalue(v):
		if v < -2**31 or v > 2**32-1:
			raise ValueError()
		return v.to_bytes(4, 'big', signed=v<0)

	@staticmethod
	def longaddress(v):    # long means fit for our address space of 8K i.e. 2^13
		if v < 0 or v > 2**13-1:
			raise ValueError()
		return v.to_bytes(2,'big')

	@staticmethod
	def signedbytevalue(v):
		if v < -128 or v > 127:
			raise ValueError(v)
		return v

	def length(self, operand):
		if self.data:
			if operand.strip().startswith('"'):
				nvalues = len(bytes(eval(operand),encoding='UTF-8'))
			else:
				nvalues = len(operand.split(','))
			if self.addzero:
				nvalues += 1
			if self.bytes:
				return nvalues
			elif self.words:
				return nvalues * 2
			elif self.longs:
				return nvalues * 4
		else:
			return 2

opcode_list = [
  Opcode(name='MOVE', desc='MOVE R2 <- R1+R0',
     registers=0x00),
  Opcode(name='LOAD', desc='MOVE R2 <- (R1+R0)b | #val',
     registers=0x40, immediate=0xc0),
  Opcode(name='LOADW', desc='MOVE R2 <- (R1+R0)w',
     registers=0x50, immediate=0xc0),
  Opcode(name='LOADL', desc='MOVE R2 <- (R1+R0)l',
     registers=0x60, immediate=0xc0),
  Opcode(name='STOR', desc='MOVE R2 -> (R1+R0)b',
     registers=0x80),
  Opcode(name='STORW', desc='MOVE R2 -> (R1+R0)w',
     registers=0x90),
  Opcode(name='STORL', desc='MOVE R2 -> (R1+R0)l',
     registers=0xa0),
  Opcode(name='BRA', desc='BRA always address expression',
     relative=0xdc),
  Opcode(name='BRM', desc='BRA if minus address expression',
     relative=0xda),
  Opcode(name='BRP', desc='BRA if pos address expression',
     relative=0xd2),
  Opcode(name='BEQ', desc='BRA if zero address expression',
     relative=0xd9),
  Opcode(name='BNE', desc='Branch if not zero address expression',
     relative=0xd1),
  Opcode(name='JAL', desc='R2 <- PC;  PC <- R1+R0',
     registers=0xe0),
  Opcode(name='MARK', desc='R2 <- counter',
     register=0xf0),
  Opcode(name='HALT', desc='halt and dump registers at 0x0002',
     implied=0xffff),

  Opcode(name='BYTE', desc='define byte values (comma separated or string)',
     data=True, bytes=True , words=False, longs=False, addzero=False), 
  Opcode(name='BYTE0', desc='define byte values + extra nul (comma separated or string)',
     data=True, bytes=True , words=False, longs=False, addzero=True), 
  Opcode(name='WORD', desc='define word values (comma separated)',
     data=True, bytes=False, words=True , longs=False, addzero=False), 
  Opcode(name='WORD0', desc='define word values + extra nul (comma separated)',
     data=True, bytes=False, words=True , longs=False, addzero=True), 
  Opcode(name='LONG', desc='define long word values (comma separated)',
     data=True, bytes=False, words=False, longs=True , addzero=False), 
  Opcode(name='LONG0', desc='define long word values + extra nul (comma separated)',
     data=True, bytes=False, words=False, longs=True , addzero=True), 
]

opcodes = {op.name:op for op in opcode_list}
del opcode_list

def stripcomment(line):
	c1 = line.find("//")  # c++ convention
	c2 = line.find(";")  # asm convention

	if c1 < 0 :
		if c2 < 0:
			return line
		c = c2
	else:
		c = min(c1,c2) if c2 >= 0 else c1
	line = line[:c]
	return line

def assemble(lines, debug=False):
	errors = 0
	# pass1 determine label addresses
	labels={  # predefined labels for register names/aliases
	    'R0':0, 'R1':1, 'R2':2, 'R3':3, 'R4':4, 'R5':5, 'R6':6, 'R7':7, 'R8':8,
	    'R9':9, 'R10':10, 'R11':11, 'R12':12, 'R13':13, 'R14':14, 'R15':15,
	    'r0':0, 'r1':1, 'r2':2, 'r3':3, 'r4':4, 'r5':5, 'r6':6, 'r7':7, 'r8':8,
	    'r9':9, 'r10':10, 'r11':11, 'r12':12, 'r13':13, 'r14':14, 'r15':15,
	    'pc':15, 'PC':15, 'sp':14, 'SP':14, 'flags':13, 'FLAGS':13, 'link':12, 'LINK':12,
	}
	addr=0
	processed_lines = []
	lineno = 1
	deflines = None
	defop = None
	while len(lines):
		filename, linenumber, line = lines.pop(0)
		line = stripcomment(line).strip()
		if line != '':
			elements = line.split(None,1)
			op = elements[0]
			operand = elements[1] if len(elements) > 1 else ''

			if deflines is not None:
				if op == '#end':
					opcodes[defop] = Opcode(name=defop, userdefined=deflines)
					deflines = None
					defop = None
				else:
					deflines.append((filename, linenumber, line))
				continue

			if op.endswith(':') or op.endswith('='):
				constant = op.endswith('=')
				label=op[:-1]
				if label in labels: warning('%s[%d]redefined label'%(filename,linenumber))
				if operand == '':
					if constant: warning('%s[%d]empty constant definition, default to addr'%(filename,linenumber))
					labels[label]=addr  # implicit label definition
				else:
					try:
						addr=eval(operand,globals(),labels)
						labels[label]=addr  # explicit label definition
					except:  #ignore undefined in the first pass
						pass
			elif op.startswith('#define'):
				defop = operand  # should check for non empty and not yet present
				deflines = list()
				continue
			else:
				try:
					opcode = opcodes[op.upper()]
					if opcode.userdefined != None:
						for ul in reversed(opcode.userdefined):
							lines.insert(0,ul)
						continue
					else:
						addr+=opcode.length(operand)  # this does also cover byte,byte0 and word,word0,long,long0 directives
				except KeyError:
					print("Error: %s[%d] unknown opcode %s"%(filename, linenumber, op), file=sys.stderr)
					continue
		processed_lines.append((filename, linenumber, line))

	#pass 2, label bit is the same except we generate errors when we cannot resolve
	code=bytearray()
	addr=0
	lines = processed_lines
	for filename, linenumber, line in lines:
		if debug : dline = "%s[%3d] %s"%(filename, linenumber, line.strip())
		line = stripcomment(line).strip()
		if line == '': continue
		elements = line.split(None,1)
		op = elements[0]
		operand = elements[1] if len(elements) > 1 else ''
		if op.endswith(':')  or op.endswith('='):
			constant = op.endswith('=')
			label=op[:-1]
			if operand == '':
				labels[label]=addr  # implicit label definition
			else:
				try:
					newaddr=eval(operand,globals(),labels)
					labels[label]=newaddr  # explicit label definition
				except Exception as e:
					print("Error: %s[%d] syntax error %s"%(filename, linenumber, operand), file=sys.stderr)
					continue
				if not constant:		# only labels update the current address and may fill intermediate space
					fill = newaddr - addr
					if fill < 0:
						warning('%s[%d]label %s defined to be at lower address than current'%(filename,linenumber,label))
					else:
						code.extend([0] * fill)
						addr = newaddr
			if debug : dcode = "%04x %s "%(addr, label)
		else:
			try:
				pp=opcodes[op.upper()]
				newcode=pp.code(operand, addr, labels)
				code.extend(newcode)
				if debug :
					if pp.data:
						a = addr
						dcode = ""
						for i in range(0, len(newcode), 8):
							dcode += "%04x %s\n"%(a, " ".join("%02x"%b for b in newcode[i:i+8]))
							a += 8
						dcode = dcode[:-1] + "  " + "".join(["   "] * ((8 - len(newcode)%8)%8))
					else:
						dcode = "%04x %s"%(addr, " ".join("%02x"%b for b in newcode))
				addr += len(newcode)
			except Exception as e:
				print("Error: %s[%d] %s %s"%(filename, linenumber, e.args[0], line), file=sys.stderr)
		if debug: print("%-30s %s"%(dcode, dline), file=sys.stderr)
	# return results as bytes
	return code, labels, errors

if __name__ == '__main__':
	parser = ArgumentParser()
	parser.add_argument('-l', '--labels', help='print list of labels to stderr', action="store_true")
	parser.add_argument('-u', '--usage', help='show allowed syntax and exit', action="store_true")
	parser.add_argument('-d', '--debug', help='dump internal code representation', action="store_true")
	parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
	args = parser.parse_args()

	if args.usage:
		for name in sorted(opcodes):
			print("%-7s %s"%(name, opcodes[name].desc))
		sys.exit(0)

	try:
		lines = [ (fileinput.filename(),fileinput.filelineno(),line) for line in fileinput.input(files=args.files) ]
	except FileNotFoundError as e:
		print(e, file=sys.stderr)
		sys.exit(2)

	code, labels, errors = assemble(lines, args.debug)

	if args.labels:
		for label in sorted(labels):
			print("%-20s %04x"%(label,labels[label]), file=sys.stderr)

	if errors == 0:
		nbytes = len(code)
		start = 0
		end = 63
		while end <= nbytes:
			sys.stdout.buffer.write(code[start:end])
			start = end
			end += 63
		sys.stdout.buffer.write(code[start:nbytes])

	sys.exit(errors > 0)
