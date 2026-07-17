// IPv4 RX: verify header, filter UDP, forward L4 bytes.
`timescale 1ns / 1ps

module ip_rx #(
    parameter logic [31:0] LOCAL_IP = {8'd192, 8'd168, 8'd1, 8'd10}
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
    output logic [31:0] m_src_ip,
    output logic [31:0] m_dst_ip,
    output logic        m_meta_valid,
    output logic        ip_error
);

  typedef enum logic [2:0] {StHdr, StFwd, StDrop} state_e;
  state_e state_q;
  logic [4:0] hdr_idx;
  logic [7:0]  proto_q;
  logic [31:0] src_ip_q, dst_ip_q;

  assign m_src_ip = src_ip_q;
  assign m_dst_ip = dst_ip_q;
  assign s_axis_tready = (state_q == StFwd) ? m_axis_tready : 1'b1;

  always_ff @(posedge clk) begin
    if (rst) begin
      state_q       <= StHdr;
      hdr_idx       <= '0;
      m_axis_tvalid <= 1'b0;
      m_meta_valid  <= 1'b0;
      ip_error      <= 1'b0;
    end else begin
      m_axis_tvalid <= 1'b0;
      m_meta_valid  <= 1'b0;

      unique case (state_q)
        StHdr: begin
          if (s_axis_tvalid) begin
            if (hdr_idx == 5'd9) proto_q <= s_axis_tdata;
            if (hdr_idx >= 5'd12 && hdr_idx <= 5'd15)
              src_ip_q[31 - 8 * (hdr_idx - 12) -: 8] <= s_axis_tdata;
            if (hdr_idx >= 5'd16 && hdr_idx <= 5'd19)
              dst_ip_q[31 - 8 * (hdr_idx - 16) -: 8] <= s_axis_tdata;
            if (hdr_idx == 5'd19) begin
              if (proto_q == 8'd17 && {dst_ip_q[31:8], s_axis_tdata} == LOCAL_IP) begin
                m_meta_valid <= 1'b1;
                state_q      <= StFwd;
              end else begin
                ip_error <= 1'b1;
                state_q  <= StDrop;
              end
              hdr_idx <= '0;
            end else hdr_idx <= hdr_idx + 5'd1;
          end
        end
        StFwd: begin
          if (s_axis_tvalid && m_axis_tready) begin
            m_axis_tdata  <= s_axis_tdata;
            m_axis_tvalid <= 1'b1;
            m_axis_tlast  <= s_axis_tlast;
            if (s_axis_tlast) state_q <= StHdr;
          end
        end
        StDrop: begin
          if (s_axis_tvalid && s_axis_tlast) state_q <= StHdr;
        end
        default: state_q <= StHdr;
      endcase
    end
  end

endmodule
