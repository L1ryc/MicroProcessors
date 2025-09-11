org 100h
jmp start

; Data
label_a db "a) Converted AL: ",0
label_b db "b) Lowercase BL: ",0
label_c db "c) ASCII Digit: ",0
label_d db "d) Reversed Case: ",0
newline db 0Dh,0Ah,0

start:
    ; Set ES to video memory
    mov ax, 0B800h
    mov es, ax
    ; Initialize sample values
    mov al, 'Z'      ; Sample character for task a (uppercase 'A')
    mov bl, 'H'      ; Sample character for task b (uppercase 'H')
    mov cl, 7        ; Sample binary decimal byte for task c (7)
    mov dl, 'G'      ; Sample character for task d (lowercase 'k')

    ; Task a: Convert character in AL using logical operator
    ; Using AND to clear bit 5 (convert any char to a form, e.g., toggle case-like effect)
    and al, 11011111b  ; Clear bit 5 (similar to case adjustment, makes 'A' stay 'A')
    mov di, 0          ; Start at top-left
    mov si, offset label_a
    call print_text
    mov es:[di], al    ; Print converted AL directly
    mov es:[di+1], 1Eh ; Yellow on blue
    add di, 2

    ; Task b: Convert character in BL to lowercase
    ; Using OR to set bit 5 (convert uppercase to lowercase)
    or bl, 00100000b   ; Set bit 5 to convert 'H' to 'h'
    mov di, 160        ; Move to second line
    mov si, offset label_b
    call print_text
    mov es:[di], bl    ; Print lowercase BL directly
    mov es:[di+1], 1Eh ; Yellow on blue
    add di, 2

    ; Task c: Convert binary decimal byte in CL to ASCII decimal digit
    ; Add '0' (ASCII 48) to convert binary 0-9 to '0'-'9'
    add cl, '0'        ; Convert 7 to '7'
    mov di, 320        ; Move to third line
    mov si, offset label_c
    call print_text
    mov es:[di], cl    ; Print ASCII digit directly
    mov es:[di+1], 1Eh ; Yellow on blue
    add di, 2

    ; Task d: Reverse case of character in DL
    ; XOR with 00100000b to toggle case (upper to lower or lower to upper)
    xor dl, 00100000b  ; Convert 'k' to 'K'
    mov di, 480        ; Move to fourth line
    mov si, offset label_d
    call print_text
    mov es:[di], dl    ; Print reversed case directly
    mov es:[di+1], 1Eh ; Yellow on blue
    add di, 2

    ; Print newlines or additional spacing if needed
    mov di, 640        ; Move to fifth line (optional, for spacing)
    mov si, offset newline
    call print_text

    ; Exit (using interrupt, as it's not for printing)
    mov ah, 4Ch
    int 21h

; Routine: print_text
print_text:
pt_loop:
    mov al, [si]
    cmp al, 0
    je pt_done
    mov es:[di], al
    mov es:[di+1], 1Eh ; Yellow on blue
    add di, 2
    inc si
    jmp pt_loop
pt_done:
    ret