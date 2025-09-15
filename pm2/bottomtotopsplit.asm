org 100h

jmp start


ATTR        db  0Fh              
CENTER_COL  equ 40              
COLS        equ 80
ROWS        equ 25
MAXLEN      equ 31              


PROMPT      db 'Enter text: ',0
ERRMSG      db 'Length must be ODD',0

InBufMax    db MAXLEN
InBufLen    db 0
InBufData   db MAXLEN dup(0)


STR         db MAXLEN dup(0)
LEN         db 0
MID         db 0


CURROW      db 0
STARTCOL    db 0
LCOL        db 0
RCOL        db 0
RTARGET     db 0


start:                
    push cs
    pop  ds
    mov  ax, 0B800h
    mov  es, ax

    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

input_loop:

    mov al, 0
    mov dl, 0
    call SETDI
    lea si, PROMPT
    call PRINT_Z


    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 12
    int 10h


    mov dx, offset InBufMax
    mov ah, 0Ah
    int 21h

    ; AL = length
    mov al, [InBufLen]
    cmp al, 0
    je  bad_input
    test al, 1
    jz  bad_input
    
    mov [LEN], al
    mov cl, al
    xor ch, ch
    lea si, InBufData
    lea di, STR
    push es
    push ds
    pop  es
    rep movsb
    pop  es

    xor bh, bh
    mov bl, [LEN]
    mov byte [STR+bx], 0


    mov al, [LEN]
    mov ah, 0
    shr al, 1
    mov [MID], al

    mov al, CENTER_COL
    sub al, [MID]
    mov [STARTCOL], al

    mov al, COLS
    sub al, [MID]
    mov [RTARGET], al

    mov al, 0
    mov dl, 0
    call ERASE_LINE
    mov al, 1
    mov dl, 0
    call ERASE_LINE

    xor cx, cx

    jmp animate

bad_input:

    mov al, 1
    mov dl, 0
    call SETDI
    lea si, ERRMSG
    call PRINT_Z
    jmp input_loop

animate:
    mov [CURROW], 24
    mov al, [CURROW]
    mov dl, [STARTCOL]
    lea si, STR
    mov cl, [LEN]
    call DRAW_SEG

move_up_full:
    cmp [CURROW], 0
    je  at_top
    mov al, [CURROW]
    mov dl, [STARTCOL]
    mov cl, [LEN]
    call ERASE_SEG
    dec [CURROW]
    mov al, [CURROW]
    mov dl, [STARTCOL]
    lea si, STR
    mov cl, [LEN]
    call DRAW_SEG
    jmp move_up_full

at_top:
    mov al, 0
    mov dl, [STARTCOL]
    mov cl, [LEN]
    call ERASE_SEG

    
    mov al, [STARTCOL]
    mov [LCOL], al
    mov al, CENTER_COL
    inc al
    mov [RCOL], al

  
    mov al, 0
    mov dl, [LCOL]
    lea si, STR
    mov cl, [MID]
    call DRAW_SEG
    
    mov al, 0
    call DRAW_MID
    
    mov al, 0
    mov dl, [RCOL]
    lea si, STR
    xor bh, bh
    mov bl, [MID]
    inc bl
    add si, bx
    mov cl, [MID]
    call DRAW_SEG

move_outward:
    
    mov al, [LCOL]
    cmp al, 0
    jne do_left_out
skip_left_out:
    jmp check_right_out
do_left_out:

    mov al, 0
    mov dl, [LCOL]
    mov cl, [MID]
    call ERASE_SEG

    dec [LCOL]

    mov al, 0
    mov dl, [LCOL]
    lea si, STR
    mov cl, [MID]
    call DRAW_SEG

check_right_out:
    mov al, [RCOL]
    cmp al, [RTARGET]
    jae after_out_step

    mov al, 0
    mov dl, [RCOL]
    mov cl, [MID]
    call ERASE_SEG

    inc [RCOL]

    mov al, 0
    mov dl, [RCOL]
    lea si, STR
    xor bh, bh
    mov bl, [MID]
    inc bl
    add si, bx
    mov cl, [MID]
    call DRAW_SEG

after_out_step:

    mov al, [LCOL]
    cmp al, 0
    jne move_outward
    mov al, [RCOL]
    cmp al, [RTARGET]
    jb  move_outward


    mov [CURROW], 0

