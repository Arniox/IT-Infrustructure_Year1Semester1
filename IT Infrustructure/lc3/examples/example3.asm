.ORIG x3000

LEA R0,MESG1 ;load the address of the message string
TRAP x22 ;"PUTS" outputs a string

LEA R0,MESG2 ;load the address of the message string
TRAP x22 ;"PUTS" outputs a string

LEA R0,MESG3 ;load the address of the message string
TRAP x22 ;"PUTS" outputs a string

HALT
MESG1 .STRINGZ "hello\n"
MESG2 .STRINGZ "Welcome to computer science 210\n"
MESG3 .STRINGZ "Have a good day!\n"
.END