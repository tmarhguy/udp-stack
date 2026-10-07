# Journal and References

This site distinguishes two kinds of writing:

- **Reference documentation** — polished, current, organized by topic (Architecture, Verification, Reference). It describes the system as built.
- **Chronological engineering records** — dated logs preserved as written, showing how decisions were made at the time.

Do not read the log as a specification. Read it as the argument behind the specification.

## Entries

| Date | Entry | Topic |
|------|-------|-------|
| 2026-08-08 | [Understanding UDP and ITCH](2026-08-08-understanding-udp-itch.md) | Why UDP, TCP handshake cost, hardware advantage, multicast goal — the Wharton open-book origin |

The full journal directory in the repo is `log/`. Public long-form versions live at `tmarhguy.com/writing` (listed below).

## Companion repos and essays

- [NASDAQ ITCH hardware parser](https://github.com/tmarhguy/itch) — consumes this stack's payload stream.
- [itch-hw](https://github.com/tmarhguy/itch-hw) — earlier hardware parser reference.
- [Understanding the UDP Stack and Connecting to ITCH](https://www.tmarhguy.com/writing/2026-08-08-understanding-udp-stack-and-connecting-to-itch/) — TCP vs UDP for market data, public version of the log.
- [ITCH Ethernet lab bring-up](https://www.tmarhguy.com/writing/2026-08-01-itch-ethernet-lab-bring-up/) — cable, link LED, end-to-end bench goal.
- [ITCH synthesis / bitstream](https://www.tmarhguy.com/writing/2026-08-02-successful-synthesis-implementation-bitstream/) — first clean Vivado run (Aug 02, `itch` context).

## Doc map

| Doc | What's in it |
|-----|--------------|
| [UDP Stack at a Glance](../index.md) | Project identity, measured facts, status |
| [Introduction](../introduction.md) | Scope, reading order, conventions |
| [Architecture](../architecture/overview.md) … [Interfaces](../architecture/interfaces.md) | Datapath, layers, clocks, pins |
| [Bring-Up](../getting-started/build.md) | Requirements, Vivado build, bench run |
| [Verification](../verification/strategy.md) … [Implementation](../verification/results.md) | Gates, timing, utilization, power |
| [Known Limitations](../limitations.md) | Honest boundaries |
| [Repository Layout](../reference/repository.md) | Tree, truth vs docs, measurement sources |
| [`core/README.md`](https://github.com/tmarhguy/udp-stack/blob/main/core/README.md) | Vivado GUI project setup |
| `log/` | Design journal (this chapter's source) |

## How logs are kept

- Formatting may be cleaned up; meaning and chronology are preserved.
- Decisions are not rewritten as though they were obvious in hindsight.
- Measured numbers in logs point at their date; current numbers live in [Implementation](../verification/results.md).

!!! tip "Citing numbers"
    Cite reports by filename (`top_timing_summary_routed.rpt`) and screenshots by `media/` path so any reader can re-derive the numbers in [Implementation](../verification/results.md).
