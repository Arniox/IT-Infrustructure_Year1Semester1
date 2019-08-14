;******************************************************
; calculator.asm - 4-function Calculator
;
;        Author:	Paul Roper
; Last Modified:	03/31/2006
;******************************************************
; Beginning system call
;
	.orig	x3000
	br	startup		; 0 = startup
	br	scanf		; 1 = scanf( "%s", &buffer );
	br	sscanf		; 2 = sscanf( buffer[], "%d", &n ); 
	br	printf		; 3 = printf( "%d", n );
	br	prntfx 		; 4 = printf( "%0000X", n );
	ret			; 5 =
	ret			; 6 =
	ret			; 7 =

;******************************************************
;	math.h
	br	smul		; 0 = multiply
	br	sdiv		; 1 = divide


;******************************************************
global	.fill	x3800		; Start of global data
stack	.fill	x4000		; Address of stack

;******************************************************
; System start up code

startup	ld	r6,stack	; set stack
	ld	r5,global	; set global
	
;	Initialize global data

	and	r0,r0,#0
	str	r0,r5,#0	; int gHXflg = 0
	str	r0,r5,#1	; int gDBflg = 0
	add	r0,r0,#-1
	str	r0,r5,#2	; int gTop = -1 (static int g_top = EMPTY;)

	str	r6,r6,#5	; save dynamic link (3+2)
	add	r6,r6,#3	; create new activation record
	jsr	main		; call main
	halt			; terminate upon return

;******************************************************
; Routine:	scanf
; 		int scanf( "%s", &buffer );
;
;	r6 ->	 0| return value |
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: &buffer  |
;
;******************************************************
scanf	str	r7,r6,#1	; save return
	ldr	r2,r6,#3	; get buffer pointer
	and	r0,r0,#0
	str	r0,r6,#0	; default return value = 0
	str	r0,r2,#0	; buffer[0] = 0

scanf02	GETC			; get character
	ld	r1,SnSPACE
	add	r1,r1,r0	; space?
	  brn	scanf10		; n, control char
	  brp	scanf06		; n, store
	OUT			; y, echo, but ignore
	br	scanf02

scanf04	GETC			; get character
	ld	r1,SnSPACE
	add	r1,r1,r0	; white space or control char?
	  brnz	scanf10		; y, done

scanf06	OUT			; n, echo character
	str	r0,r2,#0	; buffer[i] = c
	add	r2,r2,#1	; increment pointer
	and	r0,r0,#0
	str	r0,r2,#0	; buffer[i] = 0
	ld	r0,SONE
	str	r0,r6,#0	; return value = 1
	br	scanf04

scanf10	ldr	r7,r6,#1	; get return address
	ldr	r6,r6,#2	; pop AR
	ret



;******************************************************
; Routine:	sscanf
; 		int sscanf(&buffer, "%d", &n);
;
;	r6 ->	 0| return value |
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: &buffer  |
;		 4| p2: &n       |
;
sscanf	str	r7,r6,#1	; save return

	ldr	r4,r6,#3	; get buffer pointer
	and	r1,r1,#0	; clear accumulator
	and	r3,r3,#0	; assume positive

sscnf02	ldr	r0,r4,#0	; get 1st char in r0
	add	r4,r4,#1	; ready next char
	ld	r2,SnSPACE
	add	r2,r0,r2	; is r0=' '?
	  brz	sscnf02		; y
	ld	r2,SnMINUS	; n
	add	r2,r0,r2	; is r0='-'?
	  brnp	sscnf12		; n, must be digit
	add	r3,r3,#1	; y, set negative flag
	ldr	r0,r4,#0	; get next character
	add	r4,r4,#1	; read next char
	br	sscnf12		; must be digit

sscnf10	ldr	r0,r4,#0	; get char in r0, 0?
	  brz	sscnf20		; y, done
	add	r4,r4,#1	; n, ready next char

sscnf12	ld	r2,SnZERO
	add	r2,r0,r2	; is r0>='0'?
	  brn	sscnf14		; n, return
	ld	r2,SnNINE	; y
	add	r2,r0,r2	; is r0<=9?
	  brp	sscnf14		; n, return

	ld	r2,SnZERO	; change ascii to dec
	add	r0,r0,r2

;	multipy by ten (checking for overflow)

	add	r2,r1,#0	; r2 = r1
	  brn	sscnf14
	add	r1,r1,r1	; x2
	  brn	sscnf14
	add	r1,r1,r1	; x4
	  brn	sscnf14
	add	r1,r1,r2	; x5
	  brn	sscnf14
	add	r1,r1,r1	; x10
	  brn	sscnf14
	add	r1,r1,r0	; r1 = r1*10 + r0
	  brzp	sscnf10		; loop

