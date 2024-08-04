#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Name, Student Number, UTorID, official email
# Student2: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed) 
# - Unit height in pixels: 8 (update this as needed)
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
delay:  .word 200  # Delay for sumthin



##############################################################################
# Mutable Data
##############################################################################
pixel: .word 0,0,0,0 #store the offset
rotationState: .word 0 # because some shapes have less then two axis of symetry
type: .word 1 # 1 = block 2 = line , 3 = s , 4= z, 5=L 6 =  J, 7= T
currentColour: .word 0x000000
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
    # Initialize the random seed
    move      $t0, $sp   # Seed value (you can use any value or a variable if needed)

    # Generate a pseudo-random number
    li      $t1, 1103515245
    mul     $t0, $t0, $t1
    li      $t2, 12345
    add     $t0, $t0, $t2
    li      $t3, 0x7FFFFFFF
    and     $t0, $t0, $t3

    # Scale the random number to 1-7
    li      $t4, 7
    rem     $t5, $t0, $t4 # $t5 = $t0 % 7
    addi    $t5, $t5, 1   # $t5 = ($t0 % 7) + 1
    
    # Secondary scale 1-3
    li      $t4, 3
    rem     $t7, $t0, $t4 # $t7 = $t0 % 3
    addi    $t7, $t7, 1   # $t7 = ($t0 % 3) + 1
    #
    li $t4, 2
    beq $t7, $t4, SETG
    li $t4, 3
    beq $t7, $t4, SETB
SETR:
	li $t7, 0xff0000
	j endColour
SETG:
	li $t7, 0x00ff00
	j endColour
SETB:
	li $t7, 0x0000ff
	j endColour
endColour:

    # Store the result in the data section
    la      $t6, type     # Load address of 'type'
    sw      $t5, 0($t6)   # Store the randomized value
    # Store the result in the data section
    la      $t6, currentColour    
    sw      $t7, 0($t6)

#load the specified block
    li $t7, 2
    beq $t5, $t7, L2
    li $t7, 3
    beq $t5, $t7, L3
    li $t7, 4
    beq $t5, $t7, L4
    li $t7, 5
    beq $t5, $t7, L5
    li $t7, 6
    beq $t5, $t7, L6
    li $t7, 7
    beq $t5, $t7, L7

L1:    
    jal storeBlock
    b game_loop

L2:    
    jal storeLineV
    b game_loop

L3:    
    jal storeSH
    b game_loop

L4:    
    jal storeZH
    b game_loop

L5:    
    jal storeLD
    b game_loop

L6:    
    jal storeJU
    b game_loop

L7:    
    jal storeTHU
    b game_loop

game_loop:

    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
    # 2b. Update locations 
    # 3. Draw the screen
    # 4. Sleep

    li      $v0, 32
    li      $a0, 1
    syscall

    lw      $t1, ADDR_KBRD           # $t1 = base address for keyboard
    lw      $t8, 0($t1)              # Load first word from keyboard, 0 contains status to check if a key has been pressed 
    beq     $t8, 1, keyboard_input   # 1 means a key has been pressed 
    j       call_respond_to_S        # Call respond_to_S every 1 second

keyboard_input:
    lw      $a0, 4($t1)              # Load word 
    beq     $a0, 0x64, respond_to_D  # Check if key 'd' is pressed
    beq     $a0, 0x61, respond_to_A  # Check if key 'a' is pressed
    beq     $a0, 0x73, respond_to_S  # Check if key 's' is pressed
    beq     $a0, 0x6D, respond_to_M  # Check if key 'm' is pressed
    beq     $a0, 0x77, respond_to_W  # Check if key 'w' is pressed
    beq     $a0, 0x70, start_QUIT    # Check if key 'p' is pressed
    j       game_loop                # Go back to game_loop

call_respond_to_S:
    li      $v0, 32                  
    lw      $a0, delay              
    syscall                          

    j       respond_to_S            
    j       game_loop                
	
	
	
#Everything in this box is for quiting 
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
EXIT:
	li $v0, 10
	syscall
	
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
	jal RIGHT_SIDE_CHECK
	jal redraw
	b game_loop
	
respond_to_A:
	jal LEFT_SIDE_CHECK
	jal redraw
	b game_loop
		
respond_to_M:
	jal BOTTOM_SIDE_CHECK_PETER
	jal redraw
	b game_loop
	
