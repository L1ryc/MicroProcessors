org 100h
jmp begin
; ----------------------------
; Configuration and Constants
; ----------------------------
TEXT_ATTR db 0Eh ; bright yellow on black
SCREEN_CENTER equ 40 ; middle column (0..79)
SCREEN_WIDTH equ 80
SCREEN_HEIGHT equ 25
MAX_INPUT equ 31 ; maximum input string length
; ----------------------------
; Prompt Messages
; ----------------------------
INPUT_PROMPT db 'Input odd-length text (<=31), press Enter:',0
ERROR_MSG db 'Text length must be odd and 1–31 chars. Retry.',0
; ----------------------------
; Input Buffer for DOS 0Ah
; ----------------------------
InputMax db MAX_INPUT
InputLen db 0
InputData db MAX_INPUT dup(0)
; ----------------------------
; String and Metadata
; ----------------------------
TextStr db MAX_INPUT dup(0)
TextLen db 0
TextMid db 0
; ----------------------------
; Animation Variables
; ----------------------------
CurrentRow db 0
StartColumn db 0
LeftColumn db 0
RightColumn db 0
RightTarget db 0
; ----------------------------
; Code Section
; ----------------------------
begin:
    ; Initialize DS and ES
    mov ax, cs
    mov ds, ax
    mov ax, 0B800h
    mov es, ax
    ; Clear screen using BIOS
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
input_cycle:
    ; Display prompt at row 1, col 12
    mov al, 1
    mov dl, 12
    call CalcScreenPos
    lea si, INPUT_PROMPT
    call PrintString
    ; Position cursor at row 2, col 12 for input
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 12
    int 10h
    ; Get buffered input
    mov dx, offset InputMax
    mov ah, 0Ah
    int 21h
    ; Validate input length
    mov al, [InputLen]
    cmp al, 0
    je invalid_input
    test al, 1
    jz invalid_input
    ; Copy input to TextStr
    mov [TextLen], al
    mov cl, al
    xor ch, ch
    lea si, InputData
    lea di, TextStr
    push es
    push ds
    pop es
    rep movsb
    pop es
    ; Null-terminate TextStr
    xor bh, bh
    mov bl, [TextLen]
    mov byte [TextStr+bx], 0
    ; Calculate TextMid = TextLen/2
    mov al, [TextLen]
    xor ah, ah
    shr al, 1
    mov [TextMid], al
    ; Compute StartColumn = SCREEN_CENTER - TextMid
    mov al, SCREEN_CENTER
    sub al, [TextMid]
    mov [StartColumn], al
    ; Compute RightTarget = SCREEN_WIDTH - TextMid
    mov al, SCREEN_WIDTH
    sub al, [TextMid]
    mov [RightTarget], al
    ; Clear error message line (row 3)
    mov al, 3
    mov dl, 0
    call ClearLine
    ; Clear prompt and input lines
    mov al, 1
    mov dl, 0
    call ClearLine
    mov al, 2
    mov dl, 0
    call ClearLine
    xor cx, cx
    jmp start_animation
invalid_input:
    ; Show error at row 3, col 12
    mov al, 3
    mov dl, 12
    call CalcScreenPos
    lea si, ERROR_MSG
    call PrintString
    jmp input_cycle
start_animation:
    ; Stage 1: Move full string up from row 24 to 0
    mov [CurrentRow], 24
    mov al, [CurrentRow]
    mov dl, [StartColumn]
    lea si, TextStr
    mov cl, [TextLen]
    call DrawText
move_up:
    cmp [CurrentRow], 0
    je reached_top
    ; Clear previous row
    mov al, [CurrentRow]
    mov dl, [StartColumn]
    mov cl, [TextLen]
    call ClearText
    ; Move up
    dec [CurrentRow]
    ; Draw new position
    mov al, [CurrentRow]
    mov dl, [StartColumn]
    lea si, TextStr
    mov cl, [TextLen]
    call DrawText
    jmp move_up
reached_top:
    ; Stage 2: Split string and move left/right parts outward
    mov al, 0
    mov dl, [StartColumn]
    mov cl, [TextLen]
    call ClearText
    ; Set initial left/right columns
    mov al, [StartColumn]
    mov [LeftColumn], al
    mov al, SCREEN_CENTER
    inc al
    mov [RightColumn], al
    ; Draw initial left/middle/right
    mov al, 0
    mov dl, [LeftColumn]
    lea si, TextStr
    mov cl, [TextMid]
    call DrawText
    mov al, 0
    call DrawMiddle
    mov al, 0
    mov dl, [RightColumn]
    lea si, TextStr
    xor bh, bh
    mov bl, [TextMid]
    inc bl
    add si, bx
    mov cl, [TextMid]
    call DrawText
move_sides:
    mov al, [LeftColumn]
    cmp al, 0
    jne shift_left
    jmp check_right
shift_left:
    mov al, 0
    mov dl, [LeftColumn]
    mov cl, [TextMid]
    call ClearText
    dec [LeftColumn]
    mov al, 0
    mov dl, [LeftColumn]
    lea si, TextStr
    mov cl, [TextMid]
    call DrawText
check_right:
    mov al, [RightColumn]
    cmp al, [RightTarget]
    jae sides_done
    mov al, 0
    mov dl, [RightColumn]
    mov cl, [TextMid]
    call ClearText
    inc [RightColumn]
    mov al, 0
    mov dl, [RightColumn]
    lea si, TextStr
    xor bh, bh
    mov bl, [TextMid]
    inc bl
    add si, bx
    mov cl, [TextMid]
    call DrawText
sides_done:
    mov al, [LeftColumn]
    cmp al, 0
    jne move_sides
    mov al, [RightColumn]
    cmp al, [RightTarget]
    jb move_sides
    ; Stage 3: Move left/middle/right down to row 24
    mov [CurrentRow], 0
