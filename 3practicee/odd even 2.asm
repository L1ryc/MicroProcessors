org 100h

start:
    ; Set ES to video memory
    mov ax, 0B800h
    mov es, ax

    ; Start at row 0, col 0
    mov di, 0

    ; Print label
    lea si, label_text
    call write_text

    ; Convert number to ASCII and print
    mov al, stored_val
    add al, '0'
    mov temp_digit, al
    lea si, temp_digit
    call write_text

    ; Move to row 1, col 0 (160 bytes per row)
    mov di, 160

    ; Print intro to result
    lea si, intro_text
    call write_text

    ; Check odd/even using AND
    mov al, stored_val
    and al, 1
    jz even_case

odd_case:
    lea si, odd_text
    jmp show_result

even_case:
    lea si, even_text

show_result:
    call write_text

    ; Print ending word
    lea si, end_text
    call write_text

    hlt

; --------------------------
; Write text to screen
; --------------------------
write_text:
next_char:
    mov al, [si]
    cmp al, 0
    je done_write
    mov es:[di], al
    mov es:[di+1], 1010b   ; yellow on blue
    add di, 2
    inc si
    jmp next_char
done_write:
    ret

; --------------------------
; Data
; --------------------------
stored_val db 4
label_text db "Value stored: ",0
temp_digit db ?,0
intro_text db "This number is ",0
odd_text   db "ODD",0
even_text  db "EVEN",0
end_text   db " in value.",0
