org 100h
jmp start


prompt  db 'Enter amount (3 digits): $'
p100msg db 13,10,'P100: $'
p50msg  db 13,10,'P50 : $'
p20msg  db 13,10,'P20 : $'
p5msg   db 13,10,'P5  : $'
p1msg   db 13,10,'P1  : $'

amount   dw 0


start:
    ; set DS = CS
    push cs
    pop  ds

    ; prompt
    mov  dx, offset prompt
    mov  ah, 09h
    int  21h

    ; read number string
    mov  ah, 0Ah
    lea  dx, buffer
    int  21h

    ; convert ASCII input to number
    lea  si, buffer+2
    xor  ax, ax
    xor  bx, bx
    mov  cl, [buffer+1]   ; number of chars entered
conv_loop:
    cmp  cl, 0
    je   conv_done
    mov  bl, [si]
    sub  bl, '0'
    mov  bh, 0
    mov  dx, ax
    mov  ax, 10
    mul  dx          ; AX = old*10
    add  ax, bx
    inc  si
    dec  cl
    jmp  conv_loop
conv_done:
    mov  [amount], ax

    ; compute change
    mov  ax, [amount]

    ; ---------------- P100
    mov  bx, 100
    xor  dx, dx
    div  bx
    push dx           ; remainder
    mov  cx, ax       ; count
    lea  dx, p100msg
    call print_msg_num
    pop  ax

    ; ---------------- P50
    mov  bx, 50
    xor  dx, dx
    div  bx
    push dx
    mov  cx, ax
    lea  dx, p50msg
    call print_msg_num
    pop  ax

    ; ---------------- P20
    mov  bx, 20
    xor  dx, dx
    div  bx
    push dx
    mov  cx, ax
    lea  dx, p20msg
    call print_msg_num
    pop  ax

    ; ---------------- P5
    mov  bx, 5
    xor  dx, dx
    div  bx
    push dx
    mov  cx, ax
    lea  dx, p5msg
    call print_msg_num
    pop  ax

    ; ---------------- P1
    mov  bx, 1
    xor  dx, dx
    div  bx
    mov  cx, ax
    lea  dx, p1msg
    call print_msg_num

    ; exit
    mov  ax, 4C00h
    int  21h

; ----------------------------
; Helpers
; ----------------------------

; print_msg_num:
; DX -> message string (ending with $)
; CX = number to print
print_msg_num:
    push ax
    push bx
    push cx
    push dx
    mov  ah, 09h
    int  21h
    mov  ax, cx
    call print_number
    pop  dx
    pop  cx
    pop bx
    pop ax
    ret

; print_number: AX = number (0..65535)
print_number:
    push ax
    push bx
    push cx
    push dx

    mov  bx, 10
    xor  cx, cx
pn1:
    xor  dx, dx
    div  bx
    push dx
    inc  cx
    cmp  ax, 0
    jne  pn1

pn2:
    pop  dx
    add  dl, '0'
    mov  ah, 02h
    int  21h
    loop pn2

    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret

; ----------------------------
; DOS buffered input buffer
; ----------------------------
buffer db 5       ; max chars to read
       db 0       ; actual length
       db 5 dup(0)