#!/usr/bin/python3
#
#  monitor.py (c) 2019 Michel Anders
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

import serial
from time import sleep, time
import cmd
from glob import glob
import os.path
from threading import Thread
from struct import pack, unpack

try:
    import readline
except ImportError:
    readline = None

histfile = os.path.expanduser('~/.monitor_history')
histfile_size = 1000


# https://stackoverflow.com/questions/16826172/filename-tab-completion-in-cmd-cmd-of-python
def _complete_path(path):
    if os.path.isdir(path):
        return glob(os.path.join(path, '*'))
    else:
        return glob(path+'*')


class Monitor(cmd.Cmd):
    def __init__(self, baud):
        super().__init__()
        self.scriptmode = False
        self.baud = baud
        self.ser = None

    def complete_file(self, text, line, start_idx, end_idx):
        return _complete_path(text)

    def preloop(self):
        if readline:
            readline.set_completer_delims(' \t\n')
        if readline and os.path.exists(histfile):
            readline.read_history_file(histfile)
        self.lastaddr = 0

    def postloop(self):
        self.ser.close()
        if readline:
            readline.set_history_length(histfile_size)
            readline.write_history_file(histfile)

    def precmd(self, line):
        if self.ser is None:
            self.ser = serial.Serial(port=self.dev, baudrate=self.baud, stopbits=serial.STOPBITS_ONE)
        if self.scriptmode:
            print(line)
        if line.strip().startswith("#"):
            return ''
        return(line)

    def do_EOF(self, line):
        return True

    def emptyline(self):  # empty lines are ignored because it is dangerous to run a command implicitely
        pass

    def flush(self, nbytes=0):
        """
        read a number of bytes.

        for nbytes > 0 will wait for that exact number of bytes
        for nbytes = 0 will keep readin bytes as long as they are coming
        """
        if nbytes:
            while not self.ser.in_waiting:
                sleep(0.1)
            ret = self.ser.read(nbytes)
        else:
            while self.ser.in_waiting:
                ret = self.ser.read(self.ser.in_waiting)
                sleep(0.1)

    def splitdump(self, line):
        """
        split line into arguments:  ADDR [LEN]
        """
        self.args = line.strip().split()
        self.options = {a[1:]: True for a in self.args if a.startswith("-")}
        self.args = [a for a in self.args if not a.startswith("-")]
        self.addr = int(self.args[0], 16) if len(self.args) > 0 else self.lastaddr
        self.length = int(self.args[1], base=0) if len(self.args) > 1 else 0
        self.hexbytes = []
        self.lastaddr = self.addr
        return self.addr

    def splitload(self, line):
        """
        split line into arguments:  ADDR BYTE [BYTE ...] or ADDR "string"
        """
        self.args = line.strip().split()
        self.addr = int(self.args[0], 16)
        q = line.find('"')
        hexbytes = []
        self.string = False
        if q >= 0:
            for c in line[q+1:]:
                if c == '"':
                    break
                hexbytes.append(ord(c))
            hexbytes.append(0)
            self.length = len(hexbytes)
            self.string = True
        else:
            if len(self.args) > 1:
                hexbytes = [int(hb, base=0) for hb in self.args[1:]]
                self.length = len(hexbytes)
            else:
                self.length = 0
        self.hexbytes = hexbytes
        return self.addr

    def splitrun(self, line):
        """
        split line into arguments:  ADDR [VAL]
        """
        self.args = line.strip().split()
        self.addr = int(self.args[0], 16)
        self.value = int(self.args[1], base=0) if len(self.args) > 1 else 0
        hexbytes = []
        return self.addr, self.value

    def wait(self, t):
        """
        wait for bytes to become available on the receive line.

        waits t seconds between tries.
        """
        while not self.ser.in_waiting:
            sleep(t)

    def ok(self):
        if not self.scriptmode:
            print('\nok          ')  # extra spaces to mask last progress report
        else:
            print()

    def do_dump(self, line):
        """
        dump <hexaddr> <length>          dump bytes
        """
        self.flush()
        addr = self.splitdump(line)
        if self.length == 0 or self.length > 65535:
            self.length = 48
        data = [0x02, ((addr >> 16) & 255), ((addr >> 8) & 255),
                ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        self.wait(0.1)
        count = 0
        needaddr = True
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            for b in ret:
                if needaddr:
                    print("%04x " % addr, end='')
                    needaddr = False
                if 'd' in self.options:
                    if 's' in self.options:
                        w = int(b)
                        if w > 0x7f:
                            w = -(0x100 - w)
                        print("%4d " % w, end='')
                    else:
                        print("%3d " % int(b), end='')
                else:
                    print("%02x " % int(b), end='')
                count += 1
                if count % 8 == 0:
                    addr += 8
                    print("")
                    needaddr = True
            sleep(0.1)
        self.ok()
        return False

    def do_dumpw(self, line):
        """
        dumpw [-d] [-s] <hexaddr> <length>          dump <length> bytes as words (big-endian)
        """
        self.flush()
        addr = self.splitdump(line)
        if self.length & 1:
            self.length -= 1  # make it even
        if self.length == 0 or self.length > 65535:
            self.length = 48
        data = [0x02, ((addr >> 16) & 255), ((addr >> 8) & 255),
                ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        self.wait(0.1)
        count = 0
        needaddr = True
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            w = 0
            first = True
            for b in ret:
                if first:
                    w = int(b) * 256
                first = not first
                if needaddr:
                    print("%04x " % addr, end='')
                    needaddr = False
                if first:
                    if 'd' in self.options:
                        if 's' in self.options:
                            ww = w + int(b)
                            if ww > 0x7fff:
                                ww = -(0x10000 - ww)
                            print("%6d " % (ww), end='')
                        else:
                            print("%5d " % (w + int(b)), end='')
                    else:
                        print("%04x " % (w + int(b)), end='')
                count += 1
                if count % 8 == 0:
                    addr += 8
                    print("")
                    needaddr = True
            sleep(0.1)
        self.ok()
        return False

    def do_dumpl(self, line):
        """
        dumpl [-d] [-s] <hexaddr> <length>          dump <length> bytes as long words (big-endian)
        """
        self.flush()
        addr = self.splitdump(line)
        if self.length & 1:
            self.length -= 1  # make it even
        if self.length == 0 or self.length > 65535:
            self.length = 48
        data = [0x02, ((addr >> 16) & 255), ((addr >> 8) & 255),
                ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        self.wait(0.1)
        count = 0
        needaddr = True
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            w = 0
            nb = 0
            for b in ret:
                w *= 256
                w += int(b)
                nb += 1
                if needaddr:
                    print("%04x " % addr, end='')
                    needaddr = False
                if nb == 4:
                    if 'd' in self.options:
                        if 's' in self.options:
                            if w > 0x7fffffff:
                                w = -(0x100000000 - w)
                            print("%10d " % (w), end='')
                        else:
                            print("%11d " % (w), end='')
                    elif 'f' in self.options:
                        print("%11g " % (unpack('>f', pack('>I', w))), end='')
                    else:
                        print("%08x " % (w), end='')
                    nb = 0
                    w = 0
                count += 1
                if count % 8 == 0:
                    addr += 8
                    print("")
                    needaddr = True
            sleep(0.1)
        self.ok()
        return False

    def do_dumps(self, line):
        """
        dumps <hexaddr> [<length>]

        dump string (max <length> bytes or 48 bytes if omitted) Will not show chars after \0
        """
        self.flush()
        addr = self.splitdump(line)
        if self.length == 0 or self.length > 65535:
            self.length = 48
        data = [0x02, ((addr >> 16) & 255), ((addr >> 8) & 255),
                ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        self.wait(0.1)
        count = 0
        skip = False
        print("%04x " % addr, end='')
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            if not skip:
                string = ret.decode('utf-8', "backslashreplace")
                nul = string.index(chr(0))
                if nul < 0:
                    print(string, end='')
                else:
                    print(string[:nul], end='')
                    skip = True
            sleep(0.1)
        self.ok()
        return False

    def do_show(self, line):
        """
        show      dump 16 4 byte words starting from address 0x80
        """
        self.flush()
        self.length = 64
        addr = 0x80
        data = [0x02, ((addr >> 16) & 255), ((addr >> 8) & 255),
                ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        self.wait(0.1)
        count = 0
        alias = {0: '0', 1: '1', 2: 'R2', 3: 'R3', 4: 'R4', 5: 'R5', 6: 'R6', 7: 'R7',
                 8: 'R8', 9: 'R9', 10: 'R10', 11: 'R11', 12: 'LINK', 13: 'FLAG', 14: 'SP', 15: 'PC'}
        aluop = {0: 'add', 1: 'sub', 4: 'or', 5: 'and', 6: 'xor', 7: 'not', 8: 'cmp',
                 9: 'tst', 12: '<<', 13: '>>', 14: 'mulllo', 15: 'mullhi',
                 16: 'divu', 17: 'divs', 18: 'remu', 19: 'rems'}
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            w = 0
            nb = 0
            r = 0
            asbytes = ""
            for b in ret:
                w *= 256
                w += int(b)
                asbytes += "%02x " % int(b)
                nb += 1
                if nb == 4:
                    nb = 0
                    if r == 13:
                        always = w & 0x80000000 > 0
                        neg = w & 0x40000000 > 0
                        zero = w & 0x20000000 > 0
                        carry = w & 0x10000000 > 0
                        alu = w & 0xff
                        alu = aluop[alu] if alu in aluop else str(alu)
                        print("R%-2d [%4s] A=%d N=%d Z=%d C=%d ALU=%-6s [ %s]" %
                              (r, alias[r], always, neg, zero, carry, alu, asbytes))
                    else:
                        print("R%-2d [%4s] %13d,%12d [ %s]" %
                              (r, alias[r], -(0x100000000 - w) if w > 0x7fffffff else w, w, asbytes))
                    w = 0
                    r += 1
                    asbytes = ""
            sleep(0.1)
        self.ok()
        return False

    def do_load(self, line):
        """
        load <hexaddr> <byte> ...  load bytes into memory
        """
        self.flush()
        addr = self.splitload(line)
        if self.length and self.length < 65535:
            data = [0x01, ((addr >> 16) & 255), ((addr >> 8) & 255),
                    ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
            self.ser.write(bytes(data))
            self.wait(0.1)
            self.flush(len(data))
            self.ser.write(bytes(d if d >= 0 else 256+d for d in self.hexbytes))
            self.wait(0.1)
            self.flush(len(self.hexbytes))
            self.ok()
        else:
            print("no bytes specified or more than 65535")
        return False

    def do_loadw(self, line):
        """
        loadw <hexaddr> <word> ...  load words into memory
        """
        self.flush()
        addr = self.splitload(line)
        if self.length and self.length < 32767:
            self.length *= 2
            data = [0x01, ((addr >> 16) & 255), ((addr >> 8) & 255),
                    ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
            self.ser.write(bytes(data))
            self.wait(0.1)
            self.flush(len(data))
            data = [d.to_bytes(2, byteorder='big', signed=(d < 0x8000)) for d in self.hexbytes]
            data = [item for sublist in data for item in sublist]
            self.ser.write(bytes(data))
            self.wait(0.1)
            self.flush(len(self.hexbytes))
            self.ok()
        else:
            print("no words specified or more than 32767")
        return False

    def do_loadl(self, line):
        """
        loadl <hexaddr> <long> ...  load long words into memory
        """
        self.flush()
        addr = self.splitload(line)
        if self.length and self.length < 16383:
            self.length *= 4
            data = [0x01, ((addr >> 16) & 255), ((addr >> 8) & 255),
                    ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
            self.ser.write(bytes(data))
            self.wait(0.1)
            self.flush(len(data))
            data = [d.to_bytes(4, byteorder='big', signed=(d < 0x80000000)) for d in self.hexbytes]
            data = [item for sublist in data for item in sublist]
            self.ser.write(bytes(data))
            self.wait(0.1)
            self.flush(len(self.hexbytes))
            self.ok()
        else:
            print("no words specified or more than 16383")
        return False

    def do_file(self, line):
        """
        file <filename>   [--hex]  load binary contents of <filename> into mem at $0000
        """
        self.flush()
        args = line.strip().split()
        starttime = time()
        if args[0] == '--hex' or args[0] == 'x':
            try:
                with open(args[1], 'r') as f:
                    ela = 0  # extended linear address
                    for line in f.readlines():
                        if line.startswith(':'):
                            line = line[1:].strip()
                            length = len(line)
                            if length % 2:
                                print("format error", line)
                                return False
                            values = [int(line[c:c+2], 16) for c in range(0, length, 2)]
                            if sum(values) & 255:
                                print("checksum error", line)
                                return False
                            if values[3] == 1:
                                break  # end of file, we're done
                            elif values[3] == 4:
                                ela = (values[4] << 24) + (values[5] << 16)
                                # print("ela",ela,line,values)
                            elif values[3] != 0:
                                print("cannot process record type", line)
                            else:  # a data record
                                addr = values[1] * 256 + values[2]
                                addr += ela
                                # print("addr",addr)
                                chunk = values[0]
                                data = [0x01, ((addr >> 16) & 255), ((addr >> 8) & 255),
                                        ((addr) & 255), ((chunk >> 8) & 255), ((chunk) & 255)]
                                self.ser.write(bytes(data))
                                self.wait(0.1)
                                self.flush(len(data))
                                send = values[4:-1]
                                self.ser.write(send)
                                self.wait(0.1)
                                self.flush(len(send))
                    else:
                        print("not a hex file")
                        return False
            except FileNotFoundError:
                print("file not found")
                return False
        else:
            try:
                with open(args[0], 'rb') as f:
                    hexbytes = f.read()
                    length = len(hexbytes)
            except FileNotFoundError:
                print("file not found")
                return False
            addr = 0
            chunk = 63
            while length > chunk:
                if not self.scriptmode:
                    print(length, "\r", end='')
                data = [0x01, ((addr >> 16) & 255), ((addr >> 8) & 255), ((addr) & 255), ((chunk >> 8) & 255), ((chunk) & 255)]
                self.ser.write(bytes(data))
                self.wait(0.1)
                self.flush(len(data))
                send = hexbytes[addr:addr+chunk]
                self.ser.write(send)
                self.wait(0.1)
                self.flush(len(send))
                addr += chunk
                length -= chunk
            if length > 0:
                data = [0x01, ((addr >> 16) & 255), ((addr >> 8) & 255),
                        ((addr) & 255), ((length >> 8) & 255), ((length) & 255)]
                self.ser.write(bytes(data))
                self.wait(0.1)
                self.flush(len(data))
                send = hexbytes[addr:addr+length]
                self.ser.write(send)
                self.wait(0.1)
                self.flush(len(send))
        print("elapsed time %.2f" % (time()-starttime))
        self.ok()
        return False

    def do_run(self, line):
        """
        run <hexaddress> [arg]  run program at <hexaddress> showing output as hexbytes
        """
        self.flush()
        addr, values = self.splitrun(line)
        # value argument is a dummy
        val = 0
        data = [0x03, ((addr >> 16) & 255), ((addr >> 8) & 255), ((addr) & 255), ((val >> 8) & 255), ((val) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        if not self.scriptmode:
            print('running...')
        count = 0
        again = True
        while again:
            again = False
            while self.ser.in_waiting:
                ret = self.ser.read(self.ser.in_waiting)
                for b in ret:
                    print("%02x " % int(b), end='')
                    count += 1
                    if count % 16 == 0:
                        print('')
                sleep(0.1)
            sleep(1.0)  # timeout, we do not know when a program is going to end
            again = self.ser.in_waiting > 0
        self.ok()
        return False

    def reads(self):
        while True:
            while self.ser.in_waiting:
                ret = self.ser.read(self.ser.in_waiting)
                string = ret.decode('utf-8', "backslashreplace")
                if self.timestamp:
                    dt = time() - self.starttime
                    lines = string.split('\n')
                    t = "[%6.3f] \n" % dt
                    string = t.join(lines)
                print(string, end='', flush=True)
                if self.stop:
                    return
                sleep(0.1)
            if self.stop:
                return

    def read(self):
        count = 0
        while True:
            while self.ser.in_waiting:
                ret = self.ser.read(self.ser.in_waiting)
                for b in ret:
                    print("%02x " % int(b), end='', flush=True)
                    count += 1
                    if count % 16 == 0:
                        print('')
                if self.stop:
                    return
                sleep(0.1)
            if self.stop:
                return

    def do_eval(self, line):
        """
        eval <python expression>
        """
        from struct import pack, unpack
        print(eval(line, globals(), locals()))
        self.ok()

    def do_runp(self, line):
        """
        runp <hexaddress> [arg] run program at <hexaddress> with a separate read process, showing output as hexbytes
        """
        self.flush()
        addr, values = self.splitrun(line)
        # value argument is a dummy
        val = 0
        data = [0x03, ((addr >> 16) & 255), ((addr >> 8) & 255), ((addr) & 255), ((val >> 8) & 255), ((val) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        if not self.scriptmode:
            print('running...')
        self.stop = False
        p = Thread(target=self.read)
        p.start()
        again = True
        while again:
            try:
                inp = input()
                inp += '\n'
                self.ser.write(bytes([ord(i) for i in inp]))
            except (Exception, KeyboardInterrupt) as e:
                again = False
                self.stop = True
        self.ok()
        return False

    def do_runps(self, line):
        """
        runps <hexaddress> [arg] [-t]

        run program at <hexaddress> with a separate read process, showing output as unicode strings
        """
        self.flush()
        addr, values = self.splitrun(line)
        # value argument is a dummy
        val = 0
        self.timestamp = False
        if len(self.args) > 2 and self.args[2] == '-t':
            self.timestamp = True
        data = [0x03, ((addr >> 16) & 255), ((addr >> 8) & 255), ((addr) & 255), ((val >> 8) & 255), ((val) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        if not self.scriptmode:
            print('running...')
        self.stop = False
        p = Thread(target=self.reads)
        p.start()
        again = True
        while again:
            try:
                self.starttime = time()
                inp = input()
                inp += '\n'
                self.ser.write(bytes([ord(i) for i in inp]))
            except Exception as e:
                again = False
                self.stop = True
        self.ok()
        return False

    def do_test(self, line):
        """
        test <hexaddress> (<len> <byte> ... | "string" )   verify contents of memory
        """
        self.flush()
        addr = self.splitload(line)
        compare = bytearray(self.hexbytes)
        string = self.string
        if self.length == 0 or self.length > 63:
            print("no length specified, empty string or more than 63 bytes")
            return False
        data = [0x02, ((addr >> 16) & 255), ((addr >> 8) & 255),
                ((addr) & 255), ((self.length >> 8) & 255), ((self.length) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        self.wait(0.1)
        result = bytearray()
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            result.extend(ret)
            sleep(0.1)
        if len(compare) != len(result):
            print("not ok (unequal lengths)")
        else:
            i = 0
            error = "ok"
            for original, returned in zip(compare, result):
                if original != returned:
                    if string:
                        error = "not ok (at pos %d, [%s|%s])" % (
                                    i,
                                    compare.decode('utf-8', "backslashreplace"),
                                    result.decode('utf-8', "backslashreplace"))
                    else:
                        error = "not ok (at pos %d, [%s|%s])" % (
                                    i,
                                    " ".join(["%02x" % int(b) for b in compare]),
                                    " ".join(["%02x" % int(b) for b in result]))
                    break
                i += 1
            if not self.scriptmode or error != 'ok':
                print(error)
            if error != 'ok':
                raise ValueError("test failed: "+error)
        return False

    def do_runs(self, line):
        """
        runs <hexaddress> [arg]     run program at <hexaddress> showing output as unicode chars
        """
        self.flush()
        addr, values = self.splitrun(line)
        # value argument is a dummy
        val = 0
        data = [0x03, ((addr >> 16) & 255), ((addr >> 8) & 255), ((addr) & 255), ((val >> 8) & 255), ((val) & 255)]
        self.ser.write(bytes(data))
        self.wait(0.1)
        self.flush(len(data))
        if not self.scriptmode:
            print('running...')
        count = 0
        again = True
        while again:
            again = False
            while self.ser.in_waiting:
                ret = self.ser.read(self.ser.in_waiting)
                print(ret.decode('utf-8', "backslashreplace"), end='')
                sleep(0.1)
            sleep(1.0)  # timeout, we do not know when a program is going to end
            again = self.ser.in_waiting > 0
        self.ok()
        return False

    def do_flush(self, line):
        """
        flush       dump any remaining characters in receive buffer.
        """
        count = 0
        while self.ser.in_waiting:
            ret = self.ser.read(self.ser.in_waiting)
            for b in ret:
                print("%02x " % int(b), end='')
                count += 1
                if count % 16 == 0:
                    print('')
            sleep(0.1)
        self.ok()
        return False

    def do_break(self, line):
        """
        break       dump any remaining characters in receive buffer and send break.
        """
        self.do_flush(line)
        self.ser.send_break()
        return False

    def do_echo(self, line):
        """
        write anything and show response until ctrl-c, i.e. switch to terminal mode
        """
        self.flush()
        self.timestamp = False
        if not self.scriptmode:
            print('running...')
        self.stop = False
        p = Thread(target=self.reads)
        p.start()
        again = True
        while again:
            try:
                inp = input()
                inp += '\n'
                self.ser.write(bytes([ord(i) for i in inp]))
            except Exception as e:
                again = False
                self.stop = True
        self.ok()
        return False

    def default(self, line):
        # print('default', line.strip().startswith('//'))
        if line.strip().startswith('//'):
            return False
        return super().default(line)

    def do_exit(self, line):
        """
        exit        exit monitor program
        """
        self.flush()
        # self.ser = None
        return True


if __name__ == '__main__':
    from argparse import ArgumentParser
    from serial.tools import list_ports
    import fileinput
    import sys

    parser = ArgumentParser()
    parser.add_argument('-t', '--test',
                        help='run in test mode (will not show prompts)', action="store_true")
    parser.add_argument('-i', '--ice',
                        help='find icestick/icebreaker', action="store_true")
    parser.add_argument('-x', '--exit',
                        help='exit after script', action="store_true")
    parser.add_argument('-b', '--baudrate',
                        help='set baudrate', type=int, default=115200)
    parser.add_argument('-d', '--dev', nargs='?', default='/dev/ttyUSB1',
                        help='serial device to connect to (will default to /dev/ttyUSB1')
    parser.add_argument('files', metavar='FILE', nargs='*',
                        help='files to execute, if not empty implies -t, \
                        will not end unless one of the commands encountered is exit or -x is set')

    args = parser.parse_args()

    lines = []
    if len(args.files):
        try:
            lines = [line for line in fileinput.input(files=args.files)]
        except FileNotFoundError as e:
            print(e, file=sys.stderr)
            sys.exit(2)

    m = Monitor(baud=args.baudrate)
    m.dev = args.dev
    if args.ice:
        m.dev = sorted([p.device for p in list_ports.comports() if p.vid == 0x0403 and p.pid == 0x6010])[-1]

    m.prompt = ''
    m.scriptmode = True
    errors = 0
    for line in lines:
        try:
            if m.onecmd(m.precmd(line)):
                break
        except ValueError:
            errors += 1
    m.prompt = '' if args.test else '>'
    m.scriptmode = args.test

    if errors:
        sys.exit(2)

    if not args.exit:
        while True:
            try:
                m.cmdloop()
                break
            except KeyboardInterrupt:
                if readline:
                    readline.set_history_length(histfile_size)
                    readline.write_history_file(histfile)
            except ValueError:
                pass
