VERILATOR ?= verilator
TOP := tb_sync_fifo
RTL := rtl/sync_fifo.sv
TB := tb/tb_sync_fifo.sv tb/fifo_assertions.sv
DEPTH ?= 16
DATA_WIDTH ?= 8
SEED ?= 1
BUILD_DIR := sim/obj_d$(DEPTH)_w$(DATA_WIDTH)

.PHONY: test regression clean
test:
	$(VERILATOR) --binary --timing --assert -Wall -Wno-fatal --top-module $(TOP) -GDEPTH=$(DEPTH) -GDATA_WIDTH=$(DATA_WIDTH) --Mdir $(BUILD_DIR) $(RTL) $(TB)
	./$(BUILD_DIR)/V$(TOP) +verilator+seed+$(SEED)

regression:
	$(MAKE) test DEPTH=4 DATA_WIDTH=8 SEED=1
	$(MAKE) test DEPTH=16 DATA_WIDTH=8 SEED=7
	$(MAKE) test DEPTH=32 DATA_WIDTH=16 SEED=42

clean:
	rm -rf sim/obj_dir sim/obj_d*_w*
