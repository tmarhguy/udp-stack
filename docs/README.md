# Documentation

![UDP](https://img.shields.io/badge/UDP-100%20Mbps%20stack-2563EB?style=for-the-badge)
![Nexys A7](https://img.shields.io/badge/Nexys_A7-100T-011F5B?style=for-the-badge)

Technical reference for the udp-stack repo. Story and bench photos: [README](../README.md). Design argument: [log/](../log/).

**See also:** [Understanding the UDP Stack and Connecting to ITCH](https://www.tmarhguy.com/writing/2026-08-08-understanding-udp-stack-and-connecting-to-itch/) · [itch](https://github.com/tmarhguy/itch)

| Doc | What's in it |
|-----|--------------|
| [architecture.md](architecture.md) | Datapath, modules, clocks |
| [metrics.md](metrics.md) | Timing, utilization, sim latency — sourced from reports |
| [board_setup.md](board_setup.md) | Program, cable, LEDs, traffic |
| [bitstream.md](bitstream.md) | Vivado build flow and output path |

<p align="center">
  <img src="../media/a7_running.gif" alt="Nexys A7 running on bench" width="50%" />
  <img src="../media/proj_summary.png" alt="Vivado project summary" width="47%" />
</p>

<p align="center"><em>Left: hardware on bench · Right: Vivado build summary (2026-08-10)</em></p>

Vivado GUI walkthrough: [core/README.md](../core/README.md)
