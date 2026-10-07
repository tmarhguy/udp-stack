# Implementation

Vivado build flow output and measured post-route behavior. Numbers below are copied from files in this repo — not estimated. Last Vivado build: **2026-08-10**, Vivado **2025.2**.

## Reports

Reports: `core/core.runs/impl_1/`

- Timing: `top_timing_summary_routed.rpt` — Design Timing Summary.
- Utilization: `top_utilization_placed.rpt` (post-place).
- Power: `top_power_routed.rpt`.

Screenshots: `media/proj_summary.png`, `media/dashboard.png`, `media/impl_device_design.png`, `media/synth_design.png` (copied into `docs/assets/` for this site).

## Timing @ 100 MHz

| Metric | Value |
|--------|-------|
| WNS | **+1.985 ns** |
| TNS | 0.000 ns |
| WHS | **+0.037 ns** |
| THS | 0.000 ns |
| Failing endpoints | 0 |

Timing closed at 100 MHz with ~2 ns of setup slack.

## Utilization — `xc7a100tcsg324-1`

| Resource | Used | Util% |
|----------|------|-------|
| Slice LUTs | 756 | 1.19% |
| Slice FFs | 599 | 0.47% |
| Bonded IOB | 52 | 24.76% |
| BUFG | 2 | 6.25% |

Vivado Project Summary rounds LUT/FF to **1%** and IO to **25%** — same build, coarser display. Light on fabric, heavy on I/O — exactly what a wire-facing stack should look like.

<figure>
  <img src="../assets/proj_summary.png" alt="Vivado Project Summary — WNS +1.985 ns, synthesis and implementation complete" />
  <figcaption>Vivado Project Summary — synthesis and implementation complete, WNS +1.985 ns.</figcaption>
</figure>

<figure>
  <img src="../assets/dashboard.png" alt="Vivado dashboard — utilization, timing, and power at a glance" />
  <figcaption>Vivado dashboard — utilization and timing at a glance (<code>synth_1</code> / <code>impl_1</code>).</figcaption>
</figure>

## Power

Source: `top_power_routed.rpt`

| Rail | Value |
|------|-------|
| Total on-chip (est.) | **0.115 W** |
| Dynamic | 0.018 W |
| Device static | 0.097 W |
| Junction (est.) | **25.5 °C** |

## Floorplan

Post-route floorplan — logic placement on Artix-7 fabric (same 2026-08-10 build):

<figure>
  <img src="../assets/impl_device_design.png" alt="Post-route device floorplan on Artix-7" />
  <figcaption>Implemented device — stack concentrated in left clock regions; I/O banks at package edges.</figcaption>
</figure>

The stack concentrates in left clock regions; I/O banks sit at the package edges. Package pinout (`eth_rxd/txd/mdc/mdio`) matches `top.sv` and `nexys_a7_100t.xdc` — see [Design](../architecture/design.md).

!!! note "Measurement rule"
    Numbers copied from another project do not belong here. If it was not measured in this tree, it is `TBD (unmeasured)`.

## Simulation latency

Payload loopback is budgeted and measured under [Verification](strategy.md): **2 cycles (20 ns)** against a ≤ 20-cycle budget, sourced from `sim/results/latency_summary.json`.

## Known limitations

Honest boundaries live in their own chapter: [Known Limitations](../limitations.md) — what is real today, what is explicitly not here, and what to design around. That chapter overrides any optimistic reading of the numbers above.