sscnf14	and	r0,r0,#0	; overflow or error, return false (0)
	br	sscnf30

sscnf20	add	r3,r3,#0	; positive?
	  brz	sscnf22		; y
	not	r1,r1		; n, negate R1
	add	r1,r1,#1	

sscnf22	ldr	r2,r6,#4	; get &n
	str	r1,r2,#0	; store result in n
	ld	r0,SONE		; return true (1)

sscnf30	str	r0,r6,#0	; return value
	ldr	r7,r6,#1	; pop R7
	ldr	r6,r6,#2	; pop AR
	ret

SnSPACE	.fill	xFFE0



;******************************************************
; Routine:	output signed decimal #
; 		printf("%d", n);
;******************************************************
;
;	r6 ->	 0| return value |
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: n        |
;		 4| l1: L1       |
;		 5| l2: L2       |
;
printf 	str	r7,r6,#1	; save return
	ldr	r1,r6,#3	; negative #?
	  brp	prntf01		; n
	  brz	outdz		; n, 0
	not	r1,r1		; y, negate
	add	r1,r1,#1
	ld	r0,SMINUS	; output '-'
	OUT

; initialization

prntf01	lea	r0,dectb	; point to decimal table
	str	r0,r6,#4	; save in L1
	and	r0,r0,#0	; clear leading zero flag
	str	r0,r6,#5	; save in L2

; main loop

prntf02	ldr	r3,r6,#4	; get decimal table ptr
	add	r0,r3,#1	; increment for next loop
	str	r0,r6,#4
	ldr	r2,r3,#0	; get constant, done?
	  brz	outdrt		; y
	and	r0,r0,#0	; n, clear counter

prntf03	not	r3,r1		; -r1
	add	r3,r3,#1
	add	r3,r2,r3	; r1 < r2?
	  brp	prntf04		; y, next
	add	r0,r0,#1	; n, count
	not	r3,r2		; subtract r2 from r1
	add	r3,r3,#1
	add	r1,r1,r3
	br	prntf03		; keep going

prntf04	add	r0,r0,#0	; is digit a zero?
	  brnp	prntf05		; n
	ldr	r2,r6,#5	; y, is non-zero flg set?
	  brz	prntf02		; n, don't output

prntf05	ld	r2,SaZERO	; output digit
	add	r0,r0,r2
	str	r0,r6,#5	; set non-zero flag
	OUT
	br	prntf02		; next

outdz	ld	r0,SaZERO	; 0
	OUT

outdrt	ldr	r7,r6,#1	; get return address
	ldr	r6,r6,#2	; pop AR
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
;	r6 ->	 0| return value |
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: n        |
;
prntfx 	str	r7,r6,#1	; save return
	lea	r0,Sxmsg
	PUTS
	ldr	r1,r6,#3	; get n
	ld	r4,SFOUR	; set r4 = 4

prntfx2	and	r0,r0,#0	; accumulator
	ld	r3,SFOUR	; set r3 = 4

prntfx4	add	r0,r0,r0	; shift result left 1 bit
	add	r1,r1,#0	; high bit set?
	  brzp	prntfx6		; n
	add	r0,r0,#1	; y, introduce bit

prntfx6	add	r1,r1,r1	; shift number left
	add	r3,r3,#-1	; done?
	  brp	prntfx4		; n
	ld	r2,SaZERO	; y, convert to ascii
	add	r0,r0,r2
	ld	r2,SnNINE
	add	r2,r0,r2	; > '9'?
	  brnz	prntfx8		; n
	ld	r2,SSEVEN	; y, change to 'A' - 'F'
	add	r0,r0,r2

prntfx8	OUT			; output character
	add	r4,r4,#-1	; done?
	  brp	prntfx2		; n
	ldr	r7,r6,#1	; y, get return address
	ldr	r6,r6,#2	; pop AR
	ret



;******************************************************
;	int multiply(a, b) 
;
;	r6 ->	 0| return value | smul
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: a        |
;		 4| p2: b        |
;		 5| l1: result   |
;		 6| l2: sign     |
;
smul	str	r7,r6,#1	;; int multiply(a, b) {

	and	r0,r0,#0	;;   int result = 0;
	str	r0,r6,#5
	and	r0,r0,#0	;;   int sign = 0;
	str	r0,r6,#6

	ldr	r0,r6,#4	;;   if ( b = pop() < 0) {
	  brzp	smul02
	ldr	r0,r6,#4	;;     b = -b;
	not	r0,r0
	add	r0,r0,#1
	str	r0,r6,#4
	ld	r0,SnONE	;;     sign = -1;
	str	r0,r6,#6
				;;   }
