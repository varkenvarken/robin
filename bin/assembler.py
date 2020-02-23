#!/usr/bin/python3
#  An assembler for the robin cpu  (c) 2019,2020 Michel Anders
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

# we could fill this with some additional python symbols for evaluation but
# we definitely do *not* want labels to clash with python internal names
functions = {'__builtins__': {}}


class Opcode:
    """
    Defines an opcode.
    """
    def __init__(self, name, desc='',
                 registers=None, register=None, regsidx=None, implied=None, immediate=None, longimmediate=None,
                 relative=None, setbra=None,
                 data=False, bytes=True, words=False, longs=False, addzero=True, cmd=0,
                 userdefined=None, parameters=[]):
        self.name = name.upper()
        self.desc = desc
        self.registers = registers
        self.register = register
        self.regsidx = regsidx
        self.implied = implied
        self.immediate = immediate
        self.longimmediate = longimmediate
        self.relative = relative
        self.setbra = setbra
        self.data = data
        self.bytes = bytes
        self.words = words
        self.longs = longs
        self.addzero = addzero
        self.userdefined = userdefined
        self.parameters = parameters
        self.cmd = cmd

    def __str__(self):
        return self.name

    def code(self, operand, address, labels, changed):
        immediate = False
        if operand == '':
            values = None
        else:
            values = [op.strip() for op in operand.split(',')]
            if len(values) > 1 and values[1].startswith('#'):
                immediate = True
                values[1] = values[1][1:]
            # print(values, file=sys.stderr)
            values = [eval(op, functions, labels) for op in values]
            # print(["%x"%v for v in values], file=sys.stderr)
        if immediate:
            if self.immediate is None and self.longimmediate is None:
                raise NotImplementedError("%s does not support an immediate mode" % self.name)
            if(len(values) != 2):
                raise ValueError("immediate mode takes 2 arguments")
            if values[0] < 0 or values[0] > 15:
                raise ValueError("register not in range [0:15]")
            if self.immediate is not None:
                try:
                    v = self.bytevalue_int(values[1])
                    # checks if value fits 8 bit -128 : 255
                    return (self.immediate * 256 + values[0] * 256 + v).to_bytes(2, 'big')
                except ValueError:
                    pass
            vbytes = self.longvalue(values[1])
            return (self.longimmediate * 256 + values[0] * 256).to_bytes(2, 'big') + vbytes  # checks if value fits 32 bits
        elif self.implied is not None:
            if values is not None:
                raise NotImplementedError("%s is implied and does not take an operand" % self.name)
            return self.implied.to_bytes(2, 'big')
        elif self.relative is not None:
            if(len(values) > 1):
                raise ValueError("relative mode takes 1 value only")
            rel = values[0] - (address+4)
            return (self.relative * 256).to_bytes(2, 'big') + (rel).to_bytes(2, 'big', signed=True)
        elif self.setbra is not None:
            if(len(values) != 2):
                raise ValueError("set and branch mode takes 2 values only")
            rel = values[1] - (address+4) if values[1] is not None else 0
            v = values[0]
            if v < 0 or v > 15:
                raise ValueError("target register not in range [0:15]")
            return (self.setbra * 256 + (v << 4)).to_bytes(2, 'big') + (rel).to_bytes(2, 'big', signed=True)
        elif self.registers is not None:
            if(len(values) != 3):
                raise ValueError("registers mode takes 3 values")
            for v in values:
                if v < 0 or v > 15:
                    raise ValueError("register not in range [0:15]")
            return (self.registers * 256 + values[0]*256 + values[1]*16 + values[2]).to_bytes(2, 'big')
        elif self.register is not None:
            if(len(values) != 1):
                raise ValueError("register mode takes 1 value")
            for v in values:
                if v < 0 or v > 15:
                    raise ValueError("register not in range [0:15]")
            return (self.register * 256 + values[0]*256 + self.cmd).to_bytes(2, 'big')
        elif self.regsidx is not None:
            if(len(values) != 3):
                raise ValueError("register index mode takes 3 values")
            for v in values[:2]:
                if v < 0 or v > 15:
                    raise ValueError("register not in range [0:15]")
            if values[2] < -8 or values[2] > 7:
                raise ValueError("index not in range [-8:7]")
            return (self.regsidx * 256 + values[0]*256 + values[1]*16 +
                    (values[2] if values[2] >= 0 else 16+values[2])).to_bytes(2, 'big')
        elif self.data:
            if type(values[0]) == str and self.bytes:
                values = bytes(values[0], 'UTF-8')
                if self.addzero:
                    values += b'\0'
                return values
            else:
                if self.addzero:
                    values.append(0)
                if self.bytes:
                    return b''.join(self.bytevalue(v) for v in values)
                elif self.words:
                    return b''.join(self.wordvalue(v) for v in values)
                elif self.longs:
                    return b''.join(self.longvalue(v) for v in values)
        else:
            raise NotImplementedError("%s no valid mode defined" % self.name)

    @staticmethod
    def bytes_or(a, b):
        return bytes(ba | bb for ba, bb in zip(a, b))

    @staticmethod
    def bytevalue_int(v):
        if type(v) == str:
            v = ord(v)
        if v < -128 or v > 255:
            raise ValueError("byte value out of range")
        return v if v >= 0 else 256 + v

    @staticmethod
    def bytevalue(v):
        if type(v) == str:
            v = ord(v)
        if v < -128 or v > 255:
            raise ValueError("byte value out of range")
        return v.to_bytes(1, 'big', signed=v < 0)

    @staticmethod
    def wordvalue(v):
        if type(v) == str:
            v = ord(v)
        if v < -2**15 or v > 2**16-1:
            raise ValueError("word value out of range")
        return v.to_bytes(2, 'big', signed=v < 0)

    @staticmethod
    def longvalue(v):
        if type(v) == str:
            v = ord(v)
        if v < -2**31 or v > 2**32-1:
            raise ValueError("long value out of range")
        return v.to_bytes(4, 'big', signed=v < 0)

    @staticmethod
    def longaddress(v):    # long means fit for our address space of 256K i.e. 2^18
        if v < 0 or v > 2**18-1:
            raise ValueError("long address out of range")
        return v.to_bytes(2, 'big')

    @staticmethod
    def signedbytevalue(v):
        if v < -128 or v > 127:
            raise ValueError(v)
        return v

    def length(self, operand, labels, addr, changed):
        if self.data:
            if operand.strip().startswith('"') or operand.strip().startswith('\''):
                nvalues = len(bytes(eval(operand, functions), encoding='UTF-8'))
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
            opl = 2
            if operand != '':
                values = [op.strip() for op in operand.split(',')]
                if len(values) > 1 and values[1].startswith('#'):
                    values[1] = values[1][1:]
                    # could also fail on a forward label reference in which case we
                    # assume an address ref and therefore a long
                    try:
                        values = [eval(op, functions, labels) for op in values]
                        v = self.bytevalue_int(values[1])
                        if not self.immediate:  # this implies only a longimmediate, like on LOADL
                            opl = 6
                    except Exception as e:
                        opl = 6
                elif len(values) > 0 and self.name in {'BRA', 'BRM', 'BRP', 'BEQ', 'BNE',
                                                       'SETBRA', 'SETBRM', 'SETBRP', 'SETBEQ', 'SETBNE'}:
                    return 4
            return opl


