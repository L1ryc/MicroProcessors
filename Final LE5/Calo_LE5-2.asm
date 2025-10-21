DATA SEGMENT
    ; I/O port addresses
    LED_PORT   EQU 0F0H
    SEG_PORT   EQU 0F2H
    CTRL_PORT  EQU 0F4H

    ; 7-segment codes for digits 0–9
    DIGITS DB 00111111B, 00000110B, 01011011B, 01001111B
           DB 01100110B, 01101101B, 01111101B, 00000111B
           DB 01111111B, 01101111B
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    ORG 0000H

START:
    ; initialize DS
    MOV AX, DATA
    MOV DS, AX

    ; clear outputs
    MOV DX, LED_PORT
    XOR AL, AL
    OUT DX, AL

    MOV DX, SEG_PORT
    XOR AL, AL
    OUT DX, AL

MAIN_LOOP:
    MOV DX, CTRL_PORT
    IN  AL, DX

    CMP AL, 01H
    JE  LED_MODE

    CMP AL, 02H
    JE  SEG_MODE

    JMP MAIN_LOOP

; --- LED shifting mode ---
LED_MODE:
    MOV CX, 8
    MOV DX, LED_PORT
    MOV AL, 10000000B
    OUT DX, AL
    CALL PAUSE

LED_SHIFT:
    SHR AL, 1
    OUT DX, AL
    CALL PAUSE
    LOOP LED_SHIFT
    JMP MAIN_LOOP

; --- 7-segment counting mode ---
SEG_MODE:
    MOV SI, OFFSET DIGITS
    MOV CX, 10

NEXT_DIGIT:
    MOV DX, SEG_PORT
    MOV AL, [SI]
    OUT DX, AL
    CALL PAUSE
    INC SI
    LOOP NEXT_DIGIT

    ; clear display
    XOR AL, AL
    OUT DX, AL
    JMP MAIN_LOOP

; --- delay routine (renamed to avoid mnemonic conflict) ---
PAUSE PROC
    MOV BX, 9FFFH
DLY_LOOP:
    DEC BX
    NOP
    JNZ DLY_LOOP
    RET
PAUSE ENDP

CODE ENDS
END START
      MOV AL, 01101101B
        OUT DX, AL
        CALL DELAY

        ; Display 6
        MOV AL, 01111101B
        OUT DX, AL
        CALL DELAY

        ; Display 7
        MOV AL, 00000111B 
        OUT DX, AL
        CALL DELAY

        ; Display 8
        MOV AL, 01111111B
        OUT DX, AL
        CALL DELAY

        ; Display 9
        MOV AL, 01101111B 
        OUT DX, AL
        CALL DELAY

        MOV AL, 00000000B
        OUT DX, AL

        JMP HERE          

DELAY PROC
        MOV BX, 9FFFH    
   L1:     
        DEC BX          
        NOP               
        JNZ L1            
        RET           
DELAY ENDP

CODE ENDS
END
