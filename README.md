# Parameterized Synchronous FIFO — RTL & Verification

SystemVerilog synchronous FIFO with a self-checking queue-based scoreboard, directed corner-case tests, randomized traffic, and GitHub Actions CI.

## Features
- Configurable data width and power-of-two depth (default: 8 bits x 16 entries)
- Full/empty flags and occupancy count
- Registered read output (no empty fall-through)
- Simultaneous read/write including the full boundary
- Automated simulation with Verilator

## Run
Install Verilator 5.x, make, and a C++ compiler. Then run:

```sh
make test
```

The testbench should print `PASS: ... checked cycles` when successful. **Initial commit has not yet been confirmed passing in CI.**

## Repository
- `rtl/` — FIFO RTL
- `tb/` — self-checking testbench
- `docs/verification_plan.md` — specification and verification matrix
- `sim/` — generated build outputs (ignored)
- `.github/workflows/ci.yml` — CI simulation

## Next milestones
1. Confirm CI and correct any simulator issues.
2. Test reset during traffic and multiple configurations.
3. Add SVA and functional coverage.
4. Document coverage, regressions, and waveform evidence.

**Status:** Initial implementation, not yet coverage-closed.
