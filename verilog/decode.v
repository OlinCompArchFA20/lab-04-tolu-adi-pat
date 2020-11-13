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
      case(inst[`FLD_OPCODE])

        // R-type instruction.
        // NOTE: Since we're using RS and RT for operations, immediate doesn't matter, but we still need to set imm_ext.
        // NOTE: not sure how to deal with unsigned vs signed operations? Should it be handled in the ALU?
        `OP_ZERO: begin
          wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];

          // Differentiate by FUNCT cases, do this for shifts and syscall
          case(inst[`FLD_FUNCT])
            `F_SLL, `F_SRL, `F_SRA: alu_src = `ALU_SRC_SHA;
            // If syscall, set read address1 to be $v0 and read address2 to be $a0
            `F_SYSCAL: begin
              ra1 = `REG_V0; ra2 = `REG_A0;
            end
            default: ;
          endcase
        end

        // I-type instruction.

        // Cases where we sign extend
        `ADDI, `ANDI, `ORI, `SLTI, `XORI: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_OPCODE];
        end

        // Cases where we don't sign extend
        `ADDIU, `SLTIU: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_OPCODE];
        end

        `BEQ, `BNE: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUB;
        end

        `LW: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end

        `SW: begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end

        // J-type instructions
        `J_: begin
          // Nothing matters except for pc_src
          wa = rd; ra1 = `W_REG'b0; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_JUMP;  alu_op  = `F_ADD;
        end



        //Is default NOP? Not sure what to do for NOP.

        default: begin
          wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; end
      endcase
    end
    endmodule
