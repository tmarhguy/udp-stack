# Introduction

What the system is, what this manual covers, and how to navigate the rest of the document.

## Purpose

NASDAQ's Mold-wrapped ITCH feed rides on *UDP multicast*. Before any parser sees a byte, the FPGA needs a wire-to-payload path: bring up the LAN8720 PHY over RMII, strip Ethernet framing, demux IPv4, parse IP and UDP, and hand payload bytes to application logic.

This repo is that *networking column* — RMII PHY, MAC, IPv4, UDP, cut-through echo — so [itch](https://github.com/tmarhguy/itch) can worry about messages instead of wondering how bytes got off the cable. The design is 15 SystemVerilog files of dedicated logic covering the full RX-to-TX path.

Today the proof point is a *UDP echo*: send a datagram from the host, get it back on silicon with deterministic latency. Tomorrow the same MAC → IP → UDP spine plugs into `itch`'s Mold unwrap — same RJ45, different payload handler.

The fastest way to see what the system is: the bench figure in [UDP Stack at a Glance](index.md), and the loop in [Architecture](architecture/overview.md).

## Scope

The manual covers:

- datapath and module hierarchy ([Architecture](architecture/overview.md))
- per-layer behavior, clocks, and lab defaults ([Design](architecture/design.md))
- lab addresses, tools, LEDs, and 7-segment map ([Interfaces](architecture/interfaces.md))
- requirements, Vivado build, and bench bring-up ([Bring-Up](getting-started/build.md))
- simulation and correctness gates ([Verification](verification/strategy.md))
- post-route timing, utilization, and power ([Implementation](verification/results.md))
- honest limits and roadmap to `itch` ([Known Limitations](limitations.md))
- design journal, essays, and companion repos ([Journal and References](engineering-log/index.md))

It does not replace:

- `README.md` — project identity, quick start, bench photos
- [`core/README.md`](https://github.com/tmarhguy/udp-stack/blob/main/core/README.md) — Vivado GUI walkthrough
- `log/` — full design journal text
- Vivado reports under `core/core.runs/impl_1/` — measurement sources

## How to read this manual

Read chapters in order the first time. Chapters 1–2 give context; chapters 3–5 give the working model and bench use; chapters 6–7 give the evidence the stack behaves as claimed.

Each chapter is self-contained enough to be entered directly from the sidebar once the overview in [Architecture](architecture/overview.md) is familiar. The sidebar lists every chapter by number; select a chapter title to navigate.

## Conventions

- `monospace` marks commands, file paths, identifiers, and literals.
- Source file links point at the repository on GitHub, e.g. [`core/rtl/top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/top.sv).
- Measured numbers cite their report or log source. Unmeasured values are `TBD (unmeasured)` — never silently estimated.
- Unordered lists state properties or inventories. Ordered lists state procedures where sequence matters:
    1. Program the bitstream.
    2. Plug Ethernet and check link LEDs.
    3. Send UDP and watch RX/TX pulse.

!!! note "Honest status is a project rule"
    Roadmap items stay labelled roadmap; unverified claims stay out of this manual. Where a number has not been measured it is written `TBD (unmeasured)`.

!!! tip "Searching this manual"
    Press `/` anywhere to jump to search, or use the search box in the header.
