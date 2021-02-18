#  Simple Function n + 1. The ints can be more than 2
# digits.  The reading will stop for a non-integer character.  It also has a
# main that cycles over all the command arguments until they are all used.
	.globl main
	.align  2
	.text
#store needed variables on stack
main:
    	
#  save stack frame       
        subu  $sp, $sp, 32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)

#       read Arguments
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
        addi $a0, $a0, 1   # replace with argument
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
NPlusOne:
#       save the stack frame	  	  
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)
        addi  $v0, $a0, 1
NPlusOneEnd:        
#  	restore the stack frame
        addi  $sp, $sp, 32
        lw  $ra, -4($fp)
        lw $fp,    0($fp)
	jr $ra

          .data
	  .align 2
out_string: .asciiz "N+1: "
space_str:  .asciiz " "
term_string: .asciiz ":\n"
errorString: .asciiz "string is not a number\n"
