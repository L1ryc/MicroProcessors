org 100h
jmp start


prompt      db 'Enter Fahrenheit (integer): $'
err_msg     db 13,10,'Invalid input. Try again.',13,10,'$'
res_label   db 13,10,'Celsius: $'
done_msg    db 13,10,13,10,'Press any key to exit...$'

; DOS 0Ah input buffer (keyboard line input)
InMax       db 16          ; max chars user may type
InLen       db 0           ; actual chars read (count)
InData      db 16 dup(0)   ; typed data (not zero-terminated)

start:
    ; DS = CS (so our data prints correctly in .COM)
    push cs
    pop  ds

read_again:
    ; show prompt
    mov dx, offset prompt
    mov ah, 09h
    int 21h

    ; read line into DOS 0Ah buffer
    mov dx, offset InMax
    mov ah, 0Ah
    int 21h

    ; parse signed integer from buffer -> AX, CF=0 if ok
    call parse_int
    jc   bad_input

    ; AX = Fahrenheit
    ; Celsius = (F - 32) * 5 / 9  (signed, trunc toward 0)
    sub ax, 32
    cwd                     ; sign-extend into DX
    mov bx, 5
    imul bx                 ; DX:AX = (F-32)*5
    mov bx, 9
    idiv bx                 ; AX = Celsius

    ; print label + result (preserve AX across DOS 09h)
    push ax
    mov dx, offset res_label
    mov ah, 09h
    int 21h
    pop  ax
    call print_int

    ;; finish message and exit
;    mov dx, offset done_msg
;    mov ah, 09h
;    int 21h

    ;mov ah, 08h            ; wait for any key
;    int 21h
    mov ax, 4C00h
    int 21h

bad_input:
    mov dx, offset err_msg
    mov ah, 09h
    int 21h
    jmp read_again


parse_int:
    push bx
    push cx
    push dx
    push si
    push di

    lea si, InData           ; SI -> first typed char
    xor cx, cx
    mov cl, [InLen]          ; CX = chars typed
    jcxz pi_err              ; empty -> error

; skip leading spaces
pi_skip_lead:
    cmp byte ptr [si], ' '
    jne pi_sign
    inc si
    loop pi_skip_lead
    jmp pi_err               ; all spaces

; optional sign
pi_sign:
    xor dl, dl               ; DL=0 positive, 1 negative
    jcxz pi_err
    cmp byte ptr [si], '+'
    jne pi_chk_minus
    inc si
    dec cx
    jmp pi_need_digit

pi_chk_minus:
    cmp byte ptr [si], '-'
    jne pi_need_digit
    mov dl, 1
    inc si
    dec cx

; must start with a digit
pi_need_digit:
    jcxz pi_err
    mov bl, [si]
    cmp bl, '0'
    jb  pi_err
    cmp bl, '9'
    ja  pi_err

    xor ax, ax               ; AX=result

; read digits
pi_digits:
    jcxz pi_after_digits
    mov bl, [si]
    cmp bl, '0'
    jb  pi_after_digits
    cmp bl, '9'
    ja  pi_after_digits

    ; AX = AX*10 + digit
    mov di, ax
    shl di, 1                ; *2
    shl di, 1                ; *4
    shl di, 1                ; *8
    shl ax, 1                ; *2
    add ax, di               ; *10
    sub bl, '0'
    xor bh, bh
    add ax, bx

    inc si
    dec cx
    jmp pi_digits

; skip trailing spaces
pi_after_digits:
    jcxz pi_apply_sign
pi_trim_trail:
    cmp byte ptr [si], ' '
    jne pi_check_leftover
    inc si
    loop pi_trim_trail

pi_check_leftover:
    jcxz pi_apply_sign
    jmp pi_err               ; leftover non-space -> error

; apply sign
pi_apply_sign:
    test dl, dl
    jz   pi_ok
    neg  ax

pi_ok:
    clc
    jmp  pi_exit

pi_err:
    stc

pi_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

print_int:
    push bx
    push cx
    push dx

    ; handle sign
    cmp ax, 0
    jge pi_abs
    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax

pi_abs:
    ; zero special-case
    cmp ax, 0
    jne pi_conv
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp pi_done

; push digits
pi_conv:
    xor cx, cx
    mov bx, 10
pi_div:
    xor dx, dx
    div bx              ; AX /=10, DX=remainder
    push dx
    inc cx
    test ax, ax
    jnz pi_div

; pop digits to print
pi_out:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pi_out

pi_done:
    pop dx
    pop cx
    pop bx
    ret