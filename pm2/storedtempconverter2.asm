org 100h
jmp prog_start

; ----------------------------
; Data (zero-terminated strings)
; ----------------------------
prompt_msg    db 'Enter Fahrenheit (hardcoded): ',0
celsius_label db 'Celsius: ',0
end_msg       db 'Finished. (halt) ',0

FAHR_VALUE    dw 176         ; change this value to test other inputs

; ----------------------------
; Code
; ----------------------------
prog_start:
    ; set DS = CS so string references work
    push cs
    pop  ds

    ; set ES to video memory segment
    mov ax, 0B800h
    mov es, ax

    ; start at upper-left corner of screen
    xor di, di

    ; print prompt + fahrenheit value
    mov si, offset prompt_msg
    call vid_print_str

    mov ax, [FAHR_VALUE]
    call vid_print_num

    call vid_newline

    ; compute Celsius = (F - 32) * 5 / 9  (signed arithmetic)
    mov ax, [FAHR_VALUE]
    sub ax, 32
    cwd
    mov bx, 5
    imul bx            ; DX:AX = (F-32) * 5
    mov bx, 9
    idiv bx            ; AX = Celsius (signed)

    ; print label + Celsius value
    mov si, offset celsius_label
    call vid_print_str

    call vid_print_num

    call vid_newline

    mov si, offset end_msg
    call vid_print_str
     
     hlt
    ; no interrupts allowed — just loop forever so output remains on screen


; ---------------------------------------------------------
; vid_print_str
;   Prints a zero-terminated string at DS:SI to ES:DI using STOSW.
;   Each character cell is (char,attr). Attribute used: 07h.
; ---------------------------------------------------------
vid_print_str:
    push ax
    push si
.vps_loop:
    lodsb               ; AL <- [DS:SI], SI++
    cmp al, 0
    je .vps_done
    mov ah, 07h         ; attribute: light gray on black
    stosw               ; store AX -> [ES:DI], DI += 2
    jmp .vps_loop
.vps_done:
    pop si
    pop ax
    ret

; ---------------------------------------------------------
; vid_print_num
;   Prints signed integer in AX to screen (uses AX as input).
;   Uses DIV by 10 to push remainders then pops them to print digits.
; ---------------------------------------------------------
vid_print_num:
    push ax
    push bx
    push cx
    push dx

    ; handle sign
    cmp ax, 0
    jge .vpn_abs
    mov al, '-'         ; print '-'
    mov ah, 07h
    stosw
    neg ax
.vpn_abs:
    ; zero case
    cmp ax, 0
    jne .vpn_conv
    mov al, '0'
    mov ah, 07h
    stosw
    jmp .vpn_done

; convert positive number: push remainders
.vpn_conv:
    xor cx, cx
    mov bx, 10
.vpn_div:
    xor dx, dx
    div bx              ; AX = AX / 10, DX = remainder
    push dx             ; save remainder (low byte used later)
    inc cx
    test ax, ax
    jnz .vpn_div

; pop remainders and print digits
.vpn_out:
    pop dx              ; get remainder
    add dl, '0'
    mov al, dl
    mov ah, 07h
    stosw
    loop .vpn_out

.vpn_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---------------------------------------------------------
; vid_newline
;   Advance DI to the start of the next text row.
;   Each row is 80 columns × 2 bytes = 160 bytes.
;   Compute remainder = DI mod 160, then add (160 - remainder).
; ---------------------------------------------------------
vid_newline:
    push ax
    push bx
    push dx

    mov ax, di          ; dividend = DI (byte offset)
    mov bx, 160         ; 160 bytes per row
    xor dx, dx
    div bx              ; AX = quotient, DX = remainder

    mov ax, 160
    sub ax, dx          ; AX = 160 - remainder
    add di, ax          ; DI = DI + (160 - remainder)

    pop dx
    pop bx
    pop ax
    ret
