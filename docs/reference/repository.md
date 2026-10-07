# Repository Layout

Where everything lives, what the measurement sources are, and how this manual relates to the README, logs, and companion repos.

## Tree

```text
udp-stack/
├── core/
│   ├── rtl/                  # 15 SystemVerilog sources (design truth)
│   ├── constrs/              # Pin + clock constraints (nexys_a7_100t.xdc)
│   ├── core.xpr              # Vivado project
│   └── README.md             # GUI setup walkthrough
├── sim/
│   ├── cocotb/               # run_tests.py + test_*.py gates
│   ├── hdl/                  # *_tb.sv testbenches + udp_loopback_top.sv
│   ├── python/               # eth_packets.py helpers
│   └── results/              # latency_summary.json (generated)
├── docs/                     # This site (MkDocs Material source)
├── log/                      # Design journal (chronological record)
├── media/                    # Bench photos, Vivado screenshots (figure source of truth)
└── tools/                    # send_udp.py, bench_check.py
```

## Design truth vs. documentation

| Path | Role |
|------|------|
| [`core/rtl/`](https://github.com/tmarhguy/udp-stack/tree/main/core/rtl) | Design truth — 15 `.sv` files |
| [`core/constrs/nexys_a7_100t.xdc`](https://github.com/tmarhguy/udp-stack/blob/main/core/constrs/nexys_a7_100t.xdc) | Pin + clock truth |
| [`sim/cocotb/`](https://github.com/tmarhguy/udp-stack/tree/main/sim/cocotb) | Verification truth |
| `core/core.runs/impl_1/` (gitignored, local) | Measurement truth (`*.rpt`, `top.bit`) |
| `docs/` | This manual — summarizes, never duplicates truth |
| `log/` | Chronological engineering record |

## Measurement sources

| Number | File |
|--------|------|
| WNS +1.985 ns, WHS +0.037 ns, 0 failing | `core/core.runs/impl_1/top_timing_summary_routed.rpt` |
| 756 LUT, 599 FF, 52 IOB, 2 BUFG | `core/core.runs/impl_1/top_utilization_placed.rpt` |
| 0.115 W, 25.5 °C | `core/core.runs/impl_1/top_power_routed.rpt` |
| 2 cycles (20 ns) loopback | `sim/results/latency_summary.json` |

Report directories are Vivado-generated and gitignored; screenshots in `media/` preserve the 2026-08-10 evidence.

For companion repos, essays, and the full doc map, see [Journal and References](../engineering-log/index.md).
