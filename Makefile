VERILATOR ?= verilator
TOP := tb_sync_fifo
RTL := rtl/sync_fifo.sv
TB := tb/tb_sync_fifo.sv

.PHONY: test clean
test:
	$(VERILATOR) --binary --timing --assert -Wall -Wno-fatal --top-module $(TOP) --Mdir sim/obj_dir $(RTL) $(TB)
	./sim/obj_dir/V$(TOP)

clean:
	rm -rf sim/obj_dir
