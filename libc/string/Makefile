COMPILER = python3 ../../compiler/compiler.py
ASSEMBLER = ../../assembler.py

OUTPUT = test_strlen.bin test_strchr.bin test_strreverse.bin

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

clean:
	rm -f *.bin *.hex

.PHONY: all clean
