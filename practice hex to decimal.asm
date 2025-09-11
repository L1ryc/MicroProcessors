org 100h

; --- Step 1: Prompt user ---
mov ah, 09h
lea dx, prompt
int 21h

; --- Step 2: Read one character ---
mov ah, 01h        ; read char into AL
int 21h

; --- Step 3: Convert ASCII 'A'–'F' ? decimal value ---
sub al, 'A'        ; e.g. 'C' - 'A' = 2
add al, 10         ; A=10, B=11, ... F=15
mov bl, al         ; store value in BL

; --- Step 4: Print newline ---
mov ah, 09h
lea dx, newline
int 21h

; --- Step 5: Print message ---
mov ah, 09h
lea dx, msg
int 21h

; --- Step 6: Print decimal value ---
; Decimal values 10–15 ? need 2 digits
mov al, bl
cmp al, 10
jl single_digit

; print tens digit
mov dl, '1'        ; since A–F only go 10–15 ? tens digit is always '1'
mov ah, 02h
int 21h

; print ones digit
mov al, bl
sub al, 10
add al, '0'
mov dl, al
mov ah, 02h
int 21h
jmp done

single_digit:
add al, '0'        ; convert to ASCII
mov dl, al
mov ah, 02h
int 21h

done:
; --- Exit ---
mov ah, 4Ch
int 21h

; --- Data section ---
prompt  db "ENTER A HEX DIGIT (A-F): $"
msg     db "IN DECIMAL IT IS ", '$'
newline db 0Dh,0Ah,'$'
