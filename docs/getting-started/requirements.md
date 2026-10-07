# Requirements

What you need to simulate, build, and run the echo on the bench.

## Simulation

| Tool | Version / notes |
|------|-----------------|
| Python | 3.11+ (CI uses 3.11) |
| cocotb | `>= 1.9.0` via `sim/requirements.txt` |
| pytest | `>= 7.0.0` via `sim/requirements.txt` |
| HDL simulator | Icarus Verilog by default (`SIM` overridable); `run_tests.py` passes `-g2012` for Icarus |

Install simulation dependencies:

```bash
pip install -r sim/requirements.txt
```

No GNU make is required for simulation — [`sim/cocotb/run_tests.py`](https://github.com/tmarhguy/udp-stack/blob/main/sim/cocotb/run_tests.py) is the runner on all platforms (Windows-friendly, with an OSS CAD Suite `PATH` prime on `win32`).

## Synthesis and implementation

| Tool | Version / notes |
|------|-----------------|
| Xilinx Vivado | **2025.2** (synthesis, place and route, bitstream) |
| Part | `xc7a100tcsg324-1` (Nexys A7-100T) |
| Board | Digilent Nexys A7-100T |
| PHY | SMSC LAN8720A, RMII, lab UDP port **50000** |

The Vivado project lives in `core/` (`core.xpr`). All RTL is under `core/rtl/`; constraints are `core/constrs/nexys_a7_100t.xdc`.

## Bench

- Nexys A7 board + USB-JTAG/programming cable.
- Ethernet cable: PC ↔ **FPGA RJ45** (direct or via switch — not through a monitor passthrough).
- Host on `192.168.1.x` (`192.168.1.100` default) or use broadcast `255.255.255.255` for direct-cable tests without ARP.
- Plain Python 3 sockets for traffic scripts — no extra packages beyond the standard library.

## Documentation itself

Docs require only Python + MkDocs Material. No Node.js, no `package.json`, no frontend build:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-docs.txt
mkdocs serve --dev-addr localhost:8000
```

Next: [Building the Bitstream](build.md).
