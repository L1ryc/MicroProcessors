org 100h
JMP _START
SOURCE1 DW 1234H
SOURCE2 DW 5678H
DEST1   DW 0000H
DEST2   DW 0000H
_START:
    MOV AX, 1234H
    MOV CX, 5678H
    MOV SOURCE1, AX
    MOV SOURCE2, CX
    MOV BX, OFFSET SOURCE1      ; Base for source
    MOV BP, OFFSET DEST1        ; Base for destination
    MOV DI, 0000H               ; Index
    MOV DX, [BX + DI + 0000H]   ; Load SOURCE1
    MOV [BP + DI + 0000H], DX   ; Store to DEST1
    MOV DI, 0002H               ; Next word
    MOV DX, [BX + DI + 0000H]   ; Load SOURCE2
    MOV [BP + DI + 0000H], DX   ; Store to DEST2
RET
