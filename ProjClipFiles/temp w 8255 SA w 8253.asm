;====================================================================
; Main.asm (fixed)
; Created: Wed Oct xx 2025
; Processor: 8086
; Compiler: MASM32
;====================================================================


DATA SEGMENT
   PORTA EQU 0F0H
   PORTB EQU 0F2H
   PORTC EQU 0F4H
   COM_REG EQU 0F6H
   COM_REGWORD EQU 08BH    ; 
   PIT_CH0  EQU 0F8H       ; 8253 Channel 0
   PIT_CTRL EQU 0FEH       ; 8253 Control Word Register
DATA ENDS

CODE SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA
    MOV AX, DATA
    MOV DS, AX
    ORG 0000H
    ; clear general registers (optional)
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
START:
    ; init 8255 (user's control word)
    MOV DX, COM_REG
    MOV AL, COM_REGWORD
    OUT DX, AL

    CALL INIT_8253
    
MAIN:
GET_INPUT:
    MOV DX, PORTB
    IN AL, DX
    
    CMP AL, 00000001B	;01H
    JE TOGGLE
    CMP AL, 00000010B	;02H
    JE CYCLONE
    CMP AL, 00000100B	;04H
    JE SHAKE
    
    ; if switch not = 1,2,4 , portA remains off
    MOV DX, PORTA
    MOV AL, 00H
    OUT DX, AL
	; get input again to see if switch setting changed
    CALL DELAY_1MS

JMP MAIN
    
;=======================
; LED pattern procedures 
;=======================

TOGGLE:
    MOV DX, PORTA
    MOV AL, 0FFH	; ON ALL LEDS
    OUT DX, AL
    CALL DELAY_1MS
    JMP GET_INPUT

CYCLONE:
    ;--- Step 1 ---
    MOV DX, PORTA
    MOV AL, 00001001B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_CYCLONE

    ;--- Step 2 ---
    MOV DX, PORTA
    MOV AL, 00000110B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_CYCLONE

    ;--- Step 3 ---
    MOV DX, PORTA
    MOV AL, 01100000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_CYCLONE

    ;--- Step 4 ---
    MOV DX, PORTA
    MOV AL, 10010000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_CYCLONE

    ;--- Step 5 ---
    MOV DX, PORTA
    MOV AL, 00001001B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_CYCLONE

  
    JMP CYCLONE

SHAKE:
    MOV DX, PORTA
    MOV AL, 00000011B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    MOV DX, PORTA
    MOV AL, 00000110B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    MOV DX, PORTA
    MOV AL, 00001100B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 10001000B	;26
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    ;;;
    MOV DX, PORTA
    MOV AL, 11000000B	;36
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 01100000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 00110000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    ;;;
    MOV DX, PORTA
    MOV AL, 00010001B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 00000011B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    JMP SHAKE         ; repeat SHAKE until switch changes

CHECK_CYCLONE:
    MOV DX, PORTB
    IN  AL, DX
    CMP AL, 02H
    JE  CC_RET
    JMP GET_INPUT
CC_RET:
    RET

CHECK_SHAKE:
    MOV DX, PORTB
    IN  AL, DX
    CMP AL, 04H
    JE  CS_RET
    JMP GET_INPUT
CS_RET:
    RET

;==============================
; Initialize 8253 (Channel 0)
;==============================
INIT_8253:
    MOV DX, PIT_CTRL
    MOV AL, 00110100B   ; Channel 0, LSB+MSB, Mode 0, Binary (0x30)
    OUT DX, AL
    RET

;==============================
; Hardware ~1ms delay using PIT
; Assumes PIT input clock = 1.193182 MHz (standard)
; Count = 1193 (0x04A9) -> ˜ 1.000 ms
;==============================
DELAY_1MS:
    MOV DX, PIT_CH0
    MOV AL, 01H        ; LSB = 1
    OUT DX, AL
    MOV AL, 00H         ; MSB = 00
    OUT DX, AL

WAIT_PIT:
    MOV DX, PORTC
    IN  AL, DX          ; Read PORTC (PIT output wired to PC0)
    TEST AL, 00000001b  ; look at PC0 only (PIT OUT0)
    JNZ  WAIT_PIT        ; loop while PC0 == 0 ; exit when PC0 = 1 (terminal count)
    RET

CODE ENDS
END START