smul02	ldr	r0,r6,#4	;;   while ( b-- )
	  brz	smul04
	add	r0,r0,#-1
	str	r0,r6,#4
	ldr	r0,r6,#5	;;      result += a;
	ldr	r1,r6,#3
	add	r0,r0,r1
	str	r0,r6,#5
	br	smul02

smul04	ldr	r0,r6,#6	;;   if ( sign ) result = -result;
	  brz	smul06
	ldr	r0,r6,#5
	not	r0,r0
	add	r0,r0,#1
	str	r0,r6,#5

smul06	ldr	r0,r6,#5	;;   return( result );
	str	r0,r6,#0
	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	int divide(a, b)
;
;	r6 ->	 0| return value | sdiv
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: a        |
;		 4| p2: b        |
;		 5| l1: result   |
;		 6| l2: sign     |
;
sdiv	str	r7,r6,#1	;; int divide(a, b) {
	and	r0,r0,#0	;;    int result = 0;
	str	r0,r6,#5
	ld	r0,SONE		;;    int sign = 1;
	str	r0,r6,#6

	ldr	r0,r6,#3	;;    if ( a == 0) {
	  brnp	sdiv02
	lea	r0,SD0msg	;;        printf("Error: /0");
	PUTS
	and	r0,r0,#0
	br	sdiv20		;;        return(0);
				;;    }

sdiv02	ldr	r0,r6,#3	;;    if ( a<0 ) {
	  brzp	sdiv04
	ldr	r0,r6,#3	;;        a = -a;
	not	r0,r0
	add	r0,r0,#1
	str	r0,r6,#3
	ld	r0,SnONE	;;        sign = -1;
	str	r0,r6,#6
				;;    }
sdiv04	ldr	r0,r6,#4	;;    if ( b = pop() < 0) {
	  brzp	sdiv06
	ldr	r0,r6,#4	;;        b = -b;
	not	r0,r0
	add	r0,r0,#1
	str	r0,r6,#4
	ldr	r0,r6,#6	;;        sign = -sign;
	not	r0,r0
	add	r0,r0,#1
	str	r0,r6,#6
				;;    }
sdiv06	ldr	r0,r6,#4	;;    while ( b>=a ) {
	ldr	r1,r6,#3
	not	r1,r1
	add	r1,r1,#1
	add	r0,r0,r1
	  brn	sdiv10
	ldr	r0,r6,#5	;;       result++;
	add	r0,r0,#1
	str	r0,r6,#5
	ldr	r0,r6,#4	;;       b -= a;
	ldr	r1,r6,#3
	not	r1,r1
	add	r1,r1,#1
	add	r0,r0,r1
	str	r0,r6,#4
	br	sdiv06		;;    }

sdiv10	ldr	r0,r6,#6	;;    if ( sign<0 ) result = -result
	  brzp	sdiv12
	ldr	r0,r6,#5
	not	r0,r0
	add	r0,r0,#1
	str	r0,r6,#5

sdiv12	ldr	r0,r6,#5

sdiv20	str	r0,r6,#0	;;    return( result );
	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret

SD0msg	.stringz "\nDivision by zero"


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
;******************************************************
;	Global Constants
;
ICmsg	.stringz "\nInvalid"    ;; #define BAD_INPUT_MSG    "\nERROR: not a valid number format or command"
;				;; #define WELCOME_MSG      "\nLBIC (Low Budget Integer Calculator)"
WMSG	.stringz "LBIC (Low Budget Integer Calculator R2.0a)"
QMSG	.stringz "\nBye\n"	;; #define QUIT_MSG         "\nBye"
PROMPT	.stringz "\n> "		;; #define PROMPT           "\n> "

nADD	.fill	xFFD5		;; #define ADD            '+'
nSUB	.fill	xFFD3		;; #define SUB            '-'
nMUL	.fill	xFFD6		;; #define MUL		  '*'
nDIV	.fill	xFFD1		;; #define DIV		  '/'
nMOD	.fill	xFFDB		;; #define MOD		  '%'
nPRTTOP	.fill	xFFC3		;; #define PRINT_TOP      '='
nPRTSTK	.fill	xFF8D		;; #define PRINT_STACK    's'
nCLEAR	.fill	xFF9D		;; #define CLEAR          'c'
nEXCH	.fill	xFF9B		;; #define EXCHANGE	  'e'
nPOP	.fill	xFF90		;; #define POP            'p'
nQUIT	.fill	xFF8F		;; #define QUIT           'q'

