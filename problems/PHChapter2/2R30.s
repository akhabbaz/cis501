#addi $t1, $0, $0
#LOOP:  
#     add  $t3, $s0, $t1
#     lw   $s1, 0($t3)
#     add  $s2, $s2, $s1
#     addi $t1, $t1, 4
#     slti $t2, $t1, 400
#     bne  $t2, $zero, LOOP
#END:

	.globl main
	.align  2
	.text
#set up variables
main:
	lw $s1, 0x8000($gp)        # memSize 
        la $s0, MemArray           # memArray address
        or $s2, $zero, $zero       #sum of all the assignments 
        sll $s1, $s1, 2            # s1 is one past final location       
# Version2
        add $s1, $s0, $s1          # final address
LOOP:   lw   $t0, 0($s0)           # t0 holds the temp loaded word
        add  $s2, $s2, $t0
     	addi $s0, $s0, 4
        bne  $s1, $s0, LOOP
# end of version 2 now print
endLoop:
    	li  $v0, 4
	la  $a0, out_string
	syscall
        li  $v0, 1
	move  $a0, $s2
	syscall
    	li  $v0, 4
	la  $a0, term_string
	syscall
	jr $ra
          .data      
memSize:  .word 5
MemArray: .word 1, 2, 3, 4, 5
out_string: .asciiz "sum: "
term_string: .asciiz "\n"

# five instructions reduced by 2 by eliminating slti, and using s0 as the index
# variable instead of t1.  Above you add t3 to s0 to get address and also
# increment $t1. Below you just increment s0.
