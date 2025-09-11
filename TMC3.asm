
org 100h  ; Set the origin for the program

    MOV AX, 0B800H
    MOV ES, AX                                       

    MOV AX, @DATA   ; Initialize data
    MOV DS, AX      ; Move data address to DS
    LEA DX, MSG     ; Load address of MSG into DX
    MOV AH, 9       ; Set function to print string
    INT 21H         ; Execute above command
    
    LEA DX, STR1    ; Load address of STR1 into DX
    MOV AH, 0AH     ; Set function to read string
    INT 21H         ; Execute above command
    
    LEA DX, MSG1         ; Load address of MSG2 into DX
    MOV AH, 9            ; Set function to print string
    INT 21H              ; Execute above command 
    
    ; Copy the original string to ORIG
    LEA SI, STR1 + 2  ; Load address of the input string into SI
    LEA DI, ORIG      ; Load address of the original string buffer into DI
    MOV CL, STR1[1]   ; Move the length of the string to CL
Copy:
    MOV AL, [SI]      ; Move SI memory from input string to AL
    MOV [DI], AL      ; Move string content from AL to original string buffer
    INC SI            ; Increment SI to point to the next byte in input string
    INC DI            ; Increment DI to point to the next byte in original string buffer
    DEC CL            ; Decrement CL (length counter)
    JNZ Copy          ; If CL is not zero, repeat the copy process
    
    JMP Transform     ; Jump to Transform 
    
Transform:
    MOV BL, STR1[1]     ; Get the length of the input string
    DEC BL              ; Decrease length by 1 to get the index of the last character
    MOV AL, STR1[BX+2]  ; Get the last character of the input string
    MOV CX, BX          ; Copy the index of the last character to CX
    MOV SI, BX          ; Copy the index of the last character to SI
    ADD SI, 0           ; Adjust SI to point to the last character
    
Shifting:
    MOV DL, STR1[SI+1]  ; Move character from current position to DL
    MOV STR1[SI+2], DL  ; Shift character to the right
    DEC SI              ; Decrement SI to move to the previous character
    LOOP Shifting       ; Repeat until all characters are shifted
    
    MOV STR1[2], AL      ; Place the last character at the beginning
    MOV STR1[BX+3], '$'  ; Properly terminate the string with '$'
                        
    LEA DX, MSG2         ; Load address of MSG2 into DX
    MOV AH, 9            ; Set function to print string
    INT 21H              ; Execute above command
    
    LEA DX, STR1 + 2     ; Load address of the transformed string into DX
    MOV AH, 9            ; Set function to print string
    INT 21H              ; Execute above command

    ; Compare the transformed string with the original string
    LEA SI, STR1 + 2     ; Load address of the transformed string into SI
    LEA DI, ORIG         ; Load address of the original string into DI
    MOV CL, STR1[1]      ; Move the length of the string to CL
Compare:
    MOV AL, [SI]         ; Move byte from transformed string to AL
    CMP AL, [DI]         ; Compare byte in AL with byte in original string
    JNE Transform        ; If not equal, repeat the transformation
    INC SI               ; Increment SI to point to the next byte in transformed string
    INC DI               ; Increment DI to point to the next byte in original string
    DEC CL               ; Decrement CL (length counter)
    JNZ Compare          ; If CL is not zero, repeat the comparison process

    RET 
    
.DATA
  MSG   DB "Please input a string: $"  ; Message to prompt user input
  STR1  DB 100,?, 100 dup(' ')  ; Buffer for storing the input string
  ORIG  DB 100 dup(' ')         ; Buffer for storing the original string
  MSG2  DB 0DH, 0AH, " $"       ; Message to print after transformation
  MSG1  DB 0DH, 0AH, "Output: $" ; Message to print after transformation
.CODE