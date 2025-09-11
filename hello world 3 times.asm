org 100h



mov cx, 3 ;loop 3 times


abc:
mov ah, 09h
lea dx, msg
int 21h

loop abc

ret 

msg db "Hello$", 0