
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

xor ax, ax
mov cl, 05h
mov si, 00h

back:
add al, arr[si+0]
inc si
dec cl

jnz back
mov bl, 08h
not bl
neg bl
shl bl, 1
rcr bl, 2
div dl

ret

ARR DB 01H,02H,03H,04H,05H


