org 100h
begin:
    ; Set DS to video memory (0B800h)
    mov ax, 0B800h
    mov ds, ax
    ; Set attribute (bright yellow on black)
    mov dh, 1010b
    ; =====================================================
    ; 1) Start at top-left corner: (row=0, col=0)
    ; =====================================================
    mov di, (0*80 + 0)*2
    call display_text
    ; =====================================================
    ; 2) Move right along top edge to top-right (77 cols)
    ; =====================================================
    mov cx, 75
top_right_loop:
    call clear_text
    inc di
    inc di
    call display_text
    loop top_right_loop
    ; At (row 0, col 77)
    ; =====================================================
    ; 3) Move down right edge to bottom-right (24 rows)
    ; =====================================================
    mov cx, 24
right_down_loop:
    call clear_text
    add di, 160
    call display_text
    loop right_down_loop
    ; At (row 24, col 77)
    ; =====================================================
    ; 4) Move left along bottom to bottom-left (77 cols)
    ; =====================================================
    mov cx, 75
bottom_left_loop:
    call clear_text
    sub di, 2
    call display_text
    loop bottom_left_loop
    ; At (row 24, col 0)
    ; =====================================================
    ; 5) Move up left edge to top-left (24 rows)
    ; =====================================================
    mov cx, 24
left_up_loop:
    call clear_text
    sub di, 160
    call display_text
    loop left_up_loop
    ; At (row 0, col 0)
    ; =====================================================
    ; 6) Move right to horizontal center (col 39, 39 steps)
    ; =====================================================
    mov cx, 39
center_horiz_loop:
    call clear_text
    add di, 2
    call display_text
    loop center_horiz_loop
    ; At (row 0, col 39)
    ; =====================================================
    ; 7) Move down to vertical center (row 12, 12 steps)
    ; =====================================================
    mov cx, 12
center_vert_loop:
    call clear_text
    add di, 160
    call display_text
    loop center_vert_loop
    ; At (row 12, col 39)
    ; =====================================================
    ; 8) Continue down to bottom center (12 more steps)
    ; =====================================================
    mov cx, 12
final_down_loop:
    call clear_text
    add di, 160
    call display_text
    loop final_down_loop
    ; Exit to DOS
    mov ax, 4C00h
    int 21h
; ==============================
; Display "Cyril" at DS:DI
; DL = char, DH = attribute
; ==============================
display_text:
    push ax
    push di
    mov dl, 'C'
    mov [di], dx
    add di, 2
    mov dl, 'y'
    mov [di], dx
    add di, 2
    mov dl, 'r'
    mov [di], dx
    add di, 2
    mov dl, 'i'
    mov [di], dx
    add di, 2
    mov dl, 'l'
    mov [di], dx
    pop di
    pop ax
    ret
; ==============================
; Clear 5 cells at DS:DI with spaces
; ==============================
clear_text:
    push ax
    push di
    mov dl, ' '
    mov [di], dx
    add di, 2
    mov [di], dx
    add di, 2
    mov [di], dx
    add di, 2
    mov [di], dx
    add di, 2
    mov [di], dx
    pop di
    pop ax
    ret