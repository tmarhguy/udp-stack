// Ethernet demux: skip L2 header, forward IPv4 payload to IP layer.
`timescale 1ns / 1ps

module eth_demux (
    input  logic        clk,
    input  logic        rst,
    input  logic [ 7:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic        s_axis_tlast,
    output logic [ 7:0] m_ip_tdata,
    output logic        m_ip_tvalid,
    input  logic        m_ip_tready,
    output logic        m_ip_tlast,
    output logic        arp_seen,
    output logic        ip_seen
);

  typedef enum logic [1:0] {StScan, StPass, StDrop} state_e;
  state_e state_q;
  logic [15:0] byte_idx;
  logic [15:0] eth_type;

  assign s_axis_tready = (state_q == StPass) ? m_ip_tready : 1'b1;

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q  <= StScan;
      byte_idx <= '0;
      arp_seen <= 1'b0;
      ip_seen  <= 1'b0;
    end else begin
      arp_seen <= 1'b0;
      ip_seen  <= 1'b0;

      if (s_axis_tvalid) begin
        if (byte_idx == 16'd12) eth_type[15:8] <= s_axis_tdata;
        if (byte_idx == 16'd13) begin
          eth_type[7:0] <= s_axis_tdata;
          if ({eth_type[15:8], s_axis_tdata} == 16'h0800) begin
            state_q <= StPass;
            ip_seen <= 1'b1;
          end else if ({eth_type[15:8], s_axis_tdata} == 16'h0806) begin
            state_q  <= StDrop;
            arp_seen <= 1'b1;
          end else state_q <= StDrop;
        end
        if (s_axis_tlast) begin
          state_q  <= StScan;
          byte_idx <= '0;
        end else byte_idx <= byte_idx + 16'd1;
      end
    end
  end

  assign m_ip_tdata  = s_axis_tdata;
  assign m_ip_tvalid = s_axis_tvalid && (state_q == StPass) && (byte_idx >= 16'd14);
  assign m_ip_tlast  = s_axis_tlast && (state_q == StPass);

endmodule
