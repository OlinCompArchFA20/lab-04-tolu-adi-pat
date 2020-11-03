  li  $s0, 1    # $s0 is our index = 1
  li  $s1, 0    # $s1 is our odd sum = 0
  li  $s2, 0    # $s2 is our even sum = 0
  li  $t0, 2    # $t0 is our divider to see if number is odd or even

Loop:  beq  $s0, 101, End  # if index > 100, jump to 'End'
  rem  $s4, $s0, $t0  # remainder of $s0/$t0 is stored in $s4
  beq  $s4, 0, Even  # if the remainder = 0 then jump to 'Even'
  add  $s1, $s1, $s0  # if $s0 is odd we add to $s1
  addi  $s0, $s0, 1  # increment index by 1
  j  Loop    # jump back to 'Loop'

Even:  add  $s2, $s2, $s0  # if $s0 is even we add to $s2
  addi  $s0, $s0, 1  # increment index by 1
  j  Loop    # jump back to 'Loop'
  
End:  move  $s6, $s1  # move the final odd sum to $s6
  move  $s7, $s2  # move the final even sum to $s7