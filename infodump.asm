org 100h
   
   
    ; -------------
    ;     BEGIN
    ; -------------
   
    LEA DX, INTRO         ; MOVE offset INTRO String
    MOV AH, 09h           ; SET INT 21h - 09h - Print String
    INT 21h               ; CALL interrupt
   
    LEA DX, NEWLINE       ; MOVE offset NEWLINE
    MOV AH, 09h           ; SET INT 21h - 09h - Print String
    INT 21h               ; CALL interrupt
   
   
   
   
    ; -------------
    ;    DISPLAY
    ; -------------
   
   
    DISPLAY_NAME:
   
        LEA DX, TXT1        ; MOVE offset TXT1 string
        MOV AH, 09h         ; SET INT 21h - 09h - Print String
        INT 21h             ; CALL interrupt
       
        LEA SI, IN_NAME     ; MOVE source to IN_NAME to rewrite entry
        MOV AH, 01h         ; SET INT 21h - 01h - GET character
       
       
        GET_NAME:
       
            INT 21h         ; CALL interrupt
           
            CMP AL, '$'             ; IF INPUT == '$'
            JE DISPLAY_PROGLEVEL    ; JUMP to NEXT
           
            MOV [SI], AL    ; MOVE AL [char] to content of SI
            INC SI          ; INC source for next index
            JMP GET_NAME    ; LOOP GET_NAME for next character
           
   
    ; For PROGRAM and YEAR LEVEL
       

    DISPLAY_PROGLEVEL:
   
        MOV AL, '$'         ; ADD terminator $
        MOV [SI], AL        ; TERMINATE previous string
       
        LEA DX, TXT2
        MOV AH, 09h
        INT 21h
       
        LEA SI, IN_PROGLEVEL
        MOV AH, 01h
       
        GET_PROGLEVEL:
       
            INT 21h
           
            CMP AL, '$'
            JE DISPLAY_REPETITION
           
            MOV [SI], AL
            INC SI
            JMP GET_PROGLEVEL
           
           
    ; For NUMBER OF REPETITION
       
       
    DISPLAY_REPETITION:
   
        MOV AL, '$'
        MOV [SI], AL
       
        LEA DX, TXT3
        MOV AH, 09h
        INT 21h
       
        LEA SI, IN_REPEAT
        MOV AH, 01h
       
        GET_REPETITION:
       
            INT 21h
           
            CMP AL, '$'
            JE DISPLAY_ALL
           
            MOV [SI], AL
            INC SI
            JMP GET_REPETITION
         
     
     
     
    ; For REPETITIVE DISPLAY

    DISPLAY_ALL:
   
        MOV AL, '$'         ; Terminate previous string
        MOV [SI], AL
       
        MOV BX, 0000h       ; CLEAN BX content [Used for counter]
        MOV BL, IN_REPEAT   ; HOLD value of repetition
       
        LEA DX, NEWLINE
        MOV AH, 09h
        INT 21h
        INT 21h  
                 
                 
        DISPLAY_STUDENT_INFO:
   
            CALL ADD_DELAY    ; CALL delay functio
       
            LEA DX, NEWLINE
            MOV AH, 09h
            INT 21h
       
            LEA DX, DISPLAY1
            MOV AH, 09h
            INT 21h
       
            LEA DX, IN_NAME
            MOV AH, 09h
            INT 21h
       
            LEA DX, DISPLAY2
            MOV AH, 09h
            INT 21h
       
            LEA DX, IN_PROGLEVEL
            MOV AH, 09h
            INT 21h
       
            DEC BL
            CMP BL, 30h                 ; IF BL == 0, EXIT
            JE EXIT
            JNE DISPLAY_STUDENT_INFO
       
       
       
   
    EXIT:
   
        MOV AH, 4Ch
        INT 21h       ; EXIT
   
   

     
    ADD_DELAY PROC
   
        PUSH CX
        MOV CX, 64h
       
        DEL:
        LOOP DEL
        POP CX
       
        ret
     
    ADD_DELAY ENDP
     
     
    ; MALLOC STRINGS
   
    INTRO       DB  "Display your name, program and level a # of times$"
   
    TXT1        DB 0Dh, 0Ah, "Enter your name: $"
    TXT2        DB 0Dh, 0Ah, "Enter program and Year Level: $"
    TXT3        DB 0Dh, 0Ah, "Number of repetition: $"
   
    DISPLAY1    DB 0Dh, 0Ah, "Name                     : $"
    DISPLAY2    DB 0Dh, 0Ah, "Program and Year Level   : $"
   
    IN_NAME      DB 255 DUP(?)
    IN_PROGLEVEL DB 255 DUP(?)
    IN_REPEAT    DB 255 DUP(?)
   
    NEWLINE     DB 0Ah, 0Dh, "$"