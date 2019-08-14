; Program compares two input values from the console and prints
; the HIGHER/MAX of them to the console (ALL AS ASCII CHARS!).
; INPUT: A pair of characters
; OUTPUT: The higher value between them (The ASCII value!)

        .ORIG  x3000
LOOP   
	GETC
	PUTC
       	BRnzp LOOP
 
ADD    R1,R0,#0    ; Move first char in R0 to R1
        IN                 ; Input second character to R1
        ADD    R2,R0,#0    ; Move second char from R0 to R1
        NOT    R3,R2       ; Two's complement second character
        ADD    R3,R3,#1
        ADD    R4,R1,R3    ; Subtract second char from first
        BRn    SECOND      ; If neg, second char greater
        ADD    R0,R1,#0    ; Move first char to R0
        BRnzp  OUTPUT      ; Skip over next statement
SECOND  ADD    R0,R2,#0    ; Move second char to R0
OUTPUT  OUT                ; print the max value stored in R0
        HALT
        .END