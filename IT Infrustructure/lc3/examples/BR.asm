	.ORIG	x3000
;;; Test BR instructions
	AND	R6,R6,#0
	ADD	R6,R6,#-1	; R6:	0xffff
	BRn	BRTEST1
	HALT			; Oops! Should have branched
BRTEST1 AND	R5,R5,#0
	ADD	R5,R5,#10
	BRp	BRTEST2		; Should branch
	HALT
BRTEST2	ADD	R1,R5,#-10
	BRz     BRTEST3		; Should branch
	HALT
BRTEST3 BRnzp	BRTEST4		; Should branch
BRFAIL	HALT
BRTEST4	AND	R1,R2,#0
	ADD	R1,R1,#2
	BRn	BRFAIL		; Should NOT branch
	HALT
	.END