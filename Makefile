VERILATOR ?= verilator
TOP := tb_sync_fifo
RTL := rtl/sync_fifo.sv
TB := tb/tb_sync_fifo.sv tb/fifo_assertions.sv
DEPTH ?= 16
DATA_WIDTH ?= 8
SEED ?= 1
BUILD_DIR := sim/obj_d$(DEPTH)_w$(DATA_WIDTH)
FLAGS := --timing --assert -Wall -Wno-fatal --top-module $(TOP) -GDEPTH=$(DEPTH) -GDATA_WIDTH=$(DATA_WIDTH)

.PHONY: test regression coverage waveform clean
test:
	$(VERILATOR) --binary $(FLAGS) --Mdir $(BUILD_DIR) $(RTL) $(TB)
	./$(BUILD_DIR)/V$(TOP) +verilator+seed+$(SEED)

regression:
	$(MAKE) test DEPTH=4 DATA_WIDTH=8 SEED=1
	$(MAKE) test DEPTH=16 DATA_WIDTH=8 SEED=7
	$(MAKE) test DEPTH=32 DATA_WIDTH=16 SEED=42

coverage:
	$(VERILATOR) --cc --exe --build -CFLAGS -DVL_TIME_CONTEXT $(FLAGS) --coverage --Mdir $(BUILD_DIR)_cov $(RTL) $(TB) $(abspath tb/coverage_main.cpp)
	mkdir -p sim/coverage
	rm -f sim/coverage/coverage.dat
	./$(BUILD_DIR)_cov/V$(TOP) +verilator+seed+$(SEED)
	test -s sim/coverage/coverage.dat
	@echo "Raw coverage evidence: sim/coverage/coverage.dat"

waveform:
	$(VERILATOR) --binary $(FLAGS) --trace --Mdir $(BUILD_DIR)_trace $(RTL) $(TB)
	mkdir -p sim
	rm -f sim/fifo_waveform.vcd
	./$(BUILD_DIR)_trace/V$(TOP) +verilator+seed+$(SEED) +trace
	test -s sim/fifo_waveform.vcd
	@echo "Waveform: sim/fifo_waveform.vcd (open with GTKWave)"

clean:
	rm -rf sim/obj_dir sim/obj_d*_w* sim/coverage sim/fifo_waveform.vcd
