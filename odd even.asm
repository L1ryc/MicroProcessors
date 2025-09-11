
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
       
       LEA DX, START_MESSAGE        
       MOV AH, 09h 
       INT 21h
               
               
               
               
               
       LEA SI, INPUT
       MOV AH, 01h
       
            GET_INPUT:
            
                INT 21h
                
                CMP AL, 0Dh         ; ENTER key
                JE CHECK_IF_ODD_EVEN 
                
                MOV [SI], AL
                INC SI
                JMP GET_INPUT 


      CHECK_IF_ODD_EVEN:
            
            MOV AX, [SI]
            
            INC SI
            MOV [SI], '$'
            
            LEA SI, INPUT
            
            REACH_END:
            
                CMP [SI], '$'
                JE GET_LSD
                
                INC SI
                JMP REACH_END
                
      GET_LSD:
      
            DEC SI
            MOV AL, [SI]     ; dividend
            
            CALL DIVIDE
            
            
      DIVIDE:
            
            MOV AX, [SI] 
            MOV BL, 2h       ; divisor 
            DIV BL  
                     
                     
            CMP AL, 00h
            JE PRINT_EVEN
            
            CALL PRINT_ODD
            
      
            
            
            
            
      PRINT_ODD:
      
            LEA DX, MESSAGE_ODD
            MOV AH, 09h
            INT 21h
            CALL EXIT
            
            
      
      
      PRINT_EVEN:
            
            LEA DX, MESSAGE_EVEN
            MOV AH, 09h
            INT 21h
            CALL EXIT
            
      
      
     
       EXIT:
       
        INT 20h
      
      
      
      
      
      

ret


START_MESSAGE   DB 0Dh, 0Ah, "Input a value : $"
                                              
MESSAGE_ODD     DB 0Dh, 0Ah, "The value is odd!$"                                              
MESSAGE_EVEN    DB 0Dh, 0Ah, "The value is even!$"

NEWLINE         DB 0Dh, 0Ah, "$"                                              
                                              
                                              
INPUT DB 255 DUP(?)