nFACT	.fill	xFFDF		;; #define FACTORIAL      '!'
nBUG	.fill	xFF9C		;; #define DEBUG          'd'
nHELP	.fill	xFF98		;; #define HELP           'h'
nHEX	.fill	xFF88		;; #define HEX            'x'

MAXIN	.fill	#10		;; #define MAX_INPUT_STRING  10
EMPTY	.fill	#-1		;; #define EMPTY             -1

ONE	.fill	#1
nONE	.fill	#-1

nCR	.fill	xFFF6
nA	.fill	xFFBF
nZ	.fill	xFFA6
aA	.fill	#32		; 'a'-'A'

;******************************************************
;	Global Variables are referenced off of r5
;
				;; r5,#0 = static int g_hex = 0;
				;; r5,#1 = static int g_debug = 0;
				;; r5,#2 = static int g_top = EMPTY;
				;; r5,#3 = static int g_stack[MAX_STACK_HEIGHT];

;******************************************************
;	int main ( int argc, char *argv[] )
;
;	r6 ->	 0| return value | main
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: argc     |
;		 4| p2: &argv[]  |
;		  |--------------|
;		 5| return value | exec
;		 6| return adr   |
;		 7| dynamic link |
;
main	str	r7,r6,#1	;; int main ( int argc, char *argv[] ) {
	lea	r0,WMSG		;;   printf( WELCOME_MSG );
	PUTS
	str	r6,r6,#7	;;   execute_commands();
	add	r6,r6,#5
	jsr	exec
	lea	r0,QMSG		;;   printf( QUIT_MSG );
	PUTS
	and	r0,r0,#0	;;   return 0;
	str	r0,r6,#0
	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void execute_commands()
;
;	r6 ->	 0| return value | exec
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: buffer   |
;		  |   ....       |
;		13| l2: num_chars|
;		  |--------------|
;		14| return value | getstring, addcmd, subcmd,...
;		15| return adr   |
;		16| dynamic link |
;		17| p1: &buffer  |
;		18| p2: MAXIN    |
;
exec	str	r7,r6,#1	;; void execute_commands() {
				;;   char buffer[MAX_INPUT_STRING];
				;;   int num_chars = 0;
exec10				;;   while ( TRUE ) {
	lea	r0,PROMPT	;;     printf( PROMPT );
	PUTS
	add	r0,r6,#3	;;     num_chars = get_string( buffer, MAX_INPUT_STRING );
	str	r0,r6,#17
	ld	r0,MAXIN
	str	r0,r6,#18
	str	r6,r6,#16
	add	r6,r6,#14
	jsr	getstring
	ldr	r0,r6,#14
	str	r0,r6,#13

	add	r0,r6,#3	;;     if ( push_number( buffer ) ) {
	str	r0,r6,#17
	str	r6,r6,#16
	add	r6,r6,#14
	jsr	pushn
	ldr	r0,r6,#14
	  brnp	exec90		;;       continue;
				;;     }
	ldr	r0,r6,#3	;;     if ( buffer[0] == QUIT ) return;
	ld	r1,nQUIT
	add	r0,r0,r1
	  brz	exec99
	ldr	r0,r6,#3	;;     switch( buffer[0] ){
	ld	r1,nADD
	add	r1,r0,r1
	  brz	cADD
	ld	r1,nSUB
	add	r1,r0,r1
	  brz	cSUB
	ld	r1,nMUL
	add	r1,r0,r1
	  brz	cMUL
	ld	r1,nDIV
	add	r1,r0,r1
	  brz	cDIV
	ld	r1,nPRTSTK
	add	r1,r0,r1
	  brz	cPRTSTK
	ld	r1,nPRTTOP
	add	r1,r0,r1
	  brz	cPRTTOP
	ld	r1,nCLEAR
	add	r1,r0,r1
	  brz	cCLEAR
	ld	r1,nEXCH
	add	r1,r0,r1
	  brz	cEXCH
	ld	r1,nPOP
	add	r1,r0,r1
	  brz	cPOP
	ld	r1,nHELP
	add	r1,r0,r1
	  brz	cHELP
	ld	r1,nMOD
	add	r1,r0,r1
	  brz	cMOD
				; <<< add new commands here...
	ld	r1,nBUG
	add	r1,r0,r1
	  brz	cBUG
	ld	r1,nHEX
	add	r1,r0,r1
	  brz	cHEX
	ld	r1,nFACT
	add	r1,r0,r1
	  brz	cFACT
	br	cDEFAULT

cADD				;;     case ADD:
	str	r6,r6,#16	;;       add_command();
	add	r6,r6,#14
	jsr	addcmd
	br	exec90		;;       break;


cSUB				;;     case SUB:
	str	r6,r6,#16	;;       sub_command();
	add	r6,r6,#14
	jsr	subcmd
	br	exec90		;;       break;

