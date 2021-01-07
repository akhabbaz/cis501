   	.text
        .align 2
        .globl main
main:
        subu $sp, $sp, 32
        sw $ra, 20($sp)
        sd $a0, 32($sp)
        sw $0, 24($sp)
        sw $0, 28($sp)
        addi  $s1, $s2, 100
        jr $ra 
