COMPILER = ../../bin/compiler.py
ASSEMBLER = ../../bin/assembler.py
SIMULATOR = ../../bin/simulator.py
MONITOR = ../../bin/monitor.py

OUTPUT = $(TEST)/test_mul_f32.bin $(TEST)/test_leadingzeros.bin $(TEST)/test_add_f32.bin $(TEST)/test_div_f32.bin

MACROS = ../../bin/lib.S

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
	rm -f *.bin *.hex mul_f32.s div_f32.s add_f32.s

test:
	$(SIMULATOR) --mem 0x424:9 Test/test_leadingzeros.bin | grep '00000000,00000001,00000002,00000003,00000004,00000005,00000006,00000007,00000008,'
	$(SIMULATOR) --mem 0x46c:9 Test/test_leadingzeros.bin | grep '00000000,00000004,00000008,00000009,00000010,00000012,00000018,0000001c,00000020,'

testhard:
	$(MONITOR) -b115200 -i -x Test/test_all.cmd

.PHONY: all clean test testhard