opcode_list = [
    Opcode(name='MOVE', desc='MOVE R2 <- R1+R0',
           registers=0x00),
    Opcode(name='ALU', desc='MOVE R2 <- R1 aluop R0',
           registers=0x20),
    Opcode(name='LOAD', desc='MOVE R2 <- (R1+R0)b | #val',
           registers=0x40, immediate=0xc0, longimmediate=0x70),
    Opcode(name='LOADL', desc='MOVE R2 <- (R1+R0)l | #val',
           registers=0x60, longimmediate=0x70),
    Opcode(name='STOR', desc='MOVE R2 -> (R1+R0)b',
           registers=0x80),
    Opcode(name='STORL', desc='MOVE R2 -> (R1+R0)l',
           registers=0xa0),
    Opcode(name='JAL', desc='R2 <- PC;  PC <- R1+R0',
           registers=0xe0),
    Opcode(name='PUSH', desc='SP <- SP -4; (SP) <- R2',
           register=0x90, cmd=0),
    Opcode(name='POP', desc='R2 <- (SP); SP <- SP + 4',
           register=0x10, cmd=0),
    Opcode(name='HALT', desc='halt execution',
           implied=0xffff),
    Opcode(name='MOVER', desc='MOVE R2 <- R1+extend(4*r0)',
           regsidx=0x30),

    Opcode(name='SETBRA', desc='R1 <- 1; Branch always',
           setbra=0x5c),
    Opcode(name='SETBRM', desc='R1 <- minusflag ? 1 : 0; Branch if minus',
           setbra=0x5a),
    Opcode(name='SETBRP', desc='R1 <- minusflag ? 0 : 1; Branch if positive',
           setbra=0x52),
    Opcode(name='SETBEQ', desc='R1 <- zeroflag ? 1 : 0; Branch if equal',
           setbra=0x59),
    Opcode(name='SETBNE', desc='R1 <- zeroflag ? 0 : 1; Branch if not equal',
           setbra=0x51),

    Opcode(name='BYTE', desc='define byte values (comma separated or string)',
           data=True, bytes=True, words=False, longs=False, addzero=False),
    Opcode(name='BYTE0', desc='define byte values + extra nul (comma separated or string)',
           data=True, bytes=True, words=False, longs=False, addzero=True),
    Opcode(name='WORD', desc='define word values (comma separated)',
           data=True, bytes=False, words=True, longs=False, addzero=False),
    Opcode(name='WORD0', desc='define word values + extra nul (comma separated)',
           data=True, bytes=False, words=True, longs=False, addzero=True),
    Opcode(name='LONG', desc='define long word values (comma separated)',
           data=True, bytes=False, words=False, longs=True, addzero=False),
    Opcode(name='LONG0', desc='define long word values + extra nul (comma separated)',
           data=True, bytes=False, words=False, longs=True, addzero=True),
]

