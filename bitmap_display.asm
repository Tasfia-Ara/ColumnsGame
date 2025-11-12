##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
    li $s1, 0xff0000        # $t1 = red
    li $s2, 0x00ff00        # $t2 = green
    li $s3, 0x0000ff        # $t3 = blue
    add $s4, $s1, $s2       # t4 = yellow
    li $s5, 0xff6600        # t5 = orange
    li $s6, 0x800080        # t6 = purple
    li $s7, 0x808080        # t7 = grey

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    # sw $s1, 0($t0)          # paint the first unit (i.e., top-left) red
    # sw $s2, 4($t0)          # paint the second unit on the first row green
    # sw $s3, 8($t0)        # paint the first unit on the second row blue
    # sw $s4, 12($t0)
    # sw $s5, 16($t0)
    # sw $s6, 20($t0)
    # sw $s7, 24($t0)
    j drawgrid

drawgrid:
  # Grid dimensions: 17*7
  addi $t0, $t0, 524 # first pixel
  sw $s7, 0($t0) # show the first pixel
  li $t2, 7 #ending condition
  li $t1, 0 #starting
  loop1:
    beq $t1, $t2, rightbord
      addi $t0, $t0, 4
      sw $s7, 0($t0)
      add $t1, $t1, 1
      j loop1
    
  rightbord:
  li $t2, 17 # t2 has a new value 17
  li $t1, 0 #starting 
  addi $t0, $t0, 128
  sw $s7, 0($t0)
    loop2:
    beq $t1, $t2, bottombord
      addi $t0, $t0, 128
      sw $s7, 0($t0)
      add $t1, $t1, 1
      j loop2

bottombord:
  li $t2, 7
  li $t1, 0
  subi $t0, $t0, 4
  sw $s7, 0($t0) #first new pixel
    loop3:
      beq $t1, $t2, leftbord
        subi $t0, $t0, 4
        sw $s7, 0($t0)
        add $t1, $t1, 1
        j loop3

leftbord:
  li $t2, 17
  li $t1, 0
  subi $t0, $t0, 128
  sw $s7, 0($t0)
  loop4:
    beq $t1, $t2, exit
      subi $t0, $t0, 128
      sw $s7, 0($t0)
      add $t1, $t1, 1
      j loop4
  
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
