org 100h
jmp start

bufmax      db 20
buflen      db 0
bufdata     db 20 dup(0)

prompt      db 'Enter ODD-length text (max 20): $'
badlen      db 0Dh,0Ah,'Length must be odd',0Dh,0Ah,'$'

space80     db 80 dup(' ')
attr        db 0Fh

str         db 20 dup(0)
len         db 0
mididx      db 0
centercol   db 0
midcol      db 0

leftlen     db 0
rightlen    db 0

leftpos     db 0
rightpos    db 0
lgoal       db 0
rgoal       db 0
rmax        db 0

cur_row     db 0
prev_row    db 0
bottom_row  db 24

start:
    push cs
    pop  ds

get_input:
    mov dx, offset prompt
    mov ah, 09h
    int 21h

    mov dx, offset bufmax
    mov ah, 0Ah
    int 21h

    mov al, buflen
    cmp al, 1
    jb bad_input
    cmp al, 20
    ja bad_input
    test al, 1
    jz bad_input

    mov [len], al
    push ds
    pop  es
    xor cx, cx
    mov cl, [len]
    mov si, offset bufdata
    mov di, offset str
    rep movsb
    jmp ok_input

bad_input:
    mov dx, offset badlen
    mov ah, 09h
    int 21h
    jmp get_input

ok_input:
    mov ax, 0600h
    mov bh, [attr]
    xor cx, cx
    mov dx, 184Fh
    int 10h

    mov al, [len]
    xor ah, ah
    mov bl, 2
    div bl
    mov [mididx], al

    xor bx, bx
    mov bl, [len]
    mov ax, 80
    sub ax, bx
    shr ax, 1
    mov [centercol], al

    mov al, [centercol]
    add al, [mididx]
    mov [midcol], al

    mov al, [mididx]
    mov [leftlen], al
    mov al, [len]
    sub al, [mididx]
    dec al
    mov [rightlen], al

    mov al, [centercol]
    mov [leftpos], al

    mov al, [midcol]
    inc al
    mov [rightpos], al

    mov al, 80
    sub al, [rightlen]
    mov [rmax], al

    mov al, 0
    mov [lgoal], al

    mov al, [centercol]
    add al, [mididx]
    inc al
    mov [rgoal], al

    mov al, 0
    mov [cur_row], al
    mov [prev_row], al

down_loop:
    mov dh, [prev_row]
    call clear_row

    mov dh, [cur_row]
    mov dl, [centercol]
    mov bl, [attr]
    xor ch, ch
    mov cl, [len]
    mov bp, offset str
    call draw_at

    mov al, [cur_row]
    cmp al, [bottom_row]
    je split_phase
    mov [prev_row], al
    mov al, [cur_row]
    inc al
    mov [cur_row], al
    jmp down_loop

split_phase:
split_loop:
    mov dh, [bottom_row]
    call clear_row

    mov dh, [bottom_row]
    mov dl, [leftpos]
    mov bl, [attr]
    xor ch, ch
    mov cl, [leftlen]
    cmp cl, 0
    je draw_mid_try
    mov bp, offset str
    call draw_at

draw_mid_try:
    mov al, [rightpos]
    cmp al, [rmax]
    je skip_mid
    mov dh, [bottom_row]
    mov dl, [midcol]
    mov bl, [attr]
    mov si, offset str
    mov al, [mididx]
    xor ah, ah
    add si, ax
    mov bp, si
    mov cx, 1
    call draw_at
skip_mid:

    mov dh, [bottom_row]
    mov dl, [rightpos]
    mov bl, [attr]
    mov si, offset str
    mov al, [mididx]
    xor ah, ah
    add si, ax
    inc si
    mov bp, si
    xor ch, ch
    mov cl, [rightlen]
    cmp cl, 0
    je after_draw_right
    call draw_at
after_draw_right:

    mov al, [leftpos]
    cmp al, [lgoal]
    je no_left_move
    mov al, [leftpos]
    dec al
    mov [leftpos], al
