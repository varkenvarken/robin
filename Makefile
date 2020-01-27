SYN = yosys
PNR = nextpnr-ice40
GEN = icepack
PROG = iceprog 
ASSEMBLER = python3 assembler.py

TOP = robin.v
PCF = icebreaker.pcf
DEVICE = --up5k
PACKAGE = sg48
PLACER = sa # heap
PLACERLOG = placer.log
OUTPUT = $(patsubst %.v,%.bin,$(TOP))

all: $(OUTPUT)

%.bin: %.asc
	$(GEN) $< $@

%.asc: %.json $(PCF)
	$(PNR) $(DEVICE) --placer $(PLACER) --package $(PACKAGE) --quiet --log $(PLACERLOG) --json $< --pcf $(PCF) --asc $@

%.json: $(TOP) debounce.v fifo.v ram.v spram.v cpu.v alu.v divider.v $(PCF) rom.hex Makefile
	$(SYN) -q -p "read_verilog $<; hierarchy -libdir . ; synth_ice40 -dsp -flatten -json $@"

rom.hex: lib.S firmware.S
	$(ASSEMBLER) --hex $^ > $@

leading_zeros.hex: leading_zeros.py
	python3 $^ > $@

clean:
	rm -f *.bin *.blif *.tiles *.asc *.json rom.hex

flash: $(OUTPUT)
	$(PROG) $<

.PHONY: all clean flash
