name "add-sub"

org 100h

mov al, 5
mov bl, 10

add bl, al ; 0101 + 1010 = 1111

sub bl, 1 ; 1111 - 0001 = 1110

mov cx, 8

print:
mov ah, 2
mov dl, '0'
test bl, 10000000b ; test first bit
jz zero
mov dl, '1'

zero: 
int 21h
shl bl, 1

loop print

; print binary suffix
mov dl, 'b'
int 21h

; wait for any key press
mov ah, 0 
int 16h

ret