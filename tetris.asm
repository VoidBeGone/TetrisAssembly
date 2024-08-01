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
	
