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
    move $t1, $t0 # $t1 is now a copy of the displayaddress
    lw $s0, bottomborder   #register to store the values of bottomborder
    li $s1, 0xff0000        # $s1 = red
    li $s2, 0x00ff00        # $s2 = green
    li $s3, 0x0000ff        # $s3 = blue
    add $s4, $s1, $s2       # s4 = yellow
    li $s5, 0xff6600        # s5 = orange
    li $s6, 0x800080        # s6 = purple
    li $s7, 0x808080        # s7 = grey

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

  # Check if we're at any top row position (any column in the top row) (144 to 168)

  # Calculate the range of top row positions
  addi $t1, $t0, 144      # leftmost top position
  addi $t2, $t0, 168      # rightmost top position

  # Check if $t9 is within the top row range
  blt $t9, $t1, skip_end_game_check 
  bgt $t9, $t2, skip_end_game_check 

  # Get colour of pixel below our rectangle
  addi $t6, $t9, 384     
  lw $t8, 0($t6)

  # If it's not black and not grey then game over (ie. if its the top of another rectangle)
  li $t7, 0x000000
  beq $t8, $t7, skip_end_game_check  # If black, keep playing

  li $t7, 0x808080
  beq $t8, $t7, skip_end_game_check  # If grey, keep playing

  # If it's a coloured block
  j exit
skip_end_game_check:

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
      beq $t8, 1, at_another_column     # Check for matches even at bottom border
      j check_column_collision
      
      
check_column_collision:
  # workflow: check if $t0 at $t9 + 128 is coloured - if it is stop moving
  add $t9, $t9, 384 # the pixel after the column ($t9+384+128 = 512)
  lw $t6, 0($t9) # load the colour of the pixel into $t6
  subi $t9, $t9, 384 #resets $t9 value
  bne $t6, 0x000000, at_another_column #checks that our current column collides with another column
  # No collision - move down normally
  li $v0, 0x0000
      sw $v0, 0($t9) # colour the top line black
      addi $t9, $t9, 128
  j draw_initial_blocks
  
at_another_column:
    li $t8, 1 # set collision flag
    j remove_line_of_same_gems

remove_line_of_same_gems:
    # Save return address and registers we'll use
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)  # Save $t5 to use as flag
    
    li $t5, 0  # Initialize "matches_found" flag to 0
    
    # Check horizontal matches (rows)
    addi $t6, $a2, 0        # Start at top-left corner (copy of $a2)
    li $t7, 15              # 15 rows to check

check_rows:
    beq $t7, $zero, check_cols_start
    
    # Check this row for 3+ matches
    move $t1, $t6           # Current position in row
    li $t2, 0               # Match counter
    li $t3, 0               # Previous color
    li $t4, 7               # 7 columns per row
    
check_row_loop:
    beq $t4, $zero, next_row
    lw $t8, 0($t1)          # Load current color
    beq $t8, 0x000000, reset_row_match  # Skip black (empty)
    beq $t8, $t3, increment_row_match   # Same as previous?
    
    # Different color - reset match
    move $t3, $t8           # Store new color
    li $t2, 1               # Reset count to 1
    j continue_row
    
increment_row_match:
    addi $t2, $t2, 1        # Increment match counter
    bge $t2, 3, found_row_match  # If 3+ matches, remove them
    j continue_row
    
reset_row_match:
    li $t2, 0
    li $t3, 0
    j continue_row
    
found_row_match:
    # Mark these 3 gems as black
    sw $zero, 0($t1)        # Current
    sw $zero, -4($t1)       # Previous
    sw $zero, -8($t1)       # Two back
    li $t5, 1               # Set flag that matches were found
    
continue_row:
    addi $t1, $t1, 4        # Next column
    addi $t4, $t4, -1
    j check_row_loop
    
next_row:
    addi $t6, $t6, 128      # Next row (128 bytes down)
    addi $t7, $t7, -1
    j check_rows

check_cols_start:
    # Check vertical matches (columns)
    addi $t6, $a2, 0        # Start at top-left corner
    li $t7, 7               # 7 columns to check
    
check_cols:
    beq $t7, $zero, check_diag_start
    
    move $t1, $t6           # Current position in column
    li $t2, 0               # Match counter
    li $t3, 0               # Previous color
    li $t4, 15              # 15 rows per column
    
check_col_loop:
    beq $t4, $zero, next_col
    lw $t8, 0($t1)          # Load current color
    beq $t8, 0x000000, reset_col_match  # Skip black
    
    beq $t8, $t3, increment_col_match
    
    move $t3, $t8
    li $t2, 1
    j continue_col
    
increment_col_match:
    addi $t2, $t2, 1
    bge $t2, 3, found_col_match
    j continue_col
    
reset_col_match:
    li $t2, 0
    li $t3, 0
    j continue_col
    
