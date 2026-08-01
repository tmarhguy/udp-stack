import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_mac_rx_axis(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    dut.phy_rx_valid.value = 0
    dut.m_axis_tready.value = 1
    dut.s_axis_tvalid.value = 0
    dut.phy_tx_ready.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    preamble = [0x55] * 7 + [0xD5]
    frame = preamble + [0xAA, 0xBB, 0xCC]
    for i, b in enumerate(frame):
        dut.phy_rx_byte.value = b
        dut.phy_rx_valid.value = 1
        dut.phy_rx_frame_end.value = int(i == len(frame) - 1)
        await RisingEdge(dut.clk)
    dut.phy_rx_valid.value = 0
    dut.phy_rx_frame_end.value = 0

    got = []
    for _ in range(20):
        await RisingEdge(dut.clk)
        if int(dut.m_axis_tvalid.value):
            got.append(int(dut.m_axis_tdata.value))
    assert 0xAA in got or 0xBB in got or 0xCC in got
    assert len(got) >= 1
