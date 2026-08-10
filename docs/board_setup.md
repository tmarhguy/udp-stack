# Board setup (Nexys A7)

![Nexys A7](https://img.shields.io/badge/Nexys_A7-100T-011F5B?style=for-the-badge)
![UDP](https://img.shields.io/badge/UDP-port%2050000-2563EB?style=for-the-badge)

Program, cable, and traffic for the udp-stack echo on the bench.

**See also:** [README — Run it](../README.md#run-it) · [bitstream](bitstream.md) · [metrics](metrics.md)

---

## Steps

1. Program bitstream: `core/core.runs/impl_1/top.bit`
2. Connect RJ-45 to host or switch — use the **FPGA Ethernet port**, not a monitor passthrough
3. Host on `192.168.1.x` or use broadcast

<p align="center">
  <img src="../media/a7_running.gif" alt="Nexys A7 on bench — Ethernet in, link LED and 7-segment active" width="70%" />
</p>

<p align="center"><em>Bench — RJ45 connected, power on, heartbeat on 7-segment, link LED lit near Ethernet port</em></p>

## Network defaults

From [`core/rtl/top.sv`](../core/rtl/top.sv) and [`core/rtl/stack/udp_stack_core.sv`](../core/rtl/stack/udp_stack_core.sv):

| | Value |
|---|---|
| FPGA IP | `192.168.1.10` |
| Host IP | `192.168.1.100` |
| UDP port | `50000` |
| Host MAC | Set `HOST_MAC` in `top.sv` to your PC's MAC |

Direct cable without ARP — broadcast works:

```bash
python tools/send_udp.py --host 255.255.255.255 --port 50000
```

Targeted echo:

```bash
python tools/send_udp.py --host 192.168.1.10 --port 50000 --payload "echo-test"
```

Quick bench wrapper:

```bash
python tools/bench_check.py
```

## LEDs

From [`core/rtl/top.sv`](../core/rtl/top.sv):

| LED | Meaning |
|-----|---------|
| `[7:0]` | Mirror `SW[7:0]` |
| `[8]`, `[14]` | Heartbeat (~1 Hz) |
| `[9]` | RX activity pulse |
| `[10]` | TX activity pulse |
| `[11]` | Stack error |
| `[12]` | Latency-valid pulse |
| `[13]`, `[15]` | PHY link up |

## 7-segment display

Right to left on the board:

- **Right 2 digits:** `SW[7:0]` in hex
- **Next 2 digits:** heartbeat counter (slowly increments)
- **Left 4 digits:** `0000`

## Bring-up checklist

1. Program bitstream → **LED[8]** blinks ~once per second
2. Flip switches → **LED[7:0]** follow **SW[7:0]**
3. Plug Ethernet → **LED[13]/[15]** on when link is up
4. Send UDP → **LED[9]/[10]** pulse; `send_udp.py` prints reply

Vivado project setup: [core/README.md](../core/README.md)
