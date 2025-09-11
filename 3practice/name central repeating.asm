org 100h
jmp start

myname db "Cyril John Christian",0
namelen equ $-myname
attr db 0x0f  

start:
push cs
pop ds
mov ax, 0b800h
mov es, ax


mov al, 80
sub al, namelen
shr al, 1
mov cl, al
xor ch, ch

mov dh,12

rowloop:
mov al, dh
xor ah, ah
mov bl, 80
mul bl
add ax,cx
shl ax,1
mov di, ax

mov si, offset myname

printnameloop:
mov al, [si]
cmp al, 0
je nextrow
mov es:[di],al  
mov al, [attr]
mov as:[di+1],al 
add di, 2
inc si
jmp printnameloop

nextrow:
inc dh
cmp dh, 25
jb rowloop  

hlt


