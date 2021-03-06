#!/usr/bin/python3
#  compiler.py, a compiler for the Robin SoC  (c) 2020 Michel Anders
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

import sys
from re import split
from loguru import logger
from pycparser import c_parser, c_ast, parse_file
from uuid import uuid4
from struct import pack, unpack
from argparse import ArgumentParser
import sys


class dictstack:  # not yet complete, must be able to distinguish between redeclaration and shadowing

    def __init__(self):
        self.stack = [{}]

    def __getitem__(self, key):
        for d in self.stack:
            if key in d:
                return d[key]
        raise KeyError()

    def __setitem__(self, key, value):
        for d in self.stack:
            if key in d:
                d[key] = value  # here we should check for redecl: insert at top level is redecl
                return
        self.stack[0][key] = value

    def __contains__(self, key):
        for d in self.stack:
            if key in d:
                return True
        return False

    def discard(self):
        self.stack.pop(0)

    def dup(self):
        self.stack.insert(0, {})


class symbol:
    def __init__(self, storage, location, stype=None):
        self.storage = storage  # global, auto, register
        self.location = location        # None, integer rel to frame, register name
        self.pointerdepth = 0
        self.nocode = False
        self.alloc = False
        self.allocbytes = 0
        self.type = None
        self.size = 0

        if stype is not None:
            arrayalloc = None
            if type(stype) == c_ast.FuncDef:
                stype = stype.decl.type.type
            elif type(stype) == c_ast.Decl:
                init = stype.init
                stype = stype.type
                if type(stype) == c_ast.FuncDecl:
                    stype = stype.type
                    self.nocode = True
                elif type(stype) == c_ast.ArrayDecl:
                    arrayalloc = stype.dim
                    stype = stype.type

            while type(stype) == c_ast.PtrDecl:
                self.pointerdepth += 1
                stype = stype.type

            if type(stype.type) == c_ast.Union:
                self.type = 'union'
                self.size = 4  # bluntly assume union is never larger than 4 byte
            else:
                self.type = stype.type.names[0]
                self.size = 1 if self.type == 'char' else 4

            if arrayalloc is not None:
                ev = ExprVisitor()
                self.alloc = True
                self.allocbytes = int(ev.visit(arrayalloc)[0]) * self.size

    def deref(self):
        ds = symbol(self.storage, self.location)
        ds.size = self.size
        ds.type = self.type
        ds.pointerdepth = self.pointerdepth - 1
        if ds.pointerdepth < 0:
            raise ValueError('deref on non pointer')
        return ds

    def __repr__(self):
        return 'symbol(%s, %s, %s, %d, %d, %s, %s, %d)' % (
            self.storage, str(self.location), self.type, self.pointerdepth,
            self.size, self.nocode, self.alloc, self.allocbytes)


class value:
    def __init__(self, rvalue, size, code, symbol=None):
        self.rvalue = rvalue
        self.size = size
        self.vtype = 'int'
        self.pointerdepth = 0
        if symbol is not None:
            self.vtype = symbol.type
            self.pointerdepth = symbol.pointerdepth
        self.code = code
        self.symbol = symbol

    def ispointer(self):
        return self.pointerdepth > 0

    def rsize(self):
        if self.pointerdepth:
            return 4
        return self.size

    def __repr__(self):
        return 'value(%s, %s, %s, %d, %r)' % (self.rvalue, self.size, self.vtype, self.pointerdepth, self.symbol)


symbols = dictstack()
scope = 0  # file


class GlobalUtils:
    def __init__(self):
        self.labelcount = 0
        self.random = str(uuid4()).split('-')[-1]

    def label(self, prefix):
        self.labelcount += 1
        return "%s_%04d_%s" % (prefix, self.labelcount, self.random)

    def normalize(self, s):
        if s.endswith('f'):
            return s[:-1]
        return s

# TODO create another visitor that runs first and does constant folding etc.


class ExprVisitor(c_ast.NodeVisitor):
    """class to evaluate compile time expressions"""

    def generic_visit(self, node):
        logger.error('ExprVisitor unknown node {}', node)
        return []

    def visit_InitList(self, node):
        values = []
        for e in node.exprs:
            values.extend(self.visit(e))
        return values

    def visit_Constant(self, node):
        result = []
        if node.type == 'int':
            result.append(int(node.value))
        elif node.type == 'char':
            result.append(int(node.value))
        else:
            if scope == 0:
                if node.type == 'string':
                    result.append(node.value)
        return result   # TODO make this smarter


