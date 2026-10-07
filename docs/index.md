# 100 Mbps UDP/IP Stack

A SystemVerilog UDP/IPv4/Ethernet stack for the Digilent Nexys A7-100T — RMII PHY, MAC, cut-through echo, no CPU in the datapath.

NASDAQ's Mold-wrapped ITCH feed rides on UDP multicast. Before any parser sees a byte, the FPGA needs a wire-to-payload path: bring up the LAN8720 PHY over RMII, strip Ethernet framing, demux IPv4, parse IP and UDP, and hand payload bytes to application logic. This repository is that networking column — 15 SystemVerilog files covering the full RX-to-TX path — so [itch](https://github.com/tmarhguy/itch) can worry about messages instead of wondering how bytes got off the cable.

Today the proof point is a **UDP echo**: send a datagram to port `50000` and the FPGA returns it with **2-cycle** payload latency in simulation. Tomorrow the same MAC → IP → UDP spine plugs into `itch`'s Mold unwrap — same RJ45, different payload handler.

<figure>
  <img src="assets/a7_running.gif" alt="Nexys A7 on the bench — Ethernet in, heartbeat on 7-segment, link LED lit" />
  <figcaption>Nexys A7-100T · Artix-7 · Ethernet in, heartbeat on the 7-segment, link LED lit — the stack running on silicon.</figcaption>
</figure>

## Measured facts

Last Vivado build: **2026-08-10** · Vivado **2025.2** · part `xc7a100tcsg324-1`.

| Fact | Value |
|------|-------|
| UDP payload echo (`loopback_echo` @ 100 MHz) | **2 cycles (20 ns)** |
| Timing @ 100 MHz | **WNS +1.985 ns, WHS +0.037 ns, 0 failing endpoints** |
| Fabric | LUT 756 (1.19%), FF 599 (0.47%), IO 52 (24.8%), 0.115 W |

Sources: `sim/results/latency_summary.json`, `core/core.runs/impl_1/` reports. Full tables in [Implementation](verification/results.md).

## Where to go next

- [Introduction](introduction.md) — scope, reading order, and conventions.
- [Architecture](architecture/overview.md) — the RX-to-TX loop, datapath, and module hierarchy.
- [Building the Bitstream](getting-started/build.md) — Vivado GUI flow from `core/rtl/` to `top.bit`.
- [Running on the Bench](getting-started/running.md) — cable, `send_udp.py`, LEDs, bring-up checklist.
- [Verification](verification/strategy.md) — cocotb gates and how to re-run them.
- [Journal and References](engineering-log/index.md) — chronological design record, kept separate from reference material.

## Status

| Area | Status | Notes |
|------|--------|-------|
| RMII PHY + MDIO | Working | Link LED, 50/100 MHz CDC |
| MAC (RX/TX) | Working | Preamble strip, FCS on TX |
| IPv4 + UDP RX | Working | Port filter, header parse |
| Cut-through echo | Working | 2-cycle payload latency in sim |
| ARP | Lab stub | Pre-seed host MAC; `arp_cache` single-entry |
| Vivado bitstream | Clean | WNS +1.985 ns @ 100 MHz |
| itch integration | Next | Replace echo with Mold/ITCH ingress |

!!! tip "Reading order"
    Start with [Introduction](introduction.md), then [Architecture](architecture/overview.md). Each chapter is self-contained enough to enter directly from the numbered sidebar once the overview is familiar.
