# This is an inline version of factorial.  It is not quite inline but it uses a
# loop and a function call.  The function is to separate out the input code from
# the function code.  adding the function does not add many lines:


# It also reads ints as command line arguments.  The ints can be more than 2
# digits.  The reading will stop for a non-integer character.  It also has a
# main that cycles over all the command arguments until they are all used.
	.globl main
	.align  2
	.text
#store needed variables on stack
main:
    	
#       read Arguments
#  save stack frame       
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)

        move $s0, $a0      # first string is name of procedure
        sll  $s2, $s0, 2   # bytes offset
        move $s1, $a1      # start string address
	add  $s2, $s1, $s2 # one past final address
DirPath:        
        lw   $a0, 0($s1)   # first argument address
        li   $v0, 4        # print string 
        syscall
	la  $a0, term_string
	syscall
        addi $s1, $s1, 4   # next address
MainReadLoop:       
	beq  $s2, $s1, MainEnd
        la   $a0, out_string
        li   $v0, 4          # print descriptive string
	syscall
	lw   $a0, 0($s1)   # first argument address
        jal  IntToString   # print string 
	move $s0, $v0      # store int in $s0
        move $a0, $v0      # input
        li  $v0, 1         # print int
        syscall            # print int converted
        la   $a0, space_str # print out space 
        li  $v0, 4
        syscall  
        move $a0, $s0      # Factorial
        jal Factorial      # call Factorial with argument
        move $a0, $v0
        li $v0, 1          # print answer
        syscall
	la  $a0, term_string
        li $v0, 4
	syscall
        addi $s1, $s1, 4   # next address
	j MainReadLoop
##      reload the stack frame
MainEnd:
        addi  $sp, $sp, 32
        lw  $ra, -4($fp)
        lw $fp, 0($fp)
	jr $ra

IntToString:
#store important vars onto stack  IntToSTr
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)
        sw  $a0, -8($fp) # keep the string address start on stack
        sw  $s0, -12($fp) # current character
        sw  $s1, -16($fp) # used for pointer to  current character
        sw  $s2, -20($fp) # hold compare character
        sw  $s3, -24($fp) # current integer
        sw  $s4,  -28($fp) # 10
# Function start get whether the first char is +, - or a number
        move $s1, $a0     #  current character
        or $s3, $zero, $zero # current number 
        ori $s4, $zero, 10 # store 10
# in each case $s1 points to nextChar to read, $s3 has current integer 
	lb $s0, 0($s1)
        add  $s1, $s1, 1
        subu $t0, $s0, 48  # subtract "0"
        sltu $t2, $t0, $s4  # check for a number
        beq  $t2, $zero, Sign  # first char is a sign or error
        add  $s3, $s3, $t0     # add in the current digit 
        j    PosChar
Sign:
        move $s2, 43  # check for +
        beq  $s0, $s2, ReadFirstPosChar
        move $s2, 45  # check for -
        beq  $s0, $s2, ReadFirstNegChar
# not a digit, not a + nor a - so error
        j StrError
ReadFirstPosChar:
	lb $s0, 0($s1)
        add  $s1, $s1, 1
        subu $t0, $s0, 48  # subtract "0"
        sltu $t2, $t0, $s4  # check for a number
        beq  $t2, $zero, StrError  # first char is a sign or error
        add  $s3, $s3, $t0     # add in the current digit 
        j    PosChar
ReadFirstNegChar:
	lb $s0, 0($s1)
        add  $s1, $s1, 1
        subu $t0, $s0, 48  # subtract "0"
        sltu $t2, $t0, $s4  # check for a number
        beq  $t2, $zero, StrError  # first char is a sign or error
        sub  $s3, $s3, $t0     # sub the current digit 
        j    NegChar
        
PosChar:  
	lb $s0, 0($s1)
        add  $s1, $s1, 1
        beq  $s0, $zero, endCharRead
        addi $s0, $s0, -48
        sltu $t2, $s0, $s4  # check for char out of bounds
        beq  $t2, $zero, StrError 
        mul  $s3, $s3, $s4  # prior number
        add  $s3, $s3, $s0  # current digit
        j   PosChar
endCharRead:
# restore variables from stack        
        addi  $sp, $sp, 32
        lw  $ra, -4($fp)
        lw $fp, 0($fp)
	jr $ra
StrError:	
	  la  $a0, errorString
          li $v0, 4
	  syscall
          li $v0, 10	    
	  syscall
Factorial:
#       save the stack frame	  	  
#       for inline we don't need a0 and we don't need $ra because this procedure
#       is not going to call any other so ra won't change.
     #   addi  $sp, $sp, -8
     #   sw  $ra, 4($sp)
       # sw  $a0, 0($sp)  No need to store $a0
	 addi $v0, $zero, 1 # initial value of $v0
FactorialStart:
	slti $t0, $a0, 2 # test n < 1
        bne  $t0, $zero, FactorialEnd
 #	addi $sp, $sp, 8  # pop off stack
        mul $v0, $a0, $v0
	addi $a0, $a0, -1
        j FactorialStart 
       # jal Factorial
#  	restore the stack frame
       # lw  $a0, 0($sp) #  restore $a0 not needed factorial restores $a0
       # lw  $ra, 4($sp)
       #  addi  $sp, $sp, 8
FactorialEnd:
	jr $ra
          .data
	  .align 2
valueA:   .word 2     
out_string: .asciiz "factorial: "
space_str:  .asciiz " "
term_string: .asciiz ":\n"

