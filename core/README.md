# Vivado project setup (GUI)

Create the Vivado project **in this folder** (`core/`). All RTL lives in **`rtl/`** — one directory to add from the GUI.

## Folder layout

```
core/
  rtl/                  ← Design Sources (add directory)
  constrs/              ← Constraints (add file)
    nexys_a7_100t.xdc
```

---

## Step 1 — Create the project

1. **File → Project → New…**
2. Project name: e.g. `udp-stack`, location: **this `core/` folder**
3. **RTL Project**, check **Do not specify sources at this time** (easiest), Next
4. Part: **xc7a100tcsg324-1** (Nexys A7-100T), Finish

---

## Step 2 — Add RTL (Design Sources)

**Option A — Add the whole tree (recommended)**

1. In the **Sources** window, right-click **Design Sources** → **Add Sources…**
2. Select **Add or create design sources** → Next
3. Click **Add Directories** (not “Add Files”)
4. Browse to **`core/rtl`** (the `rtl` folder inside your project)
5. Vivado lists all **15** `.sv` files (including `rtl/common/seg7_display.sv` and `rtl/arp/arp_cache.sv`) — leave them all checked → Finish

**Option B — Add files one-by-one**

1. Same as above, but click **Add Files** instead of Add Directories
2. Open `rtl/`, Ctrl+A in each subfolder, or multi-select all `.sv` files → Finish

Vivado discovers module dependencies automatically; compile order does not need to be set by hand.

---

## Step 3 — Set the top module

1. In **Sources → Design Sources**, find **`top.sv`** (under `rtl`)
2. Right-click **`top.sv`** → **Set as Top**

Hierarchy should show `top` at the root with `udp_stack_core`, `eth_mac_axis`, `rmii_phy_if`, etc. underneath.

---

## Step 4 — Add constraints

Constraints map `top` ports to Nexys A7 pins and define the two clocks (100 MHz system, 50 MHz RMII).

1. In the **Sources** window, right-click **Constraints** → **Add Sources…**
2. Select **Add or create constraints** → Next
3. Click **Add Files**
4. Browse to **`core/constrs/nexys_a7_100t.xdc`** → OK → Finish
5. When asked, choose **Constrs** (not simulation) if Vivado prompts for a target

The file must stay paired with **`top`** — port names in the XDC match `top.sv` exactly (`CLK100MHZ`, `eth_refclk`, `LED[15:0]`, etc.).

| Constraint | Purpose |
|------------|---------|
| `CLK100MHZ` @ E3 | 100 MHz board clock (10 ns period) |
| `eth_refclk` @ D5 | 50 MHz RMII reference from PHY (20 ns period) |
| `set_clock_groups -asynchronous` | Treats system and RMII clocks as unrelated (required for CDC FIFO) |
| `rst` @ N17 | Center button (active high) |
| `LED[0:15]` | Status LEDs |
| `eth_*` | RMII + MDIO to LAN8720 PHY |

**Simulation note:** `sim_1` does not need this XDC unless you run implementation-aware sim. For RTL sim, you can leave constraints out of the simulation fileset (right-click the `.xdc` → **Move to Constraints** only, or disable **Used In** → Simulation in file properties).

---

## Step 5 — Build

1. **Run Synthesis** (or **Generate Bitstream** for the full flow)
2. Fix any errors in the Messages window; all modules should resolve from the `rtl/` tree

---

## Quick checklist

| Step | Action |
|------|--------|
| Project location | `core/` |
| Design sources | Add **directory** `rtl/` |
| Top module | `top` |
| Constraint file | `constrs/nexys_a7_100t.xdc` |
| Part | xc7a100tcsg324-1 |

## Output

Bitstream: `core/core.runs/impl_1/top.bit`

## After programming — quick board test

1. **LED[8]** should blink ~once per second (heartbeat — proves bitstream is running).
2. **LED[7:0]** mirror **SW[7:0]** — flip switches, LEDs follow.
3. **7-segment display** (right to left on board):
   - **Right 2 digits**: `SW[7:0]` in hex (`00` all off, `01` = SW0 up, `03` = SW0+SW1, `FF` = all 8 switches up)
   - **Next 2 digits left**: heartbeat counter (slowly increments)
   - **Left 4 digits**: `0000`
4. **LED[13]/[15]** turn on when Ethernet link is up (cable in **FPGA RJ45**, not monitor).

If segments stay pale/blank, re-synthesize after adding **`rtl/common/seg7_display.sv`** and the updated **`constraints/udp_consts.xdc`**.

## Ethernet (after board I/O works)

- Cable: PC ↔ **Nexys A7 Ethernet port** (direct or via switch — not through a monitor).
- PC IP: `192.168.1.100/24`, FPGA: `192.168.1.10`.
- Set `HOST_MAC` in `rtl/top.sv` to your PC's MAC address.
- Test: `python tools/send_udp.py --host 192.168.1.10 --port 50000`

