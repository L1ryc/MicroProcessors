
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
    
    LEA DX, MSG_PROMPT
    MOV AH, 9
    INT 21H
    
    CALL GET_INPUT
    CALL CLEAR_SCREEN
    
    XOR CX, CX
    MOV DH, 24 
    
    DISPLAY:
        MOV AL, 1
        MOV BL, 07H
        MOV CL, INPUT[1]
        
        MOV BH, INPUT[[1]
        CMP BH, 5
        JE LEN5
        CMP BH, 7
        JE LEN7
               
        MOV BH, 0  
        MOV DL, 41
        SUB DL, INPUT[1]
        
        START:
            LEA BP, INPUT+2
            MOV AH, 13H
            INT 10H
            
            CMP DH, 0
            JE AT_TOP
            
            LEA BP, BLANK
            MOV AH, 13H
            INT 10H
            
            DEC DH
            JMP DISPLAY
           
ret

AT_TOP PROC
    MOV AX, 0B800H
    MOV ES, AX

    XOR BX, BX
    XOR DX, DX
    
    MOV BL, INPUT[1]
    CMP BX, 5
    JE MOVE_2OUTWARDS
    CMP BX, 7
    JE MOVE_3OUTWARDS
    
    MOV CX, 38    
    MOV DI, 76
    MOV SI, 80
    
    MOV DL, INPUT[4]
    MOV DH, 00H
    MOV ES:[SI], DX
    ADD SI, 2
    MOV DL, INPUT[4]
    MOV DH, 07H
    MOV ES:[SI], DX

    CALL MOVE_1OUTWARDS
        
    CALL MOVE_DOWN 
    CALL MOVE_DOWN
    CALL MOVE_DOWN
    CALL MOVE_DOWN
    CALL MOVE_DOWN 
    CALL MOVE_DOWN
    CALL MOVE_DOWN
    CALL MOVE_DOWN

    MOV CX, 38
    MOV DI, 3840
    MOV SI, 3998

    MOV DL, INPUT[4]
    MOV DH, 00H
    MOV ES:[SI], DX
    SUB SI, 2
    MOV DL, INPUT[4]
    MOV DH, 07H
    MOV ES:[SI], DX    
    
    CALL MOVE_1INWARDS
    
    CALL MOVE_UP
    CALL MOVE_UP
    CALL MOVE_UP
    CALL MOVE_UP

    JMP EXIT
   
AT_TOP ENDP

LEN5:  
    MOV BH, 0  
    MOV DL, 43
    SUB DL, INPUT[1]    
    JMP START

LEN7:  
    MOV BH, 0  
    MOV DL, 44
    SUB DL, INPUT[1]    
    JMP START

MOVE_1OUTWARDS:
    CMP CX, 0
    JE DONE1
    
    MOV DL, INPUT[2]
    MOV DH, 00H
    MOV ES:[DI], DX
    SUB DI, 2
    MOV DL, INPUT[2]
    MOV DH, 07H
    MOV ES:[DI], DX
    
    MOV DL, INPUT[4]
    MOV DH, 00H
    MOV ES:[SI], DX
    ADD SI, 2
    MOV DL, INPUT[4]
    MOV DH, 07H
    MOV ES:[SI], DX
    LOOP MOVE_1OUTWARDS
    
    DONE1:
        RET

MOVE_2OUTWARDS:
    MOV CX, 37 
    MOV DI, 76
    MOV SI, 78
    PUSH DI
    PUSH SI
    ; 72 74 76 78 80

    MOV DL, INPUT[2]
    MOV DH, 00H
    MOV ES:[DI], DX
    MOV BL, INPUT[3]
    MOV BH, 00H
    MOV ES:[SI], BX
    
    SUB DI, 2
    MOV DL, INPUT[2]
    MOV DH, 07H
    MOV ES:[DI], DX    
    SUB SI, 2
    MOV BL, INPUT[3]
    MOV BH, 07H
    MOV ES:[SI], BX
    
    PUSH DI
    PUSH SI

    MOVE_2:    
        CMP CX, 0
        JE DONE2
        
        POP SI
        POP DI
        
        MOV DL, INPUT[2]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[3]
        MOV BH, 00H
        MOV ES:[SI], BX
        
        SUB DI, 2
        MOV DL, INPUT[2]
        MOV DH, 07H
        MOV ES:[DI], DX    
        SUB SI, 2
        MOV BL, INPUT[3]
        MOV BH, 07H
        MOV ES:[SI], BX
        
        PUSH DI
        PUSH SI
        
        MOV DI, LEN5_L4_HOLDER1[0]
        MOV SI, LEN5_L5_HOLDER1[0]

        MOV DL, INPUT[5]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[6]
        MOV BH, 00H
        MOV ES:[SI], BX
        
        ADD DI, 2
        MOV DL, INPUT[5]
        MOV DH, 07H
        MOV ES:[DI], DX    
        ADD SI, 2
        MOV BL, INPUT[6]
        MOV BH, 07H
        MOV ES:[SI], BX
        
        MOV LEN5_L4_HOLDER1[0], DI
        MOV LEN5_L5_HOLDER1[0], SI        
        LOOP MOVE_2
    
    DONE2:
        CALL MOVE_DOWN 
        CALL MOVE_DOWN
        CALL MOVE_DOWN
        CALL MOVE_DOWN
        CALL MOVE_DOWN 
        CALL MOVE_DOWN
        CALL MOVE_DOWN
        CALL MOVE_DOWN 
       
        JMP MOVE_2INWARDS  

MOVE_3OUTWARDS:
    MOV CX, 36 
    MOV DI, 74
    MOV SI, 76
    MOV BP, 78
    ; 72 76 78 80 82 84 86

    MOV DL, INPUT[2]
    MOV DH, 00H
    MOV ES:[DI], DX
    MOV BL, INPUT[3]
    MOV BH, 00H
    MOV ES:[SI], BX
    MOV AL, INPUT[4]
    MOV AH, 00H
    MOV ES:[BP], AX
    
    SUB DI, 2
    MOV DL, INPUT[2]
    MOV DH, 07H
    MOV ES:[DI], DX    
    SUB SI, 2
    MOV BL, INPUT[3]
    MOV BH, 07H
    MOV ES:[SI], BX
    SUB BP, 2
    MOV BL, INPUT[4]
    MOV BH, 07H
    MOV ES:[BP], BX
    
    PUSH DI
    PUSH SI
    PUSH BP

    MOVE_3:
        ;WL_7 DW 76, 78, 80, 82, 84, 86, 88    
        CMP CX, 0
        JE DONE4
        
        POP BP
        POP SI
        POP DI
        
        MOV DL, INPUT[2]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[3]
        MOV BH, 00H
        MOV ES:[SI], BX
        MOV AL, INPUT[4]
        MOV AH, 00H
        MOV ES:[BP], AX
            
        SUB DI, 2
        MOV DL, INPUT[2]
        MOV DH, 07H
        MOV ES:[DI], DX    
        SUB SI, 2
        MOV BL, INPUT[3]
        MOV BH, 07H
        MOV ES:[SI], BX
        SUB BP, 2
        MOV AL, INPUT[4]
        MOV AH, 07H
        MOV ES:[BP], AX
        
        PUSH DI
        PUSH SI
        PUSH BP
        
        MOV DI, LEN7_L5_HOLDER1
        MOV SI, LEN7_L6_HOLDER1
        MOV BP, LEN7_L7_HOLDER1

        MOV DL, INPUT[6]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[7]
        MOV BH, 00H
        MOV ES:[SI], BX
        MOV AL, INPUT[8]
        MOV AH, 00H
        MOV ES:[BP], BX
        
        ADD DI, 2
        MOV DL, INPUT[6]
        MOV DH, 07H
        MOV ES:[DI], DX    
        ADD SI, 2
        MOV BL, INPUT[7]
        MOV BH, 07H
        MOV ES:[SI], BX
        ADD BP, 2
        MOV AL, INPUT[8]
        MOV AH, 07H
        MOV ES:[BP], AX
        
        MOV LEN7_L5_HOLDER1, DI
        MOV LEN7_L6_HOLDER1, SI
        MOV LEN7_L7_HOLDER1, BP        
        LOOP MOVE_3
    
    DONE4:
        CALL MOVE_DOWN 
        CALL MOVE_DOWN
        CALL MOVE_DOWN
        CALL MOVE_DOWN
        CALL MOVE_DOWN 
        CALL MOVE_DOWN
        CALL MOVE_DOWN
        CALL MOVE_DOWN
    
    JMP MOVE_3INWARDS

MOVE_DOWN: 
    MOV AL, 1
    MOV BH, 00H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV AH, 07H
    INT 10H
    
    MOV AL, 1
    MOV BH, 00H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV AH, 07H
    INT 10H 
    
    MOV AL, 1
    MOV BH, 00H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV AH, 07H
    INT 10H
    RET

MOVE_1INWARDS:
    CMP CX, 0
    JE DONE3
    
    MOV DL, INPUT[2]
    MOV DH, 00H
    MOV ES:[DI], DX
    ADD DI, 2
    MOV DL, INPUT[2]
    MOV DH, 07H
    MOV ES:[DI], DX
    
    MOV DL, INPUT[4]
    MOV DH, 00H
    MOV ES:[SI], DX
    SUB SI, 2
    MOV DL, INPUT[4]
    MOV DH, 07H
    MOV ES:[SI], DX   
    LOOP MOVE_1INWARDS
    
    DONE3:
        RET

MOVE_2INWARDS:
    MOV CX, 37 
    MOV DI, 3840
    MOV SI, 3842
    PUSH DI
    PUSH SI

    MOV DL, INPUT[2]
    MOV DH, 00H
    MOV ES:[DI], DX
    MOV BL, INPUT[3]
    MOV BH, 00H
    MOV ES:[SI], BX
    
    ADD DI, 2
    MOV DL, INPUT[2]
    MOV DH, 07H
    MOV ES:[DI], DX    
    ADD SI, 2
    MOV BL, INPUT[3]
    MOV BH, 07H
    MOV ES:[SI], BX
    
    PUSH DI
    PUSH SI

    MOVE_21:    
        CMP CX, 0
        JE DONE5
        
        POP SI
        POP DI
        
        MOV DL, INPUT[2]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[3]
        MOV BH, 00H
        MOV ES:[SI], BX
        
        ADD DI, 2
        MOV DL, INPUT[2]
        MOV DH, 07H
        MOV ES:[DI], DX    
        ADD SI, 2
        MOV BL, INPUT[3]
        MOV BH, 07H
        MOV ES:[SI], BX
        
        PUSH DI
        PUSH SI
        
        MOV DI, LEN5_L4_HOLDER2[0]
        MOV SI, LEN5_L5_HOLDER2[0]

        MOV DL, INPUT[5]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[6]
        MOV BH, 00H
        MOV ES:[SI], BX
        
        SUB DI, 2
        MOV DL, INPUT[5]
        MOV DH, 07H
        MOV ES:[DI], DX    
        SUB SI, 2
        MOV BL, INPUT[6]
        MOV BH, 07H
        MOV ES:[SI], BX
        
        MOV LEN5_L4_HOLDER2[0], DI
        MOV LEN5_L5_HOLDER2[0], SI        
        LOOP MOVE_21
    
    DONE5:
        CALL MOVE_UP
        CALL MOVE_UP
        CALL MOVE_UP
        CALL MOVE_UP 
        
        JMP EXIT

MOVE_3INWARDS:
    MOV CX, 36 
    MOV DI, 3840
    MOV SI, 3842
    MOV BP, 3844
    PUSH DI
    PUSH SI
    PUSH BP

    MOV DL, INPUT[2]
    MOV DH, 00H
    MOV ES:[DI], DX
    MOV BL, INPUT[3]
    MOV BH, 00H
    MOV ES:[SI], BX
    MOV AL, INPUT[4]
    MOV AH, 00H
    MOV ES:[BP], AX
    
    ADD DI, 2
    MOV DL, INPUT[2]
    MOV DH, 07H
    MOV ES:[DI], DX    
    ADD SI, 2
    MOV BL, INPUT[3]
    MOV BH, 07H
    MOV ES:[SI], BX
    ADD BP, 2
    MOV BL, INPUT[4]
    MOV BH, 07H
    MOV ES:[BP], BX
    
    PUSH DI
    PUSH SI
    PUSH BP

    MOVE_31:    
        CMP CX, 0
        JE DONE6
        
        POP BP
        POP SI
        POP DI
        
        MOV DL, INPUT[2]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[3]
        MOV BH, 00H
        MOV ES:[SI], BX
        MOV AL, INPUT[4]
        MOV AH, 00H
        MOV ES:[BP], AX
            
        ADD DI, 2
        MOV DL, INPUT[2]
        MOV DH, 07H
        MOV ES:[DI], DX    
        ADD SI, 2
        MOV BL, INPUT[3]
        MOV BH, 07H
        MOV ES:[SI], BX
        ADD BP, 2
        MOV AL, INPUT[4]
        MOV AH, 07H
        MOV ES:[BP], AX
        
        PUSH DI
        PUSH SI
        PUSH BP
        
        MOV DI, LEN7_L5_HOLDER2
        MOV SI, LEN7_L6_HOLDER2
        MOV BP, LEN7_L7_HOLDER2

        MOV DL, INPUT[6]
        MOV DH, 00H
        MOV ES:[DI], DX
        MOV BL, INPUT[7]
        MOV BH, 00H
        MOV ES:[SI], BX
        MOV AL, INPUT[8]
        MOV AH, 00H
        MOV ES:[BP], BX
        
        SUB DI, 2
        MOV DL, INPUT[6]
        MOV DH, 07H
        MOV ES:[DI], DX    
        SUB SI, 2
        MOV BL, INPUT[7]
        MOV BH, 07H
        MOV ES:[SI], BX
        SUB BP, 2
        MOV AL, INPUT[8]
        MOV AH, 07H
        MOV ES:[BP], AX
        
        MOV LEN7_L5_HOLDER2, DI
        MOV LEN7_L6_HOLDER2, SI
        MOV LEN7_L7_HOLDER2, BP         
        LOOP MOVE_31
    
    DONE6:
        CALL MOVE_UP
        CALL MOVE_UP
        CALL MOVE_UP
        CALL MOVE_UP 
        
        JMP EXIT

MOVE_UP: 
    MOV AL, 1
    MOV BH, 00H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV AH, 06H
    INT 10H
    
    MOV AL, 1
    MOV BH, 00H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV AH, 06H
    INT 10H 
    
    MOV AL, 1
    MOV BH, 00H
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV AH, 06H
    INT 10H
    RET

SET_CURSOR_POS:
    MOV DL, 40
    SUB DL, INPUT[1]
    ADD DL ,1
    MOV AH, 2
    INT 10H
    RET    

GET_INPUT:
    LEA DX, INPUT
    MOV AH, 0AH
    INT 21H
    RET

CLEAR_SCREEN:
    MOV AL, 03H
    MOV AH, 0
    INT 10H
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

MSG_PROMPT DB 'ENTER A ODD STRING: $'      
INPUT DB 20, ?, 20 DUP(?)
BLANK DB '                    '

LEN5_L4_HOLDER1 DW 82
LEN5_L5_HOLDER1 DW 84
LEN5_L4_HOLDER2 DW 3996
LEN5_L5_HOLDER2 DW 3998

LEN7_L5_HOLDER1 DW 82
LEN7_L6_HOLDER1 DW 84
LEN7_L7_HOLDER1 DW 86
LEN7_L5_HOLDER2 DW 3994
LEN7_L6_HOLDER2 DW 3996
LEN7_L7_HOLDER2 DW 3998