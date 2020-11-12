`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"

`timescale 1ns / 1ps


/*
Questions: TODO:
imm_ext? mux?
*/

module SINGLE_CYCLE_CPU
  (input clk,
   input rst);

   // start at a high lvl block diagram Here

   // PC FETCH Wires
   wire [`W_CPU-1:0] PC; // program counter wire
   wire [`W_CPU-1:0] data_in;
   wire [`W_EN-1:0] branch_ctrl;


   //wire jump;//pcsrc is jump
   //wire [W_EN-1:0] branch;
  // wire PC_branch_handled;//PC after branch has been factored and 4 is added
   //wire[W_CPU-6:0] branchmuxoutput;//wire to jump mux out of branch; adds nothing and lets +4+0, or adds +4+branch

   wire [`W_PC_SRC-1:0] pc_src;// mux for jump select
   wire [`W_CPU-1:0] reg_addr;
   wire [`W_JADDR-1:0] jump_addr;//target address
   wire [`W_IMM-1:0] imm_addr;//imm address for branching
   wire [`W_CPU-1:0] pc_next;//next pc value
   wire [`W_JADDR-1:0] addr; // jump addr field for branching


   // decode wires
   wire [`W_IMM-1:0] imm;
   wire [`W_IMM_EXT-1:0] imm_ext;
   wire [`W_OPCODE-1:0] alu_opcode;
   wire [`W_CPU-1:0] instruction; // your 32 bit wide instruction that comes out of memory
   wire [`W_REG_SRC-1:0] memToReg;
   wire [`W_CPU-`W_IMM -1: 0] imm_ext_16;


   // processor Register wires
   wire writeRegEnable; // from decode, enables register write
   reg [`W_CPU-1:0] dataToWrite_reg;
   //wire [`W_CPU-1:0] dataToWrite; // from mux (either value from memory or ALU)
   wire [`W_REG-1:0] rd; // register destination
   wire [`W_REG-1:0] rt; // register input/dest t
   wire [`W_REG-1:0] rs; // register input/dest t
   wire [`W_CPU-1:0] dataA; // data in register A and 1st  alu input
   wire [`W_CPU-1:0] dataB; // data in register B
   wire [`W_REG-1:0] addressA; //address of register A
   wire [`W_REG-1:0] addressB; // address of register B
   wire [`W_REG-1:0] Aw; // this is the output of the mux
   wire [`W_MEM_CMD-1:0] mem_cmd; // chooses to write to processor memory or not



   // processor ALU wires
   wire [`W_CPU-1:0] ALU_out; // alu result
   wire isZero; // used for JLT calculations, output of ALU
   wire [`W_ALU_SRC-1:0] alu_src; // from decode, picks between ALU inputs
   reg [`W_CPU-1:0] ALU_in; // 2nd alu input
   wire overflow; //used to detect overflow

   // processor MEMORY wires
   wire [`W_CPU-1:0] mem_out; // alu result



   // initializing PC and instruction components
   DECODE instruction_decode(.inst(instruction), .wa(Aw), .ra1(rs), .ra2(rt), .reg_wen(writeRegEnable), .imm_ext(imm_ext), .imm(imm), .addr(addr), .alu_op(alu_opcode),.pc_src(pc_src), .mem_cmd(mem_cmd), .alu_src(alu_src), .reg_src(memToReg));
   assign imm_ext_16 = {`W_IMM{imm_ext}};
   FETCH instruction_fetch(.clk(clk), .rst(rst), .pc_src(pc_src), .branch_ctrl(branch_ctrl), .reg_addr(reg_addr), .jump_addr(jump_addr), .imm_addr(imm_addr), .pc_next(pc_next));

   // this memory serves as both instruction and processor memory
   MEMORY stage_MEMORY(.clk(clk),.rst(rst),.PC(PC),.instruction(instruction), .mem_cmd(mem_cmd),.data_in(dataB),.data_addr(ALU_out),.data_out(mem_out));

   // initializing processor components
   REGFILE processor_register(.clk(clk),.rst(rst),.wren(writeRegEnable),.wa(Aw),.wd(dataToWrite_reg), .ra1(rd),.ra2(rt),.rd1(dataA),.rd2(dataB));
   ALU processor_ALU(.alu_op(alu_opcode),.A(dataA),.B(ALU_in), .R(ALU_out),.overflow(overflow),.isZero(isZero));
   // MEMORY processor_memory(.clk(clk),.rst(rst),.PC(PC),.instruction(instruction), .mem_cmd(mem_cmd),.data_in(data_in),.data_addr(data_addr),.data_out(mem_out));


   always @* begin
    case (memToReg)//MUX for data to write
      `REG_SRC_MEM: begin dataToWrite_reg = mem_out; end
      `REG_SRC_ALU: begin dataToWrite_reg = ALU_out; end
      `REG_SRC_PC: begin dataToWrite_reg = PC; end
      default: ;
    endcase
    end

    always @* begin
     case (alu_src)//MUX for B in ALU
       `ALU_SRC_REG: begin ALU_in = dataB; end
       `ALU_SRC_IMM: begin ALU_in[`W_IMM-1:0] = imm;
                            ALU_in[`W_CPU-1:`W_IMM] = imm_ext_16; end
       // `ALU_SRC_SHA: begin end
       default: ;
     endcase
     end

      //and gate for zero output ALU to branch
      //nand #5 nandbranch(branch_mux_select_nand, isZero, branch);
      //not #5 notbranch(branch_ctrl,branch_mux_select_nand);


  // the format you print in is determined by the value of $v0
  // you always actually print whatever is in $a0 or $a1 etc
  // call syscal to print

  // TODO: SYSCALL Catch
  always @(posedge clk) begin
    //Is the instruction a SYSCALL?
    if (instruction[`FLD_OPCODE] == `OP_ZERO &&
        instruction[`FLD_FUNCT]  == `F_SYSCAL) begin
        case(dataA) // output from regfile
          1 : $display("SYSCALL  1: a0 = %x",dataB);
          10: begin
              $display("SYSCALL 10: Exiting...");
              $finish;
            end
          default: $display("SYSCALL  1: a0 = %x",dataB);
        endcase
    end
  end

endmodule
