PYTHON = python3
ASSEMBLER = $(PYTHON) ../../bin/assembler.py
SIMULATOR = $(PYTHON) ../../bin/simulator.py
MONITOR = $(PYTHON) ../../bin/monitor.py
LIB = ../../bin/lib.S

OUTPUT = all_instructions.bin stack_instructions.bin alu_instructions.bin clz_instruction.bin shift_instructions.bin shift_instructions2.bin himem.bin speedtest.bin uartspeed.bin

STRING = ../string

all: $(OUTPUT)

all_instructions.bin: $(LIB) all_instructions.s
	$(ASSEMBLER) $^ > $@

stack_instructions.bin: $(LIB) stack_instructions.s
	$(ASSEMBLER) $^ > $@

alu_instructions.bin: $(LIB) alu_instructions.s
	$(ASSEMBLER) $^ > $@

clz_instruction.bin: $(LIB) clz_instruction.s
	$(ASSEMBLER) $^ > $@

shift_instructions.bin: $(LIB) shift_instructions.s
	$(ASSEMBLER) $^ > $@

shift_instructions2.bin: $(LIB) shift_instructions2.s
	$(ASSEMBLER) $^ > $@

himem.bin: $(LIB) himem.s
	$(ASSEMBLER) -i $^ > $@

speedtest.bin: $(LIB) speedtest.s
	$(ASSEMBLER) $^ > $@

uartspeed.bin: $(LIB) uartspeed.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex *.out

test: $(OUTPUT)
	$(SIMULATOR) --regs all_instructions.bin > test.out
	grep 'R00 00000000 (         0)' test.out > /dev/null
	grep 'R01 00000001 (         1)' test.out > /dev/null
	grep 'R02 00000001 (         1)' test.out > /dev/null
	grep 'R03 12345644 ( 305419844)' test.out > /dev/null
	grep 'R04 12345645 ( 305419845)' test.out > /dev/null
	grep 'R05 12345649 ( 305419849)' test.out > /dev/null
	grep 'R06 00000020 (        32)' test.out > /dev/null
	grep 'R07 00000049 (        73)' test.out > /dev/null
	grep 'R08 12345649 ( 305419849)' test.out > /dev/null
	grep 'R09 abacadab (2880220587)' test.out > /dev/null
	grep 'R10 abacadab (2880220587)' test.out > /dev/null
	grep 'R11 00000262 (       610)' test.out > /dev/null
	grep 'R12 abacadab (2880220587)' test.out > /dev/null
	$(SIMULATOR) --mem 0x400:32 alu_instructions.bin > test.out
	grep '^00de49dc,ff658740,ffffffff,22222222,dddddddd,55555555,ffffffff,aaaaaaaa,00000000,4fa4fa4f,05b05b06,aaaaaaa8,2aaaaaaa,00000001,33333333,00000001,03333333,00000000,aaaaaaaa,' test.out > /dev/null
	$(SIMULATOR) --regs shift_instructions.bin > test.out
	grep 'R04 12345678 ( 305419896)' test.out > /dev/null
	grep 'R05 2468acf0 ( 610839792)' test.out > /dev/null
	grep 'R06 48d159e0 (1221679584)' test.out > /dev/null
	grep 'R07 23456780 ( 591751040)' test.out > /dev/null
	grep 'R08 34567800 ( 878082048)' test.out > /dev/null
	grep 'R09 56780000 (1450704896)' test.out > /dev/null
	grep 'R10 00000000 (         0)' test.out > /dev/null
	$(SIMULATOR) --regs shift_instructions2.bin > test.out
	grep 'R04 12345678 ( 305419896)' test.out > /dev/null
	grep 'R05 091a2b3c ( 152709948)' test.out > /dev/null
	grep 'R06 048d159e (  76354974)' test.out > /dev/null
	grep 'R07 01234567 (  19088743)' test.out > /dev/null
	grep 'R08 00123456 (   1193046)' test.out > /dev/null
	grep 'R09 00001234 (      4660)' test.out > /dev/null
	grep 'R10 00000000 (         0)' test.out > /dev/null

testhard:
	$(MONITOR) -b115200 -i -x all_instructions.cmd
	$(MONITOR) -b115200 -i -x stack_instructions.cmd
	$(MONITOR) -b115200 -i -x alu_instructions.cmd
	$(MONITOR) -b115200 -i -x shift_instructions.cmd
	$(MONITOR) -b115200 -i -x clz_instruction.cmd
	$(MONITOR) -b115200 -i -x himem.cmd

testspeed: speedtest.bin speedtest.cmd speedpretty.py
	$(MONITOR) -b115200 -i -x speedtest.cmd | $(PYTHON) speedpretty.py

uartspeed: uartspeed.bin
	$(MONITOR) -b115200 -i -x uartspeed.cmd

.PHONY: all clean test testhard testspeed



