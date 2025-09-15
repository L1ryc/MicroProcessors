; ==========================================
; Two numbers (0–255) ? Sum, Difference, Product, Quotient, Remainder
; Direct video memory output, EMU8086 .COM
; ==========================================

org 100h
    jmp start

; ---------- DATA ----------
msg1    db 'Enter first number (0-255): ',0
msg2    db 'Enter second number (0-255): ',0

out_sum db 'Sum = ',0
out_dif db 'Difference = ',0
out_mul db 'Product = ',0
out_div db 'Quotient = ',0
out_rem db 'Remainder = ',0
div0    db 'division by zero',0

; DOS 0Ah input buffers (max 3 chars + CR)
buf1    db 3
len1    db 0
dat1    db 3 dup(0)

buf2    db 3
len2    db 0
dat2    db 3 dup(0)

val1    db 0
val2    db 0
quo     db 0
rem     db 0

ten     dw 10

; ---------- CODE ----------
start:
    ; DS = CS
    push cs
    pop  ds

    ; ES = video memory
    mov ax, 0B800h
    mov es, ax
    xor di, di          ; start at top-left

    ; ---- Read first number ----
    mov si, offset msg1
    call print_text
    mov dx, offset buf1
    mov ah, 0Ah
    int 21h
    mov si, offset buf1
    call parse_dec_0_255
    mov [val1], al
    call newline

    ; ---- Read second number ----
    mov si, offset msg2
    call print_text
    mov dx, offset buf2
    mov ah, 0Ah
    int 21h
    mov si, offset buf2
    call parse_dec_0_255
    mov [val2], al
    call newline
    call newline

    ; -------- SUM --------
    mov si, offset out_sum
    call print_text
    xor ax, ax
    mov al, [val1]
    add al, [val2]
    adc ah, 0
    call print_num_u16
    call newline

    ; -------- DIFFERENCE --------
    mov si, offset out_dif
    call print_text
    mov al, [val1]
    cmp al, [val2]
    jae diff_nonneg
    ; negative: print '-' then (B - A)
    mov al, '-'
    call print_char
    xor ax, ax
    mov al, [val2]
    sub al, [val1]
    xor ah, ah
    jmp short diff_print
diff_nonneg:
    xor ax, ax
    mov al, [val1]
    sub al, [val2]
    xor ah, ah
diff_print:
    call print_num_u16
    call newline

    ; -------- PRODUCT --------
    mov si, offset out_mul
    call print_text
    mov al, [val1]
    mov bl, [val2]
    mul bl                     ; AX = val1 * val2
    call print_num_u16
    call newline

    ; -------- DIVISION & REMAINDER --------
    mov bl, [val2]
    cmp bl, 0
    je  div_by_zero

    mov al, [val1]
    xor ah, ah
    div bl                     ; AL=quot, AH=rem
    mov [quo], al
    mov [rem], ah

    ; Quotient
    mov si, offset out_div
    call print_text
    xor ah, ah
    mov al, [quo]
    call print_num_u16
    call newline

    ; Remainder
    mov si, offset out_rem
    call print_text
    xor ah, ah
    mov al, [rem]
    call print_num_u16
    call newline
    jmp short done

div_by_zero:
    mov si, offset out_div
    call print_text
    mov si, offset div0
    call print_text
    call newline
    mov si, offset out_rem
    call print_text
    mov si, offset div0
    call print_text
    call newline

done:
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

; print_char: AL = char
print_char:
    mov es:[di], al
    mov es:[di+1], 1010b
    add di, 2
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

; print_num_u16: prints AX (0..65535) unsigned decimal
print_num_u16:
    push ax
    push bx
    push cx
    push dx
    cmp ax, 0
    jne pn_go
    mov al, '0'
    call print_char
    jmp pn_done
pn_go:
    xor cx, cx
pn_loop:
    xor dx, dx
    mov bx, 10
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne pn_loop
pn_print:
    pop dx
    add dl, '0'
    mov al, dl
    call print_char
    loop pn_print
pn_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; parse_dec_0_255
; IN : SI -> DOS 0Ah buffer (len at [SI+1], digits at [SI+2..])
; OUT: AL = parsed value clamped to 255
parse_dec_0_255:
    push bx
    push cx
    push dx
    push di
    mov cl, [si+1]        ; CL = length (0..3)
    xor ch, ch
    lea di, [si+2]        ; DI -> first char
    xor bx, bx            ; BX = accumulator
pd_loop:
    cmp cx, 0
    je  pd_done
    mov al, [di]
    inc di
    cmp al, '0'
    jb  pd_next
    cmp al, '9'
    ja  pd_next
    sub al, '0'
    cbw
    mov dx, bx
    mov ax, bx
    mov bx, 10
    mul bx
    mov bx, ax
    mov al, [di-1]
    sub al, '0'
    cbw
    add bx, ax
pd_next:
    dec cx
    jmp pd_loop
pd_done:
    cmp bx, 255
    jbe pd_ok
    mov bx, 255
pd_ok:
    mov al, bl
    pop di
    pop dx
    pop cx
    pop bx
    ret
