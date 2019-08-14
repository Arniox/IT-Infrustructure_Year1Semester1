;An Example Program
;Adds 3 numbers starting from DATA
;R1: pointer   		R0:count-down counter
;R3: accumulates sum	R4:Temporary reg
;    
	.ORIG	0x3000
	LEA R1,DATA		;initialize pointer R1
	AND R3,R3,#0	
	AND R0,R0,#0 
	ADD R0,R0,#3	;R2=3, adds 3 numbers

LOOP	BRz  DONE		;done if R2=0
	LDR R4,R1,#0
	ADD R3,R3,R4
	ADD R1,R1,#1	;increment pointer
	ADD R0,R0,#-1	;decrement counter
	BRnzp LOOP

DONE	ST R3, SUM
	HALT			;end of program

DATA	.FILL 3		;beginning of data
	.FILL -4
	.FILL 7
SUM	.BLKW 1
	.END

;What to observe: 
;Assembly process: notice the offset in branch instructions
;set breakpoints at LOOP and DONE to see what is happening.
;Look at R1, R2, R3