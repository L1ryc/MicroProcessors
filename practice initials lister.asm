org 100h

; --- Step 1: Prompt the user ---
mov ah, 09h
lea dx, prompt
int 21h

; --- Step 2: Read first initial ---
mov ah, 01h        ; read character into AL
int 21h
mov bl, al         ; store in BL

; --- Step 3: Read middle initial ---
mov ah, 01h
int 21h
mov bh, al         ; store in BH

; --- Step 4: Read last initial ---
mov ah, 01h
int 21h
mov cl, al         ; store in CL

; --- Step 5: Print newline ---
mov ah, 09h
lea dx, newline
int 21h

; --- Step 6: Display initials down the left margin ---
; Print BL
mov dl, bl
mov ah, 02h
int 21h
; newline
mov ah, 09h
lea dx, newline
int 21h

; Print BH
mov dl, bh
mov ah, 02h
int 21h
; newline
mov ah, 09h
lea dx, newline
int 21h

; Print CL
mov dl, cl
mov ah, 02h
int 21h
; newline
mov ah, 09h
lea dx, newline
int 21h

; --- Exit program ---
mov ah, 4Ch
int 21h

; --- Data section ---
prompt  db "Enter your initials (first, middle, last): $"
newline db 0Dh,0Ah,'$'
