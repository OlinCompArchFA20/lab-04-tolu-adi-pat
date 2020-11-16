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
  // Shift
  output reg [`W_SHA_EXT-1:0] sha_ext,//Sign extend for shamt
  output reg [`W_SHAMT-1:0]   sha,     // Shift Amount
  // Jump Address
  output reg [`W_JADDR-1:0]   jump_addr,    // Jump Addr Field
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
  assign sha  = inst[`FLD_SHAMT];
  assign addr = inst[`FLD_ADDR];
  //assign sha_ext = SHA_SIGN_EXT;

  always @(inst) begin
    if (`DEBUG_DECODE)
      /* verilator lint_off STMTDLY */
      #1 // Delay Slightly
      $display("op = %x rs = %x rt = %x rd = %x imm = %x addr = %x",inst[`FLD_OPCODE],rs,rt,rd,imm,addr);
      $display("inst = %x",inst);

      /* verilator lint_on STMTDLY */
  end


  // TODO: does the ADDIU and ADDI have the same control bits?

  always @* begin
      case(inst[`FLD_OPCODE])

        // R-type
        `OP_ZERO: begin
          case(inst[`FLD_FUNCT])

            `F_SLL: begin alu_src = `ALU_SRC_SHA; alu_op = `F_SLL; wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; sha_ext = `SHA_ZERO_EXT; mem_cmd = `MEM_NOP; reg_src = `REG_SRC_ALU; pc_src  = `PC_SRC_NEXT; end

            `F_SRL: begin alu_src = `ALU_SRC_SHA; alu_op = `F_SRL; wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
            imm_ext = `IMM_SIGN_EXT; sha_ext = `SHA_ZERO_EXT; mem_cmd = `MEM_NOP; reg_src = `REG_SRC_ALU; pc_src  = `PC_SRC_NEXT; end

            `F_SRA: begin alu_src = `ALU_SRC_SHA; alu_op = `F_SRA; wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
            imm_ext = `IMM_SIGN_EXT; sha_ext = `SHA_SIGN_EXT; mem_cmd = `MEM_NOP; reg_src = `REG_SRC_ALU; pc_src  = `PC_SRC_NEXT; end

            `F_SRAV: begin alu_src = `ALU_SRC_REG; alu_op = `F_SRA; wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
            imm_ext = `IMM_SIGN_EXT; sha_ext = `SHA_SIGN_EXT; mem_cmd = `MEM_NOP; reg_src = `REG_SRC_ALU; pc_src  = `PC_SRC_NEXT; end

            // address1 = $v0 & address2 = $a0
            `F_SYSCAL: begin
              ra1 = `REG_V0; ra2 = `REG_A0; wa = rd; reg_wen = `WREN;
              imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
              alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
              pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
            end
            default: begin wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; end
          endcase
        end

        // I-type

        // Sign extend
        `ADDI: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end

        `ANDI: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND;
        end

        `ORI: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR;
        end

        `SLTI: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT;
        end

        `XORI: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_XOR;
        end

        // No Sign extend
        `ADDIU: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
        end

        `SLTIU: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU;
        end

        `BEQ, `BNE: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUBU;
        end

        `LW: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
        end

        `SW: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
        end

        // J-type
        `J_: begin
        wa = rd; ra1 = `W_REG'b0; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_JUMP;  alu_op  = `F_ADD; jump_addr = addr;
        end

        default: begin
          wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; end
      endcase
    end
    endmodule
