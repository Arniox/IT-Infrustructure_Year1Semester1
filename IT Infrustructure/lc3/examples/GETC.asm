	.ORIG	x3000
	GETC		; get character
	OUT		; echo character
	GETC
	OUT
	LD	R0, NL
	OUT
	HALT
NL	.FILL	#10
	.END