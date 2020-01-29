DIR = /home/michel/fpga/robin
COMPILER = python3 ../../compiler/compiler.py
ASSEMBLER = ../../assembler.py
MONITOR = $(DIR)/monitor.py

OUTPUT = $(TEST)/test_atof.bin $(TEST)/test_atoi.bin $(TEST)/test_ftoa.bin $(TEST)/test_itoa.bin $(TEST)/test_mulu32_64_shift.bin

MACROS = ../../lib.S

STRING = ../string

TEST = Test

all: $(OUTPUT)

%.s: %.c
	$(COMPILER) $< > $@

$(TEST)/test_atoi.bin: $(MACROS) test_atoi.s $(STRING)/strlen.s $(STRING)/strreverse.s atoi.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_atof.bin: $(MACROS) test_atof.s $(STRING)/strlen.s $(STRING)/strreverse.s $(STRING)/strchr.s atoi.s atof.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_itoa.bin: $(MACROS) test_itoa.s $(STRING)/strlen.s $(STRING)/strreverse.s itoa.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_ftoa.bin: $(MACROS) test_ftoa.s $(STRING)/strlen.s $(STRING)/strreverse.s $(STRING)/strchr.s mulu32_64_shift.s itoa.s ftoa.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_mulu32_64_shift.bin: $(MACROS) test_mulu32_64_shift.s mulu32_64_shift.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex

test:
	(cd Test; $(MONITOR) -b115200 -i -x test_all.cmd)

.PHONY: all clean test
