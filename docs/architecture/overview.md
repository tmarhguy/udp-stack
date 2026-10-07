# Architecture

What the pieces are, how packets flow in and back out, and where each piece lives in the tree.

## The loop

Every lab session runs the same story. The full RX-to-TX arc runs on one FPGA.

```text
  HOST IN              STACK                 HOST OUT
  ───────              ─────                 ────────
  UDP datagram    →    RMII RX → MAC    →    UDP reply
  port 50000           IP → UDP → echo       (swapped hdrs)
```

1. **Wire in.** Live traffic hits the on-board **LAN8720** PHY. RMII RX, IPv4 filter, UDP port match — payload bytes reach `loopback_echo` without a CPU `memcpy`.
2. **Echo.** Cut-through forwarding rebuilds Ethernet + IPv4 + UDP headers with swapped addresses. Latency instrumentation reports cycle count on `LED[12]`.
3. **Wire out.** Reply leaves through the same MAC and PHY. `LED[9]` / `LED[10]` pulse on RX/TX; `LED[13]` / `LED[15]` show link up. The 7-segment and switch-mirrored LEDs tell you the bitstream is alive before you ever send a packet.

## Datapath

```text
RMII PHY ──► eth_mac_axis ──► eth_demux ──► ip_rx ──► udp_rx ──► loopback_echo
                                                                     │
                                                               stack_tx ◄──┘
                                                                     │
                                                          eth_mac_axis ──► RMII PHY
```

Inside `udp_stack_core`:

```text
eth_demux → ip_rx → udp_rx → loopback_echo → axis_fifo → stack_tx
```

### Hierarchy

| Role | Path |
|------|------|
| Board top | [`core/rtl/top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/top.sv) |
| Stack core | [`core/rtl/stack/udp_stack_core.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/stack/udp_stack_core.sv) |
| Sim top | [`sim/hdl/udp_loopback_top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/sim/hdl/udp_loopback_top.sv) |

Synthesized hierarchy: `top` → `u_mdio`, `u_phy`, `u_mac`, `u_stack`, `u_seg7`.

<figure>
  <img src="../assets/schematics_left.png" alt="Synthesized RTL schematic (left) — board I/O and PHY/MAC ingress" />
  <figcaption>RTL schematic, left — board I/O and PHY/MAC ingress.</figcaption>
</figure>

<figure>
  <img src="../assets/schematics_right.png" alt="Synthesized RTL schematic (right) — UDP stack core and RMII egress" />
  <figcaption>RTL schematic, right — <code>u_stack</code>, 7-segment, and RMII egress.</figcaption>
</figure>

## Further reading

- [Design](design.md) — per-layer behavior behind each box above.
- [Interfaces](interfaces.md) — lab addresses, tools, LEDs, and pin constraints.
- [Verification](../verification/strategy.md) — how the loop is proven in simulation before the bitstream is trusted.
