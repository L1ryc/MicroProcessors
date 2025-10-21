; Cyril John Christian A. Calo
; Calculator Simulation using 8255

data segment
   PORTA   equ 0F0h
   PORTB   equ 0F2h
   PORTC   equ 0F4h
   COMREG  equ 0F6h

   ONES     db 0
   TENS     db 0
   OPERAND1 db 0
   OPERAND2 db 0
data ends

code segment para 'code'
assume cs:code, ds:data

start:
   mov ax, data
   mov ds, ax

   ; Initialize 8255: PortA=out, PortB=out, PortC=in
   mov dx, COMREG
   mov al, 8Bh
   out dx, al

   ; Start at 00
   mov ONES, 0
   mov TENS, 0
   call show2digits

MAIN:
   ; Read mode from PortC
   mov dx, PORTC
   in al, dx

   ; Reset if all switches off
   test al, al
   jz RESET

   ; If more than one switch is on ? invalid
   mov bl, al
   dec bl
   and bl, al
   jnz RESET

   ; Exactly one switch is on
   test al, 0001b
   jnz ADDITION

   test al, 0010b
   jnz SUBTRACTION

   test al, 0100b
   jnz MULTI

   test al, 1000b
   jnz DIVISION

   jmp MAIN

; ----------------------------
; Read operands from PortB
; Lower nibble = OPERAND1
; Upper nibble = OPERAND2
; ----------------------------
read_operands:
   push dx
   push ax

   mov dx, PORTB
   in al, dx
   mov bl, al        ; save original input

   and al, 0Fh
   mov byte ptr OPERAND1, al

   mov al, bl
   mov cl, 4
   shr al, cl
   and al, 0Fh
   mov byte ptr OPERAND2, al

   pop ax
   pop dx
   ret

; ----------------------------
; Addition
; ----------------------------
ADDITION:
   call read_operands
   mov al, OPERAND1
   add al, OPERAND2
   call split
   call show2digits
   jmp MAIN

; ----------------------------
; Subtraction
; ----------------------------
SUBTRACTION:
   call read_operands
   mov al, OPERAND1
   sub al, OPERAND2
   jnc sub_ok
   mov byte ptr TENS, 0Ah     ; error code
   mov byte ptr ONES, 0Ah
   call show2digits
   jmp MAIN
sub_ok:
   call split
   call show2digits
   jmp MAIN

; ----------------------------
; Multiplication
; ----------------------------
MULTI:
   call read_operands
   mov al, OPERAND1
   mov bl, OPERAND2
   mul bl            ; AX = AL * BL
   ; AL now holds result (0–255)
   call split
   call show2digits
   jmp MAIN

; ----------------------------
; Division
; ----------------------------
DIVISION:
   call read_operands
   mov al, OPERAND1
   mov ah, 0
   mov bl, OPERAND2
   cmp bl, 0
   je div_zero
   div bl            ; AL = quotient, AH = remainder
   jmp div_cont
div_zero:
   xor al, al
div_cont:
   call split
   call show2digits
   jmp MAIN

; ----------------------------
; Split AL into TENS and ONES
; ----------------------------
split:
   cmp al, 99
   jbe split_ok
   ; overflow >99
   mov byte ptr TENS, 0Bh
   mov byte ptr ONES, 0Bh
   ret
split_ok:
   mov ah, 0
   mov bl, 10
   div bl            ; AL=quotient (tens), AH=remainder (ones)
   mov byte ptr TENS, al
   mov byte ptr ONES, ah
   ret

; ----------------------------
; Show 2 digits on PortA
; Upper nibble = TENS
; Lower nibble = ONES
; ----------------------------
show2digits:
   push ax
   push dx

   mov al, TENS
   mov cl, 4
   shl al, cl
   or al, ONES

   mov dx, PORTA
   out dx, al

   pop dx
   pop ax
   ret

; ----------------------------
; Reset state
; ----------------------------
RESET:
   mov byte ptr ONES, 0
   mov byte ptr TENS, 0
   call show2digits
   jmp MAIN

code ends
end start
