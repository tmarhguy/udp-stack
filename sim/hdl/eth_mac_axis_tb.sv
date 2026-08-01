`timescale 1ns / 1ps

module eth_mac_axis_tb (input logic clk, input logic rst);
  logic [7:0] phy_rx_byte, phy_tx_byte, m_axis_tdata, s_axis_tdata;
  logic       phy_rx_valid, phy_rx_ready, phy_rx_frame_end;
  logic       phy_tx_valid, phy_tx_ready, phy_tx_frame_end;
  logic       m_axis_tvalid, m_axis_tready, m_axis_tlast;
  logic       s_axis_tvalid, s_axis_tready, s_axis_tlast;

  eth_mac_axis dut (
      .clk(clk), .rst(rst),
      .phy_rx_byte(phy_rx_byte), .phy_rx_valid(phy_rx_valid),
      .phy_rx_ready(phy_rx_ready), .phy_rx_frame_end(phy_rx_frame_end),
      .phy_tx_byte(phy_tx_byte), .phy_tx_valid(phy_tx_valid),
      .phy_tx_ready(phy_tx_ready), .phy_tx_frame_end(phy_tx_frame_end),
      .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
      .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
      .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid),
      .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast)
  );
endmodule
