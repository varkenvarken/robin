PYTHON = python3
ASSEMBLER = $(PYTHON) ../../bin/assembler.py
SIMULATOR = $(PYTHON) ../../bin/simulator.py
MONITOR = $(PYTHON) ../../bin/monitor.py

OUTPUT = all_instructions.bin

STRING = ../string

all: $(OUTPUT)

all_instructions.bin: all_instructions.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex *.out

test: $(OUTPUT)
	$(SIMULATOR) --regs all_instructions.bin > test.out
	grep 'R00 00000000 (         0)' test.out
	grep 'R01 00000001 (         1)' test.out
	grep 'R02 00000001 (         1)' test.out
	grep 'R03 12345644 ( 305419844)' test.out
	grep 'R04 12345645 ( 305419845)' test.out
	grep 'R05 12345649 ( 305419849)' test.out
	grep 'R06 00000020 (        32)' test.out
	grep 'R07 00000049 (        73)' test.out
	grep 'R08 12345649 ( 305419849)' test.out
	grep 'R09 abacadab (2880220587)' test.out

testhard:
	$(MONITOR) -b115200 -i -x all_instructions.cmd

.PHONY: all clean test testhard



