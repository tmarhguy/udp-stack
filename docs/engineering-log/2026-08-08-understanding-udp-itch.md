# 2026-08-08 — Understanding the UDP Stack and Connecting to ITCH

*Preserved from `log/2026-08-08 - Understanding the UDP stack and connecting to ITCH.md`. Formatting cleaned; meaning and chronology preserved.*

In my personal exploration (shoutouts to my Wharton folks), I have learned the need for both the **ITCH protocol** and a **UDP stack**. **`TCP`** is not your friend if speed is your goal. **`TCP`** has the three-way handshake protocol, which, for its own good, severely limits rapid data transmission.

**`UDP`**, however, couldn't care less if you received the full data or not; it serves to inject real-time data with the least latency. For first-time engineers in the trading field, the goal is to fire the latest open book data and make live decisions on buying low and selling high.

---

## The Hardware Advantage

Processing **ITCH feeds** on a standard Von Neumann CPU is bottlenecked by the operating system's networking stack and the latency of mandatory data movement across the memory bus.

Parsing ITCH in hardware solves that by placing an **FPGA** in the loop instead of relying on **PCIe** bottlenecks and OS interrupts. This way, baked logic can make deterministic decisions in **nanoseconds**, and only inform the "slow" yet powerful CPU when necessary.

---

## The Next Hurdle: The Networking Stack

How does **`itch-hw`**, for instance, receive the data?

### The `TCP` Overhead

**`TCP`** uses a three-way handshake. All of this overhead costs bits, and thus adds latency or reduces throughput across a fixed benchmark:

1. **`A → B`** sends `SYN`
2. **`B → A`** sends `SYN-ACK`
3. **`A → B`** sends `ACK`

Additionally, 100 computers communicating via **`TCP`** with a server means the server needs to acknowledge each of them, and that overhead grows exponentially for **1000s of computers**.

| Protocol | Priority | Analogy | Data Integrity |
|----------|----------|---------|----------------|
| **`TCP`** | Reliability | Downloading a file | Ensures packet order and maintains all data. Network interruptions pause downloads, never dropping data. |
| **`UDP`** | Speed & Recency | Live video call | Drops lagging frames. Always pushes the absolute latest data, ignoring missing packets. |

### The Goal

**`UDP` multicast** is the answer. If the network lags, we don't want an old frame loaded again. We always want the **absolute latest data**. But someone's got to build that hardware parser, and that's exactly what this project is for:

> **A custom UDP stack on my FPGA board!**
