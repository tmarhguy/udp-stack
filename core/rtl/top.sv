// Nexys A7-100T board top: RMII PHY + full UDP/IP echo stack.
`timescale 1ns / 1ps

module top #(
    parameter int UDP_PORT = 50000
) (
    input  logic        CLK100MHZ,
    input  logic        CPU_RESETN,
    input  logic [15:0] SW,
    output logic [15:0] LED,
    output logic [ 7:0] AN,
    output logic        CA,
    output logic        CB,
    output logic        CC,
    output logic        CD,
    output logic        CE,
    output logic        CF,
    output logic        CG,
    output logic        DP,
    input  logic        eth_refclk,
    input  logic [ 1:0] eth_rxd,
    input  logic        eth_crs_dv,
    output logic [ 1:0] eth_txd,
    output logic        eth_txen,
    inout  logic        eth_mdc,
    inout  logic        eth_mdio,
    output logic        eth_rstn
);

  localparam logic [47:0] HOST_MAC = 48'h00_08_DC_12_34_56;
  localparam logic [31:0] HOST_IP  = {8'd192, 8'd168, 8'd1, 8'd100};

  logic        rst_sync;
  logic [ 3:0] rst_pipe;
  logic        link_up;

  logic [7:0] phy_rx_byte, phy_tx_byte;
  logic       phy_rx_valid, phy_tx_valid;
  logic       phy_rx_ready, phy_tx_ready;
  logic       phy_rx_frame_end, phy_tx_frame_end;

  logic [7:0] mac_rx_data, mac_tx_data, stack_tx_data;
  logic       mac_rx_valid, mac_tx_valid, stack_tx_valid;
  logic       mac_rx_ready, mac_tx_ready, stack_tx_ready;
  logic       mac_rx_last, mac_tx_last, stack_tx_last;

  logic [31:0] latency_cycles;
  logic        latency_valid, stack_error;

  logic [23:0] rx_pulse, tx_pulse, err_pulse;
  logic [25:0] hb_cnt;
  logic        hb_led;
  logic        hb_led_d;
  logic [15:0] disp_cnt;
  logic [31:0] seg_value;

  assign eth_rstn = CPU_RESETN & ~rst_sync;

  always_ff @(posedge CLK100MHZ or negedge CPU_RESETN) begin
    if (!CPU_RESETN) begin
      rst_pipe <= 4'hF;
      rst_sync <= 1'b1;
    end else begin
      rst_pipe <= {rst_pipe[2:0], 1'b0};
      rst_sync <= |rst_pipe;
    end
  end

  always_ff @(posedge CLK100MHZ) begin
    if (rst_sync) begin
      hb_cnt   <= '0;
      hb_led   <= 1'b0;
      hb_led_d <= 1'b0;
      disp_cnt <= '0;
    end else begin
      hb_led_d <= hb_led;
      hb_cnt   <= hb_cnt + 26'd1;
      if (hb_cnt == 26'd50_000_000) begin
        hb_cnt <= '0;
        hb_led <= ~hb_led;
      end
      if (hb_led && !hb_led_d) disp_cnt <= disp_cnt + 16'd1;
    end
  end

  lan8720_mdio u_mdio (
      .clk      (CLK100MHZ),
      .rst      (rst_sync),
      .phy_rstn (eth_rstn),
      .mdc      (eth_mdc),
      .mdio     (eth_mdio),
      .link_up  (link_up)
  );

  rmii_phy_if u_phy (
      .clk100         (CLK100MHZ),
      .rst            (rst_sync),
      .eth_refclk     (eth_refclk),
      .eth_rxd        (eth_rxd),
      .eth_crs_dv     (eth_crs_dv),
      .eth_txd        (eth_txd),
      .eth_txen       (eth_txen),
      .rx_byte        (phy_rx_byte),
      .rx_valid       (phy_rx_valid),
      .rx_ready       (phy_rx_ready),
      .rx_frame_end   (phy_rx_frame_end),
      .tx_byte        (phy_tx_byte),
      .tx_valid       (phy_tx_valid),
      .tx_ready       (phy_tx_ready),
      .tx_frame_end   (phy_tx_frame_end)
  );

  eth_mac_axis u_mac (
      .clk              (CLK100MHZ),
      .rst              (rst_sync),
      .phy_rx_byte      (phy_rx_byte),
      .phy_rx_valid     (phy_rx_valid),
      .phy_rx_ready     (phy_rx_ready),
      .phy_rx_frame_end (phy_rx_frame_end),
      .phy_tx_byte      (phy_tx_byte),
      .phy_tx_valid     (phy_tx_valid),
      .phy_tx_ready     (phy_tx_ready),
      .phy_tx_frame_end (phy_tx_frame_end),
      .m_axis_tdata     (mac_rx_data),
      .m_axis_tvalid    (mac_rx_valid),
      .m_axis_tready    (mac_rx_ready),
      .m_axis_tlast     (mac_rx_last),
      .s_axis_tdata     (mac_tx_data),
      .s_axis_tvalid    (mac_tx_valid),
      .s_axis_tready    (mac_tx_ready),
      .s_axis_tlast     (mac_tx_last)
  );

  udp_stack_core #(
      .DST_PORT(UDP_PORT)
  ) u_stack (
      .clk            (CLK100MHZ),
      .rst            (rst_sync),
      .cfg_host_mac   (HOST_MAC),
      .cfg_host_ip    (HOST_IP),
      .s_eth_tdata    (mac_rx_data),
      .s_eth_tvalid   (mac_rx_valid),
      .s_eth_tready   (mac_rx_ready),
      .s_eth_tlast    (mac_rx_last),
      .m_eth_tdata    (stack_tx_data),
      .m_eth_tvalid   (stack_tx_valid),
      .m_eth_tready   (stack_tx_ready),
      .m_eth_tlast    (stack_tx_last),
      .latency_cycles (latency_cycles),
      .latency_valid  (latency_valid),
      .stack_error    (stack_error)
  );

  assign mac_tx_data    = stack_tx_data;
  assign mac_tx_valid   = stack_tx_valid;
  assign stack_tx_ready = mac_tx_ready;
  assign mac_tx_last    = stack_tx_last;

  always_ff @(posedge CLK100MHZ) begin
    if (rst_sync) begin
      rx_pulse  <= '0;
      tx_pulse  <= '0;
      err_pulse <= '0;
    end else begin
      if (mac_rx_valid && mac_rx_ready) rx_pulse <= 24'd5_000_000;
      else if (rx_pulse != 0) rx_pulse <= rx_pulse - 24'd1;
      if (mac_tx_valid && mac_tx_ready) tx_pulse <= 24'd5_000_000;
      else if (tx_pulse != 0) tx_pulse <= tx_pulse - 24'd1;
      if (stack_error) err_pulse <= 24'd10_000_000;
      else if (err_pulse != 0) err_pulse <= err_pulse - 24'd1;
    end
  end

  // 7-segment: right 2 digits = SW[7:0] hex, next 2 = heartbeat counter, rest blank.
  assign seg_value = {16'h0000, disp_cnt[7:0], SW[7:0]};

  seg7_display u_seg7 (
      .clk   (CLK100MHZ),
      .rst   (rst_sync),
      .value (seg_value),
      .AN    (AN),
      .CA    (CA),
      .CB    (CB),
      .CC    (CC),
      .CD    (CD),
      .CE    (CE),
      .CF    (CF),
      .CG    (CG),
      .DP    (DP)
  );

  assign LED[7:0]   = SW[7:0];
  assign LED[8]     = hb_led;
  assign LED[9]     = rx_pulse != 0;
  assign LED[10]    = tx_pulse != 0;
  assign LED[11]    = stack_error || err_pulse != 0;
  assign LED[12]    = latency_valid;
  assign LED[13]    = link_up;
  assign LED[14]    = hb_led;
  assign LED[15]    = link_up;

endmodule
