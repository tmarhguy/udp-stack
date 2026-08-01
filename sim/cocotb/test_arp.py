import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_arp_cache_lookup(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    dut.learn_en.value = 0
    dut.lookup_ip.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    dut.learn_ip.value = 0xC0A80164
    dut.learn_mac.value = 0x0008DC123456
    dut.learn_en.value = 1
    await RisingEdge(dut.clk)
    dut.learn_en.value = 0

    dut.lookup_ip.value = 0xC0A80164
    await RisingEdge(dut.clk)
    assert int(dut.lookup_hit.value) == 1
    assert int(dut.lookup_mac.value) == 0x0008DC123456
