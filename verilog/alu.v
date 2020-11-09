`include "lib/opcodes.v"
`timescale 1ns / 1ps

module ALU
 (input      [`W_OPCODE-1:0]  alu_op,
  input      [`W_CPU-1:0]     A,
  input      [`W_CPU-1:0]     B,
  output reg [`W_CPU-1:0]     R,
  output reg overflow, // 1 if overflow, 0 if not
  output reg isZero);

  // insert alu slice Here

  wire [W:0]   carry;
  wire [W-1:0] result;

  assign carry[0] = 1'b0;



  always @* begin
    case(alu_op)
      `add_: begin R = A+B end // case 0
      `sub_: begin R = A-B end // case 1
      default : ;
    endcase
  end

endmodule
