# FIFO Verification Plan (v0.3)

## Interface contract
Single-clock FIFO with DATA_WIDTH > 0 and power-of-two DEPTH >= 2. Active-low asynchronous reset clears pointers, occupancy, and read output, but not RAM contents.

- Accepted read: `rd_en && !empty`
- Accepted write: `wr_en && (!full || accepted_read)`
- At empty, simultaneous requests accept only write
- At full, simultaneous requests accept both
- Registered `rd_data` changes on accepted reads and holds otherwise

## Verification matrix
| ID | Requirement | Test | Implementation |
| --- | --- | --- | --- |
| F01 | Startup reset | Directed | Done |
| F02 | FIFO ordering | Queue scoreboard | Done |
| F03 | Full write rejected | Directed | Done |
| F04 | Empty read rejected | Directed | Done |
| F05 | Simultaneous read/write at full | Directed | Done |
| F06 | Simultaneous read/write at empty | Directed | Done |
| F07 | Randomized traffic | 2,000 cycles/config | Done |
| F08 | Parameter configurations | CI depth 4/16/32, width 8/16 | Done |
| F09 | Occupancy x operation coverage | 3 x 4 cross; all bins required | Done |
| F10 | Count/flag invariants | Concurrent SVA | Done |
| F11 | Reset during traffic and full | Asynchronous reset, model cleared | Done |
| F12 | Code coverage | Verilator --coverage report | Instrumented; inspect report |
| F13 | Waveform evidence | Verilator --trace VCD | Instrumented; inspect artifact |

## Functional coverage
Occupancy bins: empty, partially occupied, full. Operation bins: idle, write-only, read-only, simultaneous. The testbench prints 12 hit counts and fails if any bin is unhit. This is manual functional coverage instrumentation, not a SystemVerilog covergroup.

## Code coverage
Run `make coverage`. Verilator creates `sim/coverage/coverage.dat`, an annotated source directory, and LCOV-compatible `coverage.info`. **No code coverage percentage is claimed until results are inspected.** Coverage measures exercised code, not verification completeness.

## Waveform
Run `make waveform` to generate `sim/fifo_waveform.vcd`. Inspect `clk`, `rst_n`, `wr_en`, `rd_en`, `wr_data`, `rd_data`, `count`, `full`, and `empty` in GTKWave.

## CI closure
All three regression configurations must pass. The 16x8 job must also produce coverage and waveform artifacts. Reproducibility uses explicitly recorded seeds 1, 7, and 42.

## Known limitations
No UVM, formal exhaustive proof, CDC (this is synchronous), or code-coverage threshold enforcement. The testbench uses a reference queue rather than an independent cycle-accurate RTL implementation.