cMUL				;;     case MUL:
	str	r6,r6,#16	;;       mul_command();
	add	r6,r6,#14
	jsr	mulcmd
	br	exec90		;;       break;

cDIV				;;     case DIV:
	str	r6,r6,#16	;;       div_command();
	add	r6,r6,#14
	jsr	divcmd
	br	exec90		;;       break;

cMOD				;;     case MOD:
				;;	 A B A B / * -
	str	r6,r6,#16	;;       mod_command();
	add	r6,r6,#14
	jsr	divcmd
	br	exec90		;;       break;

cPRTTOP				;;     case PRINT_TOP:
	str	r6,r6,#16	;;       print_top();
	add	r6,r6,#14
	jsr	top
	br	exec92		;;       break;

cPRTSTK				;;     case PRINT_STACK:
	str	r6,r6,#16	;;       print_stack();
	add	r6,r6,#14
	jsr	prntstk
	br	exec92		;;       break;

cCLEAR				;;     case CLEAR:
	str	r6,r6,#16	;;       clear_command();
	add	r6,r6,#14
	jsr	clrcmd
	br	exec90		;;       break;

cEXCH				;;     case EXCHANGE:
	str	r6,r6,#16	;;       exchange_command();
	add	r6,r6,#14
	jsr	xchcmd
	br	exec90		;;       break;

cPOP				;;     case POP:
	str	r6,r6,#16	;;       pop();
	add	r6,r6,#14
	jsr	popcmd
	br	exec90		;;       break;

cHELP				;;     case HELP:
	ld	r0,Hmsgp	;;       printf("%s", HELPmsg);
	PUTS
	br	exec92		;;       break;

Hmsgp	.fill	HELPmsg

cBUG				;;     case BUG:
	ldr	r0,r5,#1	;;       bugflg = ~bugflg;
	not	r0,r0
	str	r0,r5,#1
	br	exec90		;;       break;

cHEX				;;     case HEX:
	ldr	r0,r5,#0	;;       hexflg = ~hexflg;
	not	r0,r0
	str	r0,r5,#0
	br	exec90		;;       break;

cFACT				;;     case FACT:
	jsr	pop		;;       push( factorial( pop() ) );
	str	r0,r6,#17
	str	r6,r6,#16
	add	r6,r6,#14
	jsr	factorial
	ldr	r0,r6,#14
	jsr	push
	br	exec90		;;       break;

cDEFAULT			;;     default:
	lea	r0,ICmsg	;;       printf( BAD_INPUT_MSG );
	PUTS
	br	exec92
				;;     } /* end switch */
exec90	ldr	r0,r5,#1	;;     if (DebugFlag)
	  brz	exec10
	str	r6,r6,#16	;;       print_stack();
	add	r6,r6,#14
	jsr	prntstk

exec92	br	exec10
				;;   } /* end while */
				;; } /* end execute_commands() */
exec99	ldr r7,r6,#1
	ldr r6,r6,#2
	ret



;******************************************************
;	int get_string( char buffer[], int max )
;
;	r6 ->	 0| return value | getstring
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: &buffer  |
;	         4| p2: max      |
;                5| l1: c        |
;                6| l2: i        |
;
getstring str	r7,r6,#1	;; void getString(char* b, int max) {
				;;    int c;
	and	r0,r0,#0	;;    int i = 0;
	str	r0,r6,#6

gets02	ldr	r0,r6,#4	;;    while (i < max) {
	ldr	r1,r6,#6
	not	r1,r1
	add	r0,r0,r1
	  brn	gets10
	GETC			;;       c = getchar();
	str	r0,r6,#5
	ld	r1,nCR		;;       if (c == CR) break;       /* break on CR */
	add	r1,r1,r0
	  brz	gets10
	OUT			;;       putchar(c);
	ldr	r0,r6,#5	;;       if (c >= 'A' && c <= 'Z')  /* convert to lower case */
	ld	r1,nA
	add	r1,r1,r0
	  brn	gets04
	ld	r1,nZ
	add	r1,r1,r0
	  brp	gets04
	ld	r1,aA
	add	r0,r0,r1	;;             c += 'a' - 'A';
	str	r0,r6,#5
			
gets04	ldr	r2,r6,#3	;;       b[i++] = c;
	ldr	r1,r6,#6
	add	r2,r2,r1
	add	r1,r1,#1
	str	r1,r6,#6
	ldr	r0,r6,#5
	str	r0,r2,#0
	br	gets02		;;    }

