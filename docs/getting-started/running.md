# Running on the Bench

Program, cable, and traffic for the UDP echo.

## Program and cable

1. Program bitstream: `core/core.runs/impl_1/top.bit`.
2. Connect RJ-45 to the **FPGA Ethernet port**, not a monitor passthrough.
3. Host on `192.168.1.x` (`192.168.1.100` default) or use broadcast.

<figure>
  <img src="../assets/a7_running.gif" alt="Nexys A7 on bench — Ethernet in, link LED and 7-segment active" />
  <figcaption>Bench — RJ45 connected, power on, heartbeat on 7-segment, link LED lit near the Ethernet port.</figcaption>
</figure>

## Network defaults

From [`core/rtl/top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/top.sv) and [`core/rtl/stack/udp_stack_core.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/stack/udp_stack_core.sv):

| Field | Value |
|-------|-------|
| FPGA IP | `192.168.1.10` |
| Host IP | `192.168.1.100` |
| UDP port | `50000` |
| Host MAC | Set `HOST_MAC` in `top.sv` to your PC's MAC |

Direct cable without ARP — broadcast works:

```bash
python tools/send_udp.py --host 255.255.255.255 --port 50000
```

Targeted echo with a custom payload:

```bash
python tools/send_udp.py --host 192.168.1.10 --port 50000 --payload "echo-test"
```

Repeat a payload N times:

```bash
python tools/send_udp.py --host 192.168.1.10 --port 50000 --payload "bench" --repeat 10
```

Quick bench wrapper (broadcast `--host 255.255.255.255 --payload bench`):

```bash
python tools/bench_check.py
```

Both tools use plain UDP sockets with `SO_BROADCAST` and a 2 s reply timeout. `No reply (timeout)` means link, address, or bitstream needs checking — see the checklist below.

## LEDs

From [`core/rtl/top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/top.sv):

| LED | Meaning |
|-----|---------|
| `[7:0]` | Mirror `SW[7:0]` |
| `[8]`, `[14]` | Heartbeat (~1 Hz, `hb_led`) |
| `[9]` | RX activity pulse (5 M-cycle stretch) |
| `[10]` | TX activity pulse (5 M-cycle stretch) |
| `[11]` | Stack error (`ip_err \| udp_err`, 10 M-cycle stretch) |
| `[12]` | Latency-valid pulse (`latency_valid`) |
| `[13]`, `[15]` | PHY link up (`link_up` from MDIO) |

## 7-segment display

Right to left on the board (from `seg_value` in `top.sv`):

- **Right 2 digits:** `SW[7:0]` in hex.
- **Next 2 digits:** heartbeat counter (slowly increments each blink).
- **Left 4 digits:** `0000`.

## Bring-up checklist

1. Program bitstream → **LED[8]** blinks ~once per second.
2. Flip switches → **LED[7:0]** follow **SW[7:0]**; right 7-seg digits show hex.
3. Plug Ethernet → **LED[13]/[15]** on when link is up.
4. Send UDP → **LED[9]/[10]** pulse; `send_udp.py` prints `Reply … bytes`.

!!! tip "Blank segments"
    If segments stay pale, re-synthesize after confirming `rtl/common/seg7_display.sv` is in Design Sources. If no reply, check `HOST_MAC`, host subnet, and that the cable is in the FPGA jack.
