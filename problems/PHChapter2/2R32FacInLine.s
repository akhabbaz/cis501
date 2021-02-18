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
	lb $t0, 0($a0)
        addi $v0, $t0, -48
        ori  $t1, $zero, 10   #  store multiplier
        move $v0, $zero    #  final value
NextChar:  
	lb $t0, 0($a0)
        beq  $t0, $zero, endCharRead
        addi $t0, $t0, -48
        sltu $t2, $t0, $t1  # check for char out of bounds
        beq  $t2, $zero, StrError 
        mul  $v0, $v0, $t1  # prior number
        add  $v0, $v0, $t0 # current digit
        add  $a0, $a0, 1
        j   NextChar
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