gets10	ldr	r2,r6,#3	;;    b[i] = 0;                      /* terminate buffer */
	ldr	r1,r6,#6
	add	r2,r2,r1
	and	r0,r0,#0
	str	r0,r2,#0

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
; This code does not check for buffer overflow nor
; convert upper to lower case.  Replace with C routine above.
;
;	ldr	r0,r6,#3	; get buffer pointer
;	str	r0,r6,#10	; pass to scanf
;	str	r6,r6,#9
;	add	r6,r6,#7
;	ld	r1,stdio
;	jsrr	r1,#1		; int scanf("%s", buffer);
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

gets20	ldr r7,r6,#1		; get return address
	ldr r6,r6,#2		; pop AR
	ret			;; }



;******************************************************
;	bool push_number( char buffer[])
;
;	r6 ->	 0| return value | pushn
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: &buffer  |
;		 4| l1: n        |
;		  |--------------|
;		 5| return value | sscanf
;		 6| return adr   |
;		 7| dynamic link |
;		 8| p1: &buffer  |
;		 9| p2: &n       |
;
pushn	str	r7,r6,#1	;; bool push_number( char buffer[]) {
				;;    int n;
	ldr	r0,r6,#3	;;    if ( sscanf( buffer[], "%d", &n ) ) {
	str	r0,r6,#8
	add	r0,r6,#4
	str	r0,r6,#9
	str	r6,r6,#7
	add	r6,r6,#5
	ld	r1,stdio
	add	r1,r1,#2
	jsrr	r1
	ldr	r0,r6,#5
	  brz	pushn02
	ldr	r0,r6,#4	;;       push(n);
	jsr	push
	ld	r0,ONE		;;       return (1);
	br	pushn04
				;;    }
pushn02	and	r0,r0,#0	;;    return (0);

pushn04	str	r0,r6,#0
	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void factorial_command()
;
;	r6 ->	 0| return value | factcmd
;		 1| return addr  |
;		 2| dynamic link |
;		  |--------------|
;		 3| return value | factorial
;		 4| return adr   |
;		 5| dynamic link |
;		 6| p1: i        |
;
;factcmd str	r7,r6,#1	;; void factorial_command()
;				;;   if ( underflow(UNARY) ) return;
;	jsr	pop		;;   push( factorial( pop() ) );
;	str	r0,r6,#6
;	str	r6,r6,#5
;	add	r6,r6,#3
;	jsr	factorial
;	ldr	r0,r6,#3
;	jsr	push
;
;	ldr	r7,r6,#1	;; }
;	ldr	r6,r6,#2
;	ret



;******************************************************
;	void add_command()
;
;	r6 ->	 0| return value | addcmd
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: first    |
;		 4| l2: second   |
;
addcmd	str	r7,r6,#1	;; void add_command() {
				;;   if ( underflow(BINARY) ) return;
	jsr	pop		;;   int first = pop();
	str	r0,r6,#3

	jsr	pop		;;   int second = pop();
	str	r0,r6,#4

	ldr	r0,r6,#3	;;   push( second + first );
	ldr	r1,r6,#4
	add	r0,r0,r1
	jsr	push

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void sub_command() 
;
;	r6 ->	 0| return value | subcmd
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: first    |
;		 4| l2: second   |
;
subcmd	str	r7,r6,#1	;; void sub_command() {
				;;   if ( underflow(BINARY) ) return;
	jsr	pop		;;   int first = pop();
	str	r0,r6,#3

	jsr	pop		;;   int second = pop();
	str	r0,r6,#4

	ldr	r0,r6,#3	;;   push( second - first );
	ldr	r1,r6,#4
	not	r0,r0
	add	r1,r1,#1
	add	r0,r0,r1
	jsr	push

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret

stdio	.fill	x3000		;; #include <stdio.h>
math	.fill	x3008		;; #include <math.h>


