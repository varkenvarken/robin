COMPILER = python3 ../../compiler/compiler.py
ASSEMBLER = ../../assembler.py

OUTPUT = test_atof.bin test_atoi.bin test_strlen.bin test_strchr.bin test_strreverse.bin

MACROS = ../../lib.S

all: $(OUTPUT)

%.s: %.c
	$(COMPILER) $< > $@

test_strlen.bin: $(MACROS) test_strlen.s strlen.s
	$(ASSEMBLER) $^ > $@

test_strchr.bin: $(MACROS) test_strchr.s strchr.s
	$(ASSEMBLER) $^ > $@

test_strreverse.bin: $(MACROS) test_strreverse.s strlen.s strreverse.s
	$(ASSEMBLER) $^ > $@

test_atoi.bin: $(MACROS) test_atoi.s strlen.s strreverse.s atoi.s
	$(ASSEMBLER) $^ > $@

test_atof.bin: $(MACROS) test_atof.s strlen.s strreverse.s strchr.s atoi.s atof.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex

.PHONY: all clean
