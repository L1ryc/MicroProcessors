DATA SEGMENT
    ; I/O port addresses
    P_A     EQU 0F0H
    P_B     EQU 0F2H
    P_C     EQU 0F4H
    CMDREG  EQU 0F6H

    ; 7-seg codes for digits 0–9
    DIGTAB  DB 00111111B, 00000110B, 01011011B, 01001111B
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

    ; configure command register
    MOV DX, CMDREG
    MOV AL, 089H
    OUT DX, AL

RESET_CNT:
    ; clear both digits to 0
    MOV DX, P_A
    MOV AL, DIGTAB[0]
    OUT DX, AL

    MOV DX, P_B
    MOV AL, DIGTAB[0]
    OUT DX, AL

    XOR CX, CX          ; CX = 0000h (CH = tens, CL = units)

WAIT_KEY:
    MOV DX, P_C
    IN  AL, DX
    CMP AL, 01H
    JNE WAIT_KEY        ; wait until button pressed

    CALL PAUSE
    CALL PAUSE

    CMP CX, 0909H       ; reached 99?
    JE  RESET_CNT

    CMP CL, 09
    JNE INC_UNITS
    JMP INC_TENS

; --- units digit update ---
INC_UNITS:
    INC CL
    MOV BL, CL
    MOV DX, P_A
    MOV AL, DIGTAB[BX]
    OUT DX, AL
    JMP WAIT_KEY

; --- tens digit update ---
INC_TENS:
    XOR CL, CL          ; reset units
    MOV DX, P_A
    MOV AL, DIGTAB[0]
    OUT DX, AL

    INC CH
    MOV BL, CH
    MOV DX, P_B
    MOV AL, DIGTAB[BX]
    OUT DX, AL
    JMP WAIT_KEY

; --- delay routine ---
PAUSE PROC
    MOV BX, 1BE4H
DLY_LOOP:
    DEC BX
    NOP
    JNZ DLY_LOOP
    RET
PAUSE ENDP

CODE ENDS
END START
