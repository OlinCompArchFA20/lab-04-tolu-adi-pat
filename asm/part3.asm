li $t0, 8
li $t1, 4
li $t2, 1

loop:
    addiu $t1,$t1,1
    # beq $t0, $t1, end
    j loop

# end:
  #  addi $v0,$zero,1      #set syscall type to print int
  #  SYSCALL               #print $a0
  #  addi $v0,$zero,10     #set syscall type to exit
  #  SYSCALL               #exit
