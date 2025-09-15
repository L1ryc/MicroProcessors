org 100h
jmp start
; ----------------------------
; Data
; ----------------------------
prompt db 'Enter Fahrenheit (integer): $'
err_msg db 13,10,'Invalid input. Try again.',13,10,'$'
res_label db 13,10,'Celsius: $'
done_msg db 13,10,13,10,'Press any key to exit...$'
; DOS 0Ah input buffer (keyboard line input)
InMax db 16 ; maximum chars user may type
InLen db 0 ; actual chars read (unused here)
InData db 16 dup(0) ; the typed data (not zero-terminated)
; Hardcoded Fahrenheit input (change this value as needed)
F_IN dw 300 ; e.g., 100F -> 37C
; ----------------------------
; Code
; ----------------------------
start:
    ; DS = CS (so our data prints correctly in .COM)
    push cs
    pop ds
; Direct conversion using hardcoded Fahrenheit value
do_convert:
    ; Show prompt and the hardcoded Fahrenheit value
    mov dx, offset prompt
    mov ah, 09h
    int 21h
    mov ax, [F_IN]
    call display_number
    ; Reload AX with Fahrenheit for conversion
    mov ax, [F_IN] ; AX = Fahrenheit (hardcoded)
   
    ; Celsius = (F - 32) * 5 / 9 (signed, trunc toward 0)
    sub ax, 32
    cwd ; sign-extend into DX
    mov bx, 5
    imul bx ; DX:AX = (F-32) * 5
    mov bx, 9
    idiv bx ; AX = Celsius
    ; print label + result (preserve AX across DOS 09h)
    push ax ; save Celsius
    mov dx, offset res_label
    mov ah, 09h
    int 21h
    pop ax ; restore Celsius
    call display_number
    ; finish message
    mov dx, offset done_msg
    mov ah, 09h
    int 21h
    ; wait for a key, then exit
    mov ah, 08h
    int 21h
    mov ax, 4C00h
    int 21h
; ---------------------------------------------------------
; read_number
; Parses a signed decimal integer from DOS 0Ah buffer.
; Uses InLen to limit parsing (more robust than scanning for 0Dh).
; Allows leading/trailing spaces, optional '+'/'-'.
; Returns: AX = value, CF = 0 on success, CF = 1 on error.
; Destroys: AX,BX,CX,DX,SI,DI (but restores via pushes).
; ---------------------------------------------------------
read_number:
    push bx
    push cx
    push dx
    push si
    push di
    lea si, InData ; SI -> first typed char
    xor cx, cx
    mov cl, [InLen] ; CX = number of chars typed (no CR)
    jcxz rn_err ; empty line
; skip leading spaces (bounded by CX)
rn_skip_lead:
    cmp byte ptr [si], ' '
    jne rn_sign
    inc si
    loop rn_skip_lead ; dec cx; jnz
    jmp rn_err ; all spaces -> error
; optional sign (if chars remain)
rn_sign:
    xor dl, dl ; DL = 0 => positive, 1 => negative
    jcxz rn_err ; nothing left
    cmp byte ptr [si], '+'
    jne rn_chk_minus
    inc si
    dec cx
    jmp rn_need_digit
rn_chk_minus:
    cmp byte ptr [si], '-'
    jne rn_need_digit
    mov dl, 1
    inc si
    dec cx
; must start with a digit
rn_need_digit:
    jcxz rn_err
    mov bl, [si]
    cmp bl, '0'
    jb rn_err
    cmp bl, '9'
    ja rn_err
    xor ax, ax ; AX = result
; read digits (bounded by CX)
rn_digits:
    jcxz rn_after_digits
    mov bl, [si]
    cmp bl, '0'
    jb rn_after_digits
    cmp bl, '9'
    ja rn_after_digits
    ; AX = AX*10 + digit
    mov di, ax
    shl di, 1 ; *2
    shl di, 1 ; *4
    shl di, 1 ; *8
    shl ax, 1 ; *2
    add ax, di ; *10 total
    sub bl, '0'
    xor bh, bh
    add ax, bx
    inc si
    dec cx
    jmp rn_digits
; allow trailing spaces (consume remaining spaces)
rn_after_digits:
    jcxz rn_apply_sign
rn_trim_trail:
    cmp byte ptr [si], ' '
    jne rn_check_leftover
    inc si
    loop rn_trim_trail
rn_check_leftover:
    jcxz rn_apply_sign ; ok if nothing remains
    jmp rn_err ; leftover non-space chars -> error
; apply sign from DL
rn_apply_sign:
    test dl, dl
    jz rn_ok
    neg ax
rn_ok:
    clc
    jmp rn_exit
rn_err:
    stc
rn_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
; ---------------------------------------------------------
; display_number
; Prints signed AX in decimal using DOS int 21h/AH=02h.
; Destroys AX,BX,CX,DX.
; ---------------------------------------------------------
display_number:
    push bx
    push cx
    push dx
    ; sign handling
    cmp ax, 0
    jge dn_abs
    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax
dn_abs:
    ; zero special-case
    cmp ax, 0
    jne dn_conv
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp dn_done
; push digits (remainder method)
dn_conv:
    xor cx, cx
    mov bx, 10
dn_div:
    xor dx, dx
    div bx ; AX = AX/10 (unsigned OK, AX>=0 here), DX = rem
    push dx
    inc cx
    test ax, ax
    jnz dn_div
; pop and print digits
dn_out:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop dn_out
dn_done:
    pop dx
    pop cx
    pop bx
    ret