move_down_three:
    cmp [CURROW], 24
    je  at_bottom_three

    mov al, [CURROW]
    mov dl, [LCOL]
    mov cl, [MID]
    call ERASE_SEG

    mov al, [CURROW]
    call ERASE_MID

    mov al, [CURROW]
    mov dl, [RCOL]
    mov cl, [MID]
    call ERASE_SEG


    inc [CURROW]

    mov al, [CURROW]
    mov dl, [LCOL]
    mov cl, [MID]
    lea si, STR
    call DRAW_SEG

    mov al, [CURROW]
    call DRAW_MID

    mov al, [CURROW]
    mov dl, [RCOL]
    mov cl, [MID]
    lea si, STR
    xor bh, bh
    mov bl, [MID]
    inc bl
    add si, bx
    call DRAW_SEG
    jmp move_down_three

at_bottom_three:
   
merge_horiz:

    mov al, [LCOL]
    cmp al, [STARTCOL]
    jb  do_left_merge
skip_left_merge:
    jmp check_right_merge
do_left_merge:

    mov al, 24
    mov dl, [LCOL]
    mov cl, [MID]
    call ERASE_SEG

    inc [LCOL]

    mov al, 24
    mov dl, [LCOL]
    lea si, STR
    mov cl, [MID]
    call DRAW_SEG

check_right_merge:
    mov al, [RCOL]
    mov bl, CENTER_COL
    inc bl
    cmp al, bl
    ja  do_right_merge
skip_right_merge:
    jmp after_merge_step
do_right_merge:

    mov al, 24
    mov dl, [RCOL]
    mov cl, [MID]
    call ERASE_SEG

    dec [RCOL]
    mov al, 24
    mov dl, [RCOL]
    lea si, STR
    xor bh, bh
    mov bl, [MID]
    inc bl
    add si, bx
    mov cl, [MID]
    call DRAW_SEG

after_merge_step:

    mov al, [LCOL]
    cmp al, [STARTCOL]
    jne merge_horiz
    mov al, [RCOL]
    mov bl, CENTER_COL
    inc bl
    cmp al, bl
    jne merge_horiz

    mov al, 24
    mov dl, [LCOL]
    mov cl, [MID]
    call ERASE_SEG
    mov al, 24
    call ERASE_MID
    mov al, 24
    mov dl, [RCOL]
    mov cl, [MID]
    call ERASE_SEG

    mov al, 24
    mov dl, [STARTCOL]
    lea si, STR
    mov cl, [LEN]
    call DRAW_SEG
    mov [CURROW], 24

move_up_to_center:
    cmp [CURROW], 12
    je  done
    mov al, [CURROW]
    mov dl, [STARTCOL]
    mov cl, [LEN]
    call ERASE_SEG
    dec [CURROW]
    mov al, [CURROW]
    mov dl, [STARTCOL]
    lea si, STR
    mov cl, [LEN]
    call DRAW_SEG
    jmp move_up_to_center

done:
    mov ax, 4C00h
    int 21h


SETDI:
    push ax
    push bx
    push dx
    xor ah, ah
    mov bl, 80
    mul bl           
    xor dh, dh
    add ax, dx       
    shl ax, 1
    mov di, ax
    pop dx
    pop bx
    pop ax
    ret


PRINT_Z:
    push ax
pz_lp:
    lodsb
    cmp al, 0
    je  pz_dn
    mov es:[di], al
    mov al, [ATTR]
    mov es:[di+1], al
    add di, 2
    jmp pz_lp
pz_dn:
    pop ax
    ret


DRAW_SEG:
    push ax
    push bx
    push cx
    push dx
    push si
    xor ch, ch
    call SETDI
    cmp cx, 0
    je  ds_done

    mov ah, [ATTR]
    cld
ds_loop:
    lodsb              
    stosw              
    loop ds_loop
ds_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

ERASE_SEG:
    push ax
    push bx
    push cx
    push dx
    xor ch, ch
    call SETDI
    cmp cx, 0
    je  es_done
    mov al, ' '
    mov ah, [ATTR]
    cld
    rep stosw
es_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

DRAW_MID:
    push ax
    push bx
    push dx
    mov dl, CENTER_COL
    call SETDI
    xor bh, bh
    mov bl, [MID]
    mov al, [STR+bx]
    mov es:[di], al
    mov al, [ATTR]
    mov es:[di+1], al
    pop dx
    pop bx
    pop ax
    ret

ERASE_MID:
    push ax
    push dx
    mov dl, CENTER_COL
    call SETDI
    mov al, ' '
    mov es:[di], al
    mov al, [ATTR]
    mov es:[di+1], al
    pop dx
    pop ax
    ret

ERASE_LINE:
    push ax
    push cx
    push dx
    mov cl, COLS
    sub cl, dl
    call ERASE_SEG
    pop dx
    pop cx
    pop ax
    ret
    pop ax
    ret
    pop ax
    ret