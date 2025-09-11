org 100h

.data
msg1 db 0Dh,0Ah,"Result C = $"
msg2 db 0Dh,0Ah,"Result X = $"

temp1 dw 0
temp2 dw 0
temp3 dw 0
Cres  dw 0
temp4 dw 0
Xres  dw 0

.code
start:
    mov ax, @data
    mov ds, ax

    ; -------------------------
    ; Initial values
    ; A=9, B=3, D=3, E=4
    ; Y=200, Z=5, W=10
    ; -------------------------
    mov ax, 9      ; A
    mov bx, 3      ; B
    mov dx, 3      ; D
    mov si, 4      ; E

    mov di, 200    ; Y
    mov bp, 5      ; Z
    mov sp, 10     ; W

    ; -------------------------
    ; Equation 1: C = ((B*D) + (A/B) - (A - B + E))
    ; -------------------------

    ; temp1 = B * D
    mov ax, bx
    imul dx
    mov temp1, ax

    ; temp2 = A / B
    mov ax, 9
    cwd
    idiv bx
    mov temp2, ax

    ; temp3 = (A - B + E)
    mov ax, 9
    sub ax, bx
    add ax, si
    mov temp3, ax

    ; C = (temp1 + temp2) - temp3
    mov ax, temp1
    add ax, temp2
    sub ax, temp3
    mov Cres, ax

    ; -------------------------
    ; Equation 2: X = (Y + Z*W) / 100
    ; -------------------------
    mov ax, bp
    imul sp
    mov temp4, ax

    mov ax, di
    add ax, temp4
    mov bx, 100
    cwd
    idiv bx
    mov Xres, ax

    ; -------------------------
    ; Print results
    ; -------------------------
    mov ah, 09h
    mov dx, offset msg1
    int 21h
    mov ax, Cres
    call print_num

    mov ah, 09h
    mov dx, offset msg2
    int 21h
    mov ax, Xres
    call print_num

    ; Exit
    mov ah, 4Ch
    int 21h

; -------------------------
; Procedure: print_num (AX = number)
; -------------------------
print_num:
    push ax
    push bx
    push cx
    push dx

    mov cx, 0
    mov bx, 10
pn_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz pn_loop

pn_print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_print

    pop dx
    pop cx
    pop bx
    pop ax
    ret

end start