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
  output reg [`W_RG_DST-1:0]  rg_dst,  //Register Dest.
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


  always @* begin
    case(inst[`FLD_OPCODE]) // evaluating op codes
      `OP_ZERO: begin // if the opcode is 0
        case (inst[`FLD_FUNCT]) // evaluating functs within opcode = 0
          `F_ADD: begin alu_op=`F_ADD;  end
          `F_ADDU: begin alu_op=`F_ADDU; end
          `F_AND: begin alu_op=`F_AND; end
          `F_NOR: begin alu_op=`F_NOR; end
          `F_OR: begin alu_op=`F_OR; end
          `F_SLT: begin alu_op=`F_SLT; end
          `F_SLTU: begin alu_op=`F_SLTU; end
          `F_SUBU: begin alu_op=`F_SUBU; end
          `F_SUB: begin alu_op=`F_SUB; end
          `F_XOR: begin alu_op=`F_XOR; end
          `F_SLL: begin alu_op=`F_SLL; end
          `F_SLLV: begin alu_op=`F_SLLV; end
          `F_SRA: begin alu_op=`F_SRA; end
          `F_SRAV: begin alu_op=`F_SRAV; end
          `F_SRL: begin alu_op=`F_SRL; end
          `F_SRLV: begin alu_op=`F_SRLV; end
          `F_DIV: begin alu_op=`F_DIV; end
          `F_DIVU: begin alu_op=`F_DIVU; end
          `F_MFHI: begin alu_op=`F_MFHI; end
          `F_MFLO: begin alu_op=`F_MFLO; end
          `F_MTHI: begin alu_op=`F_MTHI; end
          `F_MTLO: begin alu_op=`F_MTLO; end
          `F_MULT: begin alu_op=`F_MULT; end
          `F_MULTU: begin alu_op=`F_MULTU; end
          `F_BREAK: begin alu_op=`F_BREAK; end
          `F_JALR: begin alu_op=`F_JALR; end
          `F_JR: begin alu_op=`F_JR; end
          `F_SYSCAL: begin alu_op=`F_SYSCAL; end
          default: /* default catch */;
        endcase
      end
      `OP_ONE: begin end // for opcode 1
      `OP_TWO: begin wa = rs + imm; end // for opcode 2
      `OP_THREE: begin wa = rs + imm; end // for opcode 3
      `ANDI: begin wa = rs && imm; end
      `ORI: begin wa = rs || imm; end
      `SLTI: begin wa = rs < imm; end
      `SLTIU: begin wa = rs < imm; end
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
