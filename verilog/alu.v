`include "lib/opcodes.v"
`timescale 1ns / 1ps

module ALU
 (input      [`W_OPCODE-1:0]  alu_op,
  input      [`W_CPU-1:0]     A,
  input      [`W_CPU-1:0]     B,
  output reg [`W_CPU-1:0]     R,
  output reg overflow,
  output reg isZero);


  always @* begin
    case(alu_op)
      default : ;
    endcase
  end

endmodule
