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
    JE ZIGZAG
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

ZIGZAG:
    ;--- Step 1 ---
    MOV DX, PORTA
    MOV AL, 00000001B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 2 ---
    MOV DX, PORTA
    MOV AL, 00100000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 3 ---
    MOV DX, PORTA
    MOV AL, 00000100B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 4 ---
    MOV DX, PORTA
    MOV AL, 10000000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 5 ---
    MOV DX, PORTA
    MOV AL, 00001000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 6 ---
    MOV DX, PORTA
    MOV AL, 01000000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 7 ---
    MOV DX, PORTA
    MOV AL, 00000010B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    ;--- Step 8 ---
    MOV DX, PORTA
    MOV AL, 00010000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_ZIGZAG

    JMP ZIGZAG

SHAKE:
    MOV DX, PORTA
    MOV AL, 00010001B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    MOV DX, PORTA
    MOV AL, 00010010B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    MOV DX, PORTA
    MOV AL, 00110000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 00100010B	;26
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    ;;;
    MOV DX, PORTA
    MOV AL, 00100100B	;36
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 01100000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 01000100B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    ;;;
    MOV DX, PORTA
    MOV AL, 01001000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 11000000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

      
    MOV DX, PORTA
    MOV AL, 10001000B
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    
    ;REVERSE
    MOV DX, PORTA
    MOV AL, 10000100B	;38
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 11000000B	;78
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 01000100B	;37
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    
    ;;
    MOV DX, PORTA
    MOV AL, 01000010B	;72
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 01100000B	;67
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE

    MOV DX, PORTA
    MOV AL, 00100010B	;62
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    
    ;;
    MOV DX, PORTA
    MOV AL, 00100001B	;16
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 00110000B	;56
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    MOV DX, PORTA
    MOV AL, 00010001B	;51
    OUT DX, AL
    CALL DELAY_1MS
    
    CALL CHECK_SHAKE


    JMP SHAKE         ; repeat zigzag until switch changes

CHECK_ZIGZAG:
    MOV DX, PORTB
    IN  AL, DX
    CMP AL, 02H
    JE  CZ_RET
    JMP GET_INPUT
CZ_RET:
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