found_col_match:
    sw $zero, 0($t1)        # Current
    sw $zero, -128($t1)     # Previous row
    sw $zero, -256($t1)     # Two rows back
    li $t5, 1               # Set flag that matches were found
    
continue_col:
    addi $t1, $t1, 128      # Next row
    addi $t4, $t4, -1
    j check_col_loop
    
next_col:
    addi $t6, $t6, 4        # Next column
    addi $t7, $t7, -1
    j check_cols

check_diag_start:
    # Check diagonal matches (\) - down-right
    # First, check diagonals starting from top row (left to right)
    addi $t6, $a2, 0        # Start at top-left corner
    li $t7, 5               # 5 starting columns (need room for 3 diagonal)
    
check_diag_dr_top_row:
    beq $t7, $zero, check_diag_dr_left_col
    
    move $t1, $t6           # Current starting position
    li $t2, 0               # Match counter
    li $t3, 0               # Previous color
    li $t4, 13              # Max length of diagonal from top row
    
check_diag_dr_from_top:
    beq $t4, $zero, next_diag_dr_top
    lw $t8, 0($t1)
    beq $t8, 0x000000, reset_diag_dr_top
    beq $t8, $t3, increment_diag_dr_top
    
    move $t3, $t8
    li $t2, 1
    j continue_diag_dr_top
    
increment_diag_dr_top:
    addi $t2, $t2, 1
    bge $t2, 3, found_diag_dr_top
    j continue_diag_dr_top
    
reset_diag_dr_top:
    li $t2, 0
    li $t3, 0
    j continue_diag_dr_top
    
found_diag_dr_top:
    sw $zero, 0($t1)
    sw $zero, -132($t1)
    sw $zero, -264($t1)
    li $t5, 1
    
continue_diag_dr_top:
    addi $t1, $t1, 132
    addi $t4, $t4, -1
    j check_diag_dr_from_top
    
next_diag_dr_top:
    addi $t6, $t6, 4        # Move to next column in top row
    addi $t7, $t7, -1
    j check_diag_dr_top_row

check_diag_dr_left_col:
    # Now check diagonals starting from left column (top to bottom)
    addi $t6, $a2, 128      # Start at row 1, column 0
    li $t7, 12              # 12 starting rows (rows 1-12, need room for 3)
    
check_diag_dr_left_loop:
    beq $t7, $zero, check_diag_dl_start
    
    move $t1, $t6
    li $t2, 0
    li $t3, 0
    li $t4, 7               # Max columns available
    
check_diag_dr_from_left:
    beq $t4, $zero, next_diag_dr_left
    lw $t8, 0($t1)
    beq $t8, 0x000000, reset_diag_dr_left
    beq $t8, $t3, increment_diag_dr_left
    
    move $t3, $t8
    li $t2, 1
    j continue_diag_dr_left
    
increment_diag_dr_left:
    addi $t2, $t2, 1
    bge $t2, 3, found_diag_dr_left
    j continue_diag_dr_left
    
reset_diag_dr_left:
    li $t2, 0
    li $t3, 0
    j continue_diag_dr_left
    
found_diag_dr_left:
    sw $zero, 0($t1)
    sw $zero, -132($t1)
    sw $zero, -264($t1)
    li $t5, 1
    
continue_diag_dr_left:
    addi $t1, $t1, 132
    addi $t4, $t4, -1
    j check_diag_dr_from_left
    
next_diag_dr_left:
    addi $t6, $t6, 128
    addi $t7, $t7, -1
    j check_diag_dr_left_loop

check_diag_dl_start:
    # Check diagonal matches (/) - down-left
    # First, check diagonals starting from top row (right to left)
    addi $t6, $a2, 8        # Start at column 2 of top row (need 3 cols to the right)
    li $t7, 5               # 5 starting columns (2-6)
    
check_diag_dl_top_row:
    beq $t7, $zero, check_diag_dl_right_col
    
    move $t1, $t6
    li $t2, 0
    li $t3, 0
    li $t4, 13              # Max length
    
check_diag_dl_from_top:
    beq $t4, $zero, next_diag_dl_top
    lw $t8, 0($t1)
    beq $t8, 0x000000, reset_diag_dl_top
    beq $t8, $t3, increment_diag_dl_top
    
    move $t3, $t8
    li $t2, 1
    j continue_diag_dl_top
    
increment_diag_dl_top:
    addi $t2, $t2, 1
    bge $t2, 3, found_diag_dl_top
    j continue_diag_dl_top
    
reset_diag_dl_top:
    li $t2, 0
    li $t3, 0
    j continue_diag_dl_top
    
found_diag_dl_top:
    sw $zero, 0($t1)
    sw $zero, -124($t1)
    sw $zero, -248($t1)
    li $t5, 1
    
