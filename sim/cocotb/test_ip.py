import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

sys_path = __import__("os").path.join(__import__("os").path.dirname(__file__), "..", "python")
import sys

sys.path.insert(0, sys_path)
from eth_packets import build_ipv4_udp_packet


async def reset(dut):
    dut.rst.value = 1
    dut.s_axis_tvalid.value = 0
    dut.m_axis_tready.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


@cocotb.test()
async def test_ip_forward(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)

    frame = build_ipv4_udp_packet(
        "00:08:dc:12:34:56",
        "00:0a:35:00:00:01",
        "192.168.1.100",
        "192.168.1.10",
        40000,
        50000,
        b"z",
    )
    ip_udp = frame[14:]
    for i, b in enumerate(ip_udp):
        dut.s_axis_tdata.value = b
        dut.s_axis_tvalid.value = 1
        dut.s_axis_tlast.value = i == len(ip_udp) - 1
        await RisingEdge(dut.clk)
    dut.s_axis_tvalid.value = 0

    got = bytearray()
    for _ in range(60):
        await RisingEdge(dut.clk)
        if int(dut.m_axis_tvalid.value):
            got.append(int(dut.m_axis_tdata.value))
    assert b"z" in bytes(got)
