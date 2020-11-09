`include "rumx.v"
`include "jumx.v"
`include "iumx.v"
`include "lib/opcodes.v"
`include "lib/debug.v"
`timescale 1ns / 1 ps

module DECODE
 (input [`W_CPU-1:0] inst,

  // Register File control
  output reg [`W_REG-1:0]     wa,      // Register Write Address
  output reg [`W_REG-1:0]     ra1,     // Register Read Address 1
  output reg [`W_REG-1:0]     ra2,     // Register Read Address 2
  output reg                  reg_wen, // Register Write Enable
  // Immediate
  output reg [`W_IMM_EXT-1:0] imm_ext, // 1-Sign or 0-Zero extend
  output reg [`W_IMM-1:0]     imm,     // Immediate Field
  // Jump Address
  output reg [`W_JADDR-1:0]   addr,    // Jump Addr Field
  // ALU Control
  output reg [`W_FUNCT-1:0]   alu_op,  // ALU OP
  // Muxing
  output reg [`W_PC_SRC-1:0]  pc_src,  // PC Source
  output reg [`W_MEM_CMD-1:0] mem_cmd, // Mem Command
  output reg [`W_ALU_SRC-1:0] alu_src, // ALU Source
  output reg [`W_REG_SRC-1:0] reg_src);// Mem to Reg

  // Unconditionally pull some instruction fields
  wire [`W_REG-1:0] rs;
  wire [`W_REG-1:0] rt;
  wire [`W_REG-1:0] rd;
  assign rs   = inst[`FLD_RS];
  assign rt   = inst[`FLD_RT];
  assign rd   = inst[`FLD_RD];
  assign imm  = inst[`FLD_IMM];
  assign addr = inst[`FLD_ADDR];

  always @(inst) begin
    if (`DEBUG_DECODE)
      /* verilator lint_off STMTDLY */
      #1 // Delay Slightly
      $display("op = %x rs = %x rt = %x rd = %x imm = %x addr = %x",inst[`FLD_OPCODE],rs,rt,rd,imm,addr);
      /* verilator lint_on STMTDLY */
  end


  // r-MUX
  // Update 1'b0 to the appropriate wire from above
  always @* begin
    case (Ctrl)
      `sll_:  begin wa = ra1 << 1'b0; end // 0
      `none: begin end // 1
      `srl_:  begin wa = ra1 >> 1'b0; end // 2
      `sra_:  begin end
      `sllv_:  begin end
      `srlv_:  begin end
      `srav_: begin end
      `jr_:  begin end
      `jalr_:   begin end
      `syscall_:  begin end
      `mfhi_:  begin end
      `mthi_:  begin end
      `mflo_:  begin end
      `mult_:  begin end
      `multu_: begin end
      `div_:  begin end
      `divu_:   begin end
      `add_:  begin wa = ra1 + ra2; end
      `addu_:  begin wa = ra1 + ra2; end
      `sub_:  begin wa = ra1 - ra2; end
      `subu_:  begin wa = ra1 - ra2; end
      `and_:  begin wa = ra1 && ra2; end
      `or_: begin wa = ra1 || ra2; end
      `xor_:  begin wa = ra1 ^ ra2; end
      `nor_:   begin wa = ra1 ~| ra2; end
      `slt_:   begin wa = ra1 < ra2; end
      `sltu_:   begin wa = ra1 < ra2; end
      default: /* default catch */;
    endcase
  end

  // j-MUX
  // Update 1'b0 to the appropriate wire from above
  always @* begin
    case (Ctrl)
      `j_:  begin end
      `jal_:  begin end
      default: /* default catch */;
    endcase
  end

  // i-MUX
  // Update 1'b0 to the appropriate wire from above
  always @* begin
    case (Ctrl)
      `beq_:  begin end
      `bne_:  begin end
      `blez_:  begin end
      `bgtz_:  begin end
      `addi_:  begin wa = ra1 + imm; end
      `addiu_: begin wa = ra1 + imm; end
      `slti_:  begin wa = ra1 < imm; end
      `sltiu_:   begin wa = ra1 < imm; end
      `andi_:  begin wa = ra1 && imm; end
      `ori_:  begin wa = ra1 || imm; end
      `xori_:  begin wa = ra1 ^ imm; end
      `lui_:  begin end
      `lb_:  begin end
      `lh_: begin end
      `lw_:  begin end
      `lbu_:   begin end
      `lhu_:  begin end
      `sb_:  begin end
      `sh_:  begin end
      `sw_:  begin end
      default: /* default catch */;
    endcase
  end


  always @* begin
    case(inst[`FLD_OPCODE])
      // Here be dragons.
      // @@@@@@@@@@@@@@@@@@@@@**^^""~~~"^@@^*@*@@**@@@@@@@@@
      // @@@@@@@@@@@@@*^^'"~   , - ' '; ,@@b. '  -e@@@@@@@@@
      // @@@@@@@@*^"~      . '     . ' ,@@@@(  e@*@@@@@@@@@@
      // @@@@@^~         .       .   ' @@@@@@, ~^@@@@@@@@@@@
      // @@@~ ,e**@@*e,  ,e**e, .    ' '@@@@@@e,  "*@@@@@'^@
      // @',e@@@@@@@@@@ e@@@@@@       ' '*@@@@@@    @@@'   0
      // @@@@@@@@@@@@@@@@@@@@@',e,     ;  ~^*^'    ;^~   ' 0
      // @@@@@@@@@@@@@@@^""^@@e@@@   .'           ,'   .'  @
      // @@@@@@@@@@@@@@'    '@@@@@ '         ,  ,e'  .    ;@
      // @@@@@@@@@@@@@' ,&&,  ^@*'     ,  .  i^"@e, ,e@e  @@
      // @@@@@@@@@@@@' ,@@@@,          ;  ,& !,,@@@e@@@@ e@@
      // @@@@@,~*@@*' ,@@@@@@e,   ',   e^~^@,   ~'@@@@@@,@@@
      // @@@@@@, ~" ,e@@@@@@@@@*e*@*  ,@e  @@""@e,,@@@@@@@@@
      // @@@@@@@@ee@@@@@@@@@@@@@@@" ,e@' ,e@' e@@@@@@@@@@@@@
      // @@@@@@@@@@@@@@@@@@@@@@@@" ,@" ,e@@e,,@@@@@@@@@@@@@@
      // @@@@@@@@@@@@@@@@@@@@@@@~ ,@@@,,0@@@@@@@@@@@@@@@@@@@
      // @@@@@@@@@@@@@@@@@@@@@@@@,,@@@@@@@@@@@@@@@@@@@@@@@@@
      // """""""""""""""""""""""""""""""""""""""""""""""""""
      // https://textart.io/art/tag/dragon/1


      default: begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; end
    endcase
  end
endmodule