move_down:
    cmp [CurrentRow], 24
    je bottom_reached
    mov al, [CurrentRow]
    mov dl, [LeftColumn]
    mov cl, [TextMid]
    call ClearText
    mov al, [CurrentRow]
    call ClearMiddle
    mov al, [CurrentRow]
    mov dl, [RightColumn]
    mov cl, [TextMid]
    call ClearText
    inc [CurrentRow]
    mov al, [CurrentRow]
    mov dl, [LeftColumn]
    lea si, TextStr
    mov cl, [TextMid]
    call DrawText
    mov al, [CurrentRow]
    call DrawMiddle
    mov al, [CurrentRow]
    mov dl, [RightColumn]
    lea si, TextStr
    xor bh, bh
    mov bl, [TextMid]
    inc bl
    add si, bx
    mov cl, [TextMid]
    call DrawText
    jmp move_down
bottom_reached:
    ; Stage 4: Merge left/right toward center at row 24
merge:
    mov al, [LeftColumn]
    cmp al, [StartColumn]
    jb merge_left
    jmp check_merge_right
merge_left:
    mov al, 24
    mov dl, [LeftColumn]
    mov cl, [TextMid]
    call ClearText
    inc [LeftColumn]
    mov al, 24
    mov dl, [LeftColumn]
    lea si, TextStr
    mov cl, [TextMid]
    call DrawText
check_merge_right:
    mov al, [RightColumn]
    mov bl, SCREEN_CENTER
    inc bl
    cmp al, bl
    ja merge_right
    jmp merge_done
merge_right:
    mov al, 24
    mov dl, [RightColumn]
    mov cl, [TextMid]
    call ClearText
    dec [RightColumn]
    mov al, 24
    mov dl, [RightColumn]
    lea si, TextStr
    xor bh, bh
    mov bl, [TextMid]
    inc bl
    add si, bx
    mov cl, [TextMid]
    call DrawText
merge_done:
    mov al, [LeftColumn]
    cmp al, [StartColumn]
    jne merge
    mov al, [RightColumn]
    mov bl, SCREEN_CENTER
    inc bl
    cmp al, bl
    jne merge
    ; Stage 5: Move full string up to row 12
    mov al, 24
    mov dl, [LeftColumn]
    mov cl, [TextMid]
    call ClearText
    mov al, 24
    call ClearMiddle
    mov al, 24
    mov dl, [RightColumn]
    mov cl, [TextMid]
    call ClearText
    mov al, 24
    mov dl, [StartColumn]
    lea si, TextStr
    mov cl, [TextLen]
    call DrawText
    mov [CurrentRow], 24
move_to_center:
    cmp [CurrentRow], 12
    je finish
    mov al, [CurrentRow]
    mov dl, [StartColumn]
    mov cl, [TextLen]
    call ClearText
    dec [CurrentRow]
    mov al, [CurrentRow]
    mov dl, [StartColumn]
    lea si, TextStr
    mov cl, [TextLen]
    call DrawText
    jmp move_to_center
finish:
    mov ax, 4C00h
    int 21h
; ----------------------------
; Helper Routines
; ----------------------------
; CalcScreenPos: AL=row, DL=col -> DI = ((row*80)+col)*2
CalcScreenPos:
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
; PrintString: Print zero-terminated string at ES:DI from DS:SI
PrintString:
    push ax
print_loop:
    lodsb
    cmp al, 0
    je print_done
    mov es:[di], al
    mov al, [TEXT_ATTR]
    mov es:[di+1], al
    add di, 2
    jmp print_loop
print_done:
    pop ax
    ret
; DrawText: Draw CX chars from DS:SI at row AL, col DL
DrawText:
    push ax
    push bx
    push cx
    push dx
    push si
    xor ch, ch
    call CalcScreenPos
    cmp cx, 0
    je draw_done
    mov ah, [TEXT_ATTR]
    cld
draw_loop:
    lodsb
    stosw
    loop draw_loop
draw_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; ClearText: Clear CX chars at row AL, col DL
ClearText:
    push ax
    push bx
    push cx
    push dx
    xor ch, ch
    call CalcScreenPos
    cmp cx, 0
    je clear_done
    mov al, ' '
    mov ah, [TEXT_ATTR]
    cld
    rep stosw
clear_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
; DrawMiddle: Draw TextStr[TextMid] at row AL, center col
DrawMiddle:
    push ax
    push bx
    push dx
    mov dl, SCREEN_CENTER
    call CalcScreenPos
    xor bh, bh
    mov bl, [TextMid]
    mov al, [TextStr+bx]
    mov es:[di], al
    mov al, [TEXT_ATTR]
    mov es:[di+1], al
    pop dx
    pop bx
    pop ax
    ret
; ClearMiddle: Clear 1 char at row AL, center col
ClearMiddle:
    push ax
    push dx
    mov dl, SCREEN_CENTER
    call CalcScreenPos
    mov al, ' '
    mov es:[di], al
    mov al, [TEXT_ATTR]
    mov es:[di+1], al
    pop dx
    pop ax
    ret
; ClearLine: Clear line from row AL, col DL to end
ClearLine:
    push ax
    push cx
    push dx
    mov cl, SCREEN_WIDTH
    sub cl, dl
    call ClearText
    pop dx
    pop cx
    pop ax
    ret
; Pause: Brief delay
Pause:
    push ax
    push bx
    push dx
    mov bx, 800h
pause_loop:
    mov dx, 80h
pause_inner:
    dec dx
    jnz pause_inner
    dec bx
    jnz pause_loop
    pop dx
    pop bx
    pop ax
    ret