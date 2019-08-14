.orig x3000

LowestValue 	.fill 9			; Use a high number, cause everything tested against this is lower
            LD     R5, LowestValue	; load reg 5 with lowest value
            LD     R4, LowestValue	; load reg 4 with lowest value
            NOT    R4, r4		; NOT this value
            ADD    R4, r4, #1		; finish flipping this value

            LEA    R3, IDNumArray	; Load the array IDNumArray into reg 3
            AND    R2, R2, #0  		; Initialize R2 <- 0 (counter)

Name 		.stringz "Nikkolas Diehl: 16945724"
IDNumEnter 	.stringz "\nEnter numbers from 1-9 separated by spaces: "
            LEA    R0, Name
            PUTS			; print the string out
	    LEA    R0, IDNumEnter
            PUTS			; print the string out
	

loopID 	    getc			; starts ID number loop. This number is saved and sorted
            ADD    R0, R0, #-10		; Test for enter character
            BRZ    finishloop2		; Cancel loop if enter is detected
            ADD    R0, R0, #10		; Switch input back to normal

            LD     R1, CheckForSpace	; Loads the check value for space into reg 1
            ADD    R1, R0, R1		; Checks for a space character
            BRZ    FuncSpace1		; If it detects a space, go to print space function

            STR    R0, r3, #0		; Store into the array, what is in reg 0
            ADD    R3, r3, #1		; Increments the pointer
            ADD    R2, r2, #1		; Increments the counter
            OUT				; Prints out the typed in number

            LD     R1, MCCharacter	; loads neg conversion number into reg 1 (this is not needed for long)
            ADD    R0, R0, R1		; converts input character to a number


checkLow    ADD    R6, R0, #0		; move input to reg 6
            NOT    R5, R5		; begin 2's complement of lowest current value
            ADD    R5, R5, #1		; reg 5 is now -(LowestValue)
            ADD    R6, R6, R5		; R6 = input + (-LowestValue)
            BRZP   checkHigh		; If the answer is pos or 0, then it's higher, skip saving a lower value
            ADD    R5, R0, #0		; If it's lower, Move new lowest value to reg 5
            BR     loopID
checkHigh   ADD    R6, R0, #0		; move input to reg 6 again
            NOT    R4, R4		; begin 2's complement of highest current value
            ADD    R4, R4, #1		; reg 7 is now -(HighestValue)
            ADD    R6, R6, R4		; R6 = input + (-(HighestValue))
            BRN    UndoAll		; If the answer is negative, then don't loop, it's lower than max, but higher than lowest value
            ADD    R4, R0, #0		; If it's higher, load new highest input into reg 4


UndoAll	    ADD    R5, R5, #0		;  if the lower value is negative, make sure to undo the NOT
            BRN    undo1		; goto undo NOT 1
            ADD    R4, R4, #0		; if the higher value is negative, make sure to undo the NOT
            BRN    undo2		; goto undo NOT 2
            BR     loopID		; Jump back to top of loop if BOTH variables are fine
undo1	    NOT    R5, R5		; If the lowest value is not fine, then NOT it
            ADD    R5, R5 #1		; Finish flipping the value
            BR     UndoAll		; It has to double check the other value as well, so restart NOT check
undo2	    NOT    R4, R4		; If the value above was fixed, or was fine already, and it comes here, then NOT the highest value
            ADD    R4, R4 #1		; finish flipping the value to fix it
            BR     loopID		; finally, restart loop

