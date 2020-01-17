import sys
from re import split

from pycparser import c_parser, c_ast, parse_file

class dictstack:  # not yet complete, must be able to distinguish between redeclaration and shadowing
    
    def __init__(self):
        self.stack = [{}]
    
    def __getitem__(self, key):
        for d in self.stack:
            if key in d: return d[key]
        raise KeyError()
    
    def __setitem__(self, key, value):
        for d in self.stack:
            if key in d:
                d[key] = value  # here we should check for redecl: insert at top level is redecl
                return
        self.stack[0][key] = value

    def __contains__(self, key):
        for d in self.stack:
            if key in d: return True
        return False

    def discard(self):
        self.stack.pop(0)
    
    def dup(self):
        self.stack.insert(0,{})

class symbol:
    def __init__(self, storage, location, stype=None):
        self.storage = storage  # global, auto, register
        self.location = location        # None, integer rel to frame, register name
        self.pointerdepth = 0
        self.nocode = False
        self.alloc = False
        self.allocbytes = 0

        if stype is not None:
            #print(stype, file=sys.stderr)
        
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
                    if init is None:
                        arrayalloc = stype.dim
                    stype = stype.type

            while type(stype) == c_ast.PtrDecl:
                self.pointerdepth += 1
                stype = stype.type

            self.type = stype.type.names[0]
            self.size = 1 if self.type == 'char' else 4

            if arrayalloc is not None:
                ev = ExprVisitor()
                self.alloc = True
                self.allocbytes = ev.visit(arrayalloc) * self.size

    def deref(self):
        ds = symbol(self.storage, self.location)
        ds.size = self.size
        ds.type = self.type
        ds.pointerdepth = self.pointerdepth - 1
        if ds.pointerdepth < 0 : raise ValueError('deref on non pointer')
        return ds
        
    def __repr__(self):
        return 'symbol(%s, %s, %s, %d, %d, %s)' %(self.storage, str(self.location), self.type, self.pointerdepth, self.size, self.nocode)

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

    def __repr__(self):
        return 'value(%s, %s, %s, %d, %r)' %(self.rvalue, self.size, self.vtype, self.pointerdepth, self.symbol)

labelcount = 0

symbols = dictstack()
scope = 0 # file

# TODO create another visitor that runs first and does constant folding etc.

class ExprVisitor(c_ast.NodeVisitor):
    """class to evaluate compile time expressions"""

    def generic_visit(self, node):
        print('unknown node', node.__class__.__name__, file=sys.stderr)
        return None

    def visit_Constant(self, node):
        return int(node.value)   # TODO make this smarter
        
