import json
import os
import sys

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "python"))
from eth_packets import build_ipv4_udp_packet, iter_frame_bytes


HOST_MAC = "00:08:dc:12:34:56"
FPGA_MAC = "00:0a:35:00:00:01"
HOST_IP = "192.168.1.100"
FPGA_IP = "192.168.1.10"
PORT = 50000


def dut_core(dut):
    return dut.dut


async def reset_dut(dut):
    c = dut_core(dut)
    c.cfg_host_mac.value = int(HOST_MAC.replace(":", ""), 16)
    c.cfg_host_ip.value = int.from_bytes(bytes(map(int, HOST_IP.split("."))), "big")
    dut.rst.value = 1
    c.s_eth_tvalid.value = 0
    c.m_eth_tready.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


async def send_frame(dut, frame: bytes):
    c = dut_core(dut)
    for byte_val, is_last in iter_frame_bytes(frame):
        c.s_eth_tdata.value = byte_val
        c.s_eth_tlast.value = int(is_last)
        c.s_eth_tvalid.value = 1
        while True:
            await RisingEdge(dut.clk)
            if int(c.s_eth_tready.value):
                break
        c.s_eth_tvalid.value = 0
        await RisingEdge(dut.clk)


async def recv_frame(dut, max_cycles=500):
    c = dut_core(dut)
    data = bytearray()
    for _ in range(max_cycles):
        await RisingEdge(dut.clk)
        if int(c.m_eth_tvalid.value) and int(c.m_eth_tready.value):
            data.append(int(c.m_eth_tdata.value))
            if int(c.m_eth_tlast.value):
                return bytes(data)
    raise AssertionError("timeout waiting for echoed frame")


@cocotb.test()
async def test_udp_echo(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    payload = b"ping"
    frame = build_ipv4_udp_packet(
        HOST_MAC, FPGA_MAC, HOST_IP, FPGA_IP, 40000, PORT, payload
    )
    await send_frame(dut, frame)
    reply = await recv_frame(dut, max_cycles=2000)
    assert payload in reply


@cocotb.test()
async def test_loopback_perf(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    payload = b"xy"
    frame = build_ipv4_udp_packet(
        HOST_MAC, FPGA_MAC, HOST_IP, FPGA_IP, 40000, PORT, payload
    )
    await send_frame(dut, frame)

    c = dut_core(dut)
    lat_cycles = None
    for _ in range(2000):
        await RisingEdge(dut.clk)
        if int(c.latency_valid.value):
            lat_cycles = int(c.latency_cycles.value)
            break

    reply = await recv_frame(dut)
    assert payload in reply
    assert lat_cycles is not None, "latency_valid never asserted"
    assert lat_cycles <= 20, f"loopback latency {lat_cycles} cycles exceeds 20 (200 ns @ 100 MHz)"

    results = {
        "loopback_max_cycles": lat_cycles,
        "loopback_max_ns": lat_cycles * 10,
    }
    out = os.path.join(os.path.dirname(__file__), "..", "results", "latency_summary.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
