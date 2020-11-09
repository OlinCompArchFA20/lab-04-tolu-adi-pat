// ALU Control
`ifndef I_ALU_CONTROL
  `define I_ALU_CONTROL 0

  `define beq_  6'd4
  `define bne_  6'd5
  `define blez_  6'd6
  `define bgtz_  6'd7
  `define addi_  6'd8
  `define addiu_ 6'd9
  `define slti_  6'd10
  `define sltiu_   6'd11
  `define andi_  6'd12
  `define ori_  6'd13
  `define xori_  6'd14
  `define lui_  6'd15
  `define lb_  6'd32
  `define lh_ 6'd33
  `define lw_  6'd34
  `define lbu_   6'd36
  `define lhu_  6'd37
  `define sb_  6'd40
  `define sh_  6'd41
  `define sw_  6'd43

`endif
