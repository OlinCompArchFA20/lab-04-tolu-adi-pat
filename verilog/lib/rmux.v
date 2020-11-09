// ALU Control
`ifndef R_ALU_CONTROL
  `define R_ALU_CONTROL 0

  `define sll_  6'd0
  `define srl_  6'd2
  `define sra_  6'd3
  `define sllv_  6'd4
  `define srlv_  6'd6
  `define srav_ 6'd7
  `define jr_  6'd8
  `define jalr_   6'd9
  `define syscall_  6'd12
  `define mfhi_  6'd16
  `define mthi_  6'd17
  `define mflo_  6'd18
  `define mtlo_  6'd19
  `define mult_ 6'd24
  `define multu_  6'd25
  `define div_   6'd26
  `define divu_  6'd27
  `define add_  6'd32
  `define addu_  6'd33
  `define sub_  6'd34
  `define subu_  6'd35
  `define and_ 6'd36
  `define or_  6'd37
  `define xor_   6'd38
  `define nor_  6'd39
  `define slt_  6'd42
  `define sltu_  6'd43

`endif