opcodes = {op.name: op for op in opcode_list}
del opcode_list


def stripcomment(line):
    c2 = line.find(";")  # asm convention

    if c2 < 0:
        return line
    return line[:c2]


def assemble(lines, debug=False):
    errors = 0
    # pass1 determine label addresses
    predefined = {  # predefined labels for register names/aliases
        'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3, 'R4': 4, 'R5': 5, 'R6': 6, 'R7': 7, 'R8': 8,
        'R9': 9, 'R10': 10, 'R11': 11, 'R12': 12, 'R13': 13, 'R14': 14, 'R15': 15,
        'r0': 0, 'r1': 1, 'r2': 2, 'r3': 3, 'r4': 4, 'r5': 5, 'r6': 6, 'r7': 7, 'r8': 8,
        'r9': 9, 'r10': 10, 'r11': 11, 'r12': 12, 'r13': 13, 'r14': 14, 'r15': 15,
        'pc': 15, 'PC': 15, 'sp': 14, 'SP': 14, 'flags': 13, 'FLAGS': 13, 'aluop': 13, 'ALUOP': 13,
        'link': 12, 'LINK': 12, 'FRAME': 11, 'frame': 11,
        # predefined labels for alu operations, lower case only
        'alu_add': 0, 'alu_sub': 1,
        'alu_and': 4, 'alu_or': 5, 'alu_xor': 6, 'alu_not': 7,
        'alu_cmp': 8, 'alu_tst': 9,
        'alu_shiftl': 12, 'alu_shiftr': 13,
        'alu_mullo': 14, 'alu_mulhi': 15,
        'alu_divu': 16, 'alu_divs': 17, 'alu_remu': 18, 'alu_rems': 19,
    }

    labels = dict(predefined)

    # we basically repeat everything until nothing changes anymore
    changed = {}
    lenmap = {}
    lastaddr0 = -1
    lastaddr = 0
    prepass = 0
    processed_lines = []
    while(lastaddr != lastaddr0):  # this is NOT foolproof is someting follows the code!
        lastaddr0 = lastaddr
        prepass += 1
        addr = 0
        if len(processed_lines):
            lines = processed_lines
        processed_lines = []
        lineno = 1
        deflines = None
        defop = None
        parameters = []
        while len(lines):
            filename, linenumber, line = lines.pop(0)
            line = stripcomment(line).strip()
            try:
                if line != '':
                    elements = line.split(None, 1)
                    op = elements[0]
                    operand = elements[1] if len(elements) > 1 else ''

                    if deflines is not None:
                        if op == '#end':
                            opcodes[defop] = Opcode(name=defop, userdefined=deflines, parameters=parameters)
                            deflines = None
                            defop = None
                            parameters = []
                        else:
                            deflines.append([filename, linenumber, line])
                        continue

                    if op.endswith(':') or op.endswith('='):
                        constant = op.endswith('=')
                        label = op[:-1]
                        if label in labels and prepass < 2:
                            print('%s[%d]redefined label' % (filename, linenumber), file=sys.stderr)
                        if operand == '':
                            if constant:
                                print('%s[%d]empty constant definition, default to addr'
                                      % (filename, linenumber), file=sys.stderr)
                            labels[label] = addr  # implicit label definition
                        else:
                            try:
                                addr = eval(operand, functions, labels)
                                labels[label] = addr  # explicit label definition
                            except Exception as e:  # ignore undefined in the first pass
                                pass
                    elif op.startswith('#define'):
                        elements = [o.strip() for o in operand.split(None, 1)]
                        defop = elements[0].upper()  # should check for non empty and not yet present
                        if len(elements) > 1:
                            parameters = [p.strip() for p in elements[1].split(',')]
                        deflines = list()
                        continue
                    else:
                        try:
                            opcode = opcodes[op.upper()]
                            if opcode.userdefined is not None:
                                if operand == '':
                                    ops = []
                                else:
                                    ops = [p.strip() for p in operand.split(',')]
                                if len(ops) != len(opcode.parameters):
                                    # print(ops,len(ops),len(opcode.parameters),file=sys.stderr)
                                    raise ValueError()
                                for fname, fno, lin in reversed(opcode.userdefined):
                                    for par, val in zip(opcode.parameters, ops):
                                        lin = lin.replace("${"+par+"}", val)
                                    lines.insert(0, (fname, fno, lin))
                                continue
                            else:
                                codelen = opcode.length(operand, labels, addr, changed)
                                if addr in lenmap and codelen != lenmap[addr]:
                                    da = codelen - lenmap[addr]
                                    changed[addr] = True
                                    lenmap = {a+da: ll for a, ll in lenmap.items() if a > addr}
                                    for l in labels:
                                        if l not in predefined and labels[l] > addr:
                                            labels[l] += da
                                lenmap[addr] = codelen
                                addr += codelen
                        except KeyError:
                            print("Error: %s[%d] unknown opcode %s" % (filename, linenumber, op), file=sys.stderr)
                            continue
                        except ValueError:
                            print("Error: %s[%d] number of parameters does not match for user defined opcode %s"
                                  % (filename, linenumber, op), file=sys.stderr)
                            continue
            except Exception as e:
                raise e
            processed_lines.append((filename, linenumber, line))
        lastaddr = addr

    # print("number of label resolving passes", prepass, file=sys.stderr)

    # pass 2, label bit is the same except we generate errors when we cannot resolve
    code = bytearray()
    addr = 0
    lines = processed_lines
    for filename, linenumber, line in lines:
        if debug:
            dline = "%-40s[%3d] %s" % (filename, linenumber, line.strip())
        line = stripcomment(line).strip()
        if line == '':
            continue
        elements = line.split(None, 1)
        op = elements[0]
        operand = elements[1] if len(elements) > 1 else ''
        if op.endswith(':') or op.endswith('='):
            constant = op.endswith('=')
            label = op[:-1]
            if operand == '':
                labels[label] = addr  # implicit label definition
            else:
                try:
                    newaddr = eval(operand, functions, labels)
                    labels[label] = newaddr  # explicit label definition
                except Exception as e:
                    print("Error: %s[%d] syntax error %s" % (filename, linenumber, operand), file=sys.stderr)
                    continue
                if not constant:		# only labels update the current address and may fill intermediate space
                    fill = newaddr - addr
                    if fill < 0:
                        print('warning: %s[%d]label %s defined to be at lower address than current'
                              % (filename, linenumber, label), file=sys.stderr)
                    else:
                        code.extend([0] * fill)
                    addr = newaddr
            if debug:
                dcode = "%04x %s " % (addr, label)
        else:
            try:
                pp = opcodes[op.upper()]
                newcode = pp.code(operand, addr, labels, changed)
                code.extend(newcode)
                if debug:
                    if pp.data:
                        a = addr
                        dcode = ""
                        for i in range(0, len(newcode), 8):
                            dcode += "%04x %s\n" % (a, " ".join("%02x" % b for b in newcode[i:i+8]))
                            a += 8
                        dcode = dcode[:-1] + "  " + "".join(["   "] * ((8 - len(newcode) % 8) % 8))
                    else:
                        dcode = "%04x %s" % (addr, " ".join("%02x" % b for b in newcode))
                addr += len(newcode)
            except Exception as e:
                print("Error: %s[%d] %s %s" % (filename, linenumber, e.args, line), file=sys.stderr)
        if debug:
            print("%-30s %s" % (dcode, dline), file=sys.stderr)
    # return results as bytes
    return code, labels, errors


