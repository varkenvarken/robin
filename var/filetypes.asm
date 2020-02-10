# location /usr/share/geany/filedefs/filetypes.asm
# For complete documentation of this file, please see Geany's main documentation
[styling]
# Edit these in the colorscheme .conf file instead
default=default
comment=comment_line
commentblock=comment
commentdirective=comment
number=number_1
string=string_1
operator=operator
identifier=identifier_1
cpuinstruction=keyword_1
mathinstruction=keyword_2
register=type
directive=preprocessor
directiveoperand=keyword_3
character=character
stringeol=string_eol
extintructions=keyword_4

[keywords]
# all items must be in one line
# this is by default a very simple instruction set
instructions=load loadw loadl stor storw storl move mover alu jal bra brm brp beq bne mark halt pop push seteq setne setmin setpos
registers=r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r14 pc sp link frame
directives=byte byte0 word word0 long long0 return call test jump  dub mullo mulhi mul16 divs divu rems remu and cmp shiftright shiftleft stackdef

[settings]
# default extension used when saving files
extension=s

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file
comment_single=;
# multiline comments
#comment_open=
#comment_close=

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=false

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[indentation]
width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
type=0

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=nasm "%f"

[lexer_properties]
fold.asm.comment.explicit=1

