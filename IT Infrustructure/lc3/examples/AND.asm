	.ORIG	x3000
;;; Test AND instructions 
	ADD	R1,R1,#5	; R1:	0x5
	ADD	R2,R2,#-2	; R2:	0xfffe
	ADD	R3,R2,R1	; R3:	0x3
	AND	R4,R3,#-1	; R4:	0x3
	AND	R5,R1,R4	; R5:	0x1
	ADD	R6,R6,#-1	; R6:	0xffff
	HALT
	.END