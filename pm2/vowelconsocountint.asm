; ==========================================
; Count vowels & consonants (EMU8086 .COM)
; org 100h, data on top, jmp start
; ==========================================

org 100h
    jmp start

; ---------- DATA ----------
prompt      db 'Input string [max. 20]: $'
inbuf       db 20
inlen       db 0
intext      db 20 dup(0)

; Modified strings for the desired output format
s_chars     db 'total characters: ', '$'
s_a         db 'a count: ', '$'
s_e         db 'e count: ', '$'
s_i         db 'i count: ', '$'
s_o         db 'o count: ', '$'
s_u         db 'u count: ', '$'
s_vow       db 'total vowels: ', '$'
s_con       db 'total consonants: ', '$'
crlf        db 0Dh,0Ah,'$'

cnt_len     dw 0
cnt_a       dw 0
cnt_e       dw 0
cnt_i       dw 0
cnt_o       dw 0
cnt_u       dw 0
cnt_v       dw 0
cnt_c       dw 0

; ---------- CODE ----------
start:
    push cs
    pop  ds

    mov  dx, offset prompt
    mov  ah, 9
    int  21h

    mov  dx, offset inbuf
    mov  ah, 0Ah
    int  21h

    ; clear counters
    xor  ax, ax
    mov  cnt_len, ax
    mov  cnt_a,   ax
    mov  cnt_e,   ax
    mov  cnt_i,   ax
    mov  cnt_o,   ax
    mov  cnt_u,   ax
    mov  cnt_v,   ax
    mov  cnt_c,   ax

    ; total characters
    mov  al, inlen
    cbw
    mov  cnt_len, ax

    ; scan characters
    mov  si, offset intext
    mov  cl, inlen
    xor  ch, ch

scan_loop:
    cmp  cx, 0
    je   show_results

    lodsb                       ; AL = char

    ; to uppercase
    cmp  al, 'a'
    jb   chk_letter
    cmp  al, 'z'
    ja   chk_letter
    sub  al, 20h                ; 'a'..'z' -> 'A'..'Z'

chk_letter:
    ; only letters A..Z count
    cmp  al, 'A'
    jb   next_char
    cmp  al, 'Z'
    ja   next_char

    ; vowel?
    cmp  al, 'A'
    je   is_A
    cmp  al, 'E'
    je   is_E
    cmp  al, 'I'
    je   is_I
    cmp  al, 'O'
    je   is_O
    cmp  al, 'U'
    je   is_U

    inc  word ptr cnt_c
    jmp  next_char

is_A:   inc  word ptr cnt_a
    inc  word ptr cnt_v
    jmp  next_char
is_E:   inc  word ptr cnt_e
    inc  word ptr cnt_v
    jmp  next_char
is_I:   inc  word ptr cnt_i
    inc  word ptr cnt_v
    jmp  next_char
is_O:   inc  word ptr cnt_o
    inc  word ptr cnt_v
    jmp  next_char
is_U:   inc  word ptr cnt_u
    inc  word ptr cnt_v

next_char:
    loop scan_loop

; ---------- OUTPUT ----------
show_results:
    ; print a blank line before results
    mov  dx, offset crlf
    mov  ah, 9
    int  21h
    
    mov  dx, offset s_chars
    mov  ah, 9
    int  21h
    mov  ax, cnt_len
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_a
    mov  ah, 9
    int  21h
    mov  ax, cnt_a
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_e
    mov  ah, 9
    int  21h
    mov  ax, cnt_e
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_i
    mov  ah, 9
    int  21h
    mov  ax, cnt_i
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_o
    mov  ah, 9
    int  21h
    mov  ax, cnt_o
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_u
    mov  ah, 9
    int  21h
    mov  ax, cnt_u
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_vow
    mov  ah, 9
    int  21h
    mov  ax, cnt_v
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h

    mov  dx, offset s_con
    mov  ah, 9
    int  21h
    mov  ax, cnt_c
    call print_decimal
    mov  dx, offset crlf
    mov  ah, 9
    int  21h
    
    mov  ax, 4C00h
    int  21h

; ---------- routines ----------
; print_decimal: prints a decimal value in AX
; This routine correctly handles single-digit numbers without leading zeros.
print_decimal:
    push ax
    push bx
    push cx
    push dx

    xor cx, cx          ; CX will count the digits
    mov bx, 10          ; divisor

pdec_loop:
    xor dx, dx
    div bx
    push dx             ; push remainder (digit)
    inc cx
    cmp ax, 0
    jne pdec_loop

pdec_print:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop pdec_print

    pop dx
    pop cx
    pop bx
    pop ax
    ret