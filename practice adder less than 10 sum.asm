org 100h

; --- Step 1: Display "?"
mov ah, 02h
mov dl, '?'
int 21h

; --- Step 2: Read first digit
mov ah, 01h     ; DOS function 01h: read char from keyboard into AL
int 21h
sub al, '0'     ; convert ASCII ? number
mov bl, al      ; store first digit in BL

; --- Step 3: Read second digit
mov ah, 01h
int 21h
sub al, '0'     ; convert ASCII ? number
mov bh, al      ; store second digit in BH

; --- Step 4: Add them
mov al, bl
add al, bh      ; AL = BL + BH
mov cl, al      ; store sum in CL

; --- Step 5: Check if sum < 10
cmp cl, 10
jge end_program ; if >= 10, just exit

; --- Step 6: Print newline
mov ah, 09h
lea dx, newline
int 21h

; --- Step 7: Print message "THE SUM OF "
mov ah, 09h
lea dx, msg1
int 21h

; --- Step 8: Print first digit
mov dl, bl
add dl, '0'
mov ah, 02h
int 21h

; --- Step 9: Print " AND "
mov ah, 09h
lea dx, msg2
int 21h

; --- Step 10: Print second digit
mov dl, bh
add dl, '0'
mov ah, 02h
int 21h

; --- Step 11: Print " IS "
mov ah, 09h
lea dx, msg3
int 21h

; --- Step 12: Print sum
mov dl, cl
add dl, '0'
mov ah, 02h
int 21h

end_program:
mov ah, 4Ch
int 21h

; --- Data section ---
newline db 0Dh,0Ah,'$'
msg1 db "THE SUM OF ", '$'
msg2 db " AND ", '$'
msg3 db " IS ", '$'
