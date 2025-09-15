;Cyril John Christian A. Calo
;le 3.1

ORG 100H
MOV AL, 0F0H
MOV BL, 20H
ADc Ax, Bx
MOV CL, AL
SbB CL, BL
ADC CL, BL

MUL BL
MUL CX
IMUL Bx
mov ax,bx
DIV dl