finishloop2
; By this point, 
; r0 has the last input as a number and/or test for space (can't use to store value within loop)
; r1 has neg/pos value of conversion (can't use within loop)
; r2 has the counter (very important, can't overwrite)
; r3 has array (very important, can't overwrite)
; r4 has highest current value (very important)
; r5 has lowest value (very important)
; r6 has test value (not important, but can't hold anything in loop)

            LEA    R0, NewLine		; loads newline into reg 0
            PUTS			; prints it out

	    AND    R6, R6, #9  		; Initialize R6 <- 9 (counter)
            LEA    R3, IDNumArray    	; Put file pointer into R3
PRINT1      LDR    R0, R3, #0  		; Put next file item into R0
            BRZ    END_PRINT1  		; Loop until file item is 0
	    OUT				; Print out the index N of the array
	    LEA    R0, SpaceCharacter	; Load space
	    PUTS			; Print it out
	    LDR    R0, R3, #0		; Load back the character to fix bug
            ADD    R3, R3, #1  		; Increment file pointer
            ADD    R6, R6, #-1  	; Decrincrement counter
            BRNZP  PRINT1      		; Counter loop
END_PRINT1

            LEA    R0, NumOfChar1
            PUTS			; prints the text
            LD     R1, MCCharacter	; load reg 1 with -48
            NOT    R1, R1		; NOT that value
            ADD    R1, R1, #1		; finish flipping to 48
            ADD    R0, R2, R1		; converts number to a printable character
            OUT				; print the counter
            LEA    R0, NumOfChar2
            PUTS

            LEA    R0, lowest		; The lowest number was:
            PUTS			; prints the text
            LD     R1, MCCharacter	; load reg 1 with -48
            NOT    R1, R1		; NOT that value
            ADD    R1, R1, #1		; finish flipping to 48
            ADD    R0, R5, R1		; converts number to a printable character
            OUT				; prints it out

            LEA    R0, highest		; The highest number was:
            PUTS			; prints the text
            LD     R1, MCCharacter	; load reg 1 with -48
            NOT    R1, R1		; NOT that value
            ADD    R1, R1, #1		; finish flipping to 48
            ADD    R0, R4, R1		; converts number to a printable character
            OUT				; prints it out
            BR     OrderingTime

FuncSpace1  LEA    R0, SpaceCharacter	; Load space character into reg 0
            PUTS			; Prints it out
            BR     loopID		; Jumps back to loop to get another character

OrderingTime
; Count the number of items to be sorted and store the value in R7

            AND    R2, R2, #0  		; Initialize R2 <- 0 (counter)
            LEA    R3, IDNumArray    	; Put file pointer into R3
COUNT       LDR    R0, R3, #0  		; Put next file item into R0
            BRZ    END_COUNT   		; Loop until file item is 0
            ADD    R3, R3, #1  		; Increment file pointer
            ADD    R2, R2, #1  		; Increment counter
            BRNZP  COUNT       		; Counter loop
END_COUNT   ADD    R4, R2, #0  		; Store total items in R4 (outer loop count)
            BRZ    SORTED      		; Empty file

; Do the bubble sort

OUTERLOOP   ADD     R4, R4, #-1 	; loop n - 1 times
            BRNZ    SORTED      	; Looping complete, exit
            ADD     R5, R4, #0  	; Initialize inner loop counter to outer
            LEA     R3, IDNumArray    	; Set file pointer to beginning of file
INNERLOOP   LDR     R0, R3, #0  	; Get item at file pointer
            LDR     R1, R3, #1  	; Get next item
            NOT     R2, R1      	; Begin 2's complement
            ADD     R2, R2, #1  	;        ... finish
            ADD     R2, R0, R2  	; swap = item - next item
            BRNZ    SWAPPED     	; Don't swap if in order (item <= next item)
            STR     R1, R3, #0  	; Perform ...
            STR     R0, R3, #1  	;         ... swap
SWAPPED     ADD     R3, R3, #1  	; Increment file pointer
            ADD     R5, R5, #-1 	; Decrement inner loop counter
            BRP     INNERLOOP   	; End of inner loop
            BRNZP   OUTERLOOP   	; End of outer loop
SORTED	    

	    LEA	    R0, ordered		; Load text
	    PUTS			; Print it out

	    AND    R2, R2, #9  		; Initialize R2 <- 9 (counter)
            LEA    R3, IDNumArray    	; Put file pointer into R3
PRINT2      LDR    R0, R3, #0  		; Put next file item into R0
            BRZ    END_PRINT2  		; Loop until file item is 0
	    OUT				; Print out the index N of the array
	    LEA    R0, SpaceCharacter	; Load space
	    PUTS			; Print it out
	    LDR    R0, R3, #0		; Load back the character to fix bug
            ADD    R3, R3, #1  		; Increment file pointer
            ADD    R2, R2, #-1  	; Decrincrement counter
            BRNZP  PRINT2      		; Counter loop
END_PRINT2
	    

HALT

IDNumArray 	.BLKW 9			; Allocate 9 spaces in the RAM for the ID characters entered
CheckForSpace	.fill -32		; Set a check value for a space
MCCharacter	.fill -48		; Set a neg conversion number

NumOfChar1	.stringz "\nThere are "
NumOfChar2 	.stringz " numbers in the list"
SpaceCharacter	.stringz " "
NewLine		.stringz "\nYou have entered: "
lowest		.stringz "\nThe lowest number was: "
highest		.stringz "\nThe highest number was: "
ordered		.stringz "\nThe ordered version is: "
.end