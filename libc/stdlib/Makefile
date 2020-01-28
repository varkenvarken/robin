COMPILER = python3 ../../compiler/compiler.py
ASSEMBLER = ../../assembler.py

OUTPUT = test_atof.bin test_atoi.bin test_ftoa.bin test_itoa.bin test_mulu32_64_shift.bin

MACROS = ../../lib.S

STRING = ../string

all: $(OUTPUT)

%.s: %.c
	$(COMPILER) $< > $@

test_atoi.bin: $(MACROS) test_atoi.s $(STRING)/strlen.s $(STRING)/strreverse.s atoi.s
	$(ASSEMBLER) $^ > $@

test_atof.bin: $(MACROS) test_atof.s $(STRING)/strlen.s $(STRING)/strreverse.s $(STRING)/strchr.s atoi.s atof.s
	$(ASSEMBLER) $^ > $@

test_itoa.bin: $(MACROS) test_itoa.s $(STRING)/strlen.s $(STRING)/strreverse.s itoa.s
	$(ASSEMBLER) $^ > $@

test_ftoa.bin: $(MACROS) test_ftoa.s $(STRING)/strlen.s $(STRING)/strreverse.s $(STRING)/strchr.s mulu32_64_shift.s itoa.s ftoa.s
	$(ASSEMBLER) $^ > $@

test_mulu32_64_shift.bin: $(MACROS) test_mulu32_64_shift.s mulu32_64_shift.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex

.PHONY: all clean
