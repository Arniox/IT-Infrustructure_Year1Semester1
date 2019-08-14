; Program to add three numbers stored in three registers
; INPUT: Put the three numbers in three registers R1, R2 and R3
; OUTPUT: The result of the addition will be stored in register R4

        .ORIG x3000
        LD    R1,NUM1      ; LOAD number 1 into R1
        LD    R2,NUM2      ; LOAD number 2 into R2
        LD    R3,NUM3      ; LOAD number 3 into R3
        AND   R4,R4,#0     ; CLEAR (zero) contents of R4
        ADD   R4,R4,R1     ; ADD 1st/R1 to R4=0
        ADD   R4,R4,R2     ; ADD 2nd/R2 to R4 sum
        ADD   R4,R4,R3     ; ADD 3rd/R3 to R4 sum
        ST    R4,RESULT    ; Store sum/R4 to RESULT
        HALT               ; Done - stop program

; Data/Variable Storage
	NUM1   .FILL   5           ; Value of 1st number
	NUM2   .FILL  10           ; Value of 2nd number
	NUM3   .FILL  15           ; Value of 3rd number
	RESULT .BLKW   1           ; Storage for sum result
        .END