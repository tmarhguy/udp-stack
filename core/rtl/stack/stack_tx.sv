// Serial TX: Ethernet + IPv4 + UDP headers then payload stream.
`timescale 1ns / 1ps

module stack_tx #(
    parameter int          LOCAL_PORT = 50000,
    parameter logic [47:0] LOCAL_MAC  = 48'h00_0A_35_00_00_01,
    parameter logic [31:0] LOCAL_IP   = {8'd192, 8'd168, 8'd1, 8'd10}
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [47:0] cfg_dst_mac,
    input  logic [31:0] cfg_dst_ip,
    input  logic [15:0] cfg_dst_port,
    input  logic [15:0] cfg_udp_len,
    input  logic        pkt_start,
    input  logic [ 7:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic        s_axis_tlast,
    output logic [ 7:0] m_axis_tdata,
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic        m_axis_tlast
);

  typedef enum logic [1:0] {StHdr, StPay, StIdle} state_e;
  state_e state_q;
  logic [5:0] hdr_idx;
  logic [15:0] total_len;

  function automatic logic [7:0] hdr_byte(
      input logic [5:0] idx,
      input logic [15:0] ulen,
      input logic [47:0] dmac,
      input logic [31:0] dip,
      input logic [15:0] dport
  );
    logic [15:0] iplen;
    iplen = ulen + 16'd28;
    unique case (idx)
      6'd0:  return dmac[47:40];
      6'd1:  return dmac[39:32];
      6'd2:  return dmac[31:24];
      6'd3:  return dmac[23:16];
      6'd4:  return dmac[15:8];
      6'd5:  return dmac[7:0];
      6'd6:  return LOCAL_MAC[47:40];
      6'd7:  return LOCAL_MAC[39:32];
      6'd8:  return LOCAL_MAC[31:24];
      6'd9:  return LOCAL_MAC[23:16];
      6'd10: return LOCAL_MAC[15:8];
      6'd11: return LOCAL_MAC[7:0];
      6'd12: return 8'h08;
      6'd13: return 8'h00;
      6'd14: return 8'h45;
      6'd15: return 8'h00;
      6'd16: return iplen[15:8];
      6'd17: return iplen[7:0];
      6'd18: return 8'h00;
      6'd19: return 8'h00;
      6'd20: return 8'h40;
      6'd21: return 8'h00;
      6'd22: return 8'h40;
      6'd23: return 8'h11;
      6'd24: return 8'h00;
      6'd25: return 8'h00;
      6'd26: return LOCAL_IP[31:24];
      6'd27: return LOCAL_IP[23:16];
      6'd28: return LOCAL_IP[15:8];
      6'd29: return LOCAL_IP[7:0];
      6'd30: return dip[31:24];
      6'd31: return dip[23:16];
      6'd32: return dip[15:8];
      6'd33: return dip[7:0];
      6'd34: return LOCAL_PORT[15:8];
      6'd35: return LOCAL_PORT[7:0];
      6'd36: return dport[15:8];
      6'd37: return dport[7:0];
      6'd38: return ulen[15:8];
      6'd39: return ulen[7:0];
      6'd40: return 8'h00;
      6'd41: return 8'h00;
      default: return 8'h00;
    endcase
  endfunction

  assign s_axis_tready = (state_q == StPay) ? m_axis_tready : 1'b0;

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q       <= StIdle;
      hdr_idx       <= '0;
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
    end else begin
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;

      if (pkt_start) begin
        total_len <= cfg_udp_len;
        hdr_idx   <= '0;
        state_q   <= StHdr;
      end else
        unique case (state_q)
          StHdr: begin
            if (m_axis_tready) begin
              m_axis_tdata  <= hdr_byte(hdr_idx, total_len, cfg_dst_mac, cfg_dst_ip, cfg_dst_port);
              m_axis_tvalid <= 1'b1;
              if (hdr_idx == 6'd41) state_q <= StPay;
              else hdr_idx <= hdr_idx + 6'd1;
            end
          end
          StPay: begin
            if (s_axis_tvalid && m_axis_tready) begin
              m_axis_tdata  <= s_axis_tdata;
              m_axis_tvalid <= 1'b1;
              m_axis_tlast  <= s_axis_tlast;
              if (s_axis_tlast) state_q <= StIdle;
            end
          end
          StIdle: ;
          default: state_q <= StIdle;
        endcase
    end
  end

endmodule