respond_to_S:
	jal BOTTOM_SIDE_CHECK
	jal redraw
	b game_loop

respond_to_W:
	lw $t0, ADDR_DSPL
	la $t1, pixel
	li $t3, 0x000000
	###clear off the screen
	jal clearShape
	####### change form
	la $t1, pixel
	lw $t2, 0($t1)
	lw $t3, rotationState
	lw $t4, type
	li $t5, 1
	beq $t4, $zero, game_loop #we dont need to rotate cube
	li $t5, 2
	beq $t4, $t5, ROTATION_LINE
	li $t5, 3
	beq $t4, $t5, ROTATION_Z
	li $t5, 4
	beq $t4, $t5, ROTATION_Z
	li $t5, 5
	beq $t4, $t5, ROTATION_L
	li $t5, 6
	beq $t4, $t5, ROTATION_J
	li $t5, 7
	beq $t4, $t5, ROTATION_T
	#dubug
	jal redraw
	b game_loop
	#to do add all rotation L J S Z 

	
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
	jal clearShape
	jal redraw
	b game_loop
verticalL:
	li $t3, 1
	sw $t3, rotationState
	jal storeTVL
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
horozontalD:
	li $t3, 2
	sw $t3, rotationState
	jal storeTHD
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
verticalR:
	li $t3, 3
	sw $t3, rotationState
	jal storeTVR
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
	
ROTATION_LINE:
	beq $t3, $zero, vertical
horozontal:
	sw $zero, rotationState
	jal storeLineV
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
vertical:
	li $t3, 1
	sw $t3, rotationState
	jal storeLineH
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
ROTATION_Z:
	beq $t3, $zero, ZV
ZH:
	sw $zero, rotationState
	jal storeZH
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
ZV:
	li $t3, 1
	sw $t3, rotationState
	jal storeZV
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
ROTATION_S:
	beq $t3, $zero, SV
SH:
	sw $zero, rotationState
	jal storeSH
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
SV:
	li $t3, 1
	sw $t3, rotationState
	jal storeSV
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
ROTATION_L:
	lw $t2, 0($t1)
	beq $t3, $zero, LL
	li $t5, 1
	beq $t3, $t5, LD
	li $t5, 2
	beq $t3, $t5, LR
LU:
	sw $zero, rotationState
	jal storeLU
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
LL:
	li $t3, 1
	sw $t3, rotationState
	jal storeLL
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
LD:
	li $t3, 2
	sw $t3, rotationState
	jal storeLD
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
LR:
	li $t3, 3
	sw $t3, rotationState
	jal storeLR
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop	
ROTATION_J:
	lw $t2, 0($t1)
	beq $t3, $zero, JL
	li $t5, 1
	beq $t3, $t5, JD
	li $t5, 2
	beq $t3, $t5, JR
JU:
	sw $zero, rotationState
	jal storeJU
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
JL:
	li $t3, 1
	sw $t3, rotationState
	jal storeJL
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
JD:
	li $t3, 2
	sw $t3, rotationState
	jal storeJD
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
JR:
	li $t3, 3
	sw $t3, rotationState
	jal storeJR
	la $t1, pixel
	sw $t2, 0($t1)
	jal clearShape
	jal redraw
	b game_loop
	

	
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



#all the code under here will handle collisions
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#for testing purpose lets do the sides 


RIGHT_SIDE_CHECK:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal clearShape
	la $t1, pixel
	li $t9, 4 #increase number
	li $t8, 0 #counter 
	li $t7, 0x000000
	lw $t0, ADDR_DSPL #loading to make less math
	addi $t0, $t0, 4 #right
loop3:
	beq $t8, $t9, return_no_block3 #code this later 
	lw $t2, 0($t1) #loading pixel in 
	
	#code is now for checking below 
	add $t0, $t0, $t2 
	lw $t3, 0($t0) #this is now led below the pixel being checked
	bne $t3, $t7, return_leave_loop_block_below3
	
	#this is reseting loop
	addi $t1, $t1, 4 #going to next pixel
	addi $t8, $t8, 1 #increase counter 
	j loop3
	
return_leave_loop_block_below3:
	jal redraw
	j game_loop
	
	
return_no_block3:
	la $t1, pixel
	lw $t2, 0($t1)
	addi $t2, $t2, 4
	sw $t2, 0($t1)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
