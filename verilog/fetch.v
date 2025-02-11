`include "lib/opcodes.v"
`include "lib/debug.v"
`timescale 1ns / 1ps

module FETCH
 (input                      clk,
  input                      rst,
  input      [`W_PC_SRC-1:0] pc_src,
  input      [`W_EN-1:0]     branch_ctrl,
  input      [`W_CPU-1:0]    reg_addr,
  input      [`W_JADDR-1:0]  jump_addr,
  input      [`W_IMM-1:0]    imm_addr,
  output reg [`W_CPU-1:0]    pc_next);


  always @(posedge clk, posedge rst) begin
    if (rst) begin
      pc_next <= `W_CPU'd0;
    end
    else begin
      case(pc_src)
        //`PC_SRC_NEXT: begin pc_next = pc_next + `W_CPU'b100; end
        `PC_SRC_JUMP: begin pc_next = {pc_next[`PC_UPPER], jump_addr, `W_WORD'b0}; $display("JUMP = %x",jump_addr); end


        `PC_SRC_BRCH: begin  if (branch_ctrl == 1)  pc_next = pc_next + 4 + {{(14){imm_addr[`W_IMM-1]}}, imm_addr, 2'b0};
                      else pc_next = pc_next + 4; end
        //`PC_SRC_REGF: pc_next = reg_addr;
        default: pc_next <= pc_next + 4;
      endcase
      if (`DEBUG_PC && ~rst)
        $display("-- PC, PC/4 = %x, %d",pc_next,pc_next/4);
    end
  end
endmodule
