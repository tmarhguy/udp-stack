# Architecture

![RMII](https://img.shields.io/badge/RMII-100%20Mbps-2563EB?style=for-the-badge)
![SystemVerilog](https://img.shields.io/badge/SystemVerilog-15%20files-311B92?style=for-the-badge)

RMII → MAC → L3/L4 stack → echo. Networking foundation for lab UDP on Nexys A7 — upstream of [itch](https://github.com/tmarhguy/itch) Mold/ITCH ingress.

**See also:** [README](../README.md) · [metrics](metrics.md) · [Understanding UDP & ITCH (log)](../log/2026-08-08%20-%20Understanding%20the%20UDP%20stack%20and%20connecting%20to%20ITCH.md) · [Writing — UDP & ITCH](https://www.tmarhguy.com/writing/2026-08-08-understanding-udp-stack-and-connecting-to-itch/)

---

## Hierarchy

| Role | Path |
|------|------|
| Board top | [`core/rtl/top.sv`](../core/rtl/top.sv) |
| Stack core | [`core/rtl/stack/udp_stack_core.sv`](../core/rtl/stack/udp_stack_core.sv) |
| Sim top | [`sim/hdl/udp_loopback_top.sv`](../sim/hdl/udp_loopback_top.sv) |

Synthesized hierarchy: `top` → `u_mdio`, `u_phy`, `u_mac`, `u_stack`, `u_seg7`.

<p align="center">
  <img src="../media/schematics_left.png" alt="Synthesized schematic (left)" width="47%" />
  <img src="../media/schematics_right.png" alt="Synthesized schematic (right)" width="50%" />
</p>

<p align="center"><em>RTL schematic — board I/O and PHY/MAC (left) · stack core and RMII egress (right)</em></p>

```
rmii_phy_if → eth_mac_axis → udp_stack_core → eth_mac_axis → rmii_phy_if
                              └─ loopback_echo → stack_tx
```

Inside `udp_stack_core`:

```
eth_demux → ip_rx → udp_rx → loopback_echo → axis_fifo → stack_tx
```

## Modules

| Layer | Module | Role |
|-------|--------|------|
| PHY | `rmii_phy_if`, `lan8720_mdio` | RMII byte stream, MDIO link status |
| L2 | `eth_mac_axis` | Preamble/FCS strip, CRC on TX |
| L2 demux | `eth_demux` | IPv4 forward; ARP ethertype detect |
| L3 | `ip_rx` | IPv4 header parse, dst-IP filter |
| L4 | `udp_rx` | UDP header parse, dst-port filter (`50000`) |
| App | `loopback_echo` | Cut-through payload echo + latency counter |
| TX | `stack_tx` | Rebuild Ethernet / IPv4 / UDP headers |
| ARP | `arp_cache` | Single-entry stub (lab: pre-seed host MAC in `top.sv`) |

## Behavior

- **RX:** MAC strips preamble/FCS; `eth_demux` forwards IPv4; `ip_rx` / `udp_rx` parse headers and filter port **50000**.
- **TX:** `loopback_echo` passes payload cut-through; `stack_tx` rebuilds headers with swapped src/dst.
- **ARP:** Detected in `eth_demux`; dynamic lookup not required for lab — set `HOST_MAC` in `top.sv`.

## Clocks

| Clock | Source | Period |
|-------|--------|--------|
| `CLK100MHZ` | Board oscillator | 10 ns (100 MHz) |
| `eth_refclk` | PHY RMII ref | 20 ns (50 MHz) |

Async clock groups: [`core/constrs/nexys_a7_100t.xdc`](../core/constrs/nexys_a7_100t.xdc).

RMII and MDIO pins on the `xc7a100tcsg324-1` package (implemented design view):

<p align="center">
  <img src="../media/synth_design.png" alt="Implemented package view — eth_rxd, eth_txd, eth_mdc, eth_mdio pinned" width="70%" />
</p>

<p align="center"><em>Package pinout — <code>eth_*</code> RMII/MDIO ports match <code>top.sv</code> and <code>nexys_a7_100t.xdc</code></em></p>

## Lab defaults

| Parameter | Value | Defined in |
|-----------|-------|------------|
| FPGA IP | `192.168.1.10` | `udp_stack_core` / `top.sv` |
| Host IP | `192.168.1.100` | `top.sv` (`HOST_IP`) |
| Host MAC | `00:08:DC:12:34:56` | `top.sv` (`HOST_MAC`) — set to your PC |
| UDP port | `50000` | `top.sv` (`UDP_PORT`) |
| Part | `xc7a100tcsg324-1` | Vivado project |

Broadcast (`255.255.255.255`) works for direct-cable tests without ARP.
