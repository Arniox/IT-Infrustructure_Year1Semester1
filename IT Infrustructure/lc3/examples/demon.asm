; demo1.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.ORIG	x3000		; directive: put code at start of user memory
	LD 	R2, Num1
	LD 	R3, Num2	
	OR 	R4, R2, R3	;add
	

DONE 	HALT

Num1	.FILL	xFFFF
Num2	.FILL   x0000

	.END		; directive: no more code