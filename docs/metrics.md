# Metrics

![Timing](https://img.shields.io/badge/WNS-%2B1.985_ns-2ea043?style=for-the-badge)
![Vivado](https://img.shields.io/badge/Vivado-2025.2-7C3AED?style=for-the-badge)

Numbers below are copied from files in this repo — not estimated. Last Vivado build: **2026-08-10**. Screenshots: `media/proj_summary.png`, `media/dashboard.png`.

**See also:** [README — at a glance](../README.md#at-a-glance) · [bitstream](bitstream.md)

---

## Simulation latency (cocotb)

Source: [`sim/results/latency_summary.json`](../sim/results/latency_summary.json) — written by `test_loopback_perf` in `sim/cocotb/test_loopback_perf.py`.

| Metric | Budget | Measured |
|--------|--------|----------|
| Payload loopback (`loopback_echo`) @ 100 MHz | ≤ 20 cycles (200 ns) | **2 cycles (20 ns)** |

Regenerate:

```bash
cd sim/cocotb && python run_tests.py
```

---

## Vivado post-route (2026-08-10)

Reports: `core/core.runs/impl_1/`

### Timing @ 100 MHz

Source: `top_timing_summary_routed.rpt` — Design Timing Summary

| Metric | Value |
|--------|-------|
| WNS | **+1.985 ns** |
| TNS | 0.000 ns |
| WHS | **+0.037 ns** |
| THS | 0.000 ns |
| Failing endpoints | 0 |

### Utilization — `xc7a100tcsg324-1`

Source: `top_utilization_placed.rpt` (post-place)

| Resource | Used | Util% |
|----------|------|-------|
| Slice LUTs | 756 | 1.19% |
| Slice FFs | 599 | 0.47% |
| Bonded IOB | 52 | 24.76% |
| BUFG | 2 | 6.25% |

Vivado Project Summary dashboard rounds LUT/FF to **1%** and IO to **25%** — same build, coarser display.

<p align="center">
  <img src="../media/proj_summary.png" alt="Vivado Project Summary — WNS +1.985 ns, synthesis and implementation complete" width="47%" />
  <img src="../media/dashboard.png" alt="Vivado dashboard — utilization and timing" width="50%" />
</p>

<p align="center"><em>Left: timing summary (WNS +1.985 ns) · Right: LUT 1%, FF 1%, IO 25%, power 0.115 W</em></p>

### Power

Source: `top_power_routed.rpt`

| | Value |
|---|---|
| Total on-chip (est.) | **0.115 W** |
| Dynamic | 0.018 W |
| Device static | 0.097 W |
| Junction temperature (est.) | **25.5 °C** |

Post-route floorplan — logic placement on Artix-7 fabric (same 2026-08-10 build):

<p align="center">
  <img src="../media/impl_device_design.png" alt="Post-route device floorplan" width="70%" />
</p>

<p align="center"><em>Implemented device — stack concentrated in left clock regions; I/O banks at package edges</em></p>
