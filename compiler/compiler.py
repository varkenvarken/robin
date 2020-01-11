import sys

from pycparser import c_parser, c_ast, parse_file

class dictstack:  # not yet complete, should not realy dup but search down stack to make it possible to distinguish between redeclaration and shadowing
    
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
        if stype is not None:
            while type(stype) == c_ast.PtrDecl:
                self.pointerdepth += 1
                stype = stype.type
            if type(stype) == c_ast.FuncDef:    # TODO funcdef should deal with pointer depth as well
                self.type = stype.decl.type.type.type.names[0]
            else:
                self.type = stype.type.names[0]
            self.size = 1 if self.type == 'char' else 4

    def deref(self):
        ds = symbol(self.storage, self.location)
        ds.size = self.size
        ds.type = self.type
        ds.pointerdepth = self.pointerdepth - 1
        if ds.pointerdepth < 0 : raise ValueError('deref on non pointer')
        return ds
        
    def __repr__(self):
        return 'symbol(%s, %s, %s, %d, %d)' %(self.storage, str(self.location), self.type, self.pointerdepth, self.size)

class value:
    def __init__(self, rvalue, size, code, symbol=None):
        self.rvalue = rvalue
        self.size = size
        self.vtype = None
        self.pointerdepth = 0
        if symbol is not None:
            self.vtype = symbol.type
            self.pointerdepth = symbol.pointerdepth
        self.code = code
        self.symbol = symbol
    
    def __repr__(self):
        return 'value(%s, %s, %s, %d, %r)' %(self.rvalue, self.size, self.vtype, self.pointerdepth, self.symbol)

labelcount = 0

symbols = dictstack()

# TODO create another visitor that runs first and does constant folding etc.

