#!/usr/bin/python3
#  simulator.py   A simulator for the Robin SoC  (c) 2020 Michel Anders
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
from struct import pack, unpack


def extend32(b):
    if b & 0x80:
        return 0xffffff00 | b
    return b

def extend16(w):
    if w & 0x8000:
        return 0xffff0000 | w
    return w


class environment:

    def __init__(self, memimage, debug=False):
        self.mem = memimage
        if debug:
            self.dump()

    def dump(self):
        for a in range(0, len(self.mem), 16):
            print("%04x" % a, end=' ')
            for i in range(16):
                if a+i < len(self.mem):
                    print("%02x " % self.mem[a+i], end='')
            for i in range(16):
                if a+i < len(self.mem):
                    c = chr(self.mem[a+i])
                    if not c.isprintable():
                        c = '.'
                    print("%s" % c, end='')
            print()

    def initcpu(self, address):
        self.R = [0] * 16
        self.R[15] = address

    def memcontent(self, addr):
        return (self.mem[addr] << 24) | (self.mem[addr+1] << 16) | (self.mem[addr+2] << 8) | (self.mem[addr+3])

    def __str__(self):
        return '\n'.join('R%02d %08x (%10d)' % (i, v, v) for i, v in enumerate(self.R))
        + " ".join("%08x" % self.memcontent(self.R[14]+i*4) for i in range(16)) + '\n'

    def run(self, address, breakpoint):
        self.initcpu(address)
        broken = False

        try:
            while True:
                self.R[0] = 0
                self.R[1] = 1
                self.R[13] |= 0x80000000  # always on bit

                ip = self.R[15]
                if breakpoint is not None and ip == breakpoint:
                    broken = True
                instruction = (self.mem[ip] << 8) + self.mem[ip+1]
                if broken:
                    print("%04x" % instruction, self.mem[1024:1028])
                    print(self)

                ip += 2
                self.R[15] = ip
                if instruction == 0xffff:
                    break

                if broken:
                    input("Press Enter to continue...")
                self.dispatch(instruction, ip)
        except (Exception, KeyboardInterrupt) as e:
            print(e, "ip=%08x" % ip)

    def dispatch(self, ins, addr):
        r2 = (ins >> 8) & 0xf
        r1 = (ins >> 4) & 0xf
        r0 = ins & 0xf
        op = (ins >> 12) & 0xf
        getattr(self, 'op'+str(op))(r2, r1, r0, addr)

    def signed(self, a):
        if a & 0x80000000:
            return -(2**32-a)
        return a

    def unsigned(self, a):
        if a < 0:
            a += 2**32
        return a & 0xffffffff

    def op0(self, r2, r1, r0, addr):  # move
        # print('move %d,%d,%d'%(r2,r1,r0))
        self.R[r2] = (self.R[r1] + self.R[r0]) & 0xffffffff

    def op2(self, r2, r1, r0, addr):  # alu
        aluop = self.R[13] & 0xff
        carry = 1 if self.R[13] & 0x10000000 else 0
        # print('alu %d <- %d <%d> %d'%(r2,r1,aluop,r0))
        ops = {
            0: lambda x, y, c: x + y,
            # 1: lambda x, y, c: x + y + c,
            2: lambda x, y, c: x - y,
            # 3: lambda x, y, c: x - y - c,
            4: lambda x, y, c: x | y,
            5: lambda x, y, c: x & y,
            6: lambda x, y, c: x ^ y,
            7: lambda x, y, c: ~x,
            8: lambda x, y, c: -1 if self.signed(x) < self.signed(y) else (1 if x > y else 0),
            9: lambda x, y, c: x,
            12: lambda x, y, c: x << y,
            13: lambda x, y, c: x >> y,
            16: lambda x, y, c: (x & 0xffff) * (y & 0xffff),
            17: lambda x, y, c: (x * y) & 0xffffffff,
            18: lambda x, y, c: (x * y) >> 32,
            32: lambda x, y, c: x // y,
            33: lambda x, y, c: (-1 if ((x ^ y) & 0x80000000) else 1) * (abs(x) // abs(y)),
            34: lambda x, y, c: x - y * (x // y),
            35: lambda x, y, c: (-1 if ((x ^ y) & 0x80000000) else 1) * (abs(x) - abs(y) * (abs(x) // abs(y))),
        }
        self.R[r2] = self.unsigned(ops[aluop](self.R[r1], self.R[r0], carry))
        self.R[13] &= 0x8fffffff  # clear flags
        self.R[13] |= 0x40000000 if self.R[r2] & 0x80000000 else 0
        self.R[13] |= 0x20000000 if self.R[r2] == 0 else 0
        # ignore generated carries for now

    def op3(self, r2, r1, r0, addr):  # mover
        # print('mover %d,%d,%d'%(r2,r1,r0))
        if r0 >= 8:
            self.R[r2] = self.unsigned((self.R[r1] - (16-r0)*4))
        else:
            self.R[r2] = self.R[r1] + r0*4

    def op4(self, r2, r1, r0, addr):  # load
        # print('load %d,%d,%d %d,%d  [%d]'%(r2,r1,r0,self.R[r1],self.R[r0],self.mem[self.R[r1] + self.R[r0]]))
        mi = (self.R[r1] + self.R[r0]) & 0xffffffff
        self.R[r2] = (self.R[r2] & 0xffffff00) | self.mem[mi]  # doesn't touch bits 31-8 in dest register

    def op6(self, r2, r1, r0, addr):  # loadl
        mi = (self.R[r1] + self.R[r0]) & 0xffffffff
        # print('loadl %d,%d,%d (%d)'%(r2,r1,r0,mi))
        self.R[r2] = (self.mem[mi] << 24) | (self.mem[mi+1] << 16) | (self.mem[mi+2] << 8) | (self.mem[mi+3])

    def op7(self, r2, r1, r0, addr):  # loadil (load immediate long)
        # print('loadli %d,%d,%d'%(r2,r1,r0))
        print(self.mem[addr:addr+4])
        self.R[r2] = (self.mem[addr] << 24) | (self.mem[addr+1] << 16) | (self.mem[addr+2] << 8) | (self.mem[addr+3])
        self.R[15] += 4

    def op8(self, r2, r1, r0, addr):  # stor
        # print('stor %d,%d,%d'%(r2,r1,r0))
        offset = (self.R[r1] + self.R[r0]) & 0xffffffff
        self.mem[offset] = self.R[r2] & 0xff
        if offset == 256:  # memory mapped serial out
            print(chr(self.mem[offset]), end='')

    def op10(self, r2, r1, r0, addr):  # storl
        # print('storl %d,%d,%d'%(r2,r1,r0))
        offset = (self.R[r1] + self.R[r0]) & 0xffffffff
        self.mem[offset] = (self.R[r2] >> 24) & 0xff
        self.mem[offset+1] = (self.R[r2] >> 16) & 0xff
        self.mem[offset+2] = (self.R[r2] >> 8) & 0xff
        self.mem[offset+3] = (self.R[r2]) & 0xff

    def op12(self, r2, r1, r0, addr):  # loadi (load byte immediate)
        # print('loadi %d,%d,%d'%(r2,r1,r0))
        self.R[r2] = (self.R[r2] & 0xffffff00) | ((r1 << 4) | r0)

    def op13(self, r2, r1, r0, addr):  # branch
        # takebranch = ((r[13][31:29] & instruction[10:8]) == ({3{instruction[11]}} & instruction[10:8]));
        flags = self.R[13] >> 29
        cond = ((r2 & 0x07) & flags) == ((r2 >> 3)*7) & (r2 & 0x07)
        offset32 = extend16(self.mem[addr] << 8) | (self.mem[addr+1])
        if cond != 0:
            addr += offset32 + 2
        else:
            addr += 2
        self.R[15] = addr & 0xffffffff

    def op14(self, r2, r1, r0, addr):  # jal (jump and link)
        # print('jal %d,%d,%d'%(r2,r1,r0))
        offset = (self.R[r1] + self.R[r0]) & 0xffffffff
        self.R[r2] = self.R[15]
        self.R[15] = offset

    def op15(self, r2, r1, r0, addr):  # special
        # print('special %d,%d,%d'%(r2,r1,r0))
        if r0 == 0:  # mark
            pass
        elif r0 == 1:  # pop
            sp = self.R[14]
            self.R[r2] = (self.mem[sp] << 24) | (self.mem[sp+1] << 16) | (self.mem[sp+2] << 8) | (self.mem[sp+3])
            self.R[14] += 4
        elif r0 == 2:  # push
            self.R[14] -= 4
            sp = self.R[14]
            self.mem[sp] = (self.R[r2] >> 24) & 0xff
            self.mem[sp+1] = (self.R[r2] >> 16) & 0xff
            self.mem[sp+2] = (self.R[r2] >> 8) & 0xff
            self.mem[sp+3] = (self.R[r2]) & 0xff
        elif r0 == 8:  # seteq
            if self.R[13] & 0x20000000:
                self.R[r2] = 1
            else:
                self.R[r2] = 0
        elif r0 == 9:  # setne
            if self.R[13] & 0x20000000:
                self.R[r2] = 0
            else:
                self.R[r2] = 1
        elif r0 == 12:  # setmin
            if self.R[13] & 0x40000000:
                self.R[r2] = 1
            else:
                self.R[r2] = 0
        elif r0 == 13:  # setpos
            if self.R[13] & 0x40000000:
                self.R[r2] = 0
            else:
                self.R[r2] = 1


def readhex(lines):
    mem = {}
    for line in lines:
        if line.startswith(':'):
            line = line[1:].strip()
            length = len(line)
            if length % 2:
                raise ValueError("format error" + line)
            values = [int(line[c:c+2], 16) for c in range(0, length, 2)]
            if sum(values) & 255:
                raise ValueError("checksum error" + line)
                return False
            if values[3] == 1:
                break  # end of file, we're done
            elif values[3] == 4:
                ela = (values[4] << 24) + (values[5] << 16)
            elif values[3] != 0:
                raise ValueError("cannot process record type" + line)
            else:  # a data record
                addr = values[1] * 256 + values[2]
                addr += ela
                length = values[0]
                data = values[4:-1]
                mem[addr] = values
    high = max(mem.keys())
    length = high + len(mem[high])
    memdata = [0] * length
    for k, v in mem.items():
        memdata[k:k+len(v)] = v
    return memdata


if __name__ == '__main__':

    parser = ArgumentParser()
    parser.add_argument('-S', '--start', help='start address of execution', default='0x200')
    parser.add_argument('-b', '--breakpoint', help='break point address', default='0')
    parser.add_argument('-d', '--debug', help='show all sorts of info', action="store_true")
    parser.add_argument('-i', '--ihex', help='files are in intel hex format', action="store_true")
    parser.add_argument('-r', '--regs', help='dump content of registers after run', action="store_true")
    parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
    parser.add_argument('-s', '--str', help='show nul terminated string after run', default='')
    parser.add_argument('-m', '--mem', help='a:n show n longs starting at address a ', default='')
    args = parser.parse_args()

    if args.ihex:
        try:
            lines = [line for line in fileinput.input(files=args.files)]
            memimg = readhex(lines)
        except Exception as e:
            print(e, file=sys.stderr)
            sys.exit(2)
    else:
        memimg = []
        for filename in args.files:
            with open(filename, 'rb') as f:
                data = f.read()
                memimg.extend(int(b) for b in data)

    env = environment(memimg, args.debug)
    env.run(int(args.start, 0), int(args.breakpoint, 0))
    if args.debug:
        env.dump()
    if args.debug or args.regs:
        print(env)
    if args.str and args.str != '':
        addr = int(args.str, 0)
        n = 256
        print('"', end='')
        while env.mem[addr] and n:
            c = chr(env.mem[addr])
            if c == '"':
                c = '\\"'
            elif c == '\\':
                c = '\\\\'
            print(c, end='')
            addr += 1
            n -= 1
        print('"')
    if args.mem and args.mem != '':
        v = args.mem.split(':')
        addr = int(v[0], 0)
        nlong = int(v[1], 0)
        while nlong > 0:
            nlong -= 1
            print("%08x" % (env.memcontent(addr)), end=',')
            addr += 4
        print()
