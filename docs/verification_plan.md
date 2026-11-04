# FIFO Verification Plan (v0.2)

## Specification
Single-clock FIFO with parameterized DATA_WIDTH and power-of-two DEPTH >= 2.
Active-low asynchronous reset clears pointers, count, and read output (not memory).
Accepted read: `rd_en && !empty`.
Accepted write: `wr_en && (!full || accepted_read)`.
On empty, simultaneous requests accept only the write (no fall-through).
On full, simultaneous requests accept both. Read data is registered and holds otherwise.

## Test matrix
| ID | Feature | Method | Status |
| --- | --- | --- | --- |
| F01 | Startup reset | Directed | Implemented |
| F02 | Data order/integrity | Queue scoreboard | Implemented |
| F03 | Full write rejection | Directed | Implemented |
| F04 | Empty read rejection | Directed | Implemented |
| F05 | Simultaneous read/write at full | Directed | Implemented |
| F06 | Simultaneous read/write at empty | Directed | Implemented |
| F07 | Random operations | 2,000 cycles/config | Implemented |
| F08 | Configurations | Depth 4/16/32, width 8/16 CI | Implemented |
| F09 | Occupancy x operation coverage | 3 x 4 cross, all bins required | Implemented |
| F10 | Invariants and count transition | Concurrent SVA checker | Implemented |
| F11 | Reset during traffic | Directed | Planned |
| F12 | Code coverage | Tool-generated report | Planned |

## Coverage model
Occupancy bins: empty, partially occupied, full. Operation bins: idle, write-only, read-only, simultaneous request. Cross: 12 bins; every bin must be hit for simulation to pass. This is manual functional coverage instrumentation, **not** a SystemVerilog covergroup or RTL code coverage report.

## Assertions
Clocked SVA checks occupancy range, full/empty flag correctness, mutual exclusion, and previous-cycle count transitions. The scoreboard separately checks data order and output flags.

## Regression
Run `make regression` locally, or use the GitHub Actions matrix. Seeds are recorded in the matrix. These are simulation checks only, not formal verification.

## Known gaps
No reset-during-traffic test, code coverage closure, or exhaustive state-space proof yet. A passing test does not imply bug-free hardware.
