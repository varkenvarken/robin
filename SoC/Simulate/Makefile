VERILOG=iverilog
OUTPUT=clz_tb alu_tb

all: $(OUTPUT)

clz_tb: ../clz.v clz_tb.v
	$(VERILOG) -o $@ $^ ; vvp $@ | awk "/FATAL/{exit(1)}"

alu_tb: ../clz.v ../alu.v alu_tb.v
	$(VERILOG) -o $@ $^ ; vvp $@ | awk "/FATAL/{exit(1)}"

clean:
	rm *_tb

.PHONY: all clean $(OUTPUT)
