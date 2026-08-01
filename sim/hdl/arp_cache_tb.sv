`timescale 1ns / 1ps

module arp_cache_tb (input logic clk, input logic rst);
  logic [31:0] lookup_ip, learn_ip;
  logic [47:0] lookup_mac, learn_mac;
  logic        lookup_hit, learn_en;

  arp_cache dut (
      .clk(clk), .rst(rst),
      .lookup_ip(lookup_ip), .lookup_mac(lookup_mac), .lookup_hit(lookup_hit),
      .learn_en(learn_en), .learn_ip(learn_ip), .learn_mac(learn_mac)
  );
endmodule
