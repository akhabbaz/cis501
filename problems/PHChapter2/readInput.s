# Read a set of input parameters from the command line:
# returns positive integers.  Only allowable digits are 0..9. Not robust to all
# inputs.
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
        lw   $a0, 0($s1)   # first argument address
        jal  IntToString        # print string 
	move $a0, $v0      # store int in $a0
        li  $v0, 1         # print int
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
	  
          .data
	  .align 2
valueA:   .word 2     
out_string: .asciiz "fibonacci: "
term_string: .asciiz ":\n"
errorString: .asciiz "string is not a number\n"
