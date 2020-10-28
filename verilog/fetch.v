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
        // Make sure you're very careful here!!
        // You need to add more cases here
        default     : pc_next <= pc_next + 4; 
      endcase
      if (`DEBUG_PC && ~rst) 
        $display("-- PC, PC/4 = %x, %d",pc_next,pc_next/4); 
    end
  end
endmodule

