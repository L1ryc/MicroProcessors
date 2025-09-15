
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

    LEA DX, MSG1
    MOV AH, 9
    INT 21H
    
    CALL GET_INPUT    
    CALL NEW_LINE
    CALL NEW_LINE
    
    CALL INIT
    MOV AL, NUM1
    CALL CHECK_AND_CONVERT    
    CALL TO_BINARY
    
    CALL INIT
    MOV AL, ' '
    CALL DISPLAY_CHAR
    
    CALL INIT 
    MOV AL, NUM2
    CALL CHECK_AND_CONVERT    
    CALL TO_BINARY 
       
    LEA DX, MSG2
    MOV AH, 9
    INT 21H
    
    CALL NEW_LINE
    CALL NEW_LINE
    CALL INIT
    CALL TO_OCTAL
    
    CALL INIT
    MOV DL, TEMP[0]
    ADD DL, '0'
    CALL DISPLAY_CHAR
    MOV DL, TEMP[1]
    ADD DL, '0'
    CALL DISPLAY_CHAR
    MOV DL, TEMP[2]
    ADD DL, '0'
    CALL DISPLAY_CHAR
    
    LEA DX, MSG3
    MOV AH, 9
    INT 21H

    JMP EXIT
ret

GET_INPUT:    
    MOV AH, 1
    INT 21H
    MOV NUM1, AL
    INT 21H
    MOV NUM2, AL

    RET

CHECK_AND_CONVERT:
    CMP AL, 'A'
    JL NOT_HEX
    CMP AL, 'F'
    JG NOT_HEX
    SUB AL, 37h
    
    RET

NOT_HEX:
    SUB AL, '0'
    RET

TO_BINARY:
    MOV BX, 2
    
    DIVIDE_B:
        DIV BL
        MOV DL, AH
        XOR AH, AH
        PUSH DX
        INC CX
        CMP CX, 4
        JNE DIVIDE_B
    
    XOR CX, CX
        
    DISPLAY_B:
        POP DX
        ADD DX, '0'
        CALL DISPLAY_CHAR
        INC CX
        CMP CX, 4
        JNE DISPLAY_B
        
    RET                

TO_OCTAL:
    MOV AL, NUM2
    CALL CHECK_AND_CONVERT
    MOV BX, 2
    
    DIVIDE_O2:
        DIV BL
        MOV DL, AH
        XOR AH, AH
        PUSH DX
        INC CX
        CMP CX, 4
        JNE DIVIDE_O2
        
    CALL INIT
    
    MOV AL, NUM1
    CALL CHECK_AND_CONVERT
    MOV BX, 2
    
    DIVIDE_O1:
        DIV BL
        MOV DL, AH
        XOR AH, AH
        PUSH DX
        INC CX
        CMP CX, 4
        JNE DIVIDE_O1
        
    CALL INIT
    
    POP AX
    MOV BL, 2
    MUL BL
    MOV BH, AL
    POP AX
    ADD AL, BH
    MOV TEMP[0], AL
    
    POP AX
    MOV BL, 4
    MUL BL
    MOV BH, AL
    POP AX
    MOV BL, 2
    MUL BL
    ADD BH, AL
    POP AX
    ADD AL, BH
    MOV TEMP[1], AL
    
    POP AX
    MOV BL, 4
    MUL BL
    MOV BH, AL
    POP AX
    MOV BL, 2
    MUL BL
    ADD BH, AL
    POP AX
    ADD AL, BH
    MOV TEMP[2], AL
    
    RET

INIT:
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    RET   

DISPLAY_CHAR:
    MOV AH, 2
    INT 21H
    RET

NEW_LINE:
    MOV DX, 13
    MOV AH, 2
    INT 21H
    MOV DX, 10
    MOV AH, 2
    INT 21H
    RET 
    
EXIT:
    MOV AH, 4CH
    INT 21H    

MSG1 DB 'Input hexadecimal value: $' 
MSG2 DB 'b in binary$'
MSG3 DB 'o in octal$'
NUM1 DB ?
NUM2 DB ?
TEMP DB ?, ?, ?