################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Elena, 1011012841
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################

    .data
    displayaddress: .word 0x10008000
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game

    lw $t0, displayaddress # $t0 = base address for display
    
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
    
    jal rand_colour         # generate random colour
    move $t3, $v0           # store random colour in $t2
    
    jal rand_colour
    move $t4, $v0           # store random colour in $t3
    
    jal rand_colour
    move $t5, $v0           # store random colour in $t4

    addi $t9, $t0, 664      # $t9 stores the middle of top line of the grid
    
draw_initial_blocks:
    sw $t3, 0($t9)          # draw the first block
    sw $t4, 128($t9)        # draw the second block on next row
    sw $t5, 256($t9)        # draw the third block on next row
    
    jal drawgrid
    
    li $v0, 32
	li $a0, 1
    
    lw $t1, ADDR_KBRD               # $t1 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed

    
drawgrid:
  # Grid dimensions: 17*7
  lw $t0, displayaddress
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
    beq $t1, $t2, temp
      subi $t0, $t0, 128
      sw $s7, 0($t0)
      add $t1, $t1, 1
      j loop4
  
temp:
    jr $ra

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
    
    
rand_colour:
    # Random colour:
    li   $v0, 42          
    li   $a0, 0          
    li   $a1, 6             # upper bound
    syscall                 # return value is in $a0
    move $t8, $a0           # $t1 = random number 0–5
    
    move $t9, $s1       # red
    beq  $t8, 0, color_done

    move $t9, $s5       # orange
    beq $t8, 1, color_done

    move $t9, $s4       # yellow
    beq $t8, 2, color_done

    move $t9, $s2       # green
    beq $t8, 3, color_done

    move $t9, $s3       # blue
    beq $t8, 4, color_done

    move $t9, $s6       # purple
    beq $t8, 5, color_done
    
color_done:
    move $v0, $t9
    jr $ra
    
keyboard_input:                     # A key is pressed
    lw $a0, 4($t1)                  # Load second word from keyboard
    beq $a0, 0x77, respond_to_W     # Check if the key w (0x77) was pressed
    beq $a0, 0x71, respond_to_Q     # Check if the key q (0x71) was pressed

    li $v0, 1                       # Ask system to print $a0
    syscall

    b main

respond_to_W:
	# initially, $t3 stores first colour, $t4 stores second, $t5 stores third
	move $t6, $t5                  # Store third colour in temporary register
	move $t5, $t4                  # Store second colour in third
	move $t4, $t3                  # Store first colour in second
	move $t3, $t6                  # Store third colour into first
	j draw_initial_blocks

respond_to_Q:
    j exit                          # Exit the game if player pressed q

