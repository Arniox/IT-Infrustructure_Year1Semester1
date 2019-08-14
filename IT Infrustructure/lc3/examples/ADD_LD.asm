;; This file is designed to check the ADD and LD
;; instructions for the LC-3 simulator.
	.ORIG x3000
	LD R1,NUM1		; R1 <- xA
	LD R2,NUM2		; R2 <- xF

	ADD R3,R1,R2		; R3 <- x19 (R1 + R2)
	ADD R4,R1,#-5		; R4 <- x5 (R1 - 5)
	HALT

NUM1	.FILL xA
NUM2	.FILL xF
	.END
