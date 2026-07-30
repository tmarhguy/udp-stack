"""Run cocotb tests (Windows-friendly, no GNU make required)."""

from __future__ import annotations

import os
import sys
from pathlib import Path

from cocotb_tools.runner import get_runner


def _prime_oss_cad_path() -> None:
    if sys.platform != "win32":
        return
    oss_bin = Path(r"C:\Tools\oss-cad-suite\bin")
    if oss_bin.is_dir():
        os.environ["PATH"] = str(oss_bin) + os.pathsep + os.environ.get("PATH", "")


RTL_FILES = [
    "common/byte_cdc_fifo.sv",
    "common/axis_fifo.sv",
    "common/eth_crc32.sv",
    "phy/lan8720_mdio.sv",
    "phy/rmii_phy_if.sv",
    "mac/eth_mac_axis.sv",
    "arp/arp_cache.sv",
    "arp/eth_demux.sv",
    "ip/ip_rx.sv",
    "udp/udp_rx.sv",
    "stack/loopback_echo.sv",
    "stack/stack_tx.sv",
    "stack/udp_stack_core.sv",
]

SIM_RTL_FILES = [
    "hdl/udp_loopback_top.sv",
]

TEST_CONFIGS = {
    "loopback": {
        "toplevel": "udp_loopback_tb",
        "module": "test_loopback_perf",
        "sources": ["hdl/udp_loopback_tb.sv"],
    },
    "udp": {
        "toplevel": "udp_rx_tb",
        "module": "test_udp",
        "sources": ["hdl/udp_rx_tb.sv"],
    },
    "ip": {
        "toplevel": "ip_rx_tb",
        "module": "test_ip",
        "sources": ["hdl/ip_rx_tb.sv"],
    },
    "arp": {
        "toplevel": "arp_cache_tb",
        "module": "test_arp",
        "sources": ["hdl/arp_cache_tb.sv"],
    },
    "mac": {
        "toplevel": "eth_mac_axis_tb",
        "module": "test_mac_axis",
        "sources": ["hdl/eth_mac_axis_tb.sv"],
    },
}


def main() -> None:
    _prime_oss_cad_path()
    sim = os.environ.get("SIM", "icarus")
    test_name = os.environ.get("TEST", "loopback")
    cfg = TEST_CONFIGS[test_name]

    root = Path(__file__).resolve().parents[1]
    repo = root.parent
    rtl = repo / "core" / "rtl"

    sources = [root / s for s in cfg["sources"]]
    sources += [rtl / f for f in RTL_FILES]
    if test_name == "loopback":
        sources += [root / f for f in SIM_RTL_FILES]

    build_args = ["-g2012"] if sim == "icarus" else ["--timing", "-Wno-fatal"]
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=cfg["toplevel"],
        always=True,
        build_args=build_args,
    )
    runner.test(hdl_toplevel=cfg["toplevel"], test_module=cfg["module"])


if __name__ == "__main__":
    main()
