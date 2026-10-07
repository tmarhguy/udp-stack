# Known Limitations

Honest boundaries: what the system is, and what it is not. This chapter overrides any optimistic reading of earlier chapters.

## What is real today

- RMII PHY + MDIO link detect (`link_up` on `LED[13]/[15]`, 50/100 MHz CDC).
- MAC RX preamble strip and TX preamble + FCS + IFG (`eth_mac_axis`).
- IPv4 header parse with dst-IP filter (`ip_rx`).
- UDP header parse with dst-port `50000` filter (`udp_rx`).
- Cut-through payload echo with 2-cycle sim latency (`loopback_echo`).
- Header rebuild with swapped src/dst (`stack_tx` + `axis_fifo`).
- Vivado 2025.2 bitstream with closed timing (WNS +1.985 ns @ 100 MHz).
- cocotb loopback + udp/ip/arp/mac gates in CI.
- Bench tools `send_udp.py` / `bench_check.py` with broadcast support.

## What is explicitly not here

- **ARP is a lab stub.** `eth_demux` detects ARP EtherType; `arp_cache` is single-entry. Dynamic lookup is not wired — pre-seed `HOST_MAC` in `top.sv` or use `255.255.255.255` broadcast for direct-cable tests.
- **ITCH parsing lives in `itch`.** Payload handling stops at echo here. Mold unwrap and order-book logic live in [itch](https://github.com/tmarhguy/itch).
- **UDP only.** TCP, DHCP, and ICMP packets are dropped. Non-UDP IPv4 raises `ip_error` and is dropped by design.
- **Checksums are minimal.** TX IP/UDP checksums are zero-filled lab values; RX does not validate header checksums beyond structure and filter.

## Limits to design around

- A packet is echoed if and only if it is IPv4 + UDP + dst-IP match + dst-port `50000`; everything else is dropped with `stack_error` pulsed.
- Published numbers are measured in this tree (2-cycle loopback, WNS +1.985 ns, 756 LUT / 599 FF / 0.115 W). Unmeasured values are `TBD (unmeasured)`.
- Same board, same PHY for `itch` — different payload handler above UDP. Replace `loopback_echo` with Mold/ITCH ingress; keep MAC → IP → UDP.
