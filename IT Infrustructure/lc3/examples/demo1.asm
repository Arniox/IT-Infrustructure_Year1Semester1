; demo1.asm
; This LC3 assembler program loops through the following operations:
;	1) reads two numbers from memory (from Num1 and Num2)
;	2) adds them
;	4) puts the result in memory (at Res1)
;	5) Next it performs a logical AND between the two numbers
;       6) puts the result in memory (at Res2)
;
;  R1: holds Num1 value
;  R2: holds Num2 value 
;  R3: holds result of operation
;                                                           YM S08
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.ORIG	x3000		; directive: put code at start of user memory

	;LEA     R4, Num1
	LD 	R2, Num1
	LD 	R3, Num2	
	ADD 	R4, R2, R3	;add
	

DONE 	HALT

Num1	.FILL	5
Num2	.FILL   6

	.END		; directive: no more code