;Cyril John Christian A. Calo

org 100h

    mov ax, 0B800h
    mov es, ax

   
    mov di, 0
    mov si, offset label_text  
    call print_text
    mov si, offset stored_str  
    call print_text

   
    mov si, offset stored_str  
    mov cx, 0
count_chars:
    mov al, [si]
    cmp al, 0
    je rotate_start
    inc cx
    inc si
    jmp count_chars

rotate_start:
    cmp cx, 0
    je end_program
    mov bx, cx         
    mov di, 160         

rotate_loop:
    push cx
    push bx
    push di

    
    mov si, offset stored_str  
    call print_text
    mov si, offset newline     
    call print_text

   
    mov si, offset stored_str
    mov dx, bx
    dec dx
    add si, dx          
    mov al, [si]        
    mov [temp_char], al

    
shift_right:
    cmp dx, 0
    je shift_done
    mov al, [si-1]
    mov [si], al
    dec si
    dec dx
    jmp shift_right

shift_done:
    mov al, [temp_char]
    mov si, offset stored_str
    mov [si], al      

    pop di
    add di, 160         
    pop bx
    pop cx
    loop rotate_loop

    ; Print final state
    mov si, offset stored_str  
    call print_text
    mov si, offset newline     
    call print_text

end_program:
    hlt


print_text:
pt_loop:
    mov al, [si]
    cmp al, 0
    je pt_done
    mov es:[di], al
    mov es:[di+1], 1010b 
    add di, 2
    inc si
    jmp pt_loop
pt_done:
    ret


label_text db "Stored String: ",0
stored_str db "Hello",0
newline db 0Dh, 0Ah,0
temp_char db 0
