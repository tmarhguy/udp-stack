// Cut-through UDP payload echo with latency instrumentation.
`timescale 1ns / 1ps

module loopback_echo (
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
    output logic [31:0] latency_cycles,
    output logic        latency_valid
);

  logic [31:0] cycle_cnt;
  logic [31:0] start_cycle;
  logic        armed;

  assign s_axis_tready = m_axis_tready;
  assign m_axis_tdata  = s_axis_tdata;
  assign m_axis_tvalid = s_axis_tvalid;
  assign m_axis_tlast  = s_axis_tlast;

  always_ff @(posedge clk) begin
    if (rst) begin
      cycle_cnt      <= '0;
      start_cycle    <= '0;
      armed          <= 1'b0;
      latency_valid  <= 1'b0;
      latency_cycles <= '0;
    end else begin
      cycle_cnt     <= cycle_cnt + 32'd1;
      latency_valid <= 1'b0;

      if (s_axis_tvalid && s_axis_tready && !armed) begin
        start_cycle <= cycle_cnt;
        armed       <= 1'b1;
      end

      if (m_axis_tvalid && m_axis_tready && m_axis_tlast && armed) begin
        latency_cycles <= cycle_cnt - start_cycle;
        latency_valid  <= 1'b1;
        armed          <= 1'b0;
      end
    end
  end

endmodule
