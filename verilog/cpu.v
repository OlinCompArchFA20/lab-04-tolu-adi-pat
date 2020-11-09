`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"

`timescale 1ns / 1ps

module SINGLE_CYCLE_CPU
  (input clk,
   input rst);

   // start at a high lvl block diagram Here

   // PC Wires
   wire PC; // program counter wire
   wire [W_CPU-1:0] data_in;
   wire  [W_CPU-1:0] data_addr;
   wire [W_CPU-1:0]  data_out;
   wire jump;
   wire branch;
   wire PC_new;//updated PC after 4 is added
   wire[W_CPU-6:0] branchmuxinput;//wire to jump mux; adds nothing and lets PC+4+), or adds PC+4+branch


   // decode wires
   wire [W_IMM-1:0] imm;
   wire [W_OPCODE-1:0] alu_opcode;
   wire [W_CPU-1:0] instruction; // your 32 bit wide instruction that comes out of memory

   // processor Register wires
   wire writeRegEnable; // from decode, enables register write
   wire [W_CPU-1:0] dataToWrite; // from mux (either value from memory or ALU)
   wire [W_REG-1:0] rd; // register destination
   wire [W_REG-1:0] rt; // register input/dest t
   wire [W_CPU-1:0] dataA; // data in register A
   wire [W_CPU-1:0] dataB; // data in register B
   wire [W_REG-1:0] addressA; //address of register A
   wire [W_REG-1:0] addressB; // address of register B
   wire [W_REG-1:0] Aw; //write address



   // processor ALU wires
   wire [W_CPU-1:0] ALU_out; // alu result
   wire isZero; // used for JLT calculations
   wire alu_src; // from decode, picks between ALU inputs
   wire [W_CPU-1:0] ALU_in; // 2nd alu input



   // processor MEMORY wires
   wire [W_CPU-1:0] mem_out; // alu result
   wire  [W_MEM_CMD-1:0] mem_cmd;




   // initializing PC and instruction components
   MEMORY instruction_memory(.clk(clk),.rst(rst),.PC(PC),.instruction(instruction), .mem_cmd(mem_cmd),.data_in(data_in),.data_addr(data_addr),.data_out(data_out));
   DECODE instruction_decode(.inst(), .wa(), .ra1(), .ra2(), .reg_wen(writeRegEnable), .imm_ext(), .imm(immediate), .addr(), .alu_op(alu_opcode),.pc_src(), .mem_cmd(), .alu_src(alu_src), .reg_src());
   ALU jump_ALU(.alu_op(0),.A(PC),.B(1'd4), .R(PC_new),.overflow(),.isZero()); // add 4 every PC increment


   // initializing processor components
   REGFILE processor_register(.clk(clk),.rst(rst),.wren(writeRegEnable),.wa(),.wd(), .ra1(),.ra2(),.rd1(),.rd2());
   ALU processor_ALU(.alu_op(alu_opcode),.A(),.B(), .R(ALU_out),.overflow(),.isZero(isZero));
   MEMORY processor_memory(.clk(clk),.rst(rst),.PC(),.instruction(), .mem_cmd(),.data_in(),.data_addr(),.data_out());



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
      case (rgdst)//MUX for reg destination
        `RdintoAw: begin Aw = rd end
        `RtintoAw: begin Aw = rt end
        default: ;
      endcase
      end

      always @* begin
       case (branch)//MUX for branch
         `nothingaddedtoPC: begin PC = PC_new end// PC updates
         `insttargetisPC: begin PC = instruction(25:0) end
         default: ;
       endcase
       end

      always @* begin
       case (jump)//MUX for jump
         `PCnewisPC: begin PC = PC_new end// PC updates
         `insttargetisPC: begin PC = branchmuxinput end
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
