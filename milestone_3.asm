################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Elena, 1011012841
# Student 2: Tasfia Ara, 1009854686
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
    bottomborder: .space 28
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
    lw $s0, bottomborder   #register to store the values of bottomborder
    li $s1, 0xff0000        # $t1 = red
    li $s2, 0x00ff00        # $t2 = green
    li $s3, 0x0000ff        # $t3 = blue
    add $s4, $s1, $s2       # t4 = yellow
    li $s5, 0xff6600        # t5 = orange
    li $s6, 0x800080        # t6 = purple
    li $s7, 0x808080        # t7 = grey

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    
    jal rand_colour         # generate random colour
    move $t3, $v0           # store random colour in $t2
    
    jal rand_colour
    move $t4, $v0           # store random colour in $t3
    
    jal rand_colour
    move $t5, $v0           # store random colour in $t4

    addi $t9, $t0, 664      # $t9 stores the middle of top line of the grid
    addi $a2, $t0, 652      # a2 stores top-left corner inside grid
    addi $a3, $t0, 676      # a3 stores top-right corner inside grid
    
    
    
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
  li $t2, 15 # t2 has a new value 17
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
  li $t2, 15
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
    beq $a0, 0x77, respond_to_W     # Check if the key w (0x77) was pressed, shuffle
    beq $a0, 0x71, respond_to_Q     # Check if the key q (0x71) was pressed, quit
    beq $a0, 0x61, respond_to_A     # Check if a key is pressed, move column left
    beq $a0, 0x64, respond_to_D     # Check if d key is pressed, move column right
    beq $a0, 0x73, respond_to_S     # Check if s key is pressed, moves capsule down **one line at a time**

    li $v0, 1                       # Ask system to print $a0
    syscall

    b main
respond_to_A:
    move $t6, $a2           # Top-left grid position ($a2)
    li $t7, 15              # 15 rows to check
    li $t8, 0               # Flag: 0 = can move, 1 = at border
    
    check_left_border:
        beq $t7, $zero, check_left_done     # Checks if we've looped through all 15 column pixels
        beq $t9, $t6, at_left_border        # Checks if our current pixel position ($t9) is equal to the left border pixel ($t6)
        addi $t6, $t6, 128                  # If it wasn't equal, increment $t6 to the next row
        addi $t7, $t7, -1                   # Decrement $t7 for loop
        j check_left_border
        
    at_left_border:
        li, $t8, 1          # If pixel is at a border, modify our $t8 flag
        
    check_left_done:
        bne $t8, $zero, dont_move           # Check if flag equals to 1, if so redraw pixels in the same spot through dont_move function
        
        # Otherwise, move $t3 $t4, $t5 one pixel to the left (i.e substract)
        # Set current pixels to be black
        li $v0, 0x0000
        sw $v0, 0($t9)
        sw $v0, 128($t9)
        sw $v0, 256($t9)
  
        subi $t9, $t9, 4
        
        j draw_initial_blocks
        
dont_move:
    j draw_initial_blocks

respond_to_D:
    move $t6, $a3           # Top-right grid position ($a3)
    li $t7, 15              # 15 rows to check
    li $t8, 0               # Flag: 0 = can move, 1 = at border
    
    check_right_border:
        beq $t7, $zero, check_right_done     # Checks if we've looped through all 15 column pixels
        beq $t9, $t6, at_right_border        # Checks if our current pixel position ($t9) is equal to the left border pixel ($t6)
        addi $t6, $t6, 128                  # If it wasn't equal, increment $t6 to the next row
        addi $t7, $t7, -1                   # Decrement $t7 for loop
        j check_right_border
        
    at_right_border:
        li, $t8, 1          # If pixel is at a border, modify our $t8 flag
        
    check_right_done:
        bne $t8, $zero, dont_move           # Check if flag equals to 1, if so redraw pixels in the same spot through dont_move function
        
          # Otherwise, move $t3 $t4, $t5 one pixel to the right (i.e add constant)
          # Set current pixels to be black
          li $v0, 0x0000
          sw $v0, 0($t9)
          sw $v0, 128($t9)
          sw $v0, 256($t9)
          
          #update $t9 and paint new pixels 
          addi $t9, $t9, 4
          
          j draw_initial_blocks

respond_to_S:
    # li $v0, 2576
    # addi $t8, $t9, 256 # adding 3 rows = $t9 + 128 + 128 = $t9 + 256
    # # ble $v0, $t8, dont_move 

    ###

    addi $t6, $t0, 2080 #bottom right grid position
    li $t7, 8               # 7 columns to check
    li $t8, 0               # Flag: 0 = can move, 1 = at border, 2 = another column
    check_bottom_border:
        beq $t7, $zero, check_bottom_done   # Checks if we've looped through all 7 row pixels
        addi $t9, $t9, 384                  # bottom pixel value
        beq $t9, $t6, at_bottom_border      # Checks if our current bottom pixel position ($t9+384) is equal to the bottom border pixel ($t6)
        subi $t9, $t9, 384                  # reset $t9
        subi $t6, $t6, 4                    # If it wasn't equal, decrement $t6 to the next column
        addi $t7, $t7, -1                   # Decrement $t7 for loop
        j check_bottom_border
        
      at_bottom_border:
          li, $t8, 1          # If pixel is at a border, modify our $t8 flag
      check_bottom_done:
          beq $t8, 1, reset           # Check if flag equals to 1, if so redraw pixels in the same spot through dont_move function and create new columns
          
          
          j check_column_collision
          
          
    check_column_collision:
      # workflow: check if $t0 at $t9 + 128 is coloured - if it is stop moving
      add $t9, $t9, 384 # the pixel after the column ($t9+384+128 = 512)
      lw $t6, 0($t9) # load the colour of the pixel into $t6
      subi $t9, $t9, 384 #resets $t9 value
      bne $t6, 0x000000, at_another_column #checks that our current column collides with another column
      # No collision - move down normally
      # Otherwise, move $t3 $t4, $t5 one pixel to the left (i.e substract)
      # Set current pixels to be black
      li $v0, 0x0000
          sw $v0, 0($t9) # colour the top line black
          addi $t9, $t9, 128
      j draw_initial_blocks
      
    at_another_column:
      li, $t8, 1 # set collision flag
      j reset # Reset and create new column on top
      
        
    
  reset:
    jal rand_colour           # generate random colour
      move $t3, $v0           # store random colour in $t2
      
      jal rand_colour
      move $t4, $v0           # store random colour in $t3
      
      jal rand_colour
      move $t5, $v0           # store random colour in $t4
    addi $t9, $t0, 144      # $t9 stores the middle of top line of the grid (reset to original value)
    j draw_initial_blocks
    
  
  
respond_to_W:
	# initially, $t3 stores first colour, $t4 stores second, $t5 stores third
	move $t6, $t5                  # Store third colour in temporary register
	move $t5, $t4                  # Store second colour in third
	move $t4, $t3                  # Store first colour in second
	move $t3, $t6                  # Store third colour into first
	j draw_initial_blocks

respond_to_Q:
    j exit                          # Exit the game if player pressed q