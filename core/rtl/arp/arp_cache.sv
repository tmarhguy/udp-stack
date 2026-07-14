// Single-entry ARP cache for lab bring-up (host MAC pre-seeded or learned).
`timescale 1ns / 1ps

module arp_cache (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] lookup_ip,
    output logic [47:0] lookup_mac,
    output logic        lookup_hit,
    input  logic        learn_en,
    input  logic [31:0] learn_ip,
    input  logic [47:0] learn_mac
);

  logic [31:0] cached_ip;
  logic [47:0] cached_mac;

  assign lookup_hit = (lookup_ip == cached_ip);
  assign lookup_mac = cached_mac;

  always_ff @(posedge clk) begin
    if (rst) begin
      cached_ip  <= '0;
      cached_mac <= '0;
    end else if (learn_en) begin
      cached_ip  <= learn_ip;
      cached_mac <= learn_mac;
    end
  end

endmodule
