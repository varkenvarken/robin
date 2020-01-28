COMPILER = python3 ../../compiler/compiler.py
ASSEMBLER = ../../assembler.py

OUTPUT = test_putchar.bin test_print.bin

MACROS = ../../lib.S

all: $(OUTPUT)

%.s: %.c
	$(COMPILER) $< > $@

test_putchar.bin: $(MACROS) test_putchar.s putchar.s
	$(ASSEMBLER) $^ > $@

test_print.bin: $(MACROS) test_print.s putchar.s print.s
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex

.PHONY: all clean
