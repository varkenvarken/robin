SYN = yosys
PNR = nextpnr-ice40
GEN = icepack
PROG = iceprog 

TOP = robin.v
PCF = icebreaker.pcf
DEVICE = --up5k
PACKAGE = sg48
PLACER = heap
PLACERLOG = placer.log
OUTPUT = $(patsubst %.v,%.bin,$(TOP))

all: $(OUTPUT)

%.bin: %.asc
	$(GEN) $< $@

%.asc: %.json $(PCF)
	$(PNR) $(DEVICE) --placer $(PLACER) --package $(PACKAGE) --quiet --log $(PLACERLOG) --json $< --pcf $(PCF) --asc $@

%.json: $(TOP) debounce.v fifo.v ram.v cpu.v alu.v divider.v $(PCF) Makefile
	$(SYN) -q -p "read_verilog $<; hierarchy -libdir . ; synth_ice40 -dsp -flatten -json $@"

clean:
	rm -f *.bin *.blif *.tiles *.asc *.json

flash: $(OUTPUT)
	$(PROG) $<

.PHONY: all clean flash
