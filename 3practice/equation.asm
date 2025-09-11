org 100h
jmp start

; Data
msg1 db 0Dh,0Ah,"Result C = ",0
msg2 db 0Dh,0Ah,"Result X = ",0
temp1 dw 0
temp2 dw 0
temp3 dw 0
Cres dw 0
temp4 dw 0
Xres dw 0

start:
    
    mov ax, 0B800h
    mov es, ax
    
    ; A=9, B=3, D=3, E=4
    ; Y=200, Z=5, W=10
    mov ax, 9    ; A
    mov bx, 3    ; B
    mov dx, 3    ; D
    mov si, 4    ; E
    mov di, 200  ; Y
    mov bp, 5    ; Z
    mov sp, 10   ; W
    ; Equation 1: C = ((B*D) + (A/B) - (A - B + E))
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
    ; Equation 2: X = (Y + Z*W) / 100
    mov ax, bp
    imul sp
    mov temp4, ax
    mov ax, di
    add ax, temp4
    mov bx, 100
    cwd
    idiv bx
    mov Xres, ax
   
   
    mov di, 0         
    mov si, offset msg1
    call print_text
    mov ax, Cres
    call print_num    
    mov di, 160       
    mov si, offset msg2
    call print_text
    mov ax, Xres
    call print_num    

    
    hlt


print_text:
pt_loop:
    mov al, [si]
    cmp al, 0
    je pt_done
    mov es:[di], al
    mov es:[di+1], 1010b ; yellow on blue
    add di, 2
    inc si
    jmp pt_loop
pt_done:
    ret

; Procedure: print_num (AX = number, DI = screen position)
print_num:
    push ax
    push bx
    push cx
    push dx
    push di           
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
    pop ax            
    add al, '0'       
    mov es:[di], al  
    mov es:[di+1], 1010b 
    add di, 2         
    loop pn_print
    pop di           
    pop dx
    pop cx
    pop bx
    pop ax
    ret
