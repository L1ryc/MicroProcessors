
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.DATA

DECIMAL DB 'Enter Decimal :$'
BINARY DB 0DH, 0AH, 'Binary: $'
HEX DB 0DH, 0AH, 'Hexadecimal: $'
OCTAL DB 0DH, 0AH, 'Octal: $'

D_DATA DB 10 DUP('$')   ;DECIMAL
B_DATA DB 10 DUP('$')   ;BINARY
H_DATA DB 10 DUP('$')   ;HEX
O_DATA DB 10 DUP('$')   ;OCTAL
     
.code

START:
    MOV AX, @data
    MOV DS, AX
    
    MOV DX, OFFSET DECIMAL
    MOV AH, 9H
    INT 21H
    
    MOV SI, OFFSET D_DATA
    MOV CX, 0
    
ENTER:
    MOV AH, 1H
    INT 21H
    INC CX
    
    MOV [SI], AL
    INC SI
    
    CMP AL, 0DH
    MOV DL, D_DATA
    MOV AX, 0
    JE  BIN1
    CMP CX, 2
    JNE ENTER
    MOV AL, 10
    MOV AH, 0
    MOV DL, D_DATA
    SUB DL, 30H
    MUL DL
    MOV DL, D_DATA + 1

BIN1:
    SUB DL, 20H
    ADD AL, DL
    PUSH AX
    MOV BX, 2
    MOV CX, 0
    
BINSOLV:
    MOV DX, 0
    DIV BX
    ADD DX, 48
    PUSH DX
    INC CX
    CMP AX, 0
    JNZ BINSOLV
    
    MOV SI, OFFSET B_DATA
    
BININPUT:
    POP AX
    MOV [SI], AL
    INC SI
    DEC CX
    
    JNZ BININPUT
    
    POP AX
    PUSH AX
    MOV BX, 8
    MOV CX, 0

HEX1:
    SUB DL, 20H
    ADD AL, DL
    PUSH AX
    MOV BX, 16
    MOV CX, 0
        
HEXSOLV:
    MOV DX, 0
    DIV BX
    ADD DX, 48
    PUSH DX
    INC CX
    CMP AX, 0
    JNZ HEXSOLV
    
    MOV SI, OFFSET H_DATA
    
HEXINPUT:
    POP AX
    MOV [SI], AL
    INC SI
    DEC CX
    
    JNZ HEXINPUT
    
    POP AX
    PUSH AX
    MOV BX, 8
    MOV CX, 0
    
OCT1:
    SUB DL, 20H
    ADD AL, DL
    PUSH AX
    MOV BX, 8
    MOV CX, 0    
    
OCTSOLV:
    MOV DX, 0
    DIV BX
    ADD DX, 48
    PUSH DX
    INC CX
    CMP AX, 0
    JNZ OCTSOLV
    
    MOV SI, OFFSET O_DATA
    
OCTINPUT:
    POP AX
    MOV [SI], AL
    INC SI
    DEC CX
    JNZ OCTINPUT
    
END:
    MOV AH, 9
    MOV DX, OFFSET BINARY
    INT 21H
    MOV AH, 9
    MOV DX, OFFSET B_DATA
    INT 21H 
    
    MOV AH, 9
    MOV DX, OFFSET HEX
    INT 21H
    MOV AH, 9
    MOV DX, OFFSET H_DATA
    INT 21H 
    
    MOV AH, 9
    MOV DX, OFFSET OCTAL
    INT 21H
    MOV AH, 9
    MOV DX, OFFSET O_DATA
    INT 21H
                    

ret

