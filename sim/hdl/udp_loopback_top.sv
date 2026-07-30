// Simulation top: thin wrapper around the board stack core.
`timescale 1ns / 1ps

module udp_loopback_top #(
    parameter int          DST_PORT  = 50000,
    parameter logic [47:0] LOCAL_MAC = 48'h00_0A_35_00_00_01,
    parameter logic [31:0] LOCAL_IP  = {8'd192, 8'd168, 8'd1, 8'd10}
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [47:0] cfg_host_mac,
    input  logic [31:0] cfg_host_ip,
    input  logic [ 7:0] s_eth_tdata,
    input  logic        s_eth_tvalid,
    output logic        s_eth_tready,
    input  logic        s_eth_tlast,
    output logic [ 7:0] m_eth_tdata,
    output logic        m_eth_tvalid,
    input  logic        m_eth_tready,
    output logic        m_eth_tlast,
    output logic [31:0] latency_cycles,
    output logic        latency_valid,
    output logic        stack_error
);

  udp_stack_core #(
      .DST_PORT (DST_PORT),
      .LOCAL_MAC(LOCAL_MAC),
      .LOCAL_IP (LOCAL_IP)
  ) u_stack (
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