lastela = None


def printrun(addr, code):
    global lastela
    # extended linear address (upper 16 bits of address)
    a3 = ((addr >> 24) & 255)
    a2 = ((addr >> 16) & 255)
    ela = ":02000004%02x%02x%02x" % (a3, a2, ((((2 + 4 + a3 + a2) & 255) ^ 255) + 1) & 255)
    if ela != lastela:
        print(ela)
        lastela = ela
    for start in range(0, len(code), 128):  # chunks of max 128 bytes (we could go to 255)
        chunk = code[start:start+128]
        nbytes = len(chunk)
        values = [nbytes, ((addr+start) >> 8) & 255, (addr+start) & 255, 0] + [int(b) for b in chunk]
        values.append((((sum(values) & 255) ^ 255) + 1) & 255)
        print(":" + "".join(["%02x" % v for v in values]))


def printihex(code):
    start = 0
    while start < len(code):
        startzero = start
        while start < len(code) and code[start] == 0:
            start += 1
        if start < len(code):
            end = start
            while end < len(code) and code[end] > 0:
                end += 1
            if start - startzero < 17:
                printrun(startzero, code[startzero:end])
            else:
                printrun(start, code[start:end])
            start = end
    print(":00000001FF")


def printhex(code):
    for start in range(0, len(code), 64):
        print("".join(["%02x " % v for v in code[start:start+64]]))


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-l', '--labels', help='print list of labels to stderr', action="store_true")
    parser.add_argument('-u', '--usage', help='show allowed syntax and exit', action="store_true")
    parser.add_argument('-d', '--debug', help='dump internal code representation', action="store_true")
    parser.add_argument('-i', '--ihex', help='produce output in Intel HEX format', action="store_true")
    parser.add_argument('-v', '--hex', help='produce output in Verilog HEX format', action="store_true")
    parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
    args = parser.parse_args()

    if args.usage:
        for name in sorted(opcodes):
            print("%-7s %s" % (name, opcodes[name].desc))
        sys.exit(0)

    try:
        lines = [(fileinput.filename(), fileinput.filelineno(), line) for line in fileinput.input(files=args.files)]
    except FileNotFoundError as e:
        print(e, file=sys.stderr)
        sys.exit(2)

    code, labels, errors = assemble(lines, args.debug)

    if args.labels:
        for label in sorted(labels):
            print("%-20s %04x" % (label, labels[label]), file=sys.stderr)

    if errors == 0:
        if args.ihex:
            printihex(code)
        elif args.hex:
            printhex(code)
        else:
            nbytes = len(code)
            start = 0
            end = 63  # a fairly arbitrary chunk size
            while end <= nbytes:
                sys.stdout.buffer.write(code[start:end])
                start = end
                end += 63
            sys.stdout.buffer.write(code[start:nbytes])

    sys.exit(errors > 0)
