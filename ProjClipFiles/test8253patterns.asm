DATA SEGMENT
   PORTA       EQU 0F0H       ; Switch input
   PORTB       EQU 0F2H       ; 7-seg output
   PORTC       EQU 0F4H
   COM_REG     EQU 0F6H
   COM_REGWORD EQU 99H        ; A=input, B=output, C=input
   PIT_CH0     EQU 0F8H
   PIT_CTRL    EQU 0FEH

   CUR_DIGIT   DB 00H         ; current digit (0–9)

   ; 7-seg codes for 0–9 (common cathode, abcdefg order)
   SEG_TAB DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
DATA ENDS

CODE SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA
    ORG 0000H

START:
    MOV AX, DATA
    MOV DS, AX

    ; init 8255
    MOV DX, COM_REG
    MOV AL, COM_REGWORD
    OUT DX, AL

    CALL INIT_8253

MAIN_LOOP:
    ; read switches
    MOV DX, PORTA
    IN  AL, DX
    AND AL, 07H           ; consider only S1..S3 (bits 0..2)

    CMP AL, 01H
    JE  COUNT_UP_MODE
    CMP AL, 02H
    JE  COUNT_DOWN_MODE
    CMP AL, 04H
    JE  PAUSE_MODE
    CMP AL, 03H           ; S1+S2 -> pause
    JE  PAUSE_MODE

    ; any other config ? blank display
    MOV DX, PORTB
    MOV AL, 00H           ; all segments OFF (common cathode)
    OUT DX, AL
    JMP MAIN_LOOP

;-------------------------
; Continuous COUNT UP while S1 stays active
COUNT_UP_MODE:
CU_LOOP:
    ; increment digit with wrap
    MOV AL, CUR_DIGIT
    INC AL
    CMP AL, 0AH
    JB  CU_SET
    MOV AL, 00H
CU_SET:
    MOV CUR_DIGIT, AL
    CALL DISPLAY_DIGIT
    CALL DELAY_500MS

    ; check if still S1 (01H) or S1+S2 (03H -> pause)
    MOV DX, PORTA
    IN  AL, DX
    AND AL, 07H
    CMP AL, 01H
    JE  CU_LOOP
    CMP AL, 03H
    JE  PAUSE_MODE
    JMP MAIN_LOOP

;-------------------------
; Continuous COUNT DOWN while S2 stays active
COUNT_DOWN_MODE:
CD_LOOP:
    MOV AL, CUR_DIGIT
    DEC AL
    JNS CD_SET
    MOV AL, 09H
CD_SET:
    MOV CUR_DIGIT, AL
    CALL DISPLAY_DIGIT
    CALL DELAY_500MS

    ; check if still S2 (02H) or S1+S2 (03H -> pause)
    MOV DX, PORTA
    IN  AL, DX
    AND AL, 07H
    CMP AL, 02H
    JE  CD_LOOP
    CMP AL, 03H
    JE  PAUSE_MODE
    JMP MAIN_LOOP

;-------------------------
PAUSE_MODE:
    ; hold current value, keep updating display
    CALL DISPLAY_DIGIT
    CALL DELAY_500MS
    ; stay paused while S3 (04H) or S1+S2 (03H) remain active
    MOV DX, PORTA
    IN  AL, DX
    AND AL, 07H
    CMP AL, 04H
    JE  PAUSE_MODE
    CMP AL, 03H
    JE  PAUSE_MODE
    JMP MAIN_LOOP

;-------------------------
; Subroutine: DISPLAY_DIGIT
; Input: AL = digit (0–9)
DISPLAY_DIGIT PROC
    ; lookup 7-seg code: AL = SEG_TAB[AL]
    MOV BX, OFFSET SEG_TAB
    XLAT
    MOV DX, PORTB
    OUT DX, AL
    RET
DISPLAY_DIGIT ENDP

;==============================
; Initialize 8253 (Channel 0)
;==============================
INIT_8253:
    MOV DX, PIT_CTRL
    MOV AL, 00110100B   ; Channel 0, LSB+MSB, Mode 0
    OUT DX, AL
    RET

;==============================
; Hardware delay ~1ms using PIT
; Note: working code used count=1 and JNZ polling.
; Keep the same OUT0-poll sense for consistency.
;==============================
DELAY_1MS:
    MOV DX, PIT_CH0
    MOV AL, 01H         ; LSB (count = 1) to match your working setup
    OUT DX, AL
    MOV AL, 00H         ; MSB
    OUT DX, AL
WAIT_PIT:
    MOV DX, PORTC
    IN  AL, DX
    TEST AL, 00000001b  ; PC0 reflects PIT OUT0
    JNZ  WAIT_PIT       ; wait until terminal count (same sense as your working code)
    RET

;==============================
; Software delay ~500ms (visible)
;==============================
DELAY_500MS PROC
    MOV CX, 10
DLY_LOOP:
    CALL DELAY_1MS
    LOOP DLY_LOOP
    RET
DELAY_500MS ENDP

CODE ENDS
END START
