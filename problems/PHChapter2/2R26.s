	.text
	.align 2
	.globl main
main:
        addi  $s2, $0, 0   #  $s2 is B
	addi  $t1, $0, 10  # load $t1 with 10, i
LOOP:        
	slt  $t2, $0, $t1    #  0 < $t1 true $t2 = 1
        beq  $t2, $0, DONE   # branche taken
        addi $t1, $t1, -1
        addi $s2, $s2, 2
        j    LOOP   
DONE:   
        jr  $ra          # must go back to system caller


