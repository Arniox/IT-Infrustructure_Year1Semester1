;******************************************************
; crawler.asm - memory crawler
;
;        Author:	Paul Roper
; Last Modified:	03/31/2006
;******************************************************
;
;	r3 = buffer
;	r4 = move address
;	r5 = # of crawls
;	r6 = stack

	.orig	0x3000
start	ld	r6,stack		; point to stack
	lea	r0,hello
	PUTS
	ld	r5,SONE			; # of crawls
	brnzp	crawler			; start of move section
;
trapa	.fill	11
trapi1	and	r0,r0,#0		; clear r0
	ret


;******************************************************
;
crawler	add	r5,r5,#1		; r5 = r5+1
	ld	r0,count
	add	r0,r5,r0		; done?
	  brnz	move			; n

done	ld	r0, NL
	OUT
	halt				; y

; put message (r0) to buffer (r3)
putmsg	ldr	r1,r0,#0		; get character, done?
	  brz	rand4			; y
	str	r1,r3,#0		; n, store character
	add	r0,r0,#1		; next
	add	r3,r3,#1
	br	putmsg
;
; generate a random number and add to r4
; restrict r4 to 0x3000 to 0xfc00 and outside of current pc
;
rand	add	r6,r6,#-1
	str	r7,r6,#0		; save return

again	ld	r0,seed			; get seed
	ld	r1,con1			; 15245
	jsr	umul
	ld	r1,con2			; 12345
	add	r0,r0,r1		; 15245 * seed + 12345
	st	r0,seed			; save new seed

; eliminate 0xf000 addresses
	ld	r1,hf000
	and	r1,r1,r0
	ld	r2,mf000
	add	r2,r2,r1
	  brz	again

; eliminate x0000 - x3fff
	ld	r1,hc000
	and	r1,r1,r0
	  brz	again

; |new(r0) - old(r4)| > size
	ld	r1,h0fff
	and	r2,r1,r0
	and	r1,r1,r4
	not	r1,r1
	add	r1,r1,#1
	add	r1,r2,r1
	  brzp	rand2			; n
	not	r1,r1			; y, get absolute value
	add	r1,r1,#1

rand2	ld	r2,msize
	add	r1,r2,r1		; |new(r0) - old(r4)| - size
	  brnz	again			; too small
	add	r4,r0,#0		; ok, adjust destination
	ldr	r7,r6,#0
	add	r6,r6,#1
;
rand4	ret

hc000	.fill	xc000
hf000	.fill	xf000
mf000	.fill	x1000
h0fff	.fill	x0fff
con1	.fill	15245
con2	.fill	12345

procid	.fill	1			; process id
stack	.fill	0xfe00			; stack at top of user memory
count	.fill	-100			; # of times to execute
hello	.stringz "Crawler R1.2"
mvmsg1	.stringz "\nProcess "
mvmsg2	.stringz ": Move #"
mvmsg3	.stringz " from "
mvmsg4	.stringz " to "
NL	.fill	#10
size	.fill	300
msize	.fill	-300
seed	.fill	0x0000
SMINUS	.fill	x002D
SnMINUS	.fill	xFFD3
SnNINE	.fill	xFFC7
SaZERO	.fill	x0030
SnZERO	.fill	xFFD0

SnONE	.fill	#-1
SFOUR	.fill	#4
SSEVEN	.fill	#7
Sxmsg	.stringz "x"


;******************************************************
; Routine:	output signed decimal #
; 		printf("%d", n);
;******************************************************
;
;	in:	r0 = #
;		r3 = buffer
;
printf	add	r6,r6,#-8	; allocate room for AR + 2 lv's
	str	r0,r6,#0	; number to output
	str	r1,r6,#1
	str	r2,r6,#2
	str	r7,r6,#3	; output buffer
	str	r4,r6,#4
	str	r5,r6,#5

	add	r1,r0,#0	; get p1, negative #?
	  brp	prntf01		; n
	  brz	outdz		; n, 0
	not	r1,r1		; y, negate
	add	r1,r1,#1
	ld	r0,SMINUS	; output '-'
	str	r0,r3,#0
	add	r3,r3,#1

; initialization

prntf01	lea	r0,dectb	; point to decimal table
	str	r0,r6,#6	; save in L1
	and	r0,r0,#0	; clear leading zero flag
	str	r0,r6,#7	; save in L2

; main loop

prntf02	ldr	r5,r6,#6	; get decimal table ptr
	add	r0,r5,#1	; increment for next loop
	str	r0,r6,#6
	ldr	r2,r5,#0	; get constant, done?
	  brz	outdrt		; y
	and	r0,r0,#0	; n, clear counter

prntf03	not	r5,r1		; -r1
	add	r5,r5,#1
	add	r5,r2,r5	; r1 < r2?
	  brp	prntf04		; y, next
	add	r0,r0,#1	; n, count
	not	r5,r2		; subtract r2 from r1
	add	r5,r5,#1
	add	r1,r1,r5
	brnzp	prntf03		; keep going

prntf04	add	r0,r0,#0	; is digit a zero?
	  brnp	prntf05		; n
	ldr	r2,r6,#7	; y, is non-zero flg set?
	  brz	prntf02		; n, don't output

