# Building the Bitstream

Synthesis → implementation → bitstream for the Nexys A7 UDP/IP stack. Full step-by-step GUI walkthrough lives in [`core/README.md`](https://github.com/tmarhguy/udp-stack/blob/main/core/README.md); this page is the short authoritative flow.

## Project

| Item | Value |
|------|-------|
| Toolchain | Vivado **2025.2** |
| Project file | `core/core.xpr` |
| Top module | `top` |
| RTL | `core/rtl/` (15 `.sv` files) |
| Constraints | `core/constrs/nexys_a7_100t.xdc` |
| Part | `xc7a100tcsg324-1` |
| Output | `core/core.runs/impl_1/top.bit` |

## GUI flow

1. **File → Project → New** in `core/`, RTL project, part `xc7a100tcsg324-1`. Checking **Do not specify sources at this time** keeps setup simplest.
2. **Add Sources → Add Directories → `core/rtl/`** (all 15 files stay checked, including `rtl/common/seg7_display.sv` and `rtl/arp/arp_cache.sv`). Vivado discovers module dependencies automatically; compile order does not need to be set by hand.
3. Set top: right-click `top.sv` → **Set as Top**. Hierarchy should show `top` at the root with `udp_stack_core`, `eth_mac_axis`, `rmii_phy_if`, and the rest underneath.
4. **Add Constraints → `core/constrs/nexys_a7_100t.xdc`**. The file must stay paired with `top` — port names match exactly (`CLK100MHZ`, `eth_refclk`, `LED[15:0]`, …).
5. **Run Synthesis** (or **Generate Bitstream** for the full flow). Fix any errors in the Messages window; all modules should resolve from the `rtl/` tree.

!!! note "Simulation fileset"
    `sim_1` does not need the XDC unless you run implementation-aware simulation. For RTL simulation, leave constraints out of the simulation fileset (right-click the `.xdc` → move to Constraints only, or disable **Used In → Simulation** in file properties).

## Output

```text
core/core.runs/impl_1/top.bit
```

<figure>
  <img src="../assets/hardware_manager.png" alt="Vivado Hardware Manager — top.bit programmed on xc7a100t_0" />
  <figcaption>Hardware Manager — <code>top.bit</code> from <code>core/core.runs/impl_1/</code> on <code>xc7a100t_0</code>.</figcaption>
</figure>

Post-route timing and utilization for this output: [Implementation](../verification/results.md) — WNS **+1.985 ns** @ 100 MHz (2026-08-10 build).

## Next

Program the board and send traffic: [Running on the Bench](running.md).
