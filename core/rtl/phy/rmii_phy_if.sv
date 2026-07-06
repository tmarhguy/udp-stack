// RMII PHY interface: nibble RX/TX @ 50 MHz with CDC to 100 MHz byte stream.
`timescale 1ns / 1ps

module rmii_phy_if (
    input  logic        clk100,
    input  logic        rst,
    input  logic        eth_refclk,
    input  logic [ 1:0] eth_rxd,
    input  logic        eth_crs_dv,
    output logic [ 1:0] eth_txd,
    output logic        eth_txen,
    output logic [ 7:0] rx_byte,
    output logic        rx_valid,
    input  logic        rx_ready,
    output logic        rx_frame_end,
    input  logic [ 7:0] tx_byte,
    input  logic        tx_valid,
    output logic        tx_ready,
    input  logic        tx_frame_end
);

  logic [1:0] rmii_phase;
  logic [7:0] rx_byte_rmii;
  logic       rx_valid_rmii;
  logic       crs_dv_d;
  logic       frame_toggle_rmii;
  logic [2:0] frame_toggle_sync;
  logic       frame_toggle_d;

  logic [7:0] fifo_rd;
  logic       fifo_empty;
  logic       fifo_rd_en;
  logic       fifo_wr_en;

  logic [1:0] tx_phase;
  logic       tx_active;
  logic [7:0] tx_byte_hold;
  logic       tx_pending;

  assign fifo_wr_en = rx_valid_rmii;
  assign fifo_rd_en = !fifo_empty && rx_ready;
  assign rx_byte    = fifo_rd;
  assign rx_valid   = fifo_rd_en;

  byte_cdc_fifo u_rx_cdc (
      .wr_clk   (eth_refclk),
      .rd_clk   (clk100),
      .rst      (rst),
      .wr_data  (rx_byte_rmii),
      .wr_en    (fifo_wr_en),
      .wr_full  (),
      .rd_data  (fifo_rd),
      .rd_en    (fifo_rd_en),
      .rd_empty (fifo_empty)
  );

  always_ff @(posedge eth_refclk) begin
    if (rst) begin
      rmii_phase        <= 2'd0;
      rx_valid_rmii     <= 1'b0;
      rx_byte_rmii      <= '0;
      crs_dv_d          <= 1'b0;
      frame_toggle_rmii <= 1'b0;
    end else begin
      rx_valid_rmii <= 1'b0;
      crs_dv_d      <= eth_crs_dv;
      if (crs_dv_d && !eth_crs_dv) frame_toggle_rmii <= ~frame_toggle_rmii;
      if (eth_crs_dv) begin
        unique case (rmii_phase)
          2'd0: rx_byte_rmii[1:0] <= eth_rxd;
          2'd1: rx_byte_rmii[3:2] <= eth_rxd;
          2'd2: rx_byte_rmii[5:4] <= eth_rxd;
          2'd3: begin
            rx_byte_rmii[7:6] <= eth_rxd;
            rx_valid_rmii     <= 1'b1;
          end
        endcase
        rmii_phase <= rmii_phase + 2'd1;
      end else rmii_phase <= 2'd0;
    end
  end

  always_ff @(posedge clk100) begin
    frame_toggle_sync <= {frame_toggle_sync[1:0], frame_toggle_rmii};
    frame_toggle_d    <= frame_toggle_sync[2];
    rx_frame_end      <= frame_toggle_sync[2] ^ frame_toggle_d;
  end

  assign tx_ready = !tx_active && !tx_pending;

  always_ff @(posedge eth_refclk) begin
    if (rst) begin
      tx_phase     <= 2'd0;
      tx_active    <= 1'b0;
      eth_txd      <= 2'b00;
      eth_txen     <= 1'b0;
      tx_byte_hold <= '0;
      tx_pending   <= 1'b0;
    end else begin
      if (tx_valid && tx_ready) begin
        tx_byte_hold <= tx_byte;
        tx_pending   <= 1'b1;
        tx_phase     <= 2'd0;
      end

      if (tx_pending && !tx_active) begin
        tx_active <= 1'b1;
        eth_txen  <= 1'b1;
      end

      if (tx_active) begin
        unique case (tx_phase)
          2'd0: eth_txd <= tx_byte_hold[1:0];
          2'd1: eth_txd <= tx_byte_hold[3:2];
          2'd2: eth_txd <= tx_byte_hold[5:4];
          2'd3: eth_txd <= tx_byte_hold[7:6];
        endcase
        tx_phase <= tx_phase + 2'd1;
        if (tx_phase == 2'd3) begin
          tx_active  <= 1'b0;
          tx_pending <= 1'b0;
          if (tx_frame_end) eth_txen <= 1'b0;
        end
      end
    end
  end

endmodule
