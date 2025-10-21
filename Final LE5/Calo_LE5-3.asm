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
Set address for PORTB
	       MOV AL, NUMB0        ; Load value for displaying 0 into AL
	       OUT DX, AL           ; Output value to PORTB
	       
	       MOV CX, 0000H        ; Initialize CX register for counting

HERE:
	       MOV DX, PORTC        ; Set address for PORTC
	       IN AL, DX            ; Read input from PORTC into AL
	       CMP AL, 01H          ; Compare AL with 1 (button press signal)
	       JE LSDIG_A               ; Jump to LSDIG_A if equal
	       JMP HERE             ; Otherwise, loop back to HERE

LSDIG_A:
	       CALL DELAY           ; Call delay procedure
	       CALL DELAY           ; Add a second delay for proper timing
	       CMP CX, 0909H        ; Check if the count has reached 99
	       JE RESET             ; Reset to 00 if CX = 99

	       CMP CL, 09H          ; Check if lower byte of CX (CL) has reached 9
	       JE MSDIG_B               ; Jump to MSDIG_B if CL = 9

	       INC CL               ; Increment CL (units counter)

	       ; Update PORTA with the corresponding number based on CL
	       LSDIG_A1:
	       CMP CL, 01H          ; Check if CL = 1
	       JNE LSDIG_A2             ; Jump to LSDIG_A2 if not
	       MOV DX, PORTA        ; Set PORTA address
	       MOV AL, NUMB1        ; Load value for 1 into AL
	       OUT DX, AL           ; Output value to PORTA
	       JMP HERE

	       LSDIG_A2:
	       CMP CL, 02H          ; Check if CL = 2
	       JNE LSDIG_A3             ; Jump to LSDIG_A3 if not
	       MOV DX, PORTA
	       MOV AL, NUMB2
	       OUT DX, AL
	       JMP HERE
		 
	       LSDIG_A3:
	       CMP CL, 03H
	       JNE LSDIG_A4
	       MOV DX, PORTA
	       MOV AL, NUMB3
	       OUT DX, AL
	       JMP HERE

	       LSDIG_A4:
	       CMP CL, 04H
	       JNE LSDIG_A5
	       MOV DX, PORTA
	       MOV AL, NUMB4
	       OUT DX, AL
	       JMP HERE

	       LSDIG_A5:
	       CMP CL, 05H
	       JNE LSDIG_A6
	       MOV DX, PORTA
	       MOV AL, NUMB5
	       OUT DX, AL
	       JMP HERE

	       LSDIG_A6:
	       CMP CL, 06H
	       JNE LSDIG_A7
	       MOV DX, PORTA
	       MOV AL, NUMB6
	       OUT DX, AL
	       JMP HERE

	       LSDIG_A7:
	       CMP CL, 07H
	       JNE LSDIG_A8
	       MOV DX, PORTA
	       MOV AL, NUMB7
	       OUT DX, AL
	       JMP HERE

	       LSDIG_A8:
	       CMP CL, 08H
	       JNE LSDIG_A9
	       MOV DX, PORTA
	       MOV AL, NUMB8
	       OUT DX, AL
	       JMP HERE

	       LSDIG_A9:
	       CMP CL, 09H          ; Check if CL = 9
	       MOV DX, PORTA
	       MOV AL, NUMB9
	       OUT DX, AL
	       JMP HERE

MSDIG_B:
	       MOV CL, 00H          ; Reset CL (units counter) to 0
	       MOV DX, PORTA
	       MOV AL, NUMB0        ; Display 0 on PORTA
	       OUT DX, AL
	       
	       INC CH               ; Increment CH (tens counter)

	       ; Update PORTB with the corresponding number based on CH
	       HLSDIG_A1:
	       CMP CH, 01H
	       JNE HLSDIG_A2
	       MOV DX, PORTB
	       MOV AL, NUMB1
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A2:
	       CMP CH, 02H
	       JNE HLSDIG_A3
	       MOV DX, PORTB
	       MOV AL, NUMB2
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A3:
	       CMP CH, 03H
	       JNE HLSDIG_A4
	       MOV DX, PORTB
	       MOV AL, NUMB3
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A4:
	       CMP CH, 04H
	       JNE HLSDIG_A5
	       MOV DX, PORTB
	       MOV AL, NUMB4
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A5:
	       CMP CH, 05H
	       JNE HLSDIG_A6
	       MOV DX, PORTB
	       MOV AL, NUMB5
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A6:
	       CMP CH, 06H
	       JNE HLSDIG_A7
	       MOV DX, PORTB
	       MOV AL, NUMB6
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A7:
	       CMP CH, 07H
	       JNE HLSDIG_A8
	       MOV DX, PORTB
	       MOV AL, NUMB7
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A8:
	       CMP CH, 08H
	       JNE HLSDIG_A9
	       MOV DX, PORTB
	       MOV AL, NUMB8
	       OUT DX, AL
	       JMP HERE

	       HLSDIG_A9:
	       CMP CH, 09H          ; Check if CH = 9
	       MOV DX, PORTB
	       MOV AL, NUMB9
	       OUT DX, AL
	       JMP HERE

DELAY PROC                    ; Delay subroutine to slow down the counting
		  MOV BX, 1BE4H   ; BX controls the delay duration
	       L1:
		  DEC BX          ; Decrement BX until it reaches 0
		  NOP             ; No operation (waste one clock cycle)
		  JNZ L1          ; Jump to L1 if BX is not zero
		  RET             ; Return from subroutine
DELAY ENDP

CODE ENDS  
END