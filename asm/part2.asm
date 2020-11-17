li $t3, 100
li $t2, 100
srl  $t3, $t3, -4
sll  $t2, $t2, 4
# addi $a0, $t2, 32

li $v0 10
syscall