class Visitor(c_ast.NodeVisitor):
    """class to generate code"""

    def generic_visit(self, node):
        print('unknown node', node.__class__.__name__, file=sys.stderr)
        
        return value(True, None, "\n".join([self.visit(c).code for c in node]))
            

    def codeformat(self, code):
        lines = code.split('\n')
        formatted = []
        for line in lines:
            elements = split(r'\t+',line)
            n = len(elements)
            if n <= 1:
                f = "".join(elements) 
            elif elements[0] == '':
                if n > 2:
                    f = "        " + "%-7s %-20s"%tuple(elements[1:3]) + " ".join(elements[3:])
                else:
                    f = "        " + "%-7s"%elements[1]
            else:
                f = " ".join(elements)
            formatted.append(f)
        return "\n".join(formatted)

    def visit_FileAST(self, node):
        #print(node, file=sys.stderr)
        global symbols
        symbols = dictstack()
        print("\n        loadl    sp,#stack")
        print("\n".join([self.codeformat(self.visit(item).code) for item in node.ext]))
        print("\n; room for stack\n        stackdef")

    def visit_FuncDef(self, node):
        scope = 1
        #print(node, file=sys.stderr)
        symbols[node.decl.name] = symbol('global',None,node)  # TODO include signature and deal with forward declarations
        symbols.dup()
        preamble = [
            ';{ %s:%s'% (node.decl.name, node.decl.coord),
            '%s:' % node.decl.name,
            '\tpush\tframe\t\t; old frame pointer',
            '\tmove\tframe,sp,0\t; new frame pointer',
            '\tmove\tr4,0,0\t\t; zero out index'
        ]
        registers = ['r5','r6','r7','r8','r9','r10']
        # arguments will have been pushed in reversed order (cdecl convention)
        n = 1
        r = 2
        movreg = []
        if node.decl.type.args is not None:
            for arg in node.decl.type.args:
                if len(registers):
                    symbols[arg.name] = symbol('register', registers.pop(),arg.type)
                    movreg.append('\tload\tr4,#%d\t\t; init argument %s'%(r*4,arg.name))
                    movreg.append('\tloadl\t%s,frame,r4'%symbols[arg.name].location)
                    r = r + 1
                else:
                    symbols[arg.name] = symbol('auto', n + 1, arg.type)  # skip over pushed frame pointer and caller return address
                    n += 1
        symbols["#nargs#"] = n
        symbols["#nauto#"] = 0
        symbols["#registers#"] = registers
        return_label = self.label("return")
        symbols["#return#"] = return_label
        body = [self.visit(node.body).code]  # only interested in de code
        # TODO some optimization can be done here because the last line from the body might be 'bra returnlabel'
        postamble = [
            symbols["#return#"]+":",
            '\tpop\tframe\t\t; old framepointer',
            '\treturn',
            ';}'
            ]
        extra_space = [
            '\tmover\tsp,sp,-%d\t; add space for auto variables'%symbols["#nauto#"], # TODO leave this out if there are zero auto variables
        ]
        nregs = 0
        for r in ['r5','r6','r7','r8','r9','r10']:
            if r not in symbols["#registers#"]:
                extra_space.append('\tpush\t%s'%r)
                postamble.insert(1,'\tpop\t%s'%r)
                nregs += 1
        
        symbols.discard()
        scope = 0
        return value(True, None, "\n".join(preamble + extra_space + movreg + body + postamble))

    def visit_ID(self, node):
        if node.name in symbols:
            symbol = symbols[node.name]
            if symbol.storage == 'register':
                result = [
                    "\tmove\tr2,%s,0\t\t; load %s"%(symbol.location,node.name),  # TODO this only works for a small number of variables as index = [-8,7]
                ]
            elif symbol.storage == 'auto':
                result = [
                    "\tmover\tr4,0,%d\t\t; load %s"%(symbol.location,node.name),  # TODO this only works for a small number of variables as index = [-8,7]
                    "\tloadl\tr2,frame,r4"
                ]
            elif symbol.storage == 'global':
                result = [
                    "\tloadl\tr2,#%s\t\t; load global symbol"%node.name
                ]
            else:
                print('Unexpected symbol storage %s with ID %s'%(symbol.storage,node.name),file=sys.stderr)
            return value(False, symbol.size, "\n".join(result), symbol)
        else:
            print("Unknown local id %s"%node.name,file=sys.stderr)
            return value(False, 0, "")

    def isnotzero(self, reg):  # prime candidate for creating a cpu intruction for
        notzero = self.label('notzero')
        end = self.label('zero_end')
        return [
            '\ttest\t%s\t\t; notzero?'%reg,
            '\tbne\t%s'%notzero,
            '\tmove\t%s,0,0'%reg,
            '\tbra\t%s'%end,
            notzero+':',
            '\tmove\t%s,0,1'%reg,
            end+':'
        ]

    def visit_BinaryOp(self, node):
        alu_opmap = {'+': 'alu_add', '-': 'alu_sub', '*': 'alu_mul', '/': 'alu_divs',
            '==': 'alu_cmp', '<': 'alu_cmp', '>': 'alu_cmp', '>=': 'alu_cmp', '<=': 'alu_cmp', '!=': 'alu_cmp',
            '&': 'alu_and', '|': 'alu_or','^': 'alu_xor',
            '&&': 'alu_and', '||': 'alu_or',
            }

        post = self.label('post')
        post2 = self.label('post')
        post_map = {
            '==' : ['\tbeq\t%s\t\t; equal'%post,'\tmove\tr2,0,0','\tbra\t%s'%post2,post+':','\tmove\tr2,0,1',post2+':'],
            '<'  : ['\tbrp\t%s\t\t; less than (reversed operands)'%post,'\tmove\tr2,0,0',post+':'],
            '>'  : ['\tbrp\t%s\t\t; greater than'%post,'\tmove\tr2,0,0',post+':'],
        }
        reversed_operands = { '<' }

        if node.op in alu_opmap:
            sl = self.visit(node.left)
            sr = self.visit(node.right)
            if sl.ispointer() and sr.ispointer() and node.op not in {'-', '<', '>', '>=', '<=', '==', '!=' }:
                print("unsupported op %s for two pointers ignored"%node.op,file=sys.stderr)
                return value(False, 0, "")
            elif sl.ispointer() and node.op not in {'+', '-', '==', '!=' }:
                print("unsupported op %s for pointer,value ignored"%node.op,file=sys.stderr)
                return value(False, 0, "")
            elif sr.ispointer() and node.op not in {'+', '==', '!=' }:
                print("unsupported op %s for value,pointer ignored"%node.op,file=sys.stderr)
                return value(False, 0, "")

            endlabel = self.label('binop_end')
            # note that results never need to be widened because internally we always work with 32 bit
            result = [sl.code]
            if node.op == '&&':
                result.extend(self.isnotzero('r2'))
                result.append('\ttest r2\t\t; && short circuit')
                result.append('\tbeq\t%s'%endlabel)
            if node.op == '||':
                result.extend(self.isnotzero('r2'))
                result.append('\ttest r2\t\t; || short circuit')
                result.append('\tbne\t%s'%endlabel)
            result.append("\tpush\tr2\t\t; binop(%s)"%node.op)
            result.append(sr.code)
            if node.op in {'&&', '||'}:
                result.extend(self.isnotzero('r2'))
            result.append("\tpop\tr3\t\t; binop(%s)"%node.op)
            # actual alu op
            result.append("\tload\tflags,#%s\t; binop(%s)"%(alu_opmap[node.op], node.op))
            if node.op in reversed_operands:
                result.append("\talu\tr2,r2,r3")
            else:
                result.append("\talu\tr2,r3,r2")
            # conversion to correct truth value
            if node.op in post_map:
                result.extend(post_map[node.op])
            # end target of short circuit expression
            if node.op in { '&&', '|| ' }:
                result.append(endlabel+':')
            # lvalue is converted to rvalue unless just the right hand side is a pointer
            rvalue = True
            if sl.ispointer() and not sr.ispointer(): rvalue = False
            return value(rvalue, 4, "\n".join(result))
        else:
            print("Binary op %s ignored"%node.op,file=sys.stderr)
            return value(False, 0, "")

    def visit_UnaryOp(self, node):
        s = self.visit(node.expr)
        #print('unop',node.op,s, file=sys.stderr)
        result = [s.code]
        isrvalue = s.rvalue
        symbol = s.symbol
        #print(node,s,file=sys.stderr)
        if node.op == 'p++':
            if isrvalue:
                raise ValueError('postinc op on rvalue')
            # pointers themselves are 4 bytes so a pointer depth of 1 actualy points to something with a possible different size
            size = s.size if s.pointerdepth == 1 else (4 if s.pointerdepth > 1 else 1)
            if size == 1:
                if symbol.storage == 'register':
                    reg = symbol.location
                    result.extend([
                        '\tmove\t%s,%s,1\t\t; postinc ptr to byte or value'%(reg,reg),
                    ])
                else:
                    print('postinc for storage other than register not implemented', file=sys.stderr)
            elif size == 4:
                if symbol.storage == 'register':
                    reg = symbol.location
                    result.extend([
                        '\tmover\t%s,%s,1\t\t; postinc ptr to 4byte'%(reg,reg),
                    ])
                else:
                    print('postinc for storage other than register not implemented', file=sys.stderr)
            else:
                print('postinc for size != 1 or 4 not implemented', file=sys.stderr)
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
                    print('postinc for storage other than register not implemented', file=sys.stderr)
            else:
                print('postinc for size != 1 not implemented', file=sys.stderr)
            symbol = symbol.deref()
            isrvalue = s.pointerdepth < 1
        return value(isrvalue, s.size, "\n".join(result), symbol)

    # TODO argument type checking
    def visit_FuncCall(self, node):
        result = []
        nargs = 0
        for expr in reversed(node.args.exprs):
            v = self.visit(expr)
            result.append(v.code)
            result.append('\tpush\tr2')
            nargs += 1
        result.append('\tpush\tlink')
        v = self.visit(node.name)
        result.append(v.code)
        result.append('\tjal\tlink,r2,0')
        result.append('\tpop\tlink')
        result.append('\tmover\tsp,sp,%d'%nargs)
        rvalue = True  # should depend on return type of function
        return value(rvalue, 4, "\n".join(result))

    def visit_Decl(self, node):
        #print(node,file=sys.stderr)
        result = []
        if "#registers#" in symbols:  # function scope
            registers = symbols["#registers#"]
            if len(registers):
                symbols[node.name] = symbol('register', registers.pop(),node.type)
            else:
                nauto = symbols["#nauto#"]
                symbols[node.name] = symbol('auto', - 1 - nauto, node.type) 
                symbols["#nauto#"] = nauto + 1
            if node.init is not None:
                s = self.visit(node.init)
                result.append(s.code)
            else:
                result.append('\tmove\tr2,0,0\t\t; missing initializer, default to 0')
            sym = symbols[node.name]
            if sym.storage == 'register':
                result.extend( [
                    "\tmove\t%s,r2,0\t\t; load %s (id node)"%(sym.location,node.name),
                ])
            elif sym.storage == 'auto':
                result.extend( [
                    "\tmover\tr4,0,%d\t\t; load %s (id node)"%(sym.location,node.name),
                    "\tstorl\tr2,frame,r4"
                ])
            else:
                print('Unexpected symbol storage %s with ID %s'%(sym.storage,node.name),file=sys.stderr)
        else:  # file scope
            sym = symbol('global',None,node)
            if not sym.nocode:
                result.append(node.name + ':')
            symbols[node.name] = sym
            if node.init is not None:
                s = self.visit(node.init)
                result.append(s.code)
            elif sym.nocode:
                pass
            elif sym.alloc:
                if sym.size == 4:
                    result.append('\tlong\t%s'%(",".join(['0']*(sym.allocbytes//4))))
                else:
                    result.append('\tbyte\t"%s"'%("".join(['\\0']*sym.allocbytes)))
            else:
                result.append('\tlong 0\t\t; missing initializer, default to 0')
        return value(True, sym.size, "\n".join(result))

    def visit_Assignment(self, node):
        #print(node, file=sys.stderr)
        result = []
        if node.op == '=':
            sr = self.visit(node.rvalue)
            result.append(sr.code)
            result.append('\tpush\tr2')
            if type(node.lvalue) == c_ast.UnaryOp and node.lvalue.op == '*':
                sl = self.visit(node.lvalue.expr)
            else:
                sl = self.visit(node.lvalue)
            result.append(sl.code)
            result.append('\tpop\tr3')
            sym = sl.symbol
            if not sl.rvalue:
                if sym.storage == 'register':
                    if sl.size == 4:
                        result.append("\tstorl\tr3,r2,0\t; assign long")
                    else:
                        result.append("\tstor\tr3,r2,0\t; assign byte")
                else:
                    result.append("\tload\tr4,#%d"%sym.location)
                    if sym.size == 4:
                        result.append("\tstorl\tr2,frame,r4\t; assign long")
                    else:
                        result.append("\tstor\tr2,frame,r4\t; assign byte")
                result.append("\tmove\tr2,r3,0\t\t; result of assignment is rvalue to be reused")
            else:
                print("assignment to rvalue",file=sys.stderr)
        else:
            print("Assignment op %s ignored"%node.op,file=sys.stderr)
        return value(False, sym.size, "\n".join(result))

    def visit_Constant(self, node):
        result = []
        size = 4
        if node.type == 'int':
            result.append("\tloadl\tr2,#%s\t\t; int"%node.value)
        elif node.type == 'char':
            result.append("\tloadl\tr2,#%s\t\t; char, but loaded as int"%node.value)
            size = 1
        else:
            if scope == 0:
                if node.type == 'string':
                    result.append('\tbyte0\t%s'%node.value)
                else:
                    result.append(";Constant of type %s ignored in file scope"%node.type)
            else:
                result.append(";Constant of type %s ignored in function scope"%node.type)
        return value(False, size, "\n".join(result))
        
    def visit_Return(self, node):  # TODO: should check that type matches return value of function
        result = []
        result.append(self.visit(node.expr).code)
        result.append("\tbra\t"+ symbols["#return#"])
        return value(False,0,"\n".join(result))

    def label(self,prefix):
        global labelcount
        labelcount += 1
        return "%s_%04d"%(prefix,labelcount)

    def visit_If(self, node):
        result = []
        result.append(self.visit(node.cond).code)
        result.append("\ttest\tr2")
        endif_label = self.label("endif")
        if node.iffalse:
            else_label = self.label("else")
            result.append("\tbeq\t" + else_label)
            result.append(self.visit(node.iftrue).code)
            result.append("\tbra\t" + endif_label)
            result.append(else_label+":")
            result.append(self.visit(node.iffalse).code)
        else:
            result.append("\tbeq\t" + endif_label)
            result.append(self.visit(node.iftrue).code)
        result.append(endif_label+":")
        return value(False,0,"\n".join(result))

    def visit_While(self, node):
        result = []
        while_label = self.label("while")
        result.append(while_label+":")
        result.append(self.visit(node.cond).code)
        result.append("\ttest\tr2")
        endwhile_label = self.label("endwhile")
        result.append("\tbeq\t" + endwhile_label)
        result.append(self.visit(node.stmt).code)
        result.append("\tbra\t" + while_label)
        result.append(endwhile_label+":")
        return value(False, 0, "\n".join(result))

    def visit_Compound(self, node):
        result = []
        symbols.dup()
        for bi,item in enumerate(node.block_items):
            s = self.visit(item)
            result.append(s.code)
        symbols.discard()
        return value(False,0,"\n".join(result))

    def visit_EmptyStatement(self, node):
        return value(True,0,"\t;empty statement")

def process(filename):
    # Note that cpp is used. Provide a path to your own cpp or
    # make sure one exists in PATH.
    ast = parse_file(filename, use_cpp=True,
                     cpp_args=r'-Iutils/fake_libc_include')

    #print(ast, file=sys.stderr)

    v = Visitor()
    v.visit(ast)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        filename  = sys.argv[1]

    process(filename)
