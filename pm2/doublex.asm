ORG 100h

START:
    MOV AX, 0B800h       ; Set video memory segment
    MOV ES, AX           ; ES points to video memory

    MOV AH, 1Eh          ; Yellow text on blue background
    MOV AL, 'X'          ; Character to draw

    ; -------------------------------
    ; Diagonal from Top-Left to Bottom-Right
    ; -------------------------------
    MOV DI, 0            ; Start at top-left (0,0)
    MOV CX, 25           ; 25 rows to cover
DIAGONAL_TL_BR:
    MOV ES:[DI], AX      ; Draw 'X'
    ADD DI, 162          ; Move down 1 row and right 1 column (160 + 2)
    LOOP DIAGONAL_TL_BR

    ; -------------------------------
    ; Diagonal from Top-Right to Bottom-Left
    ; -------------------------------
    MOV DI, 158          ; Start at top-right (0,79)
    MOV CX, 25           ; 25 rows to cover
DIAGONAL_TR_BL:
    MOV ES:[DI], AX      ; Draw 'X'
    ADD DI, 158          ; Move down 1 row and left 1 column (160 - 2)
    LOOP DIAGONAL_TR_BL

    ; -------------------------------
    ; Diagonal from Bottom-Left to Top-Right
    ; -------------------------------
    MOV DI, 3840         ; Start at bottom-left (24,0)
    MOV CX, 25           ; 25 rows to cover
DIAGONAL_BL_TR:
    MOV ES:[DI], AX      ; Draw 'X'
    SUB DI, 158          ; Move up 1 row and right 1 column (160 - 2)
    LOOP DIAGONAL_BL_TR

    ; -------------------------------
    ; Diagonal from Bottom-Right to Top-Left
    ; -------------------------------
    MOV DI, 3998         ; Start at bottom-right (24,79) = 3840 + 158
    MOV CX, 25           ; 25 rows to cover
DIAGONAL_BR_TL:
    MOV ES:[DI], AX      ; Draw 'X'
    SUB DI, 162          ; Move up 1 row and left 1 column (160 + 2)
    LOOP DIAGONAL_BR_TL

RET