class Visitor(c_ast.NodeVisitor):
    """class to generate code"""

    def __init__(self, globalutils):
        super().__init__()
        self.globalutils = globalutils

    def generic_visit(self, node):
        logger.error('Visitor unknown node {}', node)

        return value(True, None, "\n".join([self.visit(c).code for c in node]))

    def codeformat(self, code):
        lines = code.split('\n')
        formatted = []
        for line in lines:
            elements = split(r'\t+', line)
            n = len(elements)
            if n <= 1:
                f = "".join(elements)
            elif elements[0] == '':
                if n > 2:
                    f = "        " + "%-7s %-20s" % tuple(elements[1:3]) + " ".join(elements[3:])
                else:
                    f = "        " + "%-7s" % elements[1]
            else:
                f = " ".join(elements)
            formatted.append(f)
        return "\n".join(formatted)

    def visit_FileAST(self, node):
        global symbols
        symbols = dictstack()
        print("\n".join([self.codeformat(self.visit(item).code) for item in node.ext]))

    def visit_FuncDef(self, node):
        global scope
        scope = 1

        self.continue_target = None
        self.break_target = None

        # print(node, file=sys.stderr)
        symbols[node.decl.name] = symbol('global', None, node)  # TODO include signature and deal with forward declarations
        symbols.dup()
        preamble = [
            ';{ %s:%s' % (node.decl.name, node.decl.coord),
            '%s:' % node.decl.name,
            '\tpush\tframe\t\t; old frame pointer',
            '\tmove\tframe,sp,0\t; new frame pointer',
            '\tmove\tr4,0,0\t\t; zero out index'
        ]
        registers = ['r5', 'r6', 'r7', 'r8', 'r9', 'r10']
        # arguments will have been pushed in reversed order (cdecl convention)
        n = 1
        r = 2
        movreg = []
        if node.decl.type.args is not None:
            for arg in node.decl.type.args:
                if len(registers):
                    symbols[arg.name] = symbol('register', registers.pop(), arg.type)
                    movreg.append('\tload\tr4,#%d\t\t; init argument %s' % (r*4, arg.name))
                    movreg.append('\tloadl\t%s,frame,r4' % symbols[arg.name].location)
                    r = r + 1
                else:
                    # skip over pushed frame pointer and caller return address
                    symbols[arg.name] = symbol('auto', n + 1, arg.type)
                    n += 1
        symbols["#nargs#"] = n
        symbols["#nauto#"] = 0
        symbols["#registers#"] = registers
        return_label = self.globalutils.label("return")
        symbols["#return#"] = return_label
        body = [self.visit(node.body).code]  # only interested in de code
        # TODO some optimization can be done here because the last line from the body might be 'bra returnlabel'
        nvars = symbols["#nauto#"]

        postamble = [symbols["#return#"]+":"]
        if nvars > 7:
            offset = nvars * 4
            if offset > 127:
                postamble.append('\tloadl\tr3,#%d\t; remove space for %d auto variables' % (offset, nvars))
            else:
                postamble.append('\tload\tr3,#%d\t; remove space for %d auto variables' % (offset, nvars))
            postamble.append('\tmove\tsp,sp,r3\t; remove space for %d auto variables' % (nvars))
        elif nvars > 0:
            postamble.append('\tmover\tsp,sp,%d\t; remove space for %d auto variables' % (nvars, nvars))
        postamble.extend([
            '\tpop\tframe\t\t; old framepointer',
            '\treturn',
            ';}'
        ])

        extra_space = []
        if nvars > 8:
            offset = nvars * -4
            if offset > -128:
                extra_space.append('\tloadl\tr2,#%d\t; add space for %d auto variables' % (offset, nvars))
            else:
                extra_space.append('\tload\tr2,#%d\t; add space for %d auto variables' % (offset, nvars))
            extra_space.append('\tmove\tsp,sp,r2\t; add space for %d auto variables' % (nvars))
        elif nvars > 0:
            extra_space.append('\tmover\tsp,sp,-%d\t; add space for %d auto variables' % (nvars, nvars))
        nregs = 0
        for r in ['r5', 'r6', 'r7', 'r8', 'r9', 'r10']:
            if r not in symbols["#registers#"]:
                extra_space.append('\tpush\t%s' % r)
                postamble.insert(1, '\tpop\t%s' % r)
                nregs += 1

        symbols.discard()
        scope = 0
        return value(True, None, "\n".join(preamble + extra_space + movreg + body + postamble))

    def visit_ID(self, node):
        if node.name in symbols:
            symbol = symbols[node.name]
            if symbol.storage == 'register':
                result = [
                    '\tmove\tr2,%s,0\t\t; load %s' % (symbol.location, node.name),
                ]
            elif symbol.storage == 'auto':
                if symbol.alloc:
                    result = [
                        self.r4index(symbol.location, node.name),
                        "\tmove\tr2,frame,r4\t\t; load address of auto allocated array"
                    ]
                else:
                    result = [
                        self.r4index(symbol.location, node.name),
                        "\tloadl\tr2,frame,r4\t\t; load value of auto variable"
                    ]
            elif symbol.storage == 'global':
                result = [
                    "\tloadl\tr2,#%s\t\t; load adddress of global symbol" % node.name
                ]
            else:
                print('Unexpected symbol storage %s with ID %s' % (symbol.storage, node.name), file=sys.stderr)
            return value(False, symbol.size, "\n".join(result), symbol)
        else:
            print("Unknown local id %s" % node.name, file=sys.stderr)
            return value(False, 0, "")

    def visit_StructRef(self, node):  # we treat everything as a union of 4 bytes wide, even structs :-)
        logger.debug(node)
        if node.name.name in symbols:
            symbol = symbols[node.name.name]  # we also ignore the ref type (. or ->) as well as the type of the member
            if symbol.storage == 'auto':
                result = [
                    self.r4index(symbol.location, node.name.name),
                    "\tloadl\tr2,frame,r4\t\t; load value of auto variable for union"
                ]
            elif symbol.storage == 'global':
                result = [
                    "\tloadl\tr2,#%s\t\t; load adddress of global symbol for union" % node.name.name
                ]
            else:
                print('Unexpected symbol storage %s with StructRef %s' % (symbol.storage, node.name.name), file=sys.stderr)
            return value(False, symbol.size, "\n".join(result), symbol)
        else:
            print("Unknown structref %s" % node.name.name, file=sys.stderr)
            return value(False, 0, "")

    def isnotzero(self, reg):  # prime candidate for creating a cpu intruction for
        return ['\tsetne\t%s\t\t; notzero?' % reg]

    def visit_BinaryOp(self, node):
        alu_opmap = {'+': 'alu_add', '-': 'alu_sub', '*': 'alu_mullo', '/': 'alu_divs', '%': 'alu_rems',
                     '==': 'alu_cmp', '<': 'alu_cmp', '>': 'alu_cmp', '>=': 'alu_cmp', '<=': 'alu_cmp', '!=': 'alu_cmp',
                     '&': 'alu_and', '|': 'alu_or', '^': 'alu_xor',
                     '&&': 'alu_and', '||': 'alu_or', '>>': 'alu_shiftr', '<<': 'alu_shiftl',
                     }

        post = self.globalutils.label('post')
        post2 = self.globalutils.label('post')
        post_map = {
            '==': ['\tseteq\tr2\t\t; ==', '\ttest\tr2\t\t; setxxx does not alter flags'],
            '!=': ['\tsetne\tr2\t\t; !=', '\ttest\tr2\t\t; setxxx does not alter flags'],
            '<': ['\tsetmin\tr2\t\t; <', '\ttest\tr2\t\t; setxxx does not alter flags'],
            '>': ['\tsetmin\tr2\t\t; > (reversed operands)', '\ttest\tr2\t\t; setxxx does not alter flags'],
            '<=': ['\tsetpos\tr2\t\t; <= (reversed operands)', '\ttest\tr2\t\t; setxxx does not alter flags'],
            '>=': ['\tsetpos\tr2\t\t; >=', '\ttest\tr2\t\t; setxxx does not alter flags'],
        }
        reversed_operands = {'>', '<='}

        if node.op in alu_opmap:
            sl = self.visit(node.left)
            sr = self.visit(node.right)
            if sl.ispointer() and sr.ispointer() and (node.op not in {'-', '<', '>', '>=', '<=', '==', '!='}):
                logger.error("unsupported op {} for two pointers ignored", node.op)
                return value(False, 0, "")
            elif sl.ispointer() and not sr.ispointer() and node.op not in {'+', '-', '==', '!='}:
                logger.error("unsupported op {} for pointer,value ignored", node.op)
                return value(False, 0, "")
            elif sr.ispointer() and not sl.ispointer() and node.op not in {'+', '==', '!='}:
                logger("unsupported op {} for value,pointer ignored", node.op)
                return value(False, 0, "")

            endlabel = self.globalutils.label('binop_end')
            # note that results never need to be widened because internally we always work with 32 bit
            result = [sl.code]

            if type(node.left) == c_ast.ArrayRef and sl.symbol is not None and sl.symbol.alloc:
                if sl.size == 1 and not sl.ispointer():
                    result.append('\tmove\tr3,0,0\t\t; deref array ref byte binop left')
                    result.append('\tload\tr3,r2,0\t\t; deref array ref byte binop left')
                    result.append('\tmove\tr2,r3,0\t\t; deref array ref byte binop left')
                else:
                    result.append('\tloadl\tr2,r2,0\t\t; deref array ref long binop left')

            if node.op == '&&':
                result.append('\ttest\tr2\t\t; && short circuit if left side is false')
                result.append('\tsetne\tr2\t\t; also normalize value to be used in bitwise and')
                result.append('\tbeq\t%s' % endlabel)
            if node.op == '||':
                result.append('\ttest\tr2\t\t; || short circuit if left side is true')
                result.append('\tsetne\tr2\t\t; also normalize value to be used in bitwise or')
                result.append('\tbne\t%s' % endlabel)
            result.append("\tpush\tr2\t\t; binop(%s)" % node.op)
            result.append(sr.code)
            # TODO add dereferecing code for arrayref to right operand too
            if node.op in {'&&', '||'}:
                result.append('\ttest\tr2\t\t;')
                result.append('\tsetne\tr2\t\t; normalize value to be used in bitwise or/and')
            result.append("\tpop\tr3\t\t; binop(%s)" % node.op)
            # actual alu op
            result.append("\tload\tflags,#%s\t; binop(%s)" % (alu_opmap[node.op], node.op))
            if node.op in reversed_operands:
                result.append("\talu\tr2,r2,r3")
            else:
                result.append("\talu\tr2,r3,r2")
            # conversion to correct truth value
            if node.op in post_map:
                result.extend(post_map[node.op])
            # end target of short circuit expression
            if node.op in {'&&', '||'}:
                result.append(endlabel+':')
            # lvalue is converted to rvalue unless just the left hand side is a pointer
            rvalue = True
            if sl.ispointer() and not sr.ispointer():
                rvalue = False
            return value(rvalue, sl.size, "\n".join(result), sl.symbol)
        else:
            logger.error("Binary op {} ignored", node.op)
            return value(False, 0, "")

    def visit_UnaryOp(self, node):
        s = self.visit(node.expr)
        result = [s.code]
        isrvalue = s.rvalue
        symbol = s.symbol
        if node.op in {'p++', 'p--'}:
            if isrvalue:
                raise ValueError('postinc/postdec op on rvalue')
            # pointers themselves are 4 bytes so a pointer depth of 1 actualy
            # points to something with a possible different size
            size = s.size if s.pointerdepth == 1 else 1
            if size == 1:
                if symbol.storage == 'register':
                    reg = symbol.location
                    if node.op == 'p++':
                        result.extend([
                            '\tmove\t%s,%s,1\t\t; postinc ptr to byte or value' % (reg, reg),
                        ])
                    else:
                        result.extend([
                            '\tload\tr13,#alu_sub\t\t; postdec ptr to byte or value',
                            '\talu\t%s,%s,1\t\t; postdec ptr to byte or value' % (reg, reg),
                        ])
                elif symbol.storage == 'auto':
                    ind = symbol.location
                    if node.op == 'p++':
                        result.extend([
                            self.r4index(symbol.location, node.op),
                            "\tloadl\tr2,frame,r4\t\t; p++ auto var size 1",
                            "\tmove\tr3,r2,1",
                            '\tstorl\tr3,frame,r4\t\t;',
                        ])
                    else:
                        result.extend([
                            self.r4index(symbol.location, node.op),
                            "\tloadl\tr2,frame,r4\t\t; p-- auto var size 1",
                            '\tload\tr13,#alu_sub\t\t;',
                            '\talu\tr3,r3,1\t\t',
                            '\tstorl\tr3,frame,r4\t\t;',
                        ])
                else:
                    logger.error('postinc/postdec by 1 for storage other than register not implemented [symbol:{}]', symbol)
            elif size == 4:
                if symbol.storage == 'register':
                    reg = symbol.location
                    if node.op == 'p++':
                        result.extend([
                            '\tmover\t%s,%s,1\t\t; postinc ptr to 4byte value' % (reg, reg),
                        ])
                    else:
                        result.extend([
                            '\tload\tr13,#alu_sub\t\t; postdec ptr to 4byte value',
                            '\tload\tr3,#4\t\t; postdec ptr to 4byte value',
                            '\talu\t%s,%s,r3\t\t; postdec ptr to 4byte value' % (reg, reg),
                        ])
                elif symbol.storage == 'auto':
                    ind = symbol.location
                    if node.op == 'p++':
                        result.extend([
                            self.r4index(symbol.location, node.op),
                            "\tloadl\tr2,frame,r4\t\t; p++ auto var size 4",
                            "\tmover\tr3,r2,1",
                            '\tstorl\tr3,frame,r4\t\t;',
                        ])
                    else:
                        result.extend([
                            self.r4index(symbol.location, node.op),
                            "\tloadl\tr2,frame,r4\t\t; p-- auto var size 4",
                            "\tmover\tr3,r2,-1",
                            '\tstorl\tr3,frame,r4\t\t;',
                        ])
                else:
                    logger.error(
                        'postinc/postdec by 4 for storage other than register/auto not implemented [symbol:{}]', symbol)
            else:
                logger.error('postinc/postdec for size != 1 or 4 not implemented')
            # postinc does not change the lvalue status or the pointer depth!
        elif node.op in {'++', '--'}:
            if isrvalue:
                raise ValueError('preinc op on rvalue')
            # pointers themselves are 4 bytes so a pointer depth of 1 actualy
            # points to something with a possible different size
            size = s.size if s.pointerdepth == 1 else (4 if s.pointerdepth > 1 else 1)
            if size == 1:
                if symbol.storage == 'register':
                    reg = symbol.location
                    if node.op == '++':
                        result.extend([
                            '\tmove\tr2,r2,1\t\t; preinc value or pointer to size 1',
                            '\tmove\t%s,r2,0\t\t; preinc value or pointer to size 1' % reg,
                        ])
                    else:
                        result.extend([
                            '\tload\tr13,#alu_sub\t\t; predec value or pointer to size 1',
                            '\tload\tr3,#1\t\t; predec value or pointer to size 1',
                            '\talu\tr2,r2,r3\t\t; predec value or pointer to size 1',
                            '\tmove\t%s,r2,0\t\t; predec value or pointer to size 1' % reg,
                        ])
                else:
                    logger.error('preinc for storage other than register not implemented')
            elif size == 4:
                if symbol.storage == 'register':
                    reg = symbol.location
                    if node.op == '++':
                        result.extend([
                            '\tmover\tr2,r2,1\t\t; preinc pointer to size 4',
                            '\tmover\t%s,r2,0\t\t; preinc pointer to size 4' % reg,
                        ])
                    else:
                        result.extend([
                            '\tload\tr13,#alu_sub\t\t; predec pointer to size 4',
                            '\tload\tr3,#4\t\t; predec pointer to size 4',
                            '\talu\tr2,r2,r3\t\t; predec pointer to size 4',
                            '\tmove\t%s,r2,0\t\t; predec pointer to size 4' % reg,
                        ])
                else:
                    logger.error('preinc for storage other than register not implemented')
            else:
                logger.error('preinc for size != 1 or 4 not implemented')
            # postinc does not change the lvalue status or the pointer depth!
        elif node.op == '*':
            if isrvalue:
                raise ValueError('dereference op on rvalue')
            size = s.size if s.pointerdepth < 2 else 4
            if size == 1:
                if symbol.storage == 'register':
                    result.extend([
                        '\tmove\tr3,0,0',
                        '\tload\tr3,r2,0\t\t; deref byte',
                        '\tmove\tr2,r3,0'
                    ])
                else:
                    logger.error('deref for storage other than register not implemented')
            else:
                logger.error('deref for size != 1 not implemented {}', s)
            symbol = symbol.deref()
            isrvalue = s.pointerdepth < 1
        elif node.op in {'-', '~', '!'}:
            if s.pointerdepth > 0:
                logger.error('unary operator {} not allowed on pointers', node.op)
            else:
                unop_code = {
                    '-': ['\tload\tr13,#alu_sub\t\t; unary -', '\talu\tr2,0,r2'],
                    '~': ['\tload\tr13,#alu_not\t\t; unary ~', '\talu\tr2,r2,0'],
                    '!': ['\ttest\tr2\t\t; unary !', '\tseteq\tr2\t\t; unary !'],
                }
                result.extend(unop_code[node.op])
        elif node.op == '+':
            pass  # unary plus ignored
        else:
            logger.error('unary operator {} ignored', node.op)
        return value(isrvalue, s.size, "\n".join(result), symbol)

    def visit_ArrayRef(self, node):
        s = self.visit(node.name)
        sub = self.visit(node.subscript)
        result = [s.code, '\tpush\tr2', sub.code]
        if s.size == 4:
            result.extend(['\tmove\tr2,r2,r2\t\t; multiply by 2', '\tmove\tr2,r2,r2\t\t; multiply by 2'])
        result.append('\tpop\tr3')
        result.append('\tmove\tr2,r2,r3\t\t; add index to base address')
        isrvalue = s.rvalue
        symbol = s.symbol
        return value(isrvalue, s.size, "\n".join(result), symbol)

    # TODO argument type checking
    def visit_FuncCall(self, node):
        result = []
        nargs = 0
        rvalue = True
        size = 4
        sym = None
        if node.name.name == '__halt__':
            result.append('\thalt\t\t\t; explicitely inserted __halt__() call')
        else:
            sym = symbols[node.name.name]
            if node.args is not None:
                for expr in reversed(node.args.exprs):
                    v = self.visit(expr)
                    result.append(v.code)
                    if type(expr) == c_ast.ArrayRef and v.symbol is not None and v.symbol.alloc:
                        if v.size == 1 and not v.ispointer():
                            result.append('\tmove\tr3,0,0\t\t; deref array ref byte')
                            result.append('\tload\tr3,r2,0\t\t; deref array ref byte')
                            result.append('\tmove\tr2,r3,0\t\t; deref array ref byte')
                        else:
                            result.append('\tloadl\tr2,r2,0\t\t; deref array ref long')
                    result.append('\tpush\tr2')
                    nargs += 1
            result.append('\tpush\tlink')
            v = self.visit(node.name)
            result.append(v.code)
            result.append('\tjal\tlink,r2,0')
            result.append('\tpop\tlink')
            result.append('\tmover\tsp,sp,%d' % nargs)
            size = sym.size
            rvalue = sym.pointerdepth == 0
        return value(rvalue, size, "\n".join(result), sym)

    def r4index(self, location, name):
        if location >= -8:
            return "\tmover\tr4,0,%d\t\t; load %s (id node)" % (location, name)
        else:
            offset = location * 4
            if offset >= -128:
                return "\tload\tr4,#%d\t\t; load %s (id node)" % (offset, name)
            else:
                return "\tloadl\tr4,#%d\t\t; load %s (id node)" % (offset, name)

    def visit_Decl(self, node):
        ev = ExprVisitor()
        result = []
        if "#registers#" in symbols:  # function scope
            registers = symbols["#registers#"]
            if type(node.type) == c_ast.ArrayDecl:
                d = ev.visit(node.type.dim)[0]
                nauto = symbols["#nauto#"]
                symbols[node.name] = symbol('auto', - d - nauto, node)
                symbols["#nauto#"] = nauto + d
                if node.init:
                    s = ev.visit(node.init)
                    for n, v in enumerate(s, start=-d - nauto):
                        result.append('\tloadl\tr2,#%d' % v)
                        result.append('\tloadl\tr3,#%d' % (n * 4))
                        result.append('\tstorl\tr2,frame,r3')
            elif type(node.type) == c_ast.TypeDecl and type(node.type.type) == c_ast.Union:
                logger.debug(node)
                nauto = symbols["#nauto#"]
                # We crudely assume all union members are 4 byte wide and no initialization is present
                name = node.type.declname
                symbols[name] = symbol('auto', - 1 - nauto, node.type)
                symbols["#nauto#"] = nauto + 1
            elif len(registers):
                symbols[node.name] = symbol('register', registers.pop(), node.type)
            else:
                nauto = symbols["#nauto#"]
                symbols[node.name] = symbol('auto', - 1 - nauto, node.type)
                symbols["#nauto#"] = nauto + 1
            sym = symbols[node.name]
            if not sym.nocode and not sym.alloc:
                if node.init is not None:
                    s = self.visit(node.init)
                    result.append(s.code)
                    if type(node.init) == c_ast.ArrayRef and s.symbol is not None and s.symbol.alloc:
                        if s.size == 1 and not s.ispointer():
                            result.append('\tmove\tr3,0,0\t\t; deref array ref byte assign rvalue')
                            result.append('\tload\tr3,r2,0\t\t; deref array ref byte assign rvalue')
                            result.append('\tmove\tr2,r3,0\t\t; deref array ref byte assign rvalue')
                        else:
                            result.append('\tloadl\tr2,r2,0\t\t; deref array ref long assign rvalue')
                else:
                    result.append('\tmove\tr2,0,0\t\t; missing initializer, default to 0')
                if sym.storage == 'register':
                    result.extend([
                        "\tmove\t%s,r2,0\t\t; load %s (id node)" % (sym.location, node.name),
                    ])
                elif sym.storage == 'auto':
                    result.extend([
                        self.r4index(sym.location, node.name),
                        "\tstorl\tr2,frame,r4"
                    ])
                else:
                    print('Unexpected symbol storage %s with ID %s' % (sym.storage, node.name), file=sys.stderr)
        else:  # file scope
            sym = symbol('global', None, node)
            if not sym.nocode:
                result.append(node.name + ':')
            symbols[node.name] = sym
            if node.init is not None:
                s = ev.visit(node.init)
                for v in s:
                    if type(v) == int:
                        if sym.size == 1:
                            result.append("\tbyte\t%d" % v)
                        else:
                            result.append("\tlong\t%d" % v)
                    elif type(v) == str:
                        result.append('\tbyte0\t%s' % v)
                    else:
                        raise ValueError("initializer not an int")
            elif sym.nocode:
                pass
            elif sym.alloc:
                if sym.size == 4:
                    result.append('\tlong\t%s' % (",".join(['0']*(sym.allocbytes//4))))
                else:
                    result.append('\tbyte\t"%s"' % ("".join(['\\0']*sym.allocbytes)))
            else:
                result.append('\tlong 0\t\t; missing initializer, default to 0')
        return value(True, sym.size, "\n".join(result))

    def visit_DeclList(self, node):
        return value(False, 0, "\n".join([self.visit(d).code for d in node.decls]))

    def visit_Assignment(self, node):
        alu_opmap = {'+=': 'alu_add', '-=': 'alu_sub', '*=': 'alu_mullo', '/=': 'alu_divs',
                     '&=': 'alu_and', '|=': 'alu_or', '^=': 'alu_xor',
                     '&&=': 'alu_and', '||=': 'alu_or', '>>=': 'alu_shiftr', '<<=': 'alu_shiftl',
                     }
        supported_ops = {'+=', '-=', '*=', '/=', '<<=', '>>=', '|=', '&=', '^='}
        result = []
        if node.op == '=' or node.op in supported_ops:
            sr = self.visit(node.rvalue)
            result.append(sr.code)

            if type(node.rvalue) == c_ast.ArrayRef and sr.symbol is not None and sr.symbol.alloc:
                if sr.size == 1 and not sr.ispointer():
                    result.append('\tmove\tr3,0,0\t\t; deref array ref byte assign rvalue')
                    result.append('\tload\tr3,r2,0\t\t; deref array ref byte assign rvalue')
                    result.append('\tmove\tr2,r3,0\t\t; deref array ref byte assign rvalue')
                else:
                    result.append('\tloadl\tr2,r2,0\t\t; deref array ref long assign rvalue')

            result.append('\tpush\tr2')
            if type(node.lvalue) == c_ast.UnaryOp and node.lvalue.op == '*':
                sl = self.visit(node.lvalue.expr)
            else:
                sl = self.visit(node.lvalue)
            result.append(sl.code)
            result.append('\tpop\tr3')
            sym = sl.symbol
            if not sl.rvalue:
                logger.debug(node)
                logger.debug(sym)
                if sym.storage == 'register':
                    if node.op in supported_ops:
                        result.append("\tload\taluop,#%s\t\t; %s" % (alu_opmap[node.op], node.op))
                        result.append("\talu\t%s,%s,r3\t; assign long" % (sym.location, sym.location))
                        result.append("\tmove\tr2,%s,0\t\t; result of assignment is rvalue to be reused" % sym.location)
                    else:
                        if sl.ispointer() and not sr.ispointer():
                            if sl.size == 1:
                                result.append("\tstor\tr3,r2,0\t; store byte")
                            else:
                                result.append("\tstorl\tr3,r2,0\t; store long")
                        else:
                            result.append("\tmove\t%s,r3,0\t; assign long from register" % sym.location)
                            result.append("\tmove\tr2,r3,0\t\t; result of assignment is rvalue to be reused")
                elif sym.alloc or sym.storage == 'global':
                    if sr.symbol is not None:
                        if sym.size == 4:
                            result.append('\tloadl\tr3,r3,0')
                        else:
                            result.append('\tload\tr3,r3,0')
                    # r2 is lvalue r3 is rvalue
                    if node.op in supported_ops:
                        if symbol is not None:
                            if sym.size == 4:
                                result.append('\tloadl\tr4,r2,0')
                            else:
                                result.append('\tmove\tr4,0,0')
                                result.append('\tload\tr4,r2,0')
                        else:
                            logger.error("problem!!!!")
                        result.append("\tload\taluop,#%s\t\t; %s" % (alu_opmap[node.op], node.op))
                        result.append("\talu\tr3,r4,r3\t; assign long")
                    if sym.size == 4:
                        result.append('\tstorl\tr3,r2,0')
                    else:
                        result.append('\tstor\tr3,r2,0')
                    result.append("\tmove\tr2,r3,0\t\t; result of assignment is rvalue to be reused")
                else:  # auto
                    if node.op in supported_ops:
                        result.append("\tload\taluop,#%s\t\t; %s" % (alu_opmap[node.op], node.op))
                        result.append("\talu\tr3,r2,r3\t; assign long")
                    result.append("\tload\tr4,#%d" % (sym.location * 4))
                    result.append("\tstorl\tr3,frame,r4\t; assign byte/long to auto location")
                    if node.op == '=':
                        result.append("\tmove\tr2,r3,0\t\t; result of assignment is rvalue to be reused")
            else:
                print("assignment to rvalue", file=sys.stderr)
        else:
            print("Assignment op %s ignored" % node.op, file=sys.stderr)
            return value(False, 4, "\n".join(result))
        return value(False, sym.size, "\n".join(result))

    def visit_Constant(self, node):
        result = []
        size = 4
        if node.type == 'int':
            result.append("\tloadl\tr2,#%s\t\t; int" % node.value)
        elif node.type == 'char':
            result.append("\tloadl\tr2,#%s\t\t; char, but loaded as int" % node.value)
            size = 1
        elif node.type == 'string':
            if scope == 0:  # file scope
                result.append('\tbyte0\t%s' % node.value)
            else:  # nasty implementation of string in function scope: just plonk it in an jump over it
                start = self.globalutils.label("string")
                end = self.globalutils.label("endstring")
                result.append('\tbra\t' + end)
                result.append(start + ':')
                result.append('\tbyte0\t%s' % node.value)
                result.append(end + ':')
                result.append('\tloadl\tr2,#' + start)
        elif node.type == 'float':
            nodevalue = "".join("%02x" % b for b in pack('>f', float(self.globalutils.normalize(node.value))))
            result.append('\tloadl\tr2,#0x%s\t\t; float: %s' % (nodevalue, node.value))
        else:
            result.append(";Constant of type %s ignored" % node.type)
        return value(False, size, "\n".join(result))

    def visit_Return(self, node):  # TODO: should check that type matches return value of function
        result = []
        s = self.visit(node.expr)
        result.append(s.code)
        if s.symbol is not None and s.symbol.storage == 'global':
            if s.rsize() == 1:
                result.append('\tload\tr2,r2,0\t\t; r2 should be cleared first, not yet implemented')
            else:
                result.append('\tload\tr2,r2,0')
        result.append("\tbra\t" + symbols["#return#"])
        return value(False, 0, "\n".join(result))

    def cond(self, node, prefix):
        result = []
        result.append(self.visit(node.cond).code)
        result.append("\ttest\tr2")
        endif_label = self.globalutils.label("end" + prefix)
        if node.iffalse:
            else_label = self.globalutils.label("else" + prefix)
            result.append("\tbeq\t" + else_label)
            result.append(self.visit(node.iftrue).code)
            result.append("\tbra\t" + endif_label)
            result.append(else_label+":")
            result.append(self.visit(node.iffalse).code)
        else:
            result.append("\tbeq\t" + endif_label)
            result.append(self.visit(node.iftrue).code)
        result.append(endif_label+":")
        return value(False, 0, "\n".join(result))

    def visit_If(self, node):
        return self.cond(node, "_ifstmt")

    def visit_TernaryOp(self, node):
        return self.cond(node, "_condop")

    def visit_While(self, node):
        result = []
        while_label = self.globalutils.label("while")
        endwhile_label = self.globalutils.label("endwhile")
        orig_ct = self.continue_target
        orig_bt = self.break_target
        self.continue_target = while_label
        self.break_target = endwhile_label
        result.append(while_label+":")
        result.append(self.visit(node.cond).code)
        result.append("\ttest\tr2")
        result.append("\tbeq\t" + endwhile_label)
        result.append(self.visit(node.stmt).code)
        result.append("\tbra\t" + while_label)
        result.append(endwhile_label+":")
        self.continue_target = orig_ct
        self.break_target = orig_bt
        return value(False, 0, "\n".join(result))

    def visit_DoWhile(self, node):
        result = []
        dowhile_label = self.globalutils.label("dowhile")
        conddowhile_label = self.globalutils.label("conddowhile")
        enddowhile_label = self.globalutils.label("enddowhile")
        orig_ct = self.continue_target
        orig_bt = self.break_target
        self.continue_target = conddowhile_label
        self.break_target = enddowhile_label
        result.append(dowhile_label+":")
        result.append(self.visit(node.stmt).code)
        result.append(conddowhile_label+":")
        result.append(self.visit(node.cond).code)
        result.append("\ttest\tr2")
        result.append("\tbne\t" + dowhile_label)
        result.append(enddowhile_label+":")
        self.continue_target = orig_ct
        self.break_target = orig_bt
        return value(False, 0, "\n".join(result))

    def visit_For(self, node):
        result = []
        for_label = self.globalutils.label("for")
        endfor_label = self.globalutils.label("endfor")
        orig_ct = self.continue_target
        orig_bt = self.break_target
        self.continue_target = for_label
        self.break_target = endfor_label
        if node.init is not None:
            result.append(self.visit(node.init).code)
        result.append(for_label+":")
        if node.cond is not None:
            result.append(self.visit(node.cond).code)  # if cond is none it should be treated as a non zero constant
            result.append("\ttest\tr2")
            result.append("\tbeq\t" + endfor_label)
        else:
            result.append("\t; missing for condition, always true")
        result.append(self.visit(node.stmt).code)
        if node.next is not None:
            result.append(self.visit(node.next).code)
        result.append("\tbra\t" + for_label)
        result.append(endfor_label+":")
        self.continue_target = orig_ct
        self.break_target = orig_bt
        return value(False, 0, "\n".join(result))

    def visit_Continue(self, node):
        return value(False, 0, "\tbra\t%s\t\t; continue" % self.continue_target)

    def visit_Break(self, node):
        return value(False, 0, "\tbra\t%s\t\t; break" % self.break_target)

    def visit_Compound(self, node):
        result = []
        symbols.dup()
        for bi, item in enumerate(node.block_items):
            s = self.visit(item)
            result.append(s.code)
        symbols.discard()
        return value(False, 0, "\n".join(result))

    def visit_EmptyStatement(self, node):
        return value(True, 0, "\t;empty statement")

    def visit_ExprList(self, node):
        return value(False, 0, "\n".join([self.visit(e).code for e in node.exprs]))


def process(filename, globalutils):
    # Note that cpp is used. Provide a path to your own cpp or
    # make sure one exists in PATH.
    ast = parse_file(filename, use_cpp=True,
                     cpp_args=r'-Iutils/fake_libc_include')

    v = Visitor(globalutils)
    v.visit(ast)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument('-d', '--debug', help='show debug messages', action="store_true")
    parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
    args = parser.parse_args()

    logger.remove()
    logger.add(sys.stderr, colorize=False, level='DEBUG' if args.debug else 'ERROR', backtrace=False)

    gu = GlobalUtils()
    for filename in args.files:
        process(filename, gu)