LEFT_SIDE_CHECK:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal clearShape
	la $t1, pixel
	li $t9, 4 #increase number
	li $t8, 0 #counter 
	li $t7, 0x000000
	lw $t0, ADDR_DSPL #loading to make less math
	addi $t0, $t0, -4
loop4:
	beq $t8, $t9, return_no_block4 #code this later 
	lw $t2, 0($t1) #loading pixel in 
	
	#code is now for checking below 
	add $t0, $t0, $t2 
	lw $t3, 0($t0) #this is now led below the pixel being checked
	bne $t3, $t7, return_leave_loop_block_below4
	
	#this is reseting loop
	addi $t1, $t1, 4 #going to next pixel
	addi $t8, $t8, 1 #increase counter 
	j loop4
	
return_leave_loop_block_below4:
	jal redraw
	j game_loop
	#j start
	
return_no_block4:
	la $t1, pixel
	lw $t2, 0($t1)
	addi $t2, $t2, -4
	sw $t2, 0($t1)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

BOTTOM_SIDE_CHECK:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal clearShape
	la $t1, pixel
	li $t9, 4 #increase number
	li $t8, 0 #counter 
	li $t7, 0x000000
	lw $t0, ADDR_DSPL #loading to make less math
	addi $t0, $t0, 128
loop2:
	beq $t8, $t9, return_no_block2 #code this later 
	lw $t2, 0($t1) #loading pixel in 
	
	#code is now for checking below 
	add $t0, $t0, $t2 
	lw $t3, 0($t0) #this is now led below the pixel being checked
	bne $t3, $t7, return_leave_loop_block_below2
	
	#this is reseting loop
	addi $t1, $t1, 4 #going to next pixel
	addi $t8, $t8, 1 #increase counter 
	j loop2
	
return_leave_loop_block_below2:
	jal redraw
	j helper_function
	#j start
	
return_no_block2:
	la $t1, pixel
	lw $t2, 0($t1)
	addi $t2, $t2, 128
	sw $t2, 0($t1)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
BOTTOM_SIDE_CHECK_PETER:
	jal clearShape
	la $t1, pixel
	li $t9, 4 #increase number
	li $t8, 0 #counter 
	li $t7, 0x000000
	lw $t0, ADDR_DSPL #loading to make less math
	addi $t0, $t0, 128
loop1:
	beq $t8, $t9, return_no_block1 #code this later 
	lw $t2, 0($t1) #loading pixel in 
	
	#code is now for checking below 
	add $t0, $t0, $t2 
	lw $t3, 0($t0) #this is now led below the pixel being checked
	bne $t3, $t7, return_leave_loop_block_below1
	
	#this is reseting loop
	addi $t1, $t1, 4 #going to next pixel
	addi $t8, $t8, 1 #increase counter 
	j loop1
	
return_leave_loop_block_below1:
	jal redraw
	j helper_function
	#j start
	
return_no_block1:
	la $t1, pixel
	lw $t2, 0($t1)
	addi $t2, $t2, 128
	sw $t2, 0($t1)
	jr $ra
	

#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


#okay this will be for anything having to due with like block hitting 
#the ground or other blocks 
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# The logic for stopping the block and spawning a new one.
 # Go back to the start of the game loop
    



clearShape:
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
	jr $ra
	
redraw: 
	#redraw
	la $t6, currentColour    
    	lw $t3, 0($t6)
	lw $t0, ADDR_DSPL

	la $t1, pixel
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
	li $s1, 64
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
	li $s1, 64
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
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeZV:
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 124
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 124
	sw $s1, 12($s0)
	jr $ra
storeSH:
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 120
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeSV:
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 128
	sw $s1, 12($s0)
	jr $ra
storeBlock:
	la $s0, pixel
	li $s1, 64
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
	li $s1, 64
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
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 128
	sw $s1, 12($s0)
	jr $ra
storeLL:
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 120
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeLR:
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 120
	sw $s1, 12($s0)
	jr $ra
storeJU: 
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, -4
	sw $s1, 12($s0)
	jr $ra
storeJD: 
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 128
	sw $s1, 8($s0)
	li $s1, 128
	sw $s1, 12($s0)
	jr $ra
storeJL: 
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeJR: 
	la $s0, pixel
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 128
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 4
	sw $s1, 12($s0)
	jr $ra
