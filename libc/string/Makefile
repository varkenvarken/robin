PYTHON = python
COMPILER = $(PYTHON) ../../bin/compiler.py
ASSEMBLER = $(PYTHON) ../../bin/assembler.py
SIMULATOR = $(PYTHON) ../../bin/simulator.py

OUTPUT = test_strlen.bin test_strchr.bin test_strreverse.bin

MACROS = ../../bin/lib.S

all: $(OUTPUT)

%.s: %.c
	$(COMPILER) $< > $@

test_strlen.bin: $(MACROS) test_strlen.s strlen.s
	$(ASSEMBLER) $^ > $@

test_strchr.bin: $(MACROS) test_strchr.s strchr.s
	$(ASSEMBLER) $^ > $@

test_strreverse.bin: $(MACROS) test_strreverse.s strlen.s strreverse.s
	$(ASSEMBLER) $^ > $@

test: $(OUTPUT)
		$(SIMULATOR) --regs test_strlen.bin | grep 'R02 0000000f ('
		$(SIMULATOR) --regs test_strchr.bin | grep 'R02 00000402 ('
		$(SIMULATOR) -s 0x400 test_strreverse.bin | grep '"!zelur paA paaJ"'

clean:
	rm -f *.bin *.hexc strlen.s strreverse.s strchr.s

.PHONY: all clean test
