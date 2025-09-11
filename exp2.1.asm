
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

;INITIALIZE VALUES
MOV AX, 1234H
MOV BX, 5678H

;SUBSTITUTE RESPECTIVE VALUES
SUB BX, AX

ret




