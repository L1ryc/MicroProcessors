; ==========================================
; HEX (1-2 digits) -> Binary (two nibbles) & Octal
; Direct video memory output version (EMU8086)
; ==========================================

org 100h
    jmp start

; ---------- DATA ----------
prompt      db 'Enter hex (00-FF): ',0
nl          db 0
msg_bin     db 'Binary : ',0
msg_oct     db 'Octal  : ',0

value       db 0
digits      db 0

bin4_tbl    db '0000','0001','0010','0011'
            db '0100','0101','0110','0111'
            db '1000','1001','1010','1011'
            db '1100','1101','1110','1111'

; ---------- CODE ----------
start:
    ; set DS = CS
    push cs
    pop  ds

    ; set ES to video memory segment
    mov ax, 0B800h
    mov es, ax
    xor di, di          ; start at top-left

    ; show prompt
    mov si, offset prompt
    call PRINT_STR

    ; reset vars
    mov [digits], 0
    mov [value],  0

    ; read first char
    mov ah, 1
    int 21h
    cmp al, 0Dh
    je done_input
    call HEX_TO_NIBBLE
    jnc done_input
    mov bl, al
    mov [digits], 1

    ; read second char
    mov ah, 1
    int 21h
    cmp al, 0Dh
    je one_digit
    call HEX_TO_NIBBLE
    jnc one_digit
    mov bh, bl
    shl bh, 4
    or  bh, al
    mov [value], bh
    mov [digits], 2
    jmp parsed

one_digit:
    mov [value], bl

parsed:
done_input:
    call NEWLINE
    mov si, offset msg_bin
    call PRINT_STR
    call PRINT_BIN_NIBBLES

    call NEWLINE
    mov si, offset msg_oct
    call PRINT_STR
    call PRINT_OCT

    call NEWLINE
    mov ax, 4C00h
    int 21h

; ---------- ROUTINES ----------

HEX_TO_NIBBLE:
    cmp al,'0'
    jb  HN_BAD
    cmp al,'9'
    jbe HN_09
    cmp al,'A'
    jb  HN_a_check
    cmp al,'F'
    jbe HN_AF
    cmp al,'a'
    jb  HN_BAD
    cmp al,'f'
    ja  HN_BAD
    sub al,87
    stc
    ret
HN_AF:
    sub al,55
    stc
    ret
HN_09:
    sub al,'0'
    stc
    ret
HN_a_check:
    cmp al,'a'
    jb  HN_BAD
    cmp al,'f'
    ja  HN_BAD
    sub al,87
    stc
    ret
HN_BAD:
    clc
    ret

PRINT_BIN_NIBBLES:
    mov al,[digits]
    cmp al,1
    jne two_digits

    ; one digit: print "0000"
    mov si, offset bin4_tbl
    call PRINT_4CHARS
    call PRINT_SPACE
    mov al,[value]
    and al,0Fh
    mov ah,0
    mov bx,ax
    shl bx,2
    mov si, offset bin4_tbl
    add si,bx
    call PRINT_4CHARS
    ret

two_digits:
    mov al,[value]
    mov ah,0
    shr al,4
    mov bx,ax
    shl bx,2
    mov si, offset bin4_tbl
    add si,bx
    call PRINT_4CHARS
    call PRINT_SPACE
    mov al,[value]
    and al,0Fh
    mov ah,0
    mov bx,ax
    shl bx,2
    mov si, offset bin4_tbl
    add si,bx
    call PRINT_4CHARS
    ret

PRINT_4CHARS:
    mov cx,4
.p4loop:
    lodsb
    call PRINT_CHAR
    loop .p4loop
    ret

PRINT_OCT:
    mov al,[value]
    xor ah,ah
    mov cx,0
    cmp ax,0
    jne .oct_loop
    mov al,'0'
    call PRINT_CHAR
    ret
.oct_loop:
    mov bl,8
    div bl
    add ah,'0'
    push ax
    inc cx
    mov ah,0
    cmp al,0
    jne .oct_loop
.oct_print:
    cmp cx,0
    je  oct_done
    pop ax
    mov al,ah
    call PRINT_CHAR
    dec cx
    jmp .oct_print
oct_done:
    ret

; ---------- VIDEO OUTPUT HELPERS ----------

PRINT_CHAR:             ; AL = char
    mov ah, 07h         ; attribute (light gray on black)
    stosw               ; store char+attr at ES:DI
    ret

PRINT_STR:              ; SI -> zero-terminated string
.next:
    lodsb
    cmp al,0
    je .done
    call PRINT_CHAR
    jmp .next
.done:
    ret

PRINT_SPACE:
    mov al,' '
    call PRINT_CHAR
    ret

NEWLINE:
    ; move DI to next line start
    mov ax, di
    mov bx, 160
    xor dx, dx
    div bx
    inc ax
    mul bx
    mov di, ax
    ret
