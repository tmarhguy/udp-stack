`timescale 1ns / 1ps

module ip_rx_tb (input logic clk, input logic rst);
  logic [7:0] s_axis_tdata, m_axis_tdata;
  logic       s_axis_tvalid, s_axis_tready, s_axis_tlast;
  logic       m_axis_tvalid, m_axis_tready, m_axis_tlast;
  logic [31:0] m_src_ip, m_dst_ip;
  logic        m_meta_valid, ip_error;

  ip_rx dut (
      .clk(clk), .rst(rst),
      .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid),
      .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast),
      .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
      .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
      .m_src_ip(m_src_ip), .m_dst_ip(m_dst_ip),
      .m_meta_valid(m_meta_valid), .ip_error(ip_error)
  );
endmodule