prntf05	ld	r2,SaZERO	; output digit
	add	r0,r0,r2
	str	r0,r6,#7	; set non-zero flag
	str	r0,r3,#0	; output digit
	add	r3,r3,#1
	brnzp	prntf02		; next

outdz	ld	r0,SaZERO	; 0
	str	r0,r3,#0	; output digit
	add	r3,r3,#1

outdrt	ldr	r0,r6,#0	; number to output
	ldr	r1,r6,#1
	ldr	r2,r6,#2
	ldr	r7,r6,#3
	ldr	r4,r6,#4
	ldr	r5,r6,#5
	add	r6,r6,#8	; pop stack
	ret

dectb	.fill	#10000
	.fill	#1000
	.fill	#100
	.fill	#10
SONE	.fill	#1
	.fill	#0

;******************************************************
; Routine:	output hexadecimal #
; 		printf("x%0000X",n);
;******************************************************
;
;	in:	r0 = #
;		r3 = buffer
;
prntfx 	add	r6,r6,#-8	; allocate room for AR + 2 lv's
	str	r0,r6,#0	; number to output
	str	r1,r6,#1
	str	r2,r6,#2
	str	r7,r6,#3	; output buffer
	str	r4,r6,#4
	str	r5,r6,#5

	lea	r0,Sxmsg
	jsr	putmsg
	ldr	r1,r6,#0	; get n
	ld	r4,SFOUR	; set r4 = 4

prntfx2	and	r0,r0,#0	; accumulator
	ld	r5,SFOUR	; set r5 = 4

prntfx4	add	r0,r0,r0	; shift result left 1 bit
	add	r1,r1,#0	; high bit set?
	  brzp	prntfx6		; n
	add	r0,r0,#1	; y, introduce bit

prntfx6	add	r1,r1,r1	; shift number left
	add	r5,r5,#-1	; done?
	  brp	prntfx4		; n
	ld	r2,SaZERO	; y, convert to ascii
	add	r0,r0,r2
	ld	r2,SnNINE
	add	r2,r0,r2	; > '9'?
	  brnz	prntfx8		; n
	ld	r2,SSEVEN	; y, change to 'A' - 'F'
	add	r0,r0,r2

prntfx8	str	r0,r3,#0	; output character
	add	r3,r3,#1
	add	r4,r4,#-1	; done?
	  brp	prntfx2		; n 
	br	outdrt		; y



;******************************************************
;	int multiply(a, b) 
;
;	r6 ->	 0| return value | smul
;		 1| return addr  |
;		 2| r1           |
;		 3| r2           |
;		 4| r3           |
;		 5| r4           |
;		 6| return value |
;
umul	add	r6,r6,#-7
	str	r7,r6,#6	;; int multiply(a, b) {
	str	r1,r6,#2	; save r1
	str	r2,r6,#3	; save r2
	str	r3,r6,#4	; save r3
	str	r4,r6,#5	; save r4
	add	r2,r0,#0	; get b
	and	r0,r0,#0	; clear result
	ld	r3,SONE		; get 0x0001
;
;	r0 = r1 x r2
;
umul02	and	r4,r2,r3	; 1?
	  brz	umul04		; n
	add	r0,r0,r1	; y, add r1 to result

umul04	not	r4,r3		; next
	and	r2,r2,r4	; done?
	  brz	umul06		; y
	add	r3,r3,r3	; n, shift r3 left
	add	r1,r1,r1	; shift adder left
	br	umul02		; try again

umul06	ldr	r4,r6,#5	; restore r4
	ldr	r3,r6,#4	; restore r3
	ldr	r2,r6,#3	; restore r2
	ldr	r1,r6,#2	; restore r1
	ldr	r7,r6,#6
	add	r6,r6,#7
	ret


;******************************************************
;
move	lea	r3,buffer		; point to output buffer
	lea	r0,mvmsg1		; "Process "
	jsr	putmsg
	ld	r0,procid		; get process id
	jsr	printf
	lea	r0,mvmsg2		; ": Move #"
	jsr	putmsg
	add	r0,r5,#0		; get round #
	jsr	printf
	lea	r0,mvmsg3		; " from "
	jsr	putmsg
	lea	r0,start
	jsr	prntfx			; output from address
	lea	r0,mvmsg4
	jsr	putmsg
	jsr	rand			; get a random address (r4)
	add	r0,r4,#0
	jsr	prntfx 			; output address
	and	r0,r0,#0
	str	r0,r3,#0		; terminate buffer
	lea	r0,buffer
	PUTS

; ok, let's relocate

	lea	r0,crawler		; point to source
	st	r0,source		; save source
	st	r4,destin		; save destination
	ld	r1,size			; get size of move

loop	ldi	r2,source		; get data
	sti	r2,destin		; store data
	ld	r3,source		; increment source
	add	r3,r3,#1
	st	r3,source
	ld	r7,destin		; increment destination
	add	r7,r7,#1
	st	r7,destin
	add	r1,r1,#-1		; r1 = r1-1
	  brnp	loop
	jsrr	r4			; goto routine

source	.fill	0			; source
destin	.fill	0			; destination
pend	.fill	0
buffer	.fill	0
	.end
	