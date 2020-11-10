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
    `OP_ZERO: begin R = A+B end // add
    `OP_TWO: begin R = A-B end // sub TODO: need assign?
    `OP_THREE: begin R = A ^ B end // XOR
    `OP_FOUR: begin R = A < B end // SLT
    `OP_FIVE: begin R = A & B end // AND
    `OP_SIX: begin R= ~(A & B) end // NAND
    `OP_SEVEN: begin R = A ~| B end // NOR
    `OP_EIGHT: begin R = A || B end // OR
    `OP_NINE: begin R = A * B end
    default: ;
    endcase
    end
  endmodule

//       case (Ctrl)
//         `SLL: begin R = A << 1'b0; end // 0
//         `SRL: begin R = A >> 1'b0; end // 2
//         `ADD: begin R = A + B; end
//         `ADDU: begin R = A + B; end
//         `SUB: begin R = A - B; end
//         `SUBU: begin R = A - B; end
//         `AND: begin R = A && B; end
//         `OR: begin R = A || B; end
//         `NOR: begin R = A ~| B; end
//         `SLT: begin R = A < B; end
//         `SLTU: begin R = A < B; end
//         default: /* default catch */;
//       endcase
//     end
//     `OP_ONE: begin end
//     `ADDI: begin R = A + B; end
//     `ADDIU: begin R = A + B; end
//     `ANDI: begin R = A && B; end
//     `ORI: begin R = A || B; end
//     `SLTI: begin R = A < B; end
//     `SLTIU: begin R = A < B; end
//     default : ;
//     endcase
//   end
//
// endmodule
