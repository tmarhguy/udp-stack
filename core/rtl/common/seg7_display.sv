// Nexys A7 multiplexed 8-digit hex display.
// AN[0] = rightmost digit, active-low. Cathodes CA-CG active-low.
`timescale 1ns / 1ps

module seg7_display (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] value,
    output logic [ 7:0] AN,
    output logic        CA,
    output logic        CB,
    output logic        CC,
    output logic        CD,
    output logic        CE,
    output logic        CF,
    output logic        CG,
    output logic        DP
);

  logic [ 2:0] digit_sel;
  logic [16:0] refresh_cnt;
  logic [ 3:0] nibble;
  logic [ 6:0] cathode;

  function automatic logic [6:0] hex_to_seg(input logic [3:0] hex);
    unique case (hex)
      4'h0: return 7'b1000000;
      4'h1: return 7'b1111001;
      4'h2: return 7'b0100100;
      4'h3: return 7'b0110000;
      4'h4: return 7'b0011001;
      4'h5: return 7'b0010010;
      4'h6: return 7'b0000010;
      4'h7: return 7'b1111000;
      4'h8: return 7'b0000000;
      4'h9: return 7'b0010000;
      4'ha: return 7'b0001000;
      4'hb: return 7'b0000011;
      4'hc: return 7'b1000110;
      4'hd: return 7'b0100001;
      4'he: return 7'b0000110;
      4'hf: return 7'b0001110;
      default: return 7'b1111111;
    endcase
  endfunction

  always_ff @(posedge clk) begin
    if (rst) begin
      refresh_cnt <= '0;
      digit_sel   <= 3'd0;
    end else if (refresh_cnt == 17'd99_999) begin
      refresh_cnt <= '0;
      digit_sel   <= digit_sel + 3'd1;
    end else refresh_cnt <= refresh_cnt + 17'd1;
  end

  always_comb begin
    nibble  = value[digit_sel * 4 +: 4];
    cathode = hex_to_seg(nibble);
    AN      = ~(8'b0000_0001 << digit_sel);
  end

  assign {CG, CF, CE, CD, CC, CB, CA} = cathode;
  assign DP = 1'b1;

endmodule
