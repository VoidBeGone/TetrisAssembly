#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Name, Student Number, UTorID, official email
# Student2: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed) 
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# Hard Features:
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# How to play:
# (Include any instructions)
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

##############################################################################

    .data
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
pixel: .word 4
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    jal draw_SCREEN
    jal load_array
start:
    li $t1, 0xff0000        # $t1 = red
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 4
    sw $t1, 0($t0)          # paint the first unit (i.e., top-left) red
    #this is just me making this pixel 
  
game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    
    li 		$v0, 32
    li 		$a0, 1
    syscall
    
    lw $t1, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard 0 basically contains status to say that if a key has been pressd 
    beq $t8, 1 , keyboard_input      # 1 means that It I CHECKING IF ANY KEY HAS BEEN PRESSED 
    b game_loop
   
keyboard_input:
	lw $a0, 4($t1)                  # Load word 
	beq $a0, 0x64, respond_to_D   
	beq $a0, 0x61, respond_to_A
	beq $a0, 0x73, respond_to_S
	beq $a0, 0x77, respond_to_W
	beq $a0, 0x70, start_QUIT
	b game_loop
	
	
	
#Everything in this box is for quiting 
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start_QUIT:
	li $t2, 0x000000
	lw $t0, ADDR_DSPL
	li $t1, 0
	li $t3, 4096
	#the code for the clearing screen will go under here
	jal  screen_CLEAR
	li $v0, 10
	syscall
#this is clearing my screen
screen_CLEAR:
	beq $t3, $t1, end_CLEAR
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	j screen_CLEAR
#this allow us to go back to the start_QUIT
end_CLEAR:
	jr $ra
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#Everything here will be for the initial start of the game
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
draw_SCREEN:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t8, $ra
	jal BORDER_SIDE
	jal BORDER_BOTTOM
	lw $ra 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
BORDER_SIDE:
	#right side border just do loop and 128 mod thing 
	li $t1, 0 
	li $t2, 0xf0f00f
	li $t3, 4096
	lw $t0, ADDR_DSPL
	
BORDER_LOOP_SIDE:
	beq $t3, $t1, end_DRAW
	sw $t2, 0($t0)
	addi $t0, $t0, 124
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 128
	j BORDER_LOOP_SIDE
	
BORDER_BOTTOM:
	li $t1, 3968
	li $t2, 0xf0f00f
	li $t3, 4096
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 3968

BORDER_BOTTOM_LOOP:
	beq $t3, $t1, end_DRAW
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	j BORDER_BOTTOM_LOOP
	
end_DRAW:
	jr $ra
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>	
	
	
	
#Everything in this box is for movement	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
respond_to_D:
	li $t2, 0xff0000        # $t1 = red     
    	lw $t1, pixel
    	addi $t3, $t1, 4 #each led is 4 position
    	li $t4, -4
    	
    	#Pushing and function
    	addi $sp, $sp, -8
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	jal RIGHT_SIDE_CHECK
	b game_loop

respond_to_A:
	li $t2, 0xff0000
	lw $t1, pixel 
	addi $t3, $t1, -4
	li $t4, 4
	#push thing 
	addi $sp, $sp, -8
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	jal LEFT_SIDE_CHECK
	b game_loop
	
respond_to_S:
	li $t2, 0xff0000
	lw $t1, pixel
	addi $t3, $t1, 128
	li $t4, -128
	#push this info to stack
	addi $sp, $sp, -8
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	jal checking_movement
	b game_loop
	


respond_to_W:
	lw $t1, pixel
	addi $t3, $t1, -128
	li $t4, 128
	#pushing from stack
	addi $sp, $sp, -8 #get space
	sw $t3, 4($sp)
	sw $t4, 0($sp) 
	jal MOVING_UP_CHECK
	b game_loop
	
	
CHANGING_LED:
#t4 will always have the number for deletion
#t3 will store the number of the move 
#t2 is color 
#t0 is display
	li $t2, 0xff0000
	lw $t0, ADDR_DSPL
	#Pulling from stack
	lw $t4, 0($sp)
	lw $t3, 4($sp)
	addi $sp, $sp, 8 #deallocate space
	
	sw $t3, pixel
	add $t0, $t0, $t3
	sw $t2, 0($t0)
	
	#pushing from stack 
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t4, 0($sp)
	jal REMOVING_OLD_LED
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
REMOVING_OLD_LED:
	#t4 contain the ammount previous you need to minus 
	li $t2, 0x000000
	#pulling from stack 
	lw $t4, 0($sp)
	addi $sp, $sp, 4
	#other code under 
	add $t0, $t0, $t4
	sw $t2, 0($t0)
	jr $ra
	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



#all the code under here will handle collisions
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#for testing purpose lets do the sides 

MOVING_UP_CHECK:
	#pulling everything off the stacks just in case
 	lw $t3, 4($sp)
 	lw $t4, 0($sp)
 	addi $sp, $sp, 8
 	ble $t3, $zero, game_loop
	
	#we can move so now load into stack
	addi $sp, $sp, -8
	sw $t3, 0($sp)
	sw $t4, 0($sp)
	j checking_movement
	
LEFT_SIDE_CHECK:
	lw $t3, 4($sp)
	lw $t4, 0($sp)
	addi $sp, $sp, 8
	#checking stuff
	li $t5, 128
	div $t3, $t5
	mfhi $t1 
	li $t6, 0
	beq $t1, $t6, game_loop
	
	#now we can move since we checked 
	addi $sp, $sp, -8
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	
	j checking_movement

RIGHT_SIDE_CHECK:
	lw $t3, 4($sp)
	lw $t4, 0($sp)
	addi $sp, $sp, 8
	addi $t3, $t3, 4
	
	li $t5, 128
	div $t3, $t5
	mfhi $t1
	li $t6, 0
	beq $t1, $t6, game_loop
	
	#now we can move we checked
	addi $t3, $t3, -4
	addi $sp, $sp, -8 
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	j checking_movement
	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#okay this will be for anything having to due with like block hitting 
#the ground or other blocks 
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# The logic for stopping the block and spawning a new one.
checking_movement:
    # Initialize my own things
    # Pull from the stack since this is checking down 
    lw $t0, ADDR_DSPL
    lw $t3, 4($sp) # Currently hosting how much I'm moving
    lw $t4, 0($sp) # Not really being used just scared to see what happens if I don't pull it out
    addi $sp, $sp, 8

    add $t0, $t0, $t3
    lw $t9, 0($t0)
    li $t8, 0x000000
    beq $t9, $t8, no_block
    # This means that there is a block so load this in mem if we cant move down

    # Check if we can move down
    add $t0, $t0, $t4
    addi $t0, $t0, 128 # Checking the position under me
    lw $t9, 0($t0)
    beq $t9, $t8, can_move_down

   # Finalize the block position and reset
    lw $t0, ADDR_DSPL
    li $t8, 4 # Resetting the pixel variable to a new starting position
    sw $t8, pixel
    li $t7, 0x10008000
    sw $t7, ADDR_DSPL
    j start # Go back to the start of the game loop
    
no_block:
    addi $sp, $sp, -8
    sw $t3, 4($sp)
    sw $t4, 0($sp)
    j CHANGING_LED

can_move_down:
    # Move down if there's space
    j game_loop

	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>




























