	.text
	.align 2
	.globl main
main:
	lui  $t0, 0x0010  # load upper registers with a constant
        addi $t0, $t0, 0x1000 
        slt  $t2, $0, $t0    #  0 < $t0 true $t2 = 1
        bne  $t2, $0, ELSE   # branche taken
        j    DONE
ELSE:    
	addi $t2, $t2, 2   
DONE:   
        jr  $ra          # must go back to main


