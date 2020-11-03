  li  $s0, 2    # $s0 is current index of the sequence
  li  $s1, 0    # $s1 is the 1st value of our sequence
  li  $s2, 1    # $s2 is the 2nd value of our sequence
  li  $s4, 0    # $s4 is where we hold our current index value

Loop:  beq  $s0, 10, End  # if index > 10, jump to 'End'
  add  $s4, $s1, $s2  # current index value is the sum of the previous two index values
  move  $s1, $s2  # update the n-2 index value to be previous n-1 value
  move  $s2, $s4  # update the n-1 index value to be previous n value
  addi  $s0, $s0, 1  # increment index by 1
  j  Loop    # jump back to 'Loop'

End:  move  $s5, $s4  # move the final odd sum to $s3