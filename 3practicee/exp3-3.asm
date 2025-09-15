
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
; Cyril John Christian A. Calo
org 100h

ORG 100H 
MOV DX, OFFSET BUFFER  
MOV AH, 0AH 
INT 21H  
CALL PRINT 
RET 
PRINT: 
XOR BX, BX 
MOV BL, BUFFER[1]  
MOV BUFFER[BX+2], '$' 
MOV DX, OFFSET BUFFER + 2  
MOV AH, 9 
INT 21H  
RET 
BUFFER DB 10, ?, 10 DUP(' ') 

 