storeTHU:
	la $s0, pixel
	li $s1, 64
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
	li $s1, 64
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
	li $s1, 64
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
	li $s1, 64
	sw $s1, 0($s0)
	li $s1, 4
	sw $s1, 4($s0)
	li $s1, 4
	sw $s1, 8($s0)
	li $s1, 124
	sw $s1, 12($s0)
	jr $ra
	
		
#->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
########peters line drop

helper_function:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 3960 #at this point in time ADDR_DSPL IS at the last line last pos
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    li $t8, 0 #holy grail
    j has_been_touched # Go back to the start of the game loop
 
has_been_touched:
	#so basically each line is 30 unit and we have 31 lines
	# we need to start from the bottom up obviously 
	#so basically lets add ADDR_DSPL with 4x 30x29 since size thing ya 
	lw $t0, 0($sp) 
	addi $sp, $sp, 4
	li $t7, 7
	#we are going to do something cool, we are going to do a loop but backwards cause ehhh the lols
	li $t1, 30
	li $t2, 0 #counter for loop
	li $t3, 0# how many time we have an led 
	li $t9, 0x000000
	
has_been_touched_backwards_loop:
	beq $t2, $t1, END_TOUCH_LOOP
	lw $t4, 0($t0) #loading led 
	bne $t4, $t9, LED_COUNT_INCREASE
	j LED_COUNT_OTHER
	

LED_COUNT_INCREASE: #if there exist an led on
	addi $t3, $t3, 1 #increasing how many led on
	j LED_COUNT_OTHER
	
LED_COUNT_OTHER: #just doing the loop stuff 
	addi $t2, $t2, 1 #increase counter
	addi $t0, $t0, -4 #checking another position
	j has_been_touched_backwards_loop
	
	
END_TOUCH_LOOP:
	beq $t3, $t1, LINE_FULL #this means that we have an entire line lit 
	#code under here mine no line is not full 
	j LINE_FULL_LOOP_END #checking other lines
	
LINE_FULL:
	#this means line is full so we will need to remove it, then drop everything above it down 
	#lets work on removing the line 
	li $t8, 7
	add $t0, $t0, 120 #we are moving it back to the start of the line in reverse 
	li $t4, 30 #counter end
	#li $t9, 0x0000ff
	
LINE_FULL_LOOP:
	beq $t4, $zero, LINE_FULL_LOOP_END
	sw $t9, 0($t0) #changing to black 
	subi $t4, $t4, 1
	addi $t0, $t0, -4
	j LINE_FULL_LOOP

LINE_FULL_LOOP_END:
	li $t5, 0x10008000
	blt $t0, $t5, CHECKING_FULL_STOP
	#HOLT GRRAIL CHECK IM OUT OF IDEA
	beq $t7, $t8, LINE_DROP
	addi $t0, $t0, -8 #cause the border spots need to be the removed 
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	j has_been_touched     #currently what this is doing is just looping through the the next line and checking


CHECKING_FULL_STOP:
	j start
	
	
LINE_DROP:
	addi $t0, $t0 , -8 #should be the the end now
	#lw $t0, ADDR_DSPL
	#addi $t0, $t0, 3832
	li $t1, 30
	#jal array_reset
	#la $t2, array_reset	
	li $t9, 0x000000
	
LINE_DROP_LOOP:
	beq $t1, $zero, LINE_DROP_LOOP_END
	lw $t4, 0($t0)
	bne $t4, $t9, LINE_DROP_PASS_ONE
	j LINE_DROP_CONT


LINE_DROP_PASS_ONE:
	lw $t5, 128($t0)
	beq $t5, $t9 LINE_DROP_PASS_TWO
	j LINE_DROP_CONT

LINE_DROP_PASS_TWO:
	#this mean i move 
	sw $t4, 128($t0) #dropped bitch
	sw $t9, 0($t0)
	j LINE_DROP_CONT
	
LINE_DROP_CONT:
	addi $t0, $t0, -4
	addi $t1, $t1, -1
	j LINE_DROP_LOOP
	
LINE_DROP_LOOP_END:
	li $t5, 0x10008000
	blt $t0, $t5, LINE_DROP_FULL_STOP
	j LINE_DROP
	
LINE_DROP_FULL_STOP:
	j helper_function



