;******************************************************
;	void mulc_command() 
;
;	r6 ->	 0| return value | mulcmd
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: first    |
;		 4| l2: second   |
;		  |--------------|
;		 5| return value | sys_mul, push
;		 6| return adr   |
;		 7| dynamic link |
;		 8| p1: a        |
;		 9| p2: b        |
;
mulcmd	str	r7,r6,#1	;; void mul_command() {
				;;   int a,b;
	jsr	pop		;;   a = pop();
	str	r0,r6,#3
	jsr	pop		;;   b = pop();
	str	r0,r6,#4

	ldr	r0,r6,#3	;;   push ( a * b );
	str	r0,r6,#8
	ldr	r0,r6,#4
	str	r0,r6,#9
	str	r6,r6,#7
	add	r6,r6,#5
	ld	r1,math
	jsrr	r1
	ldr	r0,r6,#5
	jsr	push

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void div_command()
;
;	r6 ->	 0| return value | divcmd
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: first    |
;		 4| l2: second   |
;		  |--------------|
;		 5| return value | sys_div, push
;		 6| return adr   |
;		 7| dynamic link |
;		 8| p1: a        |
;		 9| p2: b        |
;
divcmd	str	r7,r6,#1	;; void div_command() {
				;;   int a,b;
	jsr	pop		;;   a = pop();
	str	r0,r6,#3
	jsr	pop		;;   b = pop();
	str	r0,r6,#4

	ldr	r0,r6,#3	;;   push ( b / a );
	str	r0,r6,#8
	ldr	r0,r6,#4
	str	r0,r6,#9
	str	r6,r6,#7
	add	r6,r6,#5
	ld	r1,math
	add	r1,r1,#1
	jsrr	r1
	ldr	r0,r6,#5
	jsr	push

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	int factorial(n)
;
;	r6 ->	 0| return value | factorial
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: n        |
;		  |--------------|
;		 4| return value | factorial, mul
;		 5| return adr   |
;		 6| dynamic link |
;		 7| p1: n or a   |
;		 8| p2: b        |
;
factorial			;; int factorial(n) {
	str	r7,r6,#1
	ldr	r0,r6,#3	;;    if( n<1 ) return (1);
	  brp	fact02
	ld	r0,factC1
	br	fact10

fact02	ldr	r0,r6,#3	;;    return ( n * factorial(n-1));
	add	r0,r0,#-1
	str	r0,r6,#7
	str	r6,r6,#6
	add	r6,r6,#4
	jsr	factorial
	ldr	r0,r6,#3
	str	r0,r6,#7
	ldr	r0,r6,#4
	str	r0,r6,#8
	str	r6,r6,#6
	add	r6,r6,#4
	ld	r1,math
	jsrr	r1
	ldr	r0,r6,#4

fact10	str	r0,r6,#0
	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret

factC1	.fill	1


;******************************************************
;	void print_stack() 
;
;	r6 ->	 0| return value | prntstk
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: i        |
;		  |--------------|
;		 4| return value | outstk
;		 5| return adr   |
;		 6| dynamic link |
;		 7| p1: i        |
;
prntstk	str	r7,r6,#1	;; void print_stack() {
				;;    int i;
	lea	r0,S1msg	;;    printf("  :");
	PUTS
	ldr	r1,r5,#2	;;    if (gTOP <0) {
	  brzp	prnts2
	lea	r0,ESmsg	;;       printf("Empty");
	PUTS
	br	prnts8		;;       return;
				;;    }
prnts2	ldr	r0,r5,#2	;;    for (i=gTOP; i>=0; i--) {
	str	r0,r6,#3

prnts4	ldr	r1,r6,#3
	  brn	prnts8
	str	r1,r6,#7	;;      outStack(i);
	str	r6,r6,#6
	add	r6,r6,#4
	jsr	outstk
	ldr	r0,r6,#3	;       if( i > 0 ) printf(", ");
	  brnz	prnts6
	lea	r0,CRmsg
	PUTS

prnts6	ldr	r0,r6,#3	; i--
	add	r0,r0,#-1
	str	r0,r6,#3
	br	prnts4

prnts8	ldr	r7,r6,#1	;;    return;
	ldr	r6,r6,#2	;; }
	ret

S1msg	.stringz "   "
ESmsg	.stringz "Empty"	;; #define EMPTY_STACK_MSG  "\nERROR: stack empty"
;CRmsg	.stringz "\n"
CRmsg	.stringz ", "



;******************************************************
;	void clear_command() 
;
;	r6 ->	 0| return value | clrcmd
;		 1| return addr  |
;		 2| dynamic link |
;
clrcmd	str	r7,r6,#1	;; void clear_command() {

	and	r0,r0,#0	;;    gTop = EMPTY;
	add	r0,r0,#-1
	str	r0,r5,#2

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void exchange_command() 
;
;	r6 ->	 0| return value | xchcmd
;		 1| return addr  |
;		 2| dynamic link |
;		 3| l1: first    |
;		 4| l2: second   |
;
;
xchcmd	str	r7,r6,#1	;; void exchange_command() {

	jsr	pop		;;    int first = pop();
	str	r0,r6,#3

	jsr	pop		;;    int second = pop();
	str	r0,r6,#4

	ldr	r0,r6,#3	;;    push(first);
	jsr	push

	ldr	r0,r6,#4	;;    push(second);
	jsr	push

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void pop_command() 
;
;	r6 ->	 0| return value | popcmd
;		 1| return addr  |
;		 2| dynamic link |
;
popcmd	str	r7,r6,#1	;; void pop_command() {

	jsr	pop		;;    pop();

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void top() - output top number on stack 
;
;	r6 ->	 0| return value | top
;		 1| return addr  |
;		 2| dynamic link |
;		  |--------------|
;		 3| return value | outstk
;		 4| return adr   |
;		 5| dynamic link |
;		 6| p1: gTop     |
;
top	str	r7,r6,#1	;; void top() {

	lea	r0,S1msg	;;   printf("  :");
	PUTS
	ldr	r0,r5,#2	;;   outstk(gTop);
	str	r0,r6,#6
	str	r6,r6,#5
	add	r6,r6,#3
	jsr	outstk

	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	void outstk(int i)
