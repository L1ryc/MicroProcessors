;Cyril John Christian A. Calo

org 100h

start:
    
    mov ax, 0B800h
    mov es, ax
    mov di, 0          

    
    mov si, offset label_text
    call print_text

  
    mov si, offset my_string
    call print_text

    ; next line
    mov di, 160

  
    mov cx, 0          
    mov si, offset my_string

count_loop:
    mov al, [si]
    cmp al, 0
    je count_done

    cmp al, 'a'
    je inc_vowel
    cmp al, 'e'
    je inc_vowel
    cmp al, 'i'
    je inc_vowel
    cmp al, 'o'
    je inc_vowel
    cmp al, 'u'
    je inc_vowel 
    cmp al, 'A'
    je inc_vowel
    cmp al, 'E'
    je inc_vowel
    cmp al, 'I'
    je inc_vowel
    cmp al, 'O'
    je inc_vowel
    cmp al, 'U'
    je inc_vowel

    jmp next_char

inc_vowel:
    inc cx

next_char:
    inc si
    jmp count_loop

count_done:                    

    mov si, offset result_text
    call print_text

    
    mov ax, cx
    add al, '0'
    mov vowel_digit, al
    mov si, offset vowel_digit
    call print_text

    
    mov si, offset end_text
    call print_text

    hlt

print_text:
print_loop:
    mov al, [si]
    cmp al, 0
    je pt_done
    mov es:[di], al
    mov es:[di+1], 1010b
    add di, 2
    inc si
    jmp print_loop 
    
pt_done:
    ret

label_text  db "Stored string = ",0
my_string   db "cyril calo",0 ;interchangable string
result_text db "String contains ",0
vowel_digit db ?,0
end_text    db " vowels!",0
