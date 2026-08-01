import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


async def reset(dut):
    dut.rst.value = 1
    dut.s_axis_tvalid.value = 0
    dut.m_axis_tready.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)


@cocotb.test()
async def test_port_filter(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)

    hdr = bytes([0x9C, 0x40, 0xC3, 0x50, 0x00, 0x08, 0x00, 0x00])
    payload = b"ab"
    stream = hdr + payload

    got = bytearray()
    for i, b in enumerate(stream):
        dut.s_axis_tdata.value = b
        dut.s_axis_tvalid.value = 1
        dut.s_axis_tlast.value = i == len(stream) - 1
        await RisingEdge(dut.clk)
        if int(dut.m_axis_tvalid.value):
            got.append(int(dut.m_axis_tdata.value))

    for _ in range(10):
        await RisingEdge(dut.clk)
        if int(dut.m_axis_tvalid.value):
            got.append(int(dut.m_axis_tdata.value))

    assert bytes(got) == payload
