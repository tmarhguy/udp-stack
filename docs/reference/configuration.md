# Configuration

Single place for every lab knob: what it is, what it defaults to, and where it is defined. Edit the source, rebuild, reprogram.

## Lab defaults

| Parameter | Value | Defined in |
|-----------|-------|------------|
| FPGA IP | `192.168.1.10` | `udp_stack_core.LOCAL_IP` / `stack_tx.LOCAL_IP` |
| FPGA MAC | `00:0A:35:00:00:01` | `stack_tx.LOCAL_MAC` |
| Host IP | `192.168.1.100` | [`core/rtl/top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/top.sv) (`HOST_IP`) |
| Host MAC | `00:08:DC:12:34:56` | [`core/rtl/top.sv`](https://github.com/tmarhguy/udp-stack/blob/main/core/rtl/top.sv) (`HOST_MAC`) — set to your PC |
| UDP port | `50000` | `top.UDP_PORT` → `DST_PORT` |
| Part | `xc7a100tcsg324-1` | Vivado project in `core/` |
| Clocks | 100 MHz system / 50 MHz RMII ref | [`core/constrs/nexys_a7_100t.xdc`](https://github.com/tmarhguy/udp-stack/blob/main/core/constrs/nexys_a7_100t.xdc) |

Broadcast (`255.255.255.255`) works for direct-cable tests without ARP.

## Editing host identity

Before building for a new host, update the pre-seeded values in `top.sv`:

```systemverilog
localparam logic [47:0] HOST_MAC = 48'h00_08_DC_12_34_56;
localparam logic [31:0] HOST_IP  = {8'd192, 8'd168, 8'd1, 8'd100};
```

Then rebuild per [Building the Bitstream](../getting-started/build.md) and re-test per [Running on the Bench](../getting-started/running.md):

```bash
python tools/send_udp.py --host 192.168.1.10 --port 50000 --payload "echo-test"
```

## Constraints

| Constraint | Purpose |
|------------|---------|
| `CLK100MHZ` @ E3 | 100 MHz board clock (10 ns period) |
| `eth_refclk` @ D5 | 50 MHz RMII reference from PHY (20 ns period) |
| `set_clock_groups -asynchronous` | Treats system and RMII clocks as unrelated (required for CDC FIFO) |
| `rst` @ N17 path via `CPU_RESETN` @ C12 | Center-button reset |
| `LED[0:15]`, `SW[15:0]` | Status and switches |
| `eth_*` | RMII + MDIO to LAN8720 PHY |

!!! caution "Build truth"
    `core/constrs/nexys_a7_100t.xdc` is the constraint used for the measured build. `constraints/udp_consts.xdc` is a legacy copy and is not referenced by the Vivado flow.
