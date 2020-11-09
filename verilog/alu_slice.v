`include "defines.v"
`include "fa.v"
`include "sub.v"
`timescale 1ns / 1ps

module ALU_SLICE
 #(parameter DLY = 5)
  (input [2:0] Ctrl,
   input A, B, Cin,
   output reg R, Cout);

  // all Intermediary wires
  wire [13:0] mid;

  full_adder fa_add(.A(A),.B(B), .Ci(Cin), .S(mid[0]), .Co(mid[1]));
  full_sub fs_sub(.A(A),.B(B), .Ci(Cin), .S(mid[2]), .Co(mid[3]));
  //full_adder fa2_sub(.A(mid[2]), .B(mid[3]<<1), .Ci(Cin), .S(mid[4]), .Co(mid[5]));

  xor #DLY xor_bs(mid[6], A,B);


  not #DLY not_A(mid[12],A);
  nand #DLY nand_SLT(mid[13], mid[12], B);
  not #DLY and_SLT(mid[7], mid[13]); // take the outputs of the subtraction and xor them to get SLT output

  nand #DLY nand_bs(mid[9],A,B);
  not #DLY and_bs(mid[8],mid[9]);

  nor #DLY nor_bs(mid[10], A,B);
  not #DLY or_bs(mid[11], mid[10]);

  // MUX
  // Update 1'b0 to the appropriate wire from above
  always @* begin
    case (Ctrl)
      `ADD_:  begin R = mid[0]; Cout = mid[1]; end
      `SUB_:  begin R = mid[2]; Cout = mid[3]; end
      `XOR_:  begin R = mid[6]; end
      `SLT_:  begin R = mid[7]; Cout = 1'b0; end
      `AND_:  begin R = mid[8]; end
      `NAND_: begin R = mid[9]; end
      `NOR_:  begin R = mid[10]; end
      `OR_:   begin R = mid[11]; end
      default: /* default catch */;
    endcase
  end

endmodule
