# Parameterized Synchronous FIFO — RTL & Verification

[![FIFO simulation](https://github.com/dhruvishv06/systemverilog-fifo-design-verification/actions/workflows/ci.yml/badge.svg)](https://github.com/dhruvishv06/systemverilog-fifo-design-verification/actions/workflows/ci.yml)

A hardware design verification portfolio project implementing a parameterized single-clock FIFO in synthesizable SystemVerilog, with a self-checking testbench, concurrent assertions, functional coverage, randomized regression, and CI.

## Design
- Parameterized DATA_WIDTH and power-of-two DEPTH (default 8-bit x 16-entry)
- Full/empty flags and occupancy count
- Registered read data; empty read does not fall through
- Simultaneous read/write supported, including the full boundary
- Active-low asynchronous reset of control state

## Verification
- Queue-based reference scoreboard checks ordering, data, flags and occupancy
- Directed boundary tests plus 2,000 randomized cycles per configuration
- Reset tests while buffered and while full
- Concurrent SystemVerilog Assertions (SVA) for state invariants and occupancy transitions
- Functional coverage: all 12 occupancy x operation bins required for PASS
- CI matrix: depth 4/16/32 and data width 8/8/16
- Code coverage instrumentation and VCD waveform generation

## Run locally
Requirements: Verilator 5.x, GNU Make, C++ compiler.

```sh
make test
make regression
make coverage
make waveform
```

`make coverage` produces `sim/coverage/coverage.info` and annotated sources.
`make waveform` produces `sim/fifo_waveform.vcd`, viewable in GTKWave.

CI also uploads **fifo-verification-evidence** as a downloadable artifact from the latest successful Actions run. Generated evidence is intentionally not committed to the repository.

## Project map
| Path | Purpose |
| --- | --- |
| `rtl/sync_fifo.sv` | FIFO implementation |
| `tb/tb_sync_fifo.sv` | Stimulus, scoreboard, functional coverage, reset tests |
| `tb/fifo_assertions.sv` | SVA checker |
| `docs/verification_plan.md` | Requirements, verification matrix, limitations |
| `Makefile` | Reproducible local simulations |
| `.github/workflows/ci.yml` | CI regression and evidence upload |

## Status and limitations
Earlier baseline CI passed. **The latest reset/coverage/waveform enhancements require confirmation from their new CI run.** The 12-bin functional metric is not equivalent to RTL code coverage or formal proof. This is a lightweight non-UVM simulation environment.