no_left_move:

    mov al, [rightpos]
    cmp al, [rmax]
    je no_right_move
    mov al, [rightpos]
    inc al
    mov [rightpos], al
no_right_move:

    mov al, [leftpos]
    cmp al, [lgoal]
    jne split_loop
    mov al, [rightpos]
    cmp al, [rmax]
    jne split_loop

    mov dh, [bottom_row]
    call clear_row
    mov al, [bottom_row]
    mov [prev_row], al
    mov [cur_row],  al
    jmp rise_loop


rise_loop:
    mov dh, [prev_row]
    call clear_row

    mov dh, [cur_row]
    mov dl, [leftpos]
    mov bl, [attr]
    xor ch, ch
    mov cl, [leftlen]
    cmp cl, 0
    je rise_draw_mid
    mov bp, offset str
    call draw_at
rise_draw_mid:
    mov dh, [cur_row]
    mov dl, [midcol]
    mov bl, [attr]
    mov si, offset str
    mov al, [mididx]
    xor ah, ah
    add si, ax
    mov bp, si
    mov cx, 1
    call draw_at
    mov dh, [cur_row]
    mov dl, [rightpos]
    mov bl, [attr]
    mov si, offset str
    mov al, [mididx]
    xor ah, ah
    add si, ax
    inc si
    mov bp, si
    xor ch, ch
    mov cl, [rightlen]
    cmp cl, 0
    je rise_after_draw
    call draw_at
rise_after_draw:

    mov al, [cur_row]
    cmp al, 0
    je merge_phase
    mov [prev_row], al
    mov al, [cur_row]
    dec al
    mov [cur_row], al
    jmp rise_loop

merge_phase:
merge_loop:
    mov dh, 0
    call clear_row

    mov dh, 0
    mov dl, [leftpos]
    mov bl, [attr]
    xor ch, ch
    mov cl, [leftlen]
    cmp cl, 0
    je merge_draw_mid
    mov bp, offset str
    call draw_at
merge_draw_mid:
    mov dh, 0
    mov dl, [midcol]
    mov bl, [attr]
    mov si, offset str
    mov al, [mididx]
    xor ah, ah
    add si, ax
    mov bp, si
    mov cx, 1
    call draw_at
    mov dh, 0
    mov dl, [rightpos]
    mov bl, [attr]
    mov si, offset str
    mov al, [mididx]
    xor ah, ah
    add si, ax
    inc si
    mov bp, si
    xor ch, ch
    mov cl, [rightlen]
    cmp cl, 0
    je after_merge_draw
    call draw_at
after_merge_draw:

    mov al, [leftpos]
    cmp al, [centercol]
    je no_left_in
    mov al, [leftpos]
    inc al
    mov [leftpos], al
no_left_in:

    mov al, [rightpos]
    cmp al, [rgoal]
    je no_right_in
    mov al, [rightpos]
    dec al
    mov [rightpos], al
no_right_in:

    mov al, [leftpos]
    cmp al, [centercol]
    jne merge_loop
    mov al, [rightpos]
    cmp al, [rgoal]
    jne merge_loop

    mov dh, 0
    call clear_row
    mov dh, 0
    mov dl, [centercol]
    mov bl, [attr]
    xor ch, ch
    mov cl, [len]
    mov bp, offset str
    call draw_at

    mov ax, 4C00h
    int 21h

clear_row:
    push ax
    push bx
    push cx
    push dx
    push bp
    push ds
    pop  es
    mov dl, 0
    mov ax, 1301h
    mov bh, 0
    mov bl, [attr]
    mov cx, 80
    lea bp, space80
    int 10h
    pop  bp
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret

draw_at:
    push ax
    push bx
    push cx
    push dx
    push bp
    push ds
    pop  es
    mov ax, 1301h
    mov bh, 0
    int 10h
    pop  bp
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret