# Verification

How the project proves the stack is correct — and how to re-run that proof locally. Simulation comes first: the bitstream is trusted only after the loopback passes.

## Testbench map

| Gate | Toplevel | Python driver |
|------|----------|---------------|
| loopback (default) | `udp_loopback_tb` | `sim/cocotb/test_loopback_perf.py` |
| udp | `udp_rx_tb` | `sim/cocotb/test_udp.py` |
| ip | `ip_rx_tb` | `sim/cocotb/test_ip.py` |
| arp | `arp_cache_tb` | `sim/cocotb/test_arp.py` |
| mac | `eth_mac_axis_tb` | `sim/cocotb/test_mac_axis.py` |

HDL testbenches live in `sim/hdl/`; packet helpers in `sim/python/eth_packets.py`; the runner is [`sim/cocotb/run_tests.py`](https://github.com/tmarhguy/udp-stack/blob/main/sim/cocotb/run_tests.py) (Icarus by default, `SIM` overridable, Windows-friendly with no GNU make).

The runner selects the gate from `TEST_CONFIGS`:

```python
TEST_CONFIGS = {
    "loopback": {"toplevel": "udp_loopback_tb", ...},
    "udp":      {"toplevel": "udp_rx_tb", ...},
    "ip":       {"toplevel": "ip_rx_tb", ...},
    "arp":      {"toplevel": "arp_cache_tb", ...},
    "mac":      {"toplevel": "eth_mac_axis_tb", ...},
}
```

## Running the gates

Default loopback gate:

```bash
cd sim/cocotb
pip install -r ../requirements.txt
python run_tests.py
```

Unit gates (same as CI):

```bash
cd sim/cocotb
TEST=udp python run_tests.py
TEST=ip  python run_tests.py
TEST=arp python run_tests.py
TEST=mac python run_tests.py
```

This is the same gate CI runs on every push (`.github/workflows/ci.yml`): install Icarus + requirements, run loopback, run the four unit gates, upload `sim/results/latency_summary.json`.

=== "Default"

    ```bash
    cd sim/cocotb && python run_tests.py
    ```

=== "All gates (CI order)"

    ```bash
    cd sim/cocotb
    python run_tests.py
    TEST=udp python run_tests.py
    TEST=ip  python run_tests.py
    TEST=arp python run_tests.py
    TEST=mac python run_tests.py
    ```

## Correctness properties

| Property | Where it is checked |
|----------|---------------------|
| UDP payload echo preserves bytes and `tlast` | loopback perf test |
| IP drops non-UDP and wrong dst-IP with `ip_error` | `test_ip` |
| UDP drops wrong dst-port with `udp_error` | `test_udp` |
| ARP single-entry behavior | `test_arp` |
| MAC strips preamble, forwards frame, appends FCS | `test_mac_axis` |

`stack_error = ip_err | udp_err` is the single board-visible error aggregate (see [Interfaces](../architecture/interfaces.md)).

## Latency budget

Source: `sim/results/latency_summary.json` — written by `test_loopback_perf`.

| Metric | Budget | Measured |
|--------|--------|----------|
| Payload loopback (`loopback_echo`) @ 100 MHz | ≤ 20 cycles (200 ns) | **2 cycles (20 ns)** |

```json
{
  "loopback_max_cycles": 2,
  "loopback_max_ns": 20
}
```

Regenerate with `cd sim/cocotb && python run_tests.py`. Wire-level confirmation is `LED[12]` pulsing per packet on the bench.

!!! tip "Adding header features"
    When adding a header feature, add the drop-path test first. A failing unit test is the specification; a passing one is the proof.

Next: [Implementation](results.md) for post-route timing, utilization, and power.
