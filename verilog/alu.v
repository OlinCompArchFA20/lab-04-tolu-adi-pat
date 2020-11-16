`include "lib/opcodes.v"
`timescale 1ns / 1ps

module ALU
 (input      [`W_OPCODE-1:0]  alu_op,
  input      [`W_CPU-1:0]     A,
  input      [`W_CPU-1:0]     B,
  output reg [`W_CPU-1:0]     R,
  output reg overflow, // 1 if overflow, 0 if not
  output reg isZero);

  // reg temp;
  // behavioral ALU

  always @* begin
    case(alu_op)
    `F_ADD: begin R = A + B; end // add
    `F_ADDU: begin R = A + B; end // add unsigned
    `F_AND: begin R = A & B; end
    `F_NOR: begin R = A ~| B; end
    `F_OR: begin R = A | B;  end

    `F_SLT: begin  if (A < B)  R = `W_CPU'b1;
      else R = `W_CPU'b0;
      end
    `F_SLTU: begin if (A < B)  R = `W_CPU'b1;
      else R = `W_CPU'b0; end
    `F_SUBU: begin R = A - B; end
    `F_SUB: begin R = A - B; end
    `F_XOR: begin R = A ^ B; end
    `F_SLL: begin R = A << B; end
    `F_SLLV: begin R = A << B; end
    `F_SRA: begin R = A >> B; end
    `F_SRAV: begin R = A >> B; end
    `F_SRL: begin R = A >> B; end
    `F_SRLV: begin R = A >> B; end
    `F_DIV: begin R = A / B; end
    `F_DIVU: begin R = A / B; end
    //`F_MFHI: begin end
    //`F_MFLO: begin end
    //`F_MTHI: begin end
    //`F_MTLO: begin end
    `F_MULT: begin R = A * B; end
    `F_MULTU: begin R = A * B; end
    //`F_BREAK: begin end
    //`F_JALR: begin end
    //`F_JR: begin end
    //`F_SYSCAL: begin end
    default: ;
    endcase
    end

    reg temp;
    always @*
    begin
    if (R == 1'b0)
         temp = 1'b1;
    else
        temp = 1'b0;
    end

    assign isZero = temp;

    // if (R == 0)  assign isZero = 1;

endmodule
