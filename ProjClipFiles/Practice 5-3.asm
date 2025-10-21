



DATA SEGMENT
   PORTA EQU 0F0H
   PORTB EQU 0F2H
   PORTC EQU 0F4H
   COMREG EQU 0F6H
   DIGITS DB 00111111B, 00000110B, 01011011B, 01001111B
            DB 01100110B, 01101101B, 01111101B, 00000111B
            DB 01111111B, 01101111B
DATA ENDS

CODE SEGMENT 
   ASSUME CS:CODE, DS:DATA

   org 0000h

START:
   mov ax, data
   mov ds, ax
   
   ;config command register
   mov dx, COMREG
   mov al, 89h
   out dx, al
   
reset_count:
   ;reset to 0 ang 7seg
   mov dx, PORTA
   mov al, 00111111b
   out dx, al
   
   mov dx, PORTB
   mov al, 00111111b
   out dx, al
   
   xor cx, cx
   
huwat_press:
   mov dx, PORTC
   in al, dx
   cmp al, 01h
   jne huwat_press
   
   call pause
   call pause
   
   cmp cx, 0909h ;naka abot nag 99?
   je reset_count
   
   cmp cl, 09
   jne inc_units
   jmp inc_tens
   
inc_units:
   inc cl
   mov bl, cl
   mov dx, PORTA
   mov al, DIGITS[bx]
   out dx, al
   jmp huwat_press
   
inc_tens:
   xor cl, cl
   mov dx, PORTA
   mov al, DIGITS[0] ; 7seg 0
   out dx, al
   
   inc ch
   mov bl, ch
   mov dx, PORTB
   mov al, DIGITS[bx]
   out dx, al
   jmp huwat_press
   
   
pause proc
   mov bx, 1be4h
delay:
   dec bx
   nop
   jnz delay
   ret
pause endp
   
code ends

end start

   
   
   CODE ENDS