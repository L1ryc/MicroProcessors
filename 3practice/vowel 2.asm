org 100h

start:
    ; Set ES to video memory
    mov ax, 0B800h
    mov es, ax

    ; Start at top-left
    mov di, 0

    ; Print label and string
    mov si, offset label_text
    call print_text

    mov si, offset stored_str
    call print_text

    ; Reset DI for second line
    mov di, 160

    ; Count vowels in stored_str
    mov cx, 0                  ; CX = vowel counter
    mov si, offset stored_str

count_chars:
    mov al, [si]
    cmp al, 0
    je counting_done
    call check_vowel
    inc si
    jmp count_chars

counting_done:
    ; Print "String contains "
    mov si, offset result_text
    call print_text

    ; Convert count to ASCII and print
    mov ax, cx
    add al, '0'
    mov count_char, al
    mov si, offset count_char
    call print_text

    ; Print " Vowels!"
    mov si, offset end_text
    call print_text

    hlt

; --------------------------
; Routine: check_vowel
; In: AL = character
; Out: increments CX if vowel
; --------------------------
check_vowel:
    cmp al, 'a'
    je is_vowel
    cmp al, 'e'
    je is_vowel
    cmp al, 'i'
    je is_vowel
    cmp al, 'o'
    je is_vowel
    cmp al, 'u'
    je is_vowel
    ret
is_vowel:
    inc cx
    ret

; --------------------------
; Routine: print_text
; Prints null-terminated string at ES:DI
; --------------------------
print_text:
pt_loop:
    mov al, [si]
    cmp al, 0
    je pt_done
    mov es:[di], al
    mov es:[di+1], 1Eh   ; yellow on blue
    add di, 2
    inc si
    jmp pt_loop
pt_done:
    ret

; --------------------------
; Data
; --------------------------
label_text  db "Stored String: ",0
stored_str  db "hello kababayan",0
result_text db "String contains ",0
count_char  db ?,0
end_text    db " Vowels!",0
