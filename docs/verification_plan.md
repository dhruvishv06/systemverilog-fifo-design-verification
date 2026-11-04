# FIFO Verification Plan (v0.1)

## Scope
Single-clock, first-in-first-out buffer. DATA_WIDTH defaults to 8; DEPTH defaults to 16 and must be a power of two >= 2. Asynchronous active-low reset clears control state and read data, not the memory array.

## Interface contract
- Write accepted when `wr_en && (!full || do_read)`.
- Read accepted when `rd_en && !empty`.
- A simultaneous read/write on full is accepted for both operations.
- A simultaneous read/write on empty accepts only the write (no fall-through).
- `rd_data` updates on accepted reads and otherwise holds its previous value.
- `count` represents occupancy; `full` and `empty` are combinational flags.

## Verification matrix
| ID | Requirement | Test | Status |
| --- | --- | --- | --- |
| F01 | Reset empties FIFO | Startup reset | Implemented |
| F02 | FIFO ordering | Queue scoreboard | Implemented |
| F03 | Full rejects write-only | Directed full write | Implemented |
| F04 | Empty rejects read | Directed empty read | Implemented |
| F05 | Simultaneous full read/write | Directed boundary case | Implemented |
| F06 | Random traffic integrity | 2,000 seeded-by-simulator cycles | Implemented |
| F07 | Reset during traffic | Mid-traffic reset | Planned |
| F08 | Multiple parameter configurations | CI matrix | Planned |
| F09 | Functional coverage closure | Occupancy and operation crosses | Planned |
| F10 | SVA protocol/invariant checks | Assertion module | Planned |

## Closure criteria (future)
All directed tests pass; randomized regressions pass with documented seeds; functional coverage targets are defined and measured; lint and CI pass. No coverage percentage is claimed yet.

## Limitations
This is a functional simulation testbench, not UVM. Verilator compatibility and successful execution must be confirmed in CI or locally. This project does not implement an asynchronous FIFO or CDC verification.
