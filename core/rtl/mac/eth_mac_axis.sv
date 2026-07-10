// Ethernet MAC with byte AXI-Stream frame interfaces (no preamble/FCS on AXIS).
`timescale 1ns / 1ps

module eth_mac_axis (
    input  logic        clk,
    input  logic        rst,
    input  logic [ 7:0] phy_rx_byte,
    input  logic        phy_rx_valid,
    output logic        phy_rx_ready,
    input  logic        phy_rx_frame_end,
    output logic [ 7:0] phy_tx_byte,
    output logic        phy_tx_valid,
    input  logic        phy_tx_ready,
    output logic        phy_tx_frame_end,
    output logic [ 7:0] m_axis_tdata,
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic        m_axis_tlast,
    input  logic [ 7:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic        s_axis_tlast
);

  typedef enum logic [2:0] {RxIdle, RxPre, RxData} rx_state_e;
  typedef enum logic [2:0] {TxIdle, TxIfg, TxPre, TxData, TxFcs} tx_state_e;

  rx_state_e rx_state_q;
  tx_state_e tx_state_q;
  logic [3:0]  rx_pre_cnt;
  logic [3:0]  tx_ifg_cnt;
  logic [3:0]  tx_pre_idx;
  logic [1:0]  tx_crc_idx;
  logic        crc_init;
  logic        crc_valid;
  logic [ 7:0] crc_data;
  logic [31:0] crc_out;

  eth_crc32 u_crc (
      .clk     (clk),
      .rst     (rst),
      .init    (crc_init),
      .data_in (crc_data),
      .valid   (crc_valid),
      .crc_out (crc_out)
  );

  assign phy_rx_ready = (rx_state_q == RxData) ? m_axis_tready : 1'b1;

  always_ff @(posedge clk) begin
    if (rst) begin
      rx_state_q    <= RxIdle;
      rx_pre_cnt    <= '0;
      m_axis_tdata  <= '0;
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
    end else begin
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;

      if (phy_rx_frame_end && rx_state_q != RxIdle) rx_state_q <= RxIdle;

      unique case (rx_state_q)
        RxIdle: begin
          if (phy_rx_valid && phy_rx_byte == 8'h55) begin
            rx_pre_cnt <= 4'd6;
            rx_state_q <= RxPre;
          end
        end
        RxPre: begin
          if (phy_rx_valid) begin
            if (phy_rx_byte == 8'hD5) rx_state_q <= RxData;
            else if (rx_pre_cnt != 0) rx_pre_cnt <= rx_pre_cnt - 4'd1;
            else rx_state_q <= RxIdle;
          end
        end
        RxData: begin
          if (phy_rx_valid && phy_rx_ready) begin
            m_axis_tdata  <= phy_rx_byte;
            m_axis_tvalid <= 1'b1;
            if (phy_rx_frame_end) begin
              m_axis_tlast <= 1'b1;
              rx_state_q   <= RxIdle;
            end
          end
        end
        default: rx_state_q <= RxIdle;
      endcase
    end
  end

  function automatic logic [7:0] preamble_byte(input logic [3:0] idx);
    if (idx == 4'd7) return 8'hD5;
    return 8'h55;
  endfunction

  assign s_axis_tready = (tx_state_q == TxData) && phy_tx_ready;
  assign phy_tx_valid  = (tx_state_q == TxPre) || (tx_state_q == TxData) || (tx_state_q == TxFcs);
  assign phy_tx_frame_end = (tx_state_q == TxFcs) && (tx_crc_idx == 2'd3) && phy_tx_ready;

  always_ff @(posedge clk) begin
    crc_init  <= 1'b0;
    crc_valid <= 1'b0;
    crc_data  <= '0;

    if (rst) begin
      tx_state_q  <= TxIdle;
      tx_ifg_cnt  <= '0;
      tx_pre_idx  <= '0;
      tx_crc_idx  <= '0;
      phy_tx_byte <= '0;
    end else begin
      unique case (tx_state_q)
        TxIdle: begin
          if (s_axis_tvalid && s_axis_tready) begin
            tx_ifg_cnt <= 4'd11;
            tx_state_q <= TxIfg;
          end
        end
        TxIfg: begin
          if (tx_ifg_cnt == 0) begin
            tx_pre_idx <= '0;
            tx_state_q <= TxPre;
          end else tx_ifg_cnt <= tx_ifg_cnt - 4'd1;
        end
        TxPre: begin
          phy_tx_byte <= preamble_byte(tx_pre_idx);
          if (phy_tx_ready) begin
            if (tx_pre_idx == 4'd7) begin
              crc_init   <= 1'b1;
              tx_state_q <= TxData;
            end else tx_pre_idx <= tx_pre_idx + 4'd1;
          end
        end
        TxData: begin
          if (s_axis_tvalid && s_axis_tready) begin
            phy_tx_byte <= s_axis_tdata;
            crc_data    <= s_axis_tdata;
            crc_valid   <= 1'b1;
            if (s_axis_tlast) begin
              tx_crc_idx <= '0;
              tx_state_q <= TxFcs;
            end
          end
        end
        TxFcs: begin
          unique case (tx_crc_idx)
            2'd0: phy_tx_byte <= crc_out[7:0];
            2'd1: phy_tx_byte <= crc_out[15:8];
            2'd2: phy_tx_byte <= crc_out[23:16];
            default: phy_tx_byte <= crc_out[31:24];
          endcase
          if (phy_tx_ready) begin
            if (tx_crc_idx == 2'd3) tx_state_q <= TxIdle;
            else tx_crc_idx <= tx_crc_idx + 2'd1;
          end
        end
        default: tx_state_q <= TxIdle;
      endcase
    end
  end

endmodule
