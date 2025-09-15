
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA
DISPLAY DB 'Password: $'
TRUE DB 0DH, 0AH, 'Access Granted!$'
FALSE DB 0DH, 0AH, 'Access Denied!$'
PASS DB 'nCrGu@rd!@ns'

DATA DB 255 DUP('$')
.CODE

START:
    MOV AX, @DATA
    MOV DS, AX
    MOV AH, 9
    MOV DX, OFFSET DISPLAY
    INT 21H
    MOV SI, OFFSET DATA
    
ENTER:
    MOV AH, 7H
    INT 21H
    CMP AL, 0DH
    JE VERIFY
    CMP AL, 0AH
    JE VERIFY
    MOV [SI], AL
    INC SI
    MOV AH, 2H
    MOV DL, '*'
    INT 21H
    JMP ENTER
    
VERIFY:
    MOV SI, OFFSET PASS
    MOV DI, OFFSET DATA
    cld
    MOV CX,11
    REPE CMPSB
    JE GRANTED
    JNE DENIED
    
GRANTED:
    MOV DX, OFFSET TRUE
    MOV AH, 9H
    INT 21H
    ret
    
DENIED:
    MOV DX, OFFSET FALSE 
    MOV AH, 9H
    INT 21H
    ret               
ret
