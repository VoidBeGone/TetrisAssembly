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
pixel: .word 0,0,0,0 #store the offset
rotationState: .word 0 # because some shapes have less then two axis of symetry
type: .word 1 # 0 = block 1 = line , 2 = s , 3= z, 4=L 5 =  J, 6= T
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    jal draw_SCREEN

start:

    
    jal storeLineV
    
  
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
	jal moveLine1R
	b game_loop
	
	######### DNE
	li $t2, 0xff0000        # $t1 = red     
    	la $t0, pixel
    	addi $t3, $t1, 4 #each led is 4 position
    	li $t4, -4
    	
    	#Pushing and function
    	addi $sp, $sp, -8
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	jal RIGHT_SIDE_CHECK
	b game_loop

respond_to_A:
	jal moveLine1L
	b game_loop
	
	######### DNE
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
	jal BOTTOM_SIDE_CHECK
	jal moveLine1D
	b game_loop


	


respond_to_W:
	lw $t0, ADDR_DSPL
	la $t1, pixel
	li $t3, 0x000000
	###clear off the screen
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	####### change form
	la $t1, pixel
	lw $t2, 0($t1)
	lw $t3, rotationState
	lw $t4, type
	li $t5, 1
	beq $t4, $t5, ROTATION_LINE
	beq $t4, $zero, game_loop #we dont need to rotate cube 
	li $t5, 6
	beq $t4, $t5, ROTATION_T
ROTATION_T:
	lw $t2, 0($t1)
	beq $t3, $zero, verticalL
	li $t5, 1
	beq $t3, $t5, horozontalD
	li $t5, 2
	beq $t3, $t5, verticalR
horozontalU:
	sw $zero, rotationState
	jal storeTHU
	la $t1, pixel
	sw $t2, 0($t1)
	jal moveLine1R
	jal moveLine1L
	b game_loop
verticalL:
	li $t3, 1
	sw $t3, rotationState
	jal storeTVL
	la $t1, pixel
	sw $t2, 0($t1)
	jal moveLine1R
	jal moveLine1L
	b game_loop
horozontalD:
	li $t3, 2
	sw $t3, rotationState
	jal storeTHD
	la $t1, pixel
	sw $t2, 0($t1)
	jal moveLine1R
	jal moveLine1L
	b game_loop
verticalR:
	li $t3, 3
	sw $t3, rotationState
	jal storeTVR
	la $t1, pixel
	sw $t2, 0($t1)
	jal moveLine1R
	jal moveLine1L
	b game_loop
	
ROTATION_LINE:
	beq $t3, $zero, vertical
horozontal:
	sw $zero, rotationState
	jal storeLineV
	sw $t2, 0($t1)
	jal moveLine1R
	jal moveLine1L
	b game_loop
vertical:
	li $t3, 1
	sw $t3, rotationState
	jal storeLineH
	sw $t2, 0($t1)
	jal moveLine1R
	jal moveLine1L
	b game_loop
	
	

	

	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



#all the code under here will handle collisions
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#for testing purpose lets do the sides 


	
LEFT_SIDE_CHECK:



RIGHT_SIDE_CHECK:

BOTTOM_SIDE_CHECK:
	lw $t0, ADDR_DSPL
	la $t1, pixel
	lw $t2, 0($t1)
	addi $t2, $t2, 128
	addi $t2, $t2, 128
	addi $t2, $t2, 128
	addi $t2, $t2, 128
	add $t0, $t0, $t2
	li $t3, 0x000000
	lw $t4, 0($t0)
	bne $t3, $t4, start
	jr $ra
	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#okay this will be for anything having to due with like block hitting 
#the ground or other blocks 
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# The logic for stopping the block and spawning a new one.
 # Go back to the start of the game loop
    



    
moveLine1D: ####vertical down 
	lw $t0, ADDR_DSPL
	la $t1, pixel
	li $t3, 0x000000
	###clear off the screen
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	###move down in pixel array
	lw $t2, 0($t1)
	addi $t2, $t2, 128
	sw $t2, 0($t1)
	#redraw
	lw $t0, ADDR_DSPL
	li $t3, 0xff0000
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	
	jr $ra
moveLine1R: ####vertical right
	lw $t0, ADDR_DSPL
	la $t1, pixel
	li $t3, 0x000000
	###clear off the screen
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	###move down in pixel array
	lw $t2, 0($t1)
	addi $t2, $t2, 4
	sw $t2, 0($t1)
	#redraw
	lw $t0, ADDR_DSPL
	li $t3, 0xff0000
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	jr $ra
moveLine1L: ### left
	lw $t0, ADDR_DSPL
	la $t1, pixel
	li $t3, 0x000000
	###clear off the screen
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	###move down in pixel array
	lw $t2, 0($t1)
	addi $t2, $t2, -4
	sw $t2, 0($t1)
	#redraw
	lw $t0, ADDR_DSPL
	li $t3, 0xff0000
	lw $t2, 0($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 4($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 8($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	lw $t2, 12($t1)
	add $t0, $t0, $t2
	sw $t3, 0($t0)
	
	jr $ra



storeLineV:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 128
	sw $s1, 12($s0)
	jr $ra
storeLineH:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra	

storeZH:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeSH:
	la $s0, pixel
	li $s1, 8
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 120
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeBlock:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1 4
	sw $s1, 4($s0)
	li $s1, 124
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeLD:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeLU:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 128
	sw $s1, 12($s0)
	jr $ra
storeLL: #(left L)
	la $s0, pixel
	li $s1, 8
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, -4
	sw $s1, 12($s0)
	jr $ra
storeTHU:
	la $s0, pixel
	li $s1, 8
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, -4
	sw $s1, 8($s0)
	li $s1, 8
	sw $s1, 12($s0)
	jr $ra
storeTVL:
	la $s0, pixel
	li $s1, 8
	sw $s1, 0($s0)
	li $s1, 124
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 128
	sw $s1, 12($s0)
	jr $ra
storeTVR:
	la $s0, pixel
	li $s1, 8
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 124
	sw $s1, 12($s0)
	jr $ra		
storeTHD:
	la $s0, pixel
	li $s1, 4
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 124
	sw $s1, 12($s0)
	jr $ra
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>




