continue_diag_dl_top:
    addi $t1, $t1, 124
    addi $t4, $t4, -1
    j check_diag_dl_from_top
    
next_diag_dl_top:
    addi $t6, $t6, 4
    addi $t7, $t7, -1
    j check_diag_dl_top_row

check_diag_dl_right_col:
    # Check diagonals starting from right column (top to bottom)
    addi $t6, $a2, 152      # Row 1, column 6 (128 + 24)
    li $t7, 12              # 12 starting rows
    
check_diag_dl_right_loop:
    beq $t7, $zero, show_removed_matches
    
    move $t1, $t6
    li $t2, 0
    li $t3, 0
    li $t4, 7               # Max columns
    
check_diag_dl_from_right:
    beq $t4, $zero, next_diag_dl_right
    lw $t8, 0($t1)
    beq $t8, 0x000000, reset_diag_dl_right
    beq $t8, $t3, increment_diag_dl_right
    
    move $t3, $t8
    li $t2, 1
    j continue_diag_dl_right
    
increment_diag_dl_right:
    addi $t2, $t2, 1
    bge $t2, 3, found_diag_dl_right
    j continue_diag_dl_right
    
reset_diag_dl_right:
    li $t2, 0
    li $t3, 0
    j continue_diag_dl_right
    
found_diag_dl_right:
    sw $zero, 0($t1)
    sw $zero, -124($t1)
    sw $zero, -248($t1)
    li $t5, 1
    
continue_diag_dl_right:
    addi $t1, $t1, 124
    addi $t4, $t4, -1
    j check_diag_dl_from_right
    
next_diag_dl_right:
    addi $t6, $t6, 128
    addi $t7, $t7, -1
    j check_diag_dl_right_loop

show_removed_matches:
    # Check if any matches were found
    beq $t5, 0, no_matches_found
    
    # Restore registers to get column colors back
    lw $ra, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    addi $sp, $sp, 24
    
    # Redraw grid to show removed matches (black pixels)
    jal drawgrid
    
    # Add small delay to see the removed matches
    li $v0, 32
    li $a0, 300
    syscall
    
    j drop

no_matches_found:
    # Restore registers
    lw $ra, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    addi $sp, $sp, 24
    j reset_another_column_collision

drop:
    # Start from bottom row, move up
    # For each empty cell, look above for a colored gem
    li $t3, 0               # Flag to track if any drops occurred
    addi $t6, $a2, 1792     # Bottom-left of grid (a2 + 14*128)
    li $t7, 14              # Start from second-to-bottom row (row 14)
    
drop_rows:
    blt $t7, $zero, check_if_more_drops_needed
    
    move $t1, $t6           # Current row position
    li $t2, 7               # 7 columns
    
drop_cols:
    beq $t2, $zero, next_drop_row
    
    lw $t8, 128($t1)        # Check cell below
    bne $t8, 0x000000, skip_drop  # If not empty, skip
    
    # Cell below is empty, check if current has color
    lw $t8, 0($t1)
    beq $t8, 0x000000, skip_drop  # Current is empty too
    
    # Drop the gem
    sw $t8, 128($t1)        # Move to cell below
    sw $zero, 0($t1)        # Clear current cell
    li $t3, 1               # Set flag that a drop occurred
    
skip_drop:
    addi $t1, $t1, 4        # Next column
    addi $t2, $t2, -1
    j drop_cols
    
next_drop_row:
    subi $t6, $t6, 128      # Move up one row
    addi $t7, $t7, -1
    j drop_rows

check_if_more_drops_needed:
    beq $t3, 1, drop        # If drops occurred, do another pass
    j show_dropped_pixels   # Otherwise, we're done dropping

show_dropped_pixels:
    # Redraw grid to show dropped pixels
    jal drawgrid
    
    # Add small delay to see the drop
    li $v0, 32
    li $a0, 300
    syscall
    
    j remove_line_of_same_gems

reset_another_column_collision:
    # DON'T clear the current column position - it's already locked in place
    # Just generate new colors and reset position to top
    jal rand_colour
    move $t3, $v0             # store random colour in $t3
    
    jal rand_colour
    move $t4, $v0             # store random colour in $t4
    
    jal rand_colour
    move $t5, $v0             # store random colour in $t5
    
    addi $t9, $t0, 144        # Reset to centered position
    j draw_initial_blocks

reset:
    # Clear the current column position first (remove any black pixels)
    li $v0, 0x000000
    sw $v0, 0($t9)
    sw $v0, 128($t9)
    sw $v0, 256($t9)
    jal rand_colour           # generate random colour
    move $t3, $v0             # store random colour in $t3
    
    jal rand_colour
    move $t4, $v0             # store random colour in $t4
    
    jal rand_colour
    move $t5, $v0             # store random colour in $t5
    
    addi $t9, $t0, 144        # Reset to centered position
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