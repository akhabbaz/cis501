# fibonacci in assembly.  This works past n = 21.  It does recursive fibonacci.
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
        move $a0, $s0      # Fibonacci
        jal Fibonacci      # call Fibonacci with argument
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
Fibonacci:
#       save the stack frame	  	  
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)
        sw  $a0, -8($fp)
        sw  $s0, -12($fp)  # temp fib value
        bne  $a0, $zero, FibElseIf
        move $v0, $zero
        j   FibEnd
FibElseIf:
	li $v0, 1
        bne  $v0, $a0, FibElse
        j  FibEnd
FibElse:
	addi $a0, $a0, -1  # next fib call n -1
        jal Fibonacci
        move $s0, $v0
        lw   $a0, -8($fp)
        addi $a0, $a0, -2  # final fib call n-2
        jal Fibonacci
        add $v0, $v0, $s0  # store the two fib calls in $v0 
FibEnd:        
#  	restore the stack frame
        addi  $sp, $sp, 32
        lw  $ra, -4($fp)
#       lw  $a0, -8($fp) not needed to restore $a0 because 
			#  a0 may be changed between calls
        lw  $s0, -12($fp)  # restore $s0 from stack
        lw $fp,    0($fp)
	jr $ra

          .data
	  .align 2
valueA:   .word 2     
out_string: .asciiz "fibonacci: "
space_str:  .asciiz " "
term_string: .asciiz ":\n"
errorString: .asciiz "string is not a number\n"