;	Print the ith element of the stack 
;
;	r6 ->	 0| return value | outstk
;		 1| return addr  |
;		 2| dynamic link |
;		 3| p1: i        |
;		  |--------------|
;		 4| return value | printf
;		 5| return adr   |
;		 6| dynamic link |
;		 7| p1: n        |
;
outstk	str	r7,r6,#1	;; void outstk(int i) { 

	ldr	r1,r6,#3	;;   if (i < 0) printf("\nEmpty");
	  brzp	outstk2
	lea	r0,ESmsg
	PUTS
	br	outstk6

outstk2
;	lea	r0,CRmsg	;;   else printf("\n%d", stack[i]);
;	PUTS
	add	r2,r5,#3
	ldr	r1,r6,#3
	add	r2,r2,r1
	ldr	r0,r2,#0
	str	r0,r6,#7
	str	r6,r6,#6
	add	r6,r6,#4
	ld	r1,stdio
	ldr	r0,r5,#0	; check hexflag
	  brnp	outstk4
	add	r1,r1,#3
	jsrr	r1		; printf("%d",n);
	br	outstk6

outstk4	add	r1,r1,#4
	jsrr	r1		; printf("%0000X",n);

outstk6	ldr	r7,r6,#1	;; }
	ldr	r6,r6,#2
	ret



;******************************************************
;	int pop()
;
;	NOTE: pop does not use an activation record! 
;
;	out: r0 = number
;
pop	add	r3,r7,#0	; save return
	ldr	r0,r5,#2	; if ( gtop == EMPTY ) {
	  brzp	pop02
	lea	r0,UFmsg	; printf( "\nError: stack underflow" );
	PUTS
	and	r0,r0,#0	; return 0;
	br	pop04

pop02	add	r2,r5,#3	; point to gStack
	ldr	r1,r5,#2	; get gTop
	add	r2,r2,r1	; gStack[gTop]
	add	r1,r1,#-1
	str	r1,r5,#2	; gTop--
	ldr	r0,r2,#0	; return gStack[gTop--]

pop04	add	r7,r3,#0	; return resturn
	ret

OFmsg	.stringz "\nOverflow"	;; #define OVERFLOW_MSG     "\nERROR: stack overflow"
UFmsg	.stringz "\nUnderflow"	;; #define UNDERFLOW_MSG    "\nERROR: stack underflow"
MAXSZ	.fill	#20		;; #define MAX_STACK_HEIGHT  20


;******************************************************
;	void push( int n ) 
;
;	NOTE: push does not use an activation record! 
;
;	in: r0 = #
;
push	add	r3,r7,#0	; save return
	ld	r2,MAXSZ	; if ( gTop >= MAXSZ) {
	ldr	r1,r5,#2	; get gTop
	not	r1,r1
	add	r2,r2,r1
	  brp	push02
	lea	r0,OFmsg	; printf("Error: stack overflow");
	PUTS
	br	push04

push02	ldr	r1,r5,#2	; get gTop
	add	r1,r1,#1	; ++gTop
	str	r1,r5,#2	; save
	add	r2,r5,#3	; point to gStack
	add	r2,r2,r1	; gStack[++gTop] = a
	str	r0,r2,#0

push04	add	r7,r3,#0	; return
	ret

HELPmsg	.stringz "\n  +  Add\n  -  Subtract\n  *  Multiply\n  /  Divide\n  =  Print TOS\n  s  Print stack\n  c  Clear stack\n  e  Exchange\n  p  Pop stack\n  q  Quit\n  !  Factorial\n  d  Toggle debug\n  x  Toggle hex output"


;******************************************************
; global storage is referenced beyond r5
;
;gHxflg	.fill	#0		;; r5,#0 = static int g_hex = 0;
;gDBflg	.fill	#0		;; r5,#1 = static int g_debug = 0;
;gTop	.fill	#-1		;; r5,#2 = static int g_top = EMPTY;
;gStack	.blkw	20		;; r5,#3 = static int g_stack[MAX_STACK_HEIGHT];


	.end
