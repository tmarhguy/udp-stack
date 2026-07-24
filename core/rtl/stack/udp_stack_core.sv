// Integrated UDP/IP stack core with cut-through echo (sim + board).
`timescale 1ns / 1ps

module udp_stack_core #(
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

  logic [7:0] demux_data, ip_rx_data, udp_rx_data, echo_data, fifo_data;
  logic       demux_valid, ip_rx_valid, udp_rx_valid, echo_valid, fifo_valid;
  logic       demux_ready, ip_rx_ready, udp_rx_ready, echo_ready, fifo_ready;
  logic       demux_last, ip_rx_last, udp_rx_last, echo_last, fifo_last;
  logic [31:0] rx_src_ip;
  logic [15:0] tx_dst_port;
  logic        ip_meta, udp_meta, ip_err, udp_err;
  logic        pkt_start;
  logic [15:0] udp_total_len;
  logic [15:0] pay_cnt;

  eth_demux u_demux (
      .clk(clk), .rst(rst),
      .s_axis_tdata(s_eth_tdata), .s_axis_tvalid(s_eth_tvalid),
      .s_axis_tready(s_eth_tready), .s_axis_tlast(s_eth_tlast),
      .m_ip_tdata(demux_data), .m_ip_tvalid(demux_valid),
      .m_ip_tready(demux_ready), .m_ip_tlast(demux_last),
      .arp_seen(), .ip_seen()
  );

  ip_rx #(.LOCAL_IP(LOCAL_IP)) u_ip_rx (
      .clk(clk), .rst(rst),
      .s_axis_tdata(demux_data), .s_axis_tvalid(demux_valid),
      .s_axis_tready(demux_ready), .s_axis_tlast(demux_last),
      .m_axis_tdata(ip_rx_data), .m_axis_tvalid(ip_rx_valid),
      .m_axis_tready(ip_rx_ready), .m_axis_tlast(ip_rx_last),
      .m_src_ip(rx_src_ip), .m_dst_ip(), .m_meta_valid(ip_meta), .ip_error(ip_err)
  );

  udp_rx #(.DST_PORT(DST_PORT)) u_udp_rx (
      .clk(clk), .rst(rst),
      .s_axis_tdata(ip_rx_data), .s_axis_tvalid(ip_rx_valid),
      .s_axis_tready(ip_rx_ready), .s_axis_tlast(ip_rx_last),
      .m_axis_tdata(udp_rx_data), .m_axis_tvalid(udp_rx_valid),
      .m_axis_tready(udp_rx_ready), .m_axis_tlast(udp_rx_last),
      .m_src_port(tx_dst_port), .m_dst_port(), .m_meta_valid(udp_meta), .udp_error(udp_err)
  );

  loopback_echo u_echo (
      .clk(clk), .rst(rst),
      .s_axis_tdata(udp_rx_data), .s_axis_tvalid(udp_rx_valid),
      .s_axis_tready(udp_rx_ready), .s_axis_tlast(udp_rx_last),
      .m_axis_tdata(echo_data), .m_axis_tvalid(echo_valid),
      .m_axis_tready(echo_ready), .m_axis_tlast(echo_last),
      .latency_cycles(latency_cycles), .latency_valid(latency_valid)
  );

  axis_fifo #(.DEPTH(64)) u_pay_fifo (
      .clk(clk), .rst(rst),
      .s_axis_tdata(echo_data), .s_axis_tvalid(echo_valid),
      .s_axis_tready(echo_ready), .s_axis_tlast(echo_last),
      .m_axis_tdata(fifo_data), .m_axis_tvalid(fifo_valid),
      .m_axis_tready(fifo_ready), .m_axis_tlast(fifo_last)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      udp_total_len <= 16'd8;
      pay_cnt       <= '0;
      pkt_start     <= 1'b0;
    end else begin
      pkt_start <= 1'b0;
      if (udp_meta) pay_cnt <= '0;
      if (echo_valid && echo_ready) begin
        if (echo_last) begin
          udp_total_len <= pay_cnt + 16'd9;
          pkt_start     <= 1'b1;
        end
        pay_cnt <= pay_cnt + 16'd1;
      end
    end
  end

  stack_tx #(
      .LOCAL_PORT(DST_PORT),
      .LOCAL_MAC(LOCAL_MAC),
      .LOCAL_IP(LOCAL_IP)
  ) u_tx (
      .clk(clk), .rst(rst),
      .cfg_dst_mac(cfg_host_mac), .cfg_dst_ip(rx_src_ip),
      .cfg_dst_port(tx_dst_port), .cfg_udp_len(udp_total_len),
      .pkt_start(pkt_start),
      .s_axis_tdata(fifo_data), .s_axis_tvalid(fifo_valid),
      .s_axis_tready(fifo_ready), .s_axis_tlast(fifo_last),
      .m_axis_tdata(m_eth_tdata), .m_axis_tvalid(m_eth_tvalid),
      .m_axis_tready(m_eth_tready), .m_axis_tlast(m_eth_tlast)
  );

  assign stack_error = ip_err | udp_err;

endmodule
