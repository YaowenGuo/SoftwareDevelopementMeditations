SECTION .data           ; Section containing initialised data  
    EOL     equ 10      ; Linux end-of-line character  
    FILLCHR equ 32      ; Default to ASCII space character  
    CHRTROW equ 2       ; Chart begins 2 lines from top  
    CHRTLEN equ 32      ; Each chart line shows 32 chars  
; This escape sequence will clear the console terminal and place the  
; text cursor to the origin (1,1) on virtually all Linux consoles:  
    ClrHome db 27,"[2J",27,"[01;01H"  
    CLRLEN  equ $-ClrHome   ; Length of term clear string  
      
SECTION .bss            ; Section containing uninitialized data   
  
    COLS    equ 81      ; Line length + 1 char for EOL  
    ROWS    equ 25      ; Number of lines in display  
    VidBuff resb COLS*ROWS  ; Buffer size adapts to ROWS & COLS  
  
SECTION .text           ; Section containing code  
  
global  _start          ; Linker needs this to find the entry point!  
  
; This macro clears the Linux console terminal and sets the cursor position  
; to 1,1, using a single predefined escape sequence.  
%macro  ClearTerminal 0  
    pushad              ; Save all registers  
    mov eax,4           ; Specify sys_write call  
    mov ebx,1           ; Specify File Descriptor 1: Standard Output  
    mov ecx,ClrHome     ; Pass offset of the error message  
    mov edx,CLRLEN      ; Pass the length of the message  
    int 80H             ; Make kernel call  
    popad               ; Restore all registers  
%endmacro  
  
Show:   pushad              ; Save all registers  
    mov eax,4               ; Specify sys_write call  
    mov ebx,1               ; Specify File Descriptor 1: Standard Output  
    mov ecx,VidBuff         ; Pass offset of the buffer  
    mov edx,COLS*ROWS       ; Pass the length of the buffer  
    int 80H                 ; Make kernel call  
    popad                   ; Restore all registers  
    ret                     ; And go home!  
  
ClrVid: push eax            ; Save caller's registers  
    push ecx  
    push edi  
    cld                     ; Clear DF; we're counting up-memory  
    mov al,FILLCHR          ; Put the buffer filler char in AL  
    mov edi,VidBuff         ; Point destination index at buffer  
    mov ecx,COLS*ROWS       ; Put count of chars stored into ECX  
    rep stosb               ; Blast chars at the buffer  
; Buffer is cleared; now we need to re-insert the EOL char after each line:  
    mov edi,VidBuff         ; Point destination at buffer again  
    dec edi                 ; Start EOL position count at VidBuff char 0  
    mov ecx,ROWS            ; Put number of rows in count register  
PtEOL:  add edi,COLS        ; Add column count to EDU  
    mov byte [edi],EOL      ; Store EOL char at end of row  
    loop PtEOL              ; Loop back if still more lines  
    pop edi                 ; Restore caller's registers  
    pop ecx  
    pop eax  
    ret                     ; and go home!  
  
Ruler:  push eax            ; Save the registers we change  
    push ebx  
    push ecx  
    push edi  
    mov edi,VidBuff         ; Load video address to EDI  
    dec eax                 ; Adjust Y value down by 1 for address calculation  
    dec ebx                 ; Adjust X value down by 1 for address calculation  
    mov ah,COLS             ; Move screen width to AH  
    mul ah                  ; Do 8-bit multiply AL*AH to AX  
    add edi,eax             ; Add Y offset into vidbuff to EDI  
    add edi,ebx             ; Add X offset into vidbuf to EDI  
; EDI now contains the memory address in the buffer where the ruler  
; is to begin. Now we display the ruler, starting at that position:  
    mov al,'1'              ; Start ruler with digit '1'  
DoChar: stosb               ; Note that there's no REP prefix!  
    add al,'1'              ; Bump the character value in AL up by 1  
    aaa                     ; Adjust AX to make this a BCD addition  
    add al,'0'              ; Make sure we have binary 3 in AL's high nybble  
    loop DoChar             ; Go back & do another char until ECX goes to 0  
    pop edi                 ; Restore the registers we changed  
    pop ecx  
    pop ebx  
    pop eax  
    ret     ; And go home!  
  
;-------------------------------------------------------------------------  
; MAIN PROGRAM:  
      
_start:  
    nop                     ; This no-op keeps gdb happy...  
  
; Get the console and text display text buffer ready to go:  
    ClearTerminal           ; Send terminal clear string to console  
    call ClrVid             ; Init/clear the video buffer  
  
    mov eax,1               ; Start ruler at display position 1,1  
    mov ebx,1  
    mov ecx,32              ; Make ruler 32 characters wide  
    call Ruler              ; Generate the ruler  
  
; Now let's generate the chart itself:  
    mov edi,VidBuff         ; Start with buffer address in EDI  
    add edi,COLS*CHRTROW    ; Begin table display down CHRTROW lines  
    mov ecx,224             ; Show 256 chars minus first 32  
    mov al,32               ; Start with char 32; others won't show  
.DoLn:  mov bl,CHRTLEN      ; Each line will consist of 32 chars  
.DoChr: jcxz AllDone        ; When the full set is printed, quit  
    stosb                   ; Note that there's no REP prefix!  
    inc al                  ; Bump the character value in AL up by 1  
    dec bl                  ; Decrement the line counter by one  
    loopnz .DoChr           ; Go back & do another char until BL goes to 0  
    add edi,COLS-CHRTLEN    ; Move EDI to start of next line  
    jmp .DoLn               ; Start display of the next line  
  
; Having written all that to the buffer, send the buffer to the console:  
AllDone:  
    call Show               ; Refresh the buffer to the console  
  
Exit:   mov eax,1           ; Code for Exit Syscall  
    mov ebx,0               ; Return a code of zero   
    int 80H                 ; Make kernel call  