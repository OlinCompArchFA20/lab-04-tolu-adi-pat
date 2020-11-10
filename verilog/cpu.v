`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"

`timescale 1ns / 1ps


/*
Questions: TODO:
pc_src?
use instruction memory for processor memory???
can alu be behavioral?
should our decode be
- Unconditionally setting values of rs rt, imm addr etc
- and to set the ALU op code just a ton of muxing that looks for the assembly command? 

*/

module SINGLE_CYCLE_CPU
  (input clk,
   input rst);

   // start at a high lvl block diagram Here

   // PC FETCH Wires
   wire PC; // program counter wire
   wire [W_CPU-1:0] data_in;
   wire [W_CPU-1:0] data_addr;
   wire [W_CPU-1:0]  data_out;
   //wire jump;//pcsrc is jump
   wire [`W_EN-1:0] branch;
   wire PC_branch_handled;//PC after branch has been factored and 4 is added
   wire[W_CPU-6:0] branchmuxoutput;//wire to jump mux out of branch; adds nothing and lets PC+4+0, or adds PC+4+branch
   wire[W_PC_SRC-1:0] pc_src;// mux for jump select
  wire [W_CPU-1:0] reg_addr;
  wire [W_JADDR-1:0] jump_addr;//target address
  wire  [W_IMM-1:0] imm_addr;//imm address for branching
  wire [W_CPU-1:0] pc_next;//next pc value







   // decode wires
   wire [W_IMM-1:0] imm;
   wire [W_IMM_EXT-1:0] imm_ext;
   wire [W_OPCODE-1:0] alu_opcode;
   wire [W_CPU-1:0] instruction; // your 32 bit wide instruction that comes out of memory
  // wire rgdst;



   // processor Register wires
   wire writeRegEnable; // from decode, enables register write
   wire [W_CPU-1:0] dataToWrite; // from mux (either value from memory or ALU)
   wire [W_REG-1:0] rd; // register destination
   wire [W_REG-1:0] rt; // register input/dest t
   wire [W_REG-1:0] rs; // register input/dest t
   wire [W_CPU-1:0] dataA; // data in register A and 1st  alu input
   wire [W_CPU-1:0] dataB; // data in register B
   wire [W_REG-1:0] addressA; //address of register A
   wire [W_REG-1:0] addressB; // address of register B
   wire [W_REG-1:0] Aw; //write address
   wire [W_MEM_CMD-1:0] mem_cmd;//chooses rt or rd?? instead of rgdst



   // processor ALU wires
   wire [W_CPU-1:0] ALU_out; // alu result
   wire isZero; // used for JLT calculations
   wire alu_src; // from decode, picks between ALU inputs
   wire [W_CPU-1:0] ALU_in; // 2nd alu input
   wire overflow; //used to detect overflow




   // processor MEMORY wires
   wire [W_CPU-1:0] mem_out; // alu result





   // initializing PC and instruction components
   MEMORY instruction_memory(.clk(clk),.rst(rst),.PC(PC),.instruction(instruction), .mem_cmd(mem_cmd),.data_in(data_in),.data_addr(data_addr),.data_out(data_out));
   DECODE instruction_decode(.inst(instruction), .wa(Aw), .ra1(rs), .ra2(rt), .reg_wen(writeRegEnable), .imm_ext(imm_ext), .imm(immediate), .addr(), .alu_op(alu_opcode),.pc_src(pc_src), .mem_cmd(mem_cmd), .alu_src(alu_src), .reg_src(memToReg));
   FETCH instruction_fetch(.clk(clk), .rst(rst), .pc_src(pc_src), .branch_ctrl(branch_ctrl), .reg_addr(reg_addr), .jump_addr(jump_addr), .imm_addr(imm_addr), .pc_next(pc_next));


   // initializing processor components
   REGFILE processor_register(.clk(clk),.rst(rst),.wren(writeRegEnable),.wa(rgdst),.wd(dataToWrite), .ra1(rd),.ra2(rt),.rd1(dataA),.rd2(dataB));
   ALU processor_ALU(.alu_op(alu_opcode),.A(dataA),.B(ALU_in), .R(ALU_out),.overflow(overflow),.isZero(isZero));
   MEMORY processor_memory(.clk(clk),.rst(rst),.PC(PC),.instruction(instruction), .mem_cmd(mem_cmd),.data_in(data_in),.data_addr(data_addr),.data_out(mem_out));




   always @* begin
    case (memToReg)//MUX for data to write
      `mem_write: begin dataToWrite = ALU_out end
      `ALU_write: begin dataToWrite = mem_out end
      default: ;
    endcase
    end

    always @* begin
     case (alu_src)//MUX for B in ALU
       `dataBintoALU: begin ALU_in = dataB end
       `immintoALU: begin ALU_in = immediate end
       default: ;
     endcase
     end

     always @* begin
      case (mem_cmd)//MUX to set destination register for processor regfile
        `RdintoAw: begin Aw = rd end // if rgdst is 0
        `RtintoAw: begin Aw = rt end //
        default: ;
      endcase
      end

      //and gate for zero output ALU to branch
      nand #5 nandbranch(branch_mux_select_nand, isZero, branch);
      not #5 notbranch(branch_ctrl,branch_mux_select_nand);

      always @* begin
       case (branch_ctrl)//MUX for branch
         `nothingaddedtoPC: begin branchmuxoutput = 1'b0// PC updates
         `addbranchaddresstoPC: begin branchmuxoutput= immediate end
         default: ;
       endcase
       end

    //  PC_branch_handled = 1'd4 + branchmuxoutput + PC ;//update PC

      always @* begin
       case (pc_src)//MUX for jump and finalize update to PC
         `PCnewisPC: begin PC = PC_branch_handled end// PC updates
         `insttargetisPC: begin PC = instruction[W_CPU-6:0] end
         default: ;
       endcase
       end


  //SYSCALL Catch
  always @(posedge clk) begin
    //Is the instruction a SYSCALL?
    if (inst[`FLD_OPCODE] == `OP_ZERO &&
        inst[`FLD_FUNCT]  == `F_SYSCAL) begin
        case(rd1)
          1 : $display("SYSCALL  1: a0 = %x",rd2);
          10: begin
              $display("SYSCALL 10: Exiting...");
              $finish;
            end
          default:;
        endcase
    end
  end

endmodule
