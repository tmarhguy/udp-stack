# Bitstream build

![Vivado](https://img.shields.io/badge/Vivado-2025.2-7C3AED?style=for-the-badge)
![Artix-7](https://img.shields.io/badge/FPGA-xc7a100tcsg324--1-DC2626?style=for-the-badge)

Synthesis → implementation → bitstream for the Nexys A7 UDP/IP stack.

**See also:** [core/README.md](../core/README.md) (GUI walkthrough) · [metrics](metrics.md) · [board_setup](board_setup.md)

---

## Project

| | |
|---|---|
| Toolchain | Vivado **2025.2** |
| Project file | `core/core.xpr` |
| Top module | `top` |
| RTL | `core/rtl/` (15 `.sv` files) |
| Constraints | `core/constrs/nexys_a7_100t.xdc` |
| Part | `xc7a100tcsg324-1` |

## GUI flow

1. Open or create project in `core/`
2. **Add Sources** → directory `core/rtl/`
3. Set top: `top`
4. **Add Constraints** → `core/constrs/nexys_a7_100t.xdc`
5. Run synthesis → implementation → bitstream

Full step-by-step: [core/README.md](../core/README.md)

## Output

```
core/core.runs/impl_1/top.bit
```

<p align="center">
  <img src="../media/hardware_manager.png" alt="Vivado Hardware Manager — top.bit programmed on xc7a100t_0" width="65%" />
</p>

<p align="center"><em>Hardware Manager — <code>top.bit</code> from <code>core/core.runs/impl_1/</code> on <code>xc7a100t_0</code></em></p>

Post-route timing and utilization: [metrics.md](metrics.md) — WNS **+1.985 ns** @ 100 MHz (2026-08-10 build).

## Board test

```bash
python tools/send_udp.py --host 255.255.255.255 --port 50000
```

Bench details: [board_setup.md](board_setup.md)
