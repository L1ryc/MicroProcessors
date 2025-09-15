
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

    LEA DX, MSG
    MOV AH, 9
    INT 21H
    
    LEA DX, INPUT
    MOV AH, 0AH
    INT 21H
    
    CALL NEW_LINE
    CALL NEW_LINE 
    CALL NEW_LINE 
    CALL COUNT_VOWELS
    
    MOV AL, VOW_A
    ADD VOW_TOTAL, AL
    MOV AL, VOW_E    
    ADD VOW_TOTAL, AL
    MOV AL, VOW_I    
    ADD VOW_TOTAL, AL
    MOV AL, VOW_O    
    ADD VOW_TOTAL, AL
    MOV AL, VOW_U    
    ADD VOW_TOTAL, AL
        
    MOV BL, INPUT[1]
    MOV LEN, BL
    XOR BX, BX
    
    LEA SI, LEN
    MOV CX, 1
    CALL DISPLAY_2DIGIT
    
    LEA DX, MSG2
    MOV AH, 9
    INT 21H

    CALL NEW_LINE   
    CALL NEW_LINE
    LEA SI, VOW_A
    MOV CX, 1
    CALL DISPLAY_2DIGIT

    LEA DX, MSG3
    MOV AH, 9
    INT 21H
    CALL DISPLAY_APS
    
    CALL NEW_LINE 
    CALL NEW_LINE
    LEA SI, VOW_E
    MOV CX, 1
    CALL DISPLAY_2DIGIT

    LEA DX, MSG4
    MOV AH, 9
    INT 21H
    CALL DISPLAY_APS      
    
    CALL NEW_LINE 
    CALL NEW_LINE
    LEA SI, VOW_I
    MOV CX, 1
    CALL DISPLAY_2DIGIT

    LEA DX, MSG5
    MOV AH, 9
    INT 21H 
    CALL DISPLAY_APS     
    
    CALL NEW_LINE 
    CALL NEW_LINE
    LEA SI, VOW_O
    MOV CX, 1
    CALL DISPLAY_2DIGIT

    LEA DX, MSG6
    MOV AH, 9
    INT 21H 
    CALL DISPLAY_APS    
    
    CALL NEW_LINE 
    CALL NEW_LINE
    LEA SI, VOW_U
    MOV CX, 1
    CALL DISPLAY_2DIGIT

    LEA DX, MSG7
    MOV AH, 9
    INT 21H
    CALL DISPLAY_APS
    
    CALL NEW_LINE 
    CALL NEW_LINE 
    CALL NEW_LINE
    LEA SI, VOW_TOTAL
    MOV CX, 1
    CALL DISPLAY_2DIGIT

    LEA DX, MSG8
    MOV AH, 9
    INT 21H     
    
    CALL NEW_LINE 
    CALL NEW_LINE
    LEA SI, CON_TOTAL
    MOV CX, 1
    CALL DISPLAY_2DIGIT
    
    LEA DX, MSG9
    MOV AH, 9
    INT 21H
    
ret

COUNT_VOWELS:
    LEA SI, INPUT[2]
    XOR CX, CX
    MOV CL, INPUT[1]

    START:
        CMP [SI], ' '
        JE NOCOUNT
        CMP [SI], '0'
        JB CHECK_VOWELS
        CMP [SI], '9'
        JA CHECK_VOWELS

        INC SI
        JMP GO_LS

    CHECK_VOWELS:
        CMP [SI], 'A'
        JE COUNTA
        CMP [SI], 'E'
        JE COUNTE
        CMP [SI], 'I'
        JE COUNTI
        CMP [SI], 'O'
        JE COUNTO
        CMP [SI], 'U'
        JE COUNTU
        CMP [SI], 'a'
        JE COUNTA
        CMP [SI], 'e'
        JE COUNTE
        CMP [SI], 'i'
        JE COUNTI
        CMP [SI], 'o'
        JE COUNTO
        CMP [SI], 'u'
        JE COUNTU
        
        INC CON_TOTAL
        INC SI
        
        GO_LS:
            LOOP START
        
    RET

NOCOUNT:
    INC SI
    JMP GO_LS

COUNTA:
    INC VOW_A
    INC SI
    JMP GO_LS

COUNTE:
    INC VOW_E
    INC SI
    JMP GO_LS
 
COUNTI:
    INC VOW_I
    INC SI
    JMP GO_LS

COUNTO:
    INC VOW_O
    INC SI
    JMP GO_LS

COUNTU:
    INC VOW_U
    INC SI
    JMP GO_LS

DISPLAY_2DIGIT: 
    MOV AX, 00H 
    MOV AL, [SI]
    MOV BL, 10
    DIV BL
    
    MOV BH, AH      
    MOV DL, AL 
    ADD DL, '0'      
    CALL DISPLAY_CHAR
    
    MOV DL, BH 
    ADD DL, '0'      
    CALL DISPLAY_CHAR
    
    MOV DL, ' '
    MOV DH, 00001011B
    CALL DISPLAY_CHAR
    INC SI
    LOOP DISPLAY_2DIGIT
    RET

DISPLAY_APS:
    MOV DL, 39
    CALL DISPLAY_CHAR
    MOV DL, 's'
    CALL DISPLAY_CHAR
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


MSG DB 'Input string [max. 20]: $'
INPUT DB 20, ?, 20 DUP(?)
MSG2 DB '- chars inputted$'
MSG3 DB '- a$'
MSG4 DB '- e$'
MSG5 DB '- i$'
MSG6 DB '- o$'
MSG7 DB '- u$'
MSG8 DB '- total vowels$'
MSG9 DB '- total consonants$'
LEN DB ?
VOW_A DB 0
VOW_E DB 0
VOW_I DB 0
VOW_O DB 0
VOW_U DB 0
VOW_TOTAL DB 0
CON_TOTAL DB 0