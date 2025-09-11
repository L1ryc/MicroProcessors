.model small
.stack 100h

.data
    input_buffer db 50, ?, 50 dup(0)   ; DOS input buffer
    str db 50 dup('$')                ; buffer to hold the string
    len dw 0                          ; length of the string (word size)
    prompt db 'Input a string: $'
    newline db 13, 10, '$'
    original_first db ?               ; to store original first character

.code
main:
    mov ax, @data
    mov ds, ax

    ; Display prompt
    mov ah, 09h
    lea dx, prompt
    int 21h

    ; Read string from user
    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    ; Get string length
    mov al, input_buffer+1
    mov ah, 0
    mov len, ax

    ; Copy string to str buffer
    lea si, input_buffer+2
    lea di, str
    mov cx, len
copy_loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop copy_loop

    ; Save original first character
    mov al, str
    mov original_first, al

    ; Display original string
    call print_string

rotation_loop:
    call rotate_right
    call print_string

    ; Check if first character matches original
    mov al, str
    cmp al, original_first
    jne rotation_loop

    ; Exit program
    mov ah, 4Ch
    int 21h

; --------------------------
; Subroutine: print_string
; --------------------------
print_string:
    mov ah, 09h
    lea dx, str
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h
    ret

; --------------------------
; Subroutine: rotate_right
; --------------------------
rotate_right:
    mov cx, len
    dec cx
    lea si, str
    add si, cx
    mov al, [si]         ; last character

    lea di, str
    mov cx, len
rotate_loop2:
    mov bl, [di]
    mov [di], al
    mov al, bl
    inc di
    loop rotate_loop2
    ret

end main
