DIR = /home/michel/fpga/robin
COMPILER = python3 ../../compiler/compiler.py
ASSEMBLER = ../../assembler.py
MONITOR = $(DIR)/monitor.py

OUTPUT = $(TEST)/test_mul_f32.bin $(TEST)/test_leadingzeros.bin $(TEST)/test_add_f32.bin $(TEST)/test_div_f32.bin

MACROS = ../../lib.S

STDLIB = ../stdlib
STRING = ../string
STDIO  = ../stdio

STDLIB_A = $(STDLIB)/ftoa.s $(STDLIB)/mulu32_64_shift.s $(STDLIB)/itoa.s
STRING_A = $(STRING)/strreverse.s $(STRING)/strlen.s $(STRING)/strchr.s
STDIO_A  = $(STDIO)/putchar.s $(STDIO)/print.s

TEST = Test

all: $(OUTPUT)

sfiles := $(patsubst %.c,%.s,$(wildcard *.c))

$(sfiles):%.s: %.c
	$(COMPILER) $< > $@

$(TEST)/test_mul_f32.bin: $(MACROS) $(TEST)/test_mul_f32.s $(STDLIB)/mulu32_64_shift.s mul_f32.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_div_f32.bin: $(MACROS) $(TEST)/test_div_f32.s $(STDLIB)/mulu32_64_shift.s add_f32.s mul_f32.s div_f32.s
	$(ASSEMBLER) $^ > $@

$(TEST)/test_add_f32.bin: $(MACROS) $(TEST)/test_add_f32.s add_f32.s $(STDLIB_A) $(STRING_A) $(STDIO_A)
	$(ASSEMBLER) $^ > $@

$(TEST)/test_leadingzeros.bin: $(MACROS) $(TEST)/test_leadingzeros.s add_f32.s $(STDLIB_A) $(STRING_A) $(STDIO_A)
	$(ASSEMBLER) $^ > $@

clean:
	rm -f *.bin *.hex

test:
	(cd Test; $(MONITOR) -b115200 -i -x test_all.cmd)

.PHONY: all clean test



