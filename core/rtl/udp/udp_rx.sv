// UDP RX: port filter and payload extract.
`timescale 1ns / 1ps

module udp_rx #(
    parameter int DST_PORT = 50000
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [ 7:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic        s_axis_tlast,
    output logic [ 7:0] m_axis_tdata,
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic        m_axis_tlast,
    output logic [15:0] m_src_port,
    output logic [15:0] m_dst_port,
    output logic        m_meta_valid,
    output logic        udp_error
);

  typedef enum logic [1:0] {StHdr, StPay, StDrop} state_e;
  state_e state_q;
  logic [3:0] hdr_idx;
  logic [15:0] src_port_q, dst_port_q;

  assign m_src_port    = src_port_q;
  assign m_dst_port    = dst_port_q;
  assign s_axis_tready = (state_q == StPay) ? m_axis_tready : 1'b1;

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q       <= StHdr;
      hdr_idx       <= '0;
      m_axis_tvalid <= 1'b0;
      m_meta_valid  <= 1'b0;
      udp_error     <= 1'b0;
    end else begin
      m_axis_tvalid <= 1'b0;
      m_meta_valid  <= 1'b0;

      unique case (state_q)
        StHdr: begin
          if (s_axis_tvalid) begin
            if (hdr_idx == 4'd0) src_port_q[15:8] <= s_axis_tdata;
            if (hdr_idx == 4'd1) src_port_q[7:0]  <= s_axis_tdata;
            if (hdr_idx == 4'd2) dst_port_q[15:8] <= s_axis_tdata;
            if (hdr_idx == 4'd3) begin
              dst_port_q[7:0] <= s_axis_tdata;
              if ({dst_port_q[15:8], s_axis_tdata} != DST_PORT[15:0]) begin
                udp_error <= 1'b1;
                state_q   <= StDrop;
              end
            end
            if (hdr_idx == 4'd7) begin
              m_meta_valid <= 1'b1;
              state_q      <= StPay;
              hdr_idx      <= 4'd0;
            end else if (state_q == StHdr) hdr_idx <= hdr_idx + 4'd1;
          end
        end
        StPay: begin
          if (s_axis_tvalid && m_axis_tready) begin
            m_axis_tdata  <= s_axis_tdata;
            m_axis_tvalid <= 1'b1;
            m_axis_tlast  <= s_axis_tlast;
            if (s_axis_tlast) begin
              state_q <= StHdr;
              hdr_idx <= '0;
            end
          end
        end
        StDrop: begin
          if (s_axis_tvalid && s_axis_tlast) begin
            state_q <= StHdr;
            hdr_idx <= '0;
          end
        end
        default: state_q <= StHdr;
      endcase
    end
  end

endmodule
