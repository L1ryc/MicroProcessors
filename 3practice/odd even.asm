;Cyril John Christian A. Calo

org 100h

main:
    
    mov ax, 0b800h
    mov es, ax
    mov di, 0  ; start at top left

    ; print msg1
    mov si, offset msg1
    call print_string

    ; prepare and print digit
    mov al, num
    add al, '0'
    mov digit, al
    mov si, offset digit
    call print_string

    ; move to next line
    mov dx, 0
    mov ax, di
    mov bx, 160
    div bx
    mov bx, 160
    sub bx, dx
    add di, bx

    ; print msg2
    mov si, offset msg2
    call print_string

    ; check odd or even
    mov al, num
    test al, 1
    jz even_label
    mov si, offset msg_odd
    jmp print_next
even_label:
    mov si, offset msg_even
print_next:
    call print_string

    ; print msg3
    mov si, offset msg3
    call print_string 
    
    ; halt
    hlt

print_string:
print_loop:
    mov al, [si]
    cmp al, 0
    je done
    mov es:[di], al
    mov es:[di+1], 1010b
    add di, 2
    inc si
    jmp print_loop
done:
    ret


num db 6    ;interchangeable value
msg1 db "Stored value = ",0
digit db ?,0
msg2 db "The value is an ",0
msg_even db "even",0
msg_odd db "odd",0
msg3 db " number!",0  

end main   


