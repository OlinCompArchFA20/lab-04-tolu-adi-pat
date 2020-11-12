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


  // TODO: does the ADDIU and ADDI have the same control bits?

  always @* begin
    case(inst[`FLD_OPCODE]) // evaluating op codes
      `OP_ZERO: begin // if the opcode is 0
        case (inst[`FLD_FUNCT]) // evaluating functs within opcode = 0
          `F_ADD: begin
             alu_op=`F_ADD; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT; end

          `F_ADDU: begin alu_op=`F_ADDU; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_AND: begin alu_op=`F_AND; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_NOR: begin alu_op=`F_NOR; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_OR: begin alu_op=`F_OR; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_SLT: begin alu_op=`F_SLT; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_SLTU: begin alu_op=`F_SLTU; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_SUBU: begin alu_op=`F_SUBU;  wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;end

          `F_SUB: begin alu_op=`F_SUB; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_XOR: begin alu_op=`F_XOR; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          // `F_SLL: begin alu_op=`F_SLL; end// TODO: pass in SHAMT?
          // `F_SRL: begin alu_op=`F_SRL; end// TODO: pass in SHAMT?
          // `F_SRA: begin alu_op=`F_SRA; end // TODO: pass in SHAMT?


          `F_SLLV: begin alu_op=`F_SLLV; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_SRAV: begin alu_op=`F_SRAV; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_SRLV: begin alu_op=`F_SRLV; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_DIV: begin alu_op=`F_DIV; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_DIVU: begin alu_op=`F_DIVU;  wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;end


          // `F_MFHI: begin alu_op=`F_MFHI; end // TODO: @tolu
          // `F_MFLO: begin alu_op=`F_MFLO; end
          // `F_MTHI: begin alu_op=`F_MTHI; end
          // `F_MTLO: begin alu_op=`F_MTLO; end

          `F_MULT: begin alu_op=`F_MULT; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          `F_MULTU: begin alu_op=`F_MULTU; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end

          // `F_BREAK: begin alu_op=`F_BREAK; end // TODO: ctrl for these
          // `F_JALR: begin alu_op=`F_JALR; end
          // `F_JR: begin alu_op=`F_JR; end
          `F_SYSCAL: begin alu_op=`F_ADD; wa=rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT; end
          default: /* default catch */;
        endcase
      end
      `OP_ONE: begin end // for opcode 1, TODO: not sure what to do

      `ADDIU: begin alu_op=`F_ADD; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      `ADDI: begin alu_op=`F_ADD; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      `ANDI: begin alu_op=`F_AND; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      `LUI: begin alu_op=`F_SLL; end
      `ORI: begin alu_op=`F_OR; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      `SLTI: begin alu_op=`F_SLT; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      `SLTIU: begin alu_op=`F_SLT; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      `XORI: begin alu_op=`F_XOR; wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT; end

      // `BEQ: begin alu_op=`F_SLT; end // TODO: Handle control bits for these
      // `BGEZ: begin alu_op=`F_SLT; end
      // `BGEZAL: begin alu_op=`F_SLT; end
      // `BGTZ: begin alu_op=`F_SLT; end
      // `BLTZ: begin alu_op=`F_SLT; end
      // `BLEZ: begin alu_op=`F_SLT; end
      // `BNE: begin alu_op=`F_SLT; end
      // `BLTZAL: begin alu_op=`F_SLT; end

      // `J_: begin alu_op=`F_ end // TODO: Resolve these
      // `JAL: begin alu_op=`end
      // `JALR: begin alu_op=`end // R type?
      // `MFC0: begin alu_op=`end
      // `JR: begin alu_op=`end // R type?
      // `MTC0: begin alu_op=` end

      // `LB: begin alu_op=`F_ADD; end // TODO: Handle control bits for these
      // `LBU: begin alu_op=`F_ADD; end
      // `LHU: begin alu_op=`F_ADD; end
      // `LH: begin alu_op=`F_ADD; end
      // `LW: begin alu_op=`F_ADD; end
      // `SB: begin alu_op=`F_ADD; end
      // `SW: begin alu_op=`F_ADD; end
      // `SH: begin alu_op=`F_ADD; end

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
