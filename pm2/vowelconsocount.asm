; ==========================================
; Vowel & Consonant Counter (Clean Output)
; Direct video memory printing, one stat per line
; ==========================================

org 100h
    jmp main

; ---------- DATA ----------
prompt      db 'Input string [max 20]: ',0
msg_chars   db 'inputted chars = ',0
msg_a       db 'a count = ',0
msg_e       db 'e count = ',0
msg_i       db 'i count = ',0
msg_o       db 'o count = ',0
msg_u       db 'u count = ',0
msg_vow     db 'vowel count = ',0
msg_con     db 'consonant count = ',0

; DOS 0Ah input buffer
inbuf       db 20
inlen       db 0
intext      db 20 dup(0)

; Counters
cnt_len dw 0
cnt_a   dw 0
cnt_e   dw 0
cnt_i   dw 0
cnt_o   dw 0
cnt_u   dw 0
cnt_v   dw 0
cnt_c   dw 0

; ---------- CODE ----------
main:
    ; DS = CS
    push cs
    pop  ds

    ; ES = video memory
    mov ax, 0B800h
    mov es, ax
    xor di, di          ; start at top-left

    ; show prompt
    mov si, offset prompt
    call print_text

    ; read input (DOS buffered)
    mov dx, offset inbuf
    mov ah, 0Ah
    int 21h

    ; clear counters
    xor ax, ax
    mov cnt_len, ax
    mov cnt_a, ax
    mov cnt_e, ax
    mov cnt_i, ax
    mov cnt_o, ax
    mov cnt_u, ax
    mov cnt_v, ax
    mov cnt_c, ax

    ; total chars
    mov al, inlen
    cbw
    mov cnt_len, ax

    ; scan characters
    mov si, offset intext
    mov cl, inlen
    xor ch, ch

scan_loop:
    cmp cx, 0
    je  results

    lodsb

    ; to uppercase if 'a'..'z'
    cmp al, 'a'
    jb  chk_letter
    cmp al, 'z'
    ja  chk_letter
    sub al, 20h

chk_letter:
    cmp al, 'A'
    jb  next_char
    cmp al, 'Z'
    ja  next_char

    cmp al, 'A'
    je  is_A
    cmp al, 'E'
    je  is_E
    cmp al, 'I'
    je  is_I
    cmp al, 'O'
    je  is_O
    cmp al, 'U'
    je  is_U

    inc word ptr cnt_c
    jmp next_char

is_A: inc word ptr cnt_a
      inc word ptr cnt_v
      jmp next_char
is_E: inc word ptr cnt_e
      inc word ptr cnt_v
      jmp next_char
is_I: inc word ptr cnt_i
      inc word ptr cnt_v
      jmp next_char
is_O: inc word ptr cnt_o
      inc word ptr cnt_v
      jmp next_char
is_U: inc word ptr cnt_u
      inc word ptr cnt_v

next_char:
    dec cx
    jmp scan_loop

; ---------- OUTPUT ----------
results:
    call newline
    mov si, offset msg_chars
    call print_text
    mov ax, cnt_len
    call print_num2d
    call newline

    mov si, offset msg_a
    call print_text
    mov ax, cnt_a
    call print_num2d
    call newline

    mov si, offset msg_e
    call print_text
    mov ax, cnt_e
    call print_num2d
    call newline

    mov si, offset msg_i
    call print_text
    mov ax, cnt_i
    call print_num2d
    call newline

    mov si, offset msg_o
    call print_text
    mov ax, cnt_o
    call print_num2d
    call newline

    mov si, offset msg_u
    call print_text
    mov ax, cnt_u
    call print_num2d
    call newline

    mov si, offset msg_vow
    call print_text
    mov ax, cnt_v
    call print_num2d
    call newline

    mov si, offset msg_con
    call print_text
    mov ax, cnt_c
    call print_num2d
    call newline

    mov ax, 4C00h
    int 21h

; ---------- ROUTINES ----------
; print_text: SI -> zero-terminated string
; writes chars to ES:DI with attribute 1010b (light green on black)
print_text:
pt_loop:
    mov al, [si]
    cmp al, 0
    je pt_done
    mov es:[di], al
    mov es:[di+1], 1010b
    add di, 2
    inc si
    jmp pt_loop
pt_done:
    ret

; newline: move DI to start of next line
newline:
    mov ax, di
    mov bx, 160
    xor dx, dx
    div bx
    inc ax
    mul bx
    mov di, ax
    ret

; print_num2d: AX = number (0..99)
print_num2d:
    cmp ax, 99
    jbe pn_ok
    mov ax, 99
pn_ok:
    xor dx, dx
    mov bx, 10
    div bx           ; AL = tens, DL = ones
    push dx
    add al, '0'
    mov es:[di], al
    mov es:[di+1], 1010b
    add di, 2
    pop dx
    add dl, '0'
    mov es:[di], dl
    mov es:[di+1], 1010b
    add di, 2
    ret
