`timescale 1ns / 1ps

module udp_rx_tb (input logic clk, input logic rst);
  logic [7:0] s_axis_tdata, m_axis_tdata;
  logic       s_axis_tvalid, s_axis_tready, s_axis_tlast;
  logic       m_axis_tvalid, m_axis_tready, m_axis_tlast;
  logic [15:0] m_src_port, m_dst_port;
  logic        m_meta_valid, udp_error;

  udp_rx dut (
      .clk(clk), .rst(rst),
      .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid),
      .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast),
      .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
      .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
      .m_src_port(m_src_port), .m_dst_port(m_dst_port),
      .m_meta_valid(m_meta_valid), .udp_error(udp_error)
  );
endmodule
