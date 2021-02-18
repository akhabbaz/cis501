	.globl main
	.align  2
	.text
main:
	lw $s0, 0x8000($gp)        # valueA  
        lw $s1, 0x8004($gp)        # valueB
        la $s2, DLoc               # call without gp use label
                                   # Dloc not initialized!
        or $s3, $zero, $zero       #sum of all the assignments 
        move $t0, $zero # initialize i = 0
OuterL:        
	sltu $t2, $t0, $s0         #t2 is comparison outer loop
	beq  $t2, $zero, endLoop
        move   $t1, $zero          # j initialized to $zero
loopIn:
	sltu $t3, $t1, $s1
        beq  $t3, $zero, endIn
        add  $t4, $t1, $t0   # $t4 = i + j
        add  $s3, $s3, $t4   # sum of all $i +j = a*b*(a + b -2)/2
        sll  $t5, $t1, 4     # 2^4 times is j*4 in bytes
        add  $t6, $t5, $s2   # base address to write
        sw   $t4, 0($t6)     # store the word at the base address
        add $t1, $t1, 1      # increment j
        j    loopIn
endIn:
	add $t0, $t0, 1      # increment i
        j   OuterL
endLoop:
    	li  $v0, 4
	la  $a0, out_string
	syscall
        li  $v0, 1
	move  $a0, $s3
	syscall
    	li  $v0, 4
	la  $a0, term_string
	syscall
	jr $ra
	.data      
valueA:	.word 5
valueB: .word 4
DLoc:
	.space 64 #  b* 4 * 4
out_string: .asciiz "sum: "
term_string: .asciiz "\n"
