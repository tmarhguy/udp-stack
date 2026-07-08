// Synchronous byte AXI-Stream FIFO.
`timescale 1ns / 1ps

module axis_fifo #(
    parameter int DEPTH  = 512,
    parameter int ADDR_W = 9
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
    output logic        m_axis_tlast
);

  logic [ADDR_W:0] wr_ptr, rd_ptr;
  (* ram_style = "block" *) logic [7:0]  data_mem[DEPTH];
  (* ram_style = "block" *) logic       last_mem[DEPTH];

  assign s_axis_tready = (wr_ptr - rd_ptr) < DEPTH;
  assign m_axis_tvalid = wr_ptr != rd_ptr;

  always_ff @(posedge clk) begin
    if (rst) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end else begin
      if (s_axis_tvalid && s_axis_tready) begin
        data_mem[wr_ptr[ADDR_W-1:0]] <= s_axis_tdata;
        last_mem[wr_ptr[ADDR_W-1:0]] <= s_axis_tlast;
        wr_ptr <= wr_ptr + 1;
      end
      if (m_axis_tvalid && m_axis_tready) rd_ptr <= rd_ptr + 1;
    end
  end

  assign m_axis_tdata = data_mem[rd_ptr[ADDR_W-1:0]];
  assign m_axis_tlast = last_mem[rd_ptr[ADDR_W-1:0]];

endmodule
