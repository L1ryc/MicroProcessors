org 100h
jmp start

row   db 0
prow  db 0
pcol  db 79
txt   db 'CYRIL'
len   db 5
attr  db 1Eh

start:
    push cs
    pop  ds
    mov ax,0B800h
    mov es,ax

    mov bl,75
    mov [row],24 ; 24 or 0row

    mov dl,bl
    mov dh,[row]
    call display

    mov [pcol],bl
    mov [prow],dh

    mov cx,24

main_loop:
    mov dl,[pcol]
    mov dh,[prow]
    call clear

    sub bl, 3
    dec [row] ;dec or inc

    mov dl,bl
    mov dh,[row]
    call display

    mov [pcol],bl
    mov [prow],dh

    loop main_loop
ret

; DI = row*160 + col*2  (DH=row, DL=col)
pos_to_offset:
    xor ax,ax
    mov al,dh
    mov di,ax
    shl ax,7
    shl di,5
    add ax,di
    mov di,ax
    xor ax,ax
    mov al,dl
    shl ax,1
    add di,ax
    ret

display:
    push si
    push ax
    push cx
    push di
    call pos_to_offset
    mov si, offset txt
    mov cl, [len]
    mov ah, [attr]
d1:
    lodsb
    mov es:[di], al
    mov es:[di+1], ah
    add di, 2
    loop d1
    pop di
    pop cx
    pop ax
    pop si
    ret

clear:
    push cx
    push di
    call pos_to_offset
    mov cl, [len]
c1:
    mov byte es:[di], ' '
    mov byte es:[di+1], 07h
    add di, 2
    loop c1
    pop di
    pop cx
    ret