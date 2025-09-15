
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA

CELSIUS DB 'Celsius: $'
FAHRENHEIT DB 0DH, 0AH, 'Celsius to Fahreinheit:$'
TEMP DB ?
ARR DB 4 DUP('$')

.CODE

START:
    MOV AX, @DATA
    MOV DS, AX 
    
    MOV AH, 9
    MOV DX, OFFSET CELSIUS
    INT 21H  
    
    MOV AH, 1
    INT 21H
    JMP COMPUTE
    
COMPUTE:
    SUB AL, 30H
    MOV AH, 0
    MOV BL, 10
    MUL BL
    MOV BL, AL
    MOV AH, 1
    INT 21H
    
    SUB AL, 30H
    MOV AH, 0
    ADD AL, BL
    MOV TEMP, AL
    MOV DL, 9
    MUL DL
    MOV BL, 5
    DIV BL
    MOV AH, 0
    ADD AL, 32
    
    MOV SI, OFFSET ARR
    CALL CONVERT
    
    MOV AH, 9
    MOV DX, OFFSET FAHRENHEIT
    INT 21H
    
    MOV AH, 9
    MOV DX, OFFSET ARR
    INT 21H
    
    MOV AH, 4CH
    INT 21H
    
CONVERT:
    MOV CX, 0
    MOV BX, 10
    
L1:
    MOV DX,0
    DIV BX
    ADD DL,30H
    PUSH DX
    INC CX
    CMP AX,9
    JG L1
        
    ADD AL,30H
    MOV [SI],AL
    
L2:
    POP AX
    INC SI
    MOV [SI],AL
    LOOP L2               

ret