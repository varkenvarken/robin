VERILOG=iverilog
OUTPUT=clz_tb alu_tb divider_tb

all: $(OUTPUT)

clz_tb: ../clz.v clz_tb.v
	$(VERILOG) -o $@ $^ ; ./$@ | awk "/FATAL/{exit(1)}"

alu_tb: ../clz.v ../alu.v alu_tb.v
	$(VERILOG) -o $@ $^ ; ./$@ | awk "/FATAL/{exit(1)}"

divider_tb: ../divider.v divider_tb.v
	$(VERILOG) -o $@ $^ ; ./$@ | awk "/FATAL/{exit(1)}"

clean:
	rm *_tb

.PHONY: all clean $(OUTPUT)