# A simple visitor for FuncDef nodes that prints the names and
# locations of function definitions.
class Visitor(c_ast.NodeVisitor):
    def generic_visit(self, node):
        print('unknown node', node.__class__.__name__)
        print(node)
        
        return value(True, None, "\n".join([self.visit(c) for c in node]))
            

    def visit_FileAST(self, node):
        global symbols
        symbols = dictstack()
        print("\n".join([self.visit(item).code for item in node.ext]))

    def visit_FuncDef(self, node):
        symbols[node.decl.name] = symbol('global',None,node)  # TODO include signature and deal with forward declarations
        symbols.dup()
        preamble = [
            '%s:\t; %s' % (node.decl.name, node.decl.coord),
            '\tpush\tframe\t\t; old frame pointer',
            '\tmove\tframe,sp,0\t; new frame pointer',
            '\tmove\tr4,0,0\t\t; zero out index'
        ]
        registers = ['r5','r6','r7','r8','r9','r10']
        # arguments will have been pushed in reversed order (cdecl convention)
        n = 1
        r = 2
        movreg = []
        for arg in node.decl.type.args:
            if len(registers):
                symbols[arg.name] = symbol('register', registers.pop(),arg.type)
                movreg.append('\tload\tr4,#%d\t\t; init argument %s'%(r*4,arg.name))
                movreg.append('\tmove\t%s,frame,r4'%symbols[arg.name].location)
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
            '\treturn'
            ]
        extra_space = [
            '\tmover\tsp,-%d\t\t; add space for auto variables'%symbols["#nauto#"], # TODO leave this out if there are zero auto variables
        ]
        nregs = 0
        for r in ['r5','r6','r7','r8','r9','r10']:
            if r not in symbols["#registers#"]:
                extra_space.append('\tpush\t%s'%r)
                postamble.insert(1,'\tpop\t%s'%r)
                nregs += 1
        
        symbols.discard()
        return value(True, None, "\n".join(preamble + extra_space + movreg + body + postamble))

    def visit_ID(self, node):
        if node.name in symbols:
            symbol = symbols[node.name]
            if symbol.storage == 'register':
                result = [
                    "\tmove\tr2,%3s,0\t; load %s (id node)"%(symbol.location,node.name),  # TODO this only works for a small number of variables as index = [-8,7]
                ]
            elif symbol.storage == 'auto':
                result = [
                    "\tmover\tr4,0,%d\t\t; load %s (id node)"%(symbol.location,node.name),  # TODO this only works for a small number of variables as index = [-8,7]
                    "\tloadl\tr2,frame,r4"
                ]
            else:
                print('Unexpected symbol storage %s with ID %s'%(symbol.storage,node.name),file=sys.stderr)
            return value(False, symbol.size, "\n".join(result), symbol)
        else:
            print("Unknown local id %s"%node.name,file=sys.stderr)
            return value(False, 0, "")

    def visit_BinaryOp(self, node):
        opmap = {'+': 'alu_add', '-': 'alu_sub', '*': 'alu_mul'}
        if node.op in opmap:
            islvalueleft, sizeleft, codeleft = self.visit(node.left)
            islvalueright, sizeright, coderight = self.visit(node.right)
            lvalue = isvalueleft
            size = max(sizeleft, sizeright)
            result = [
                codeleft,
                "\tpush\tr2\t\t; binop(%s)"%node.op,  # TODO widening
                coderight,
                "\tpop\tr3\t\t; binop(%s)"%node.op,
                "\tload\tflags,#%s\t; binop(%s)"%(opmap[node.op], node.op),
                "\talu\tr2,r3,r2"
            ]
            return value(lvalue, size, "\n".join(result))
        else:
            print("Binary op %s ignored"%node.op,file=sys.stderr)
            return value(False, 0, "")

    def visit_UnaryOp(self, node):
        s = self.visit(node.expr)
        print('unop',node.op,s)
        result = [s.code]
        isrvalue = s.rvalue
        symbol = s.symbol
        if node.op == 'p++':
            if isrvalue:
                raise ValueError('postinc op on rvalue')
            # pointers themselves are 4 bytes so a pointer depth of 1 actualy points to something with a possible different size
            size = s.size if s.pointerdepth == 1 else 4
            if size == 1:
                if symbol.storage == 'register':
                    reg = symbol.location
                    result.extend([
                        '\tmove\t%s,%s,1\t; postinc'%(reg,reg),
                    ])
                else:
                    print('postinc for storage other than register not implemented')
            elif size == 4:
                if symbol.storage == 'register':
                    reg = symbol.location
                    result.extend([
                        '\tmover\t%s,%s,1\t\t; postinc b'%(reg,reg),
                    ])
                else:
                    print('postinc for storage other than register not implemented')
            else:
                print('postinc for size != 1 or 4 not implemented')
            # postinc does not change the lvalue status or the pointer depth!
        elif node.op == '*':
            if isrvalue:
                raise ValueError('dereference op on rvalue')
            size = s.size if s.pointerdepth < 2 else 4
            if size == 1:
                if symbol.storage == 'register':
                    result.extend([
                        '\tloadb\tr2,r2,0\t\t; deref byte',
                    ])
                else:
                    print('postinc for storage other than register not implemented')
            else:
                print('postinc for size != 1 not implemented')
            symbol = symbol.deref()
            isrvalue = s.pointerdepth < 1
        return value(isrvalue, s.size, "\n".join(result), symbol)

    def visit_Decl(self, node):
        registers = symbols["#registers#"]
        if len(registers):
            symbols[node.name] = symbol('register', registers.pop(),node.type)
        else:
            nauto = symbols["#nauto#"]
            symbols[node.name] = symbol('auto', - 1 - nauto, node.type) 
            symbols["#nauto#"] = nauto + 1
        result = []
        if node.init is not None:
            s = self.visit(node.init)
            result.append(s.code)  # TODO might need widening here
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
        return value(True, sym.size, "\n".join(result))

    def visit_Assignment(self, node):
        result = []
        result.append("; assignment %s"%node.coord)
        if node.op == '=':
            result.append(self.visit(node.rvalue))
            if node.lvalue.__class__.__name__ == 'ID':
                if node.lvalue.name in symbols:
                    sym = symbols[node.lvalue.name]
                    if sym.storage == 'register':
                        if sym.size == 4:
                            result.append("\tstorl\tr2,%s,0\t; %s <- r2"%(sym.location,node.lvalue.name))
                        else:
                            result.append("\tstorb\tr2,%s,0\t; %s <- r2"%(sym.location,node.lvalue.name))
                    else:
                        result.append("\tload\tr4,#%d"%sym.location)
                        if sym.size == 4:
                            result.append("\tstorl\tr2,frame,r4\t; %s <- r2"%node.lvalue.name)
                        else:
                            result.append("\tstorb\tr2,frame,r4\t; %s <- r2"%node.lvalue.name)
                else:
                    result.append("Unknown local id %s"%node.lvalue.name,file=sys.stderr)
            else:
                print("lvalue not an ID",file=sys.stderr)
        else:
            print("Assignment op %s ignored"%node.op,file=sys.stderr)
        return value(False, sym.size, "\n".join(result))

    def visit_Constant(self, node):
        result = []
        result.append("; constant %s"%node.coord)
        size = 4
        if node.type == 'int':
            result.append("\tloadl\tr2,#%s"%node.value)
        elif node.type == 'char':
            result.append("\tloadb\tr2,#%s"%node.value)
            size = 1
        else:
            result.append("Constant of type %s ignored"%node.type)
        return value(False, size, "\n".join(result))
        
    def visit_Return(self, node):
        result = []
        result.append("; return %s"%node.coord)
        result.append(self.visit(node.expr).code)
        result.append("\tbra\t"+ symbols["#return#"])
        return value(False,0,"\n".join(result))

    def label(self,prefix):
        global labelcount
        labelcount += 1
        return "%s_%04d"%(prefix,labelcount)

    def visit_If(self, node):
        result = []
        result.append("; if")
        result.append(self.visit(node.cond))
        result.append("\ttest\tr2")
        endif_label = self.label("endif")
        if node.iffalse:
            else_label = self.label("else")
            result.append("\tbeq\t" + else_label)
            result.append(self.visit(node.iftrue))
            result.append("\tbra\t" + endif_label)
            result.append(else_label+":")
            print(node.iffalse)
            result.append(self.visit(node.iffalse))
        else:
            result.append("\tbeq\t" + endif_label)
            result.append(self.visit(node.iftrue))
        result.append(endif_label+":")
        return value(False,0,"\n".join(result))

    def visit_While(self, node):
        result = []
        result.append("; while")
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
            #print('>>>>>',bi,s,'<<<<<<<')
            result.append(s.code)
        symbols.discard()
        return value(False,0,"\n".join(result))

def process(filename):
    # Note that cpp is used. Provide a path to your own cpp or
    # make sure one exists in PATH.
    ast = parse_file(filename, use_cpp=True,
                     cpp_args=r'-Iutils/fake_libc_include')

    print(ast)

    v = Visitor()
    v.visit(ast)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        filename  = sys.argv[1]

    process(filename)
