addiu $t0, $zero, 8
addiu $t1, $zero, 3

loopy:
    addu $t0,$t0,$t1
    j loopy
