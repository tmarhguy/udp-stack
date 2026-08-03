`timescale 1ns / 1ps

module udp_loopback_tb (
    input logic clk,
    input logic rst
);

  logic [47:0] cfg_host_mac;
  logic [31:0] cfg_host_ip;
  logic [ 7:0] s_eth_tdata, m_eth_tdata;
  logic        s_eth_tvalid, s_eth_tready, s_eth_tlast;
  logic        m_eth_tvalid, m_eth_tready, m_eth_tlast;
  logic [31:0] latency_cycles;
  logic        latency_valid, stack_error;

  udp_loopback_top dut (
      .clk            (clk),
      .rst            (rst),
      .cfg_host_mac   (cfg_host_mac),
      .cfg_host_ip    (cfg_host_ip),
      .s_eth_tdata    (s_eth_tdata),
      .s_eth_tvalid   (s_eth_tvalid),
      .s_eth_tready   (s_eth_tready),
      .s_eth_tlast    (s_eth_tlast),
      .m_eth_tdata    (m_eth_tdata),
      .m_eth_tvalid   (m_eth_tvalid),
      .m_eth_tready   (m_eth_tready),
      .m_eth_tlast    (m_eth_tlast),
      .latency_cycles (latency_cycles),
      .latency_valid  (latency_valid),
      .stack_error    (stack_error)
  );

endmodule
