// Ethernet CRC-32 (reflected polynomial 0xEDB88320).
`timescale 1ns / 1ps

module eth_crc32 (
    input  logic        clk,
    input  logic        rst,
    input  logic        init,
    input  logic [ 7:0] data_in,
    input  logic        valid,
    output logic [31:0] crc_out
);

  logic [31:0] crc_q;

  function automatic logic [31:0] crc_byte(input logic [31:0] crc, input logic [7:0] d);
    logic [31:0] c;
    logic [7:0]  b;
    c = crc;
    b = d;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    b = b >> 1;
    if (c[0] ^ b[0]) c = (c >> 1) ^ 32'hEDB8_8320;
    else c = c >> 1;
    return c;
  endfunction

  always_ff @(posedge clk) begin
    if (rst || init) crc_q <= 32'hFFFF_FFFF;
    else if (valid) crc_q <= crc_byte(crc_q, data_in);
  end

  assign crc_out = ~crc_q;

endmodule
