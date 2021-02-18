# Read 4 arguments and produce a nested recursive answer 2R34
# It also reads ints as command line arguments.  The ints can be more than 2
# digits.  The reading will stop for a non-integer character. 
	.globl main
	.align  2
	.text
#store needed variables on stack
main:
    	
#       read Arguments
#  save stack frame       
        addi  $sp, $sp, -24
        sw  $fp, 20($sp)
        addi $fp, $sp, 20
        sw  $ra, -4($fp)

        move $s0, $a0      # first string is name of procedure
        # check if #a0 is large enough
        ori  $t0, $zero, 4 #  minimum number of arguments
        slt  $t1, $t0, $s0 #  t1 =1 if enough args
        beq  $t1, $zero, ArgError
        addi $s0, $zero, 5 # only use first 4 arguments plus prog name
 			   #, disgard rest 
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
        la   $s3, args     # store input arguments
        la   $a0, out_string
        li   $v0, 4          # print descriptive string
	syscall
MainReadLoop:       
	beq  $s2, $s1, FuncCall
	lw   $a0, 0($s1)   # first argument address
        jal  IntToString   # print string 
	sw $v0, 0($s3)     # store int in args
        move $a0, $v0      # input
        li  $v0, 1         # print int
        syscall            # print int converted
        la   $a0, space_str # print out space 
        li  $v0, 4
        syscall  
        addi $s1, $s1, 4   # next address
        addi $s3, $s3, 4   # increment
	j MainReadLoop
FuncCall:
        la   $t0, args
        lw $a0, 0($t0)     # input to function
        lw $a1, 4($t0)     # input to function
        lw $a2, 8($t0)     # input to function
        lw $a3, 12($t0)     # input to function
        jal f               # call f with arguments
        move $a0, $v0
        li $v0, 1          # print answer
        syscall
	la  $a0, term_string
        li $v0, 4
	syscall
##      reload the stack frame
MainEnd:
        addi  $sp, $sp, 24
        lw  $ra, -4($fp)
        lw $fp, 0($fp)
	jr $ra
ArgError:	
        la   $a0, NotEnoughArgs  # first argument address
        li   $v0, 4        # print string 
        syscall
	la  $a0, term_string
	syscall
        jr $ra   # return to calling main.

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
f:
#       save the stack frame	  	  
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)
        sw  $s0, -8($fp)  # temp fib value
        add $s0, $a2, $a3 # second argument created
        jal func          # a0, a1 still correct
        move $a0, $v0     # first arg in $a0
        move $a1, $s0     # second arg
        jal  func
#  	restore the stack frame
        lw  $s0, -12($fp)  # restore $s0 from stack
        lw  $ra, -4($fp)
        lw $fp,    0($fp)
        addi  $sp, $sp, 32
	jr $ra
#  func3 is a recursive call that takes 3 arguments.  It can be used in a tail
#  call routine.  
func3:
#       save the stack frame	  	  
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        sw  $ra, -4($fp)    # store #ra in case
        sw  $a2, -8($fp)    #  store $a2 
        jal func           # first function call
        move $a0, $v0      # first argument restored
        lw   $a1, -4($fp)   
        jal func           # second call
# restore stack frame
        lw  $ra, -4($fp)    # store #ra in case
        lw $fp, 0($fp) 
        addi  $sp, $sp, 32
        jr   $ra

func:   
#       inputted function here is just multiply	
#       save the stack frame	  	  
        addi  $sp, $sp, -32
        sw  $fp, 28($sp)
        addi $fp, $sp, 28
        mul $v0, $a0, $a1
#  	restore the stack frame
        lw $fp,    0($fp)
        addi  $sp, $sp, 32
	jr $ra
          .data
	  .align 2
valueA:   .word 2
args:     .space 16 # 4 arguments stored here.     
out_string: .asciiz "f: "
space_str:  .asciiz " "
term_string: .asciiz ":\n"
errorString: .asciiz "string is not a number\n"
NotEnoughArgs: .asciiz "Too few arguments"
