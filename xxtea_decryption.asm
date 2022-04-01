		
			.data

KEY:			.word 62, 'b', 'c', 1,	
DELTA:			.word 0x9e3779b9

FILE:			.space 790528
WORD_AFTER:		.space 4

FILE_NAME:		.asciiz "enLAND2.bmp"
TRANS_FILE_NAME:	.asciiz "deLAND2.bmp"

		
			.text
		

read_file:

	li $v0, 13
	la $a0, FILE_NAME
	li $a1, 0			#open the file
	li $a2, 0
	syscall				
	move $t0, $v0
		
	li $v0, 14
	move $a0, $t0
	la $a1, FILE			#read file content
	li $a2, 790528
	syscall	
	
	
	li $v0, 16
	move $a0, $t0			#close file
	syscall	
		
		
	la $t0, FILE			# address of FILE to $t0
	li $t2, 0			# will contain length of file
	la $s0, WORD_AFTER		# IMPORTANT - it's 'word' exactly after our 'string'
		
		
get_fend_loop:

	addu $t0, $t0, 4		# move pointer to next word
	addu $t2, $t2, 1		# increase for getting length
	ble  $t0, $s0, get_fend_loop	# loop if not the WORD_AFTER
	
	
file_end_found:

	subu $t0, $t0, 8		# 
	move $s2, $t0			# $s2 = last word of FILE
	subu $t2, $t2, 1		# corrections made to work properly
	move $s1, $t2			# s2 becomes n (like in original code)
		
		
before_do:

	li $t0, 52
	divu $t0, $t0, $s1		# 52/n
	add $t0, $t0, 6 		# rounds = 6 + 52/n
	
	lw $t6, FILE			# load first word; y = v[0]
	lw $t2, DELTA
	mulu $t3, $t2, $t0		# sum = DELTA*rounds; (rather impossible to logical shift)
		
		
do:

	srl $t4, $t3, 2  		# sum >> 2
	and $t4, $t4, 3 		# &3   = e
	
	move $t2, $s1 			# p = n
	subu $t2, $t2, 1		# p = n-1
	la $t5, WORD_AFTER		#
	subu $t5, $t5, 4		# last word of FILE
	
			
for:

	subu $t5, $t5, 4		# move pointer to (p-1) index
	lw $t1, ($t5)  			# v[p-1]
	addu $t5, $t5, 4		# get back
	
			
MX_calculate:

	srl $t7, $t1, 5			# z >> 5
	sll $t8, $t6, 2			# y << 2
	xor $t7, $t7, $t8		# ^
	
	srl $t8, $t6, 3			# y >> 3
	sll $t9, $t1, 4			# z << 4
	xor $t8, $t8, $t9		# ^
		
	addu $t7, $t7, $t8		# ((z>>5^y<<2) + (y>>3^z<<4)
		
	and $t8, $t2, 3			# p&3
	xor $t8, $t8, $t4		# ^ e
		
	la $t9, KEY			# address to KEY
	sll $t8, $t8, 2			# offset to get proper word from key
	addu $t8, $t8, $t9 		# move pointer to needed word from key
	lw $t8, ($t8)			# get needed word from key
		
	xor $t8, $t8, $t1		# key[(p&3)^e] ^ z
	xor $t9, $t3, $t6		# sum^y
	addu $t8, $t8, $t9		# (sum^y) + (key[(p&3)^e] ^ z)
		
	xor $t7, $t7, $t8		# =MX
		
		
for_continue:

	lw $t6, ($t5)			# v[p]
	subu $t6, $t6, $t7		# -= MX
	sw $t6, ($t5)			# store
		
	subu $t5, $t5, 4		# move pointer to word before
	subu $t2, $t2, 1		# decrement for iteration
	bgtz $t2, for		 	# if p>0, loop

	lw $t1, ($s2)			# v[n-1]
	
		
MX_calculate_2:

	srl $t7, $t1, 5			
	sll $t8, $t6, 2			
	xor $t7, $t7, $t8		
	srl $t8, $t6, 3			
	sll $t9, $t1, 4			
	xor $t8, $t8, $t9		
	addu $t7, $t7, $t8		
	and $t8,$t2, 3			
	xor $t8, $t8, $t4		
	sll $t8, $t8, 2			
	la $t9, KEY	
	addu $t8, $t8, $t9	
	lw $t8, ($t8)
	xor $t8, $t8, $t1	
	xor $t9, $t3, $t6
	addu $t8, $t8, $t9
	xor $t7, $t7, $t8  
		
do_continue:

	lw $t6, FILE			# v[0]
	subu $t6, $t6, $t7		# -= MX
	sw $t6, FILE			# store
			
	lw $t9, DELTA
	subu $t3, $t3, $t9		# sum -= DELTA
		
	subu $t0, $t0, 1		# rounds--
	bgtz $t0, do		# looping
	
	
write_to_file:

	li $v0, 13
	la $a0, TRANS_FILE_NAME
	li $a1, 1
	li $a2, 0
	syscall	
	move $t0, $v0
		
	li $v0, 15
	move $a0, $t0
	la $a1, FILE			# write
	la $a2, 790528
	syscall	
		
	li $v0, 16
	move $a0, $t0
	syscall


exit:	

	li $v0, 10
	syscall				#end program
