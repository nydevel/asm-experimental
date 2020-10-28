org 0x7c00

;********************************************************************;
;*                         Banner on start                          *;
;********************************************************************;

mov si, message_banner
call print_message


;********************************************************************;
;*                            Main loop                             *;
;********************************************************************;

mainloop:
    ; Print promt mark
    mov si, promt
    call print_message

    mov di, buffer
    xor cl, cl  ;input characters counter
    call key_catch

    mov si, buffer
    xor al, al
    call password_hashing
    jc password_correct

    jmp mainloop

;********************************************************************;
;*                         Print message function                   *;
;********************************************************************;

print_message: 
    ; Load symbol to AL register
    lodsb
    
    ; Check if it is string end
    test al, al
    jz print_message_end
    
    ; Move char to print buffer
    mov ah, 0x0E
    int 10h
    
    ; Loop this shit
    jmp .done 
    
    ; Return from message printing    
    .done:
        ret  

;********************************************************************;
;*                         Catch entered keys                       *;
;********************************************************************;

key_catch:
    mov ah, 0
    int 16h

    ;If ENTER pressed
    cmp al, 0x0D
    je key_catch_end

    cmp cl, 0x3F  ; if 63 characters entered
    je key_catch
    
    ; Print character from al register on display
    mov ah, 0x0E
    int 10h
    
    stosb
    inc cl
    jmp key_catch       
   
key_catch_end:
    mov al, 0
    stosb

    mov ah, 0x0E    ; teletype mode
    mov al, 0x0D    ; enter character
    int 10h         ; call interruption

    mov al, 0x0A    ; new line character
    int 10h         ; call interruption

    ret

;********************************************************************;
;*                         Password validation                      *;
;********************************************************************;

password_correct:
    mov si, message_good
    call print_message

    jmp exit

password_wrong:
    clc
    mov si, message_wrong
    call print_message

    ret

;********************************************************************;
;*                         Password hashing/check                   *;
;********************************************************************;

password_hashing:
    add al, [si]
    mov bl, [si]

    cmp bl, 0
    je password_check

    inc si

    jmp password_hashing

password_check:
    ; Password is '111'
    cmp al, 0x93
    je password_eq

    jmp password_wrong

password_eq:
    stc
    ret    

;********************************************************************;
;*                         Exit from programm                       *;
;********************************************************************;

exit:
    ret

INT 19h        ; reboot

;********************************************************************;
;*                         Variables block                          *;
;********************************************************************;

message_banner db "Please, enter password for OS boot:", 0                                         
message_good db "Password is correct", 0x0D, 0x0A, 0
message_wrong db "Password not valid", 0x0D, 0x0A, 0
promt db ">>", 0

buffer rb 64

;********************************************************************;
;*                Filling empty space in 512 bytes                  *;
;********************************************************************;

; Fill empty space up to 512
db 510-($-$$) dup (0)
db 0x55, 0xAA
