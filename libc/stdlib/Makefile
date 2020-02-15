PYTHON = python3
COMPILER = $(PYTHON) ../../bin/compiler.py
ASSEMBLER = $(PYTHON) ../../bin/assembler.py
SIMULATOR = $(PYTHON) ../../bin/simulator.py
MONITOR = $(PYTHON) ../../bin/monitor.py

OUTPUT = $(TEST)/test_atof.bin $(TEST)/test_atoi.bin $(TEST)/test_ftoa.bin $(TEST)/test_itoa.bin $(TEST)/test_mulu32_64_shift.bin

MACROS = ../../bin/lib.S

STRING = ../string

TEST = Test

all: $(OUTPUT)

sfiles := $(patsubst %.c,%.s,$(wildcard *.c))

$(sfiles):%.s: %.c
	$(COMPILER) $< > $@

$(TEST)/test_atoi.bin: $(MACROS) $(TEST)/test_atoi.s $(STRING)/strlen.s $(STRING)/strreverse.s atoi.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_atof.bin: $(MACROS) $(TEST)/test_atof.s $(STRING)/strlen.s $(STRING)/strreverse.s $(STRING)/strchr.s atoi.s atof.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_itoa.bin: $(MACROS) $(TEST)/test_itoa.s $(STRING)/strlen.s $(STRING)/strreverse.s itoa.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_ftoa.bin: $(MACROS) $(TEST)/test_ftoa.s $(STRING)/strlen.s $(STRING)/strreverse.s $(STRING)/strchr.s mulu32_64_shift.s itoa.s ftoa.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_mulu32_64_shift.bin: $(MACROS) $(TEST)/test_mulu32_64_shift.s mulu32_64_shift.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex atoi.s atof.s itoa.s ftoa.s

test: $(OUTPUT)
	$(SIMULATOR) --regs $(TEST)/test_mulu32_64_shift.bin | grep 'R03 9502f900 ('
	$(SIMULATOR) -s 0x410 $(TEST)/test_itoa.bin | grep '"-666"'
	$(SIMULATOR) --regs $(TEST)/test_atoi.bin | grep 'R02 fffffd66 ('
	$(SIMULATOR) --regs $(TEST)/test_atof.bin | grep 'R02 c0600000 ('
	$(SIMULATOR) -s 0x410 $(TEST)/test_ftoa.bin | grep '"-3.5"'

testhard:
	$(MONITOR) -b115200 -i -x Test/test_all.cmd

.PHONY: all clean test testhard



