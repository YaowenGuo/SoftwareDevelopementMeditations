SECTION .data           ; Section containing initialised data  
    EOL     equ 10      ; Linux end-of-line character  
    FILLCHR equ 32      ; ASCII space character  
    HBARCHR equ 95      ; Use dash char if this won't display  
    STRTROW equ 2       ; Row where the graph begins  
  
; The dataset is just a table of byte-length numbers:  
    Dataset db 9,17,71,52,55,18,29,36,18,68,77,63,58,44,0  
  
    Message db "Data current as of 1/9/2015"  
    MSGLEN  equ $-Message  
  
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
    pushad          ; Save all registers  
    mov eax,4       ; Specify sys_write call  
    mov ebx,1       ; Specify File Descriptor 1: Standard Output  
    mov ecx,ClrHome     ; Pass offset of the error message  
    mov edx,CLRLEN      ; Pass the length of the message  
    int 80H         ; Make kernel call  
    popad           ; Restore all registers  
%endmacro  
  
Show:   pushad          ; Save all registers  
    mov eax,4       ; Specify sys_write call  
    mov ebx,1       ; Specify File Descriptor 1: Standard Output  
    mov ecx,VidBuff     ; Pass offset of the buffer  
    mov edx,COLS*ROWS   ; Pass the length of the buffer  
    int 80H         ; Make kernel call  
    popad           ; Restore all registers  
    ret         ; And go home!  
  
ClrVid: push eax        ; Save caller's registers  
    push ecx  
    push edi  
    cld         ; Clear DF; we're counting up-memory  
    mov al,FILLCHR      ; Put the buffer filler char in AL  
    mov edi,VidBuff     ; Point destination index at buffer  
    mov ecx,COLS*ROWS   ; Put count of chars stored into ECX  
    rep stosb       ; Blast chars at the buffer  
; Buffer is cleared; now we need to re-insert the EOL char after each line:  
    mov edi,VidBuff     ; Point destination at buffer again  
    dec edi         ; Start EOL position count at VidBuff char 0  
    mov ecx,ROWS        ; Put number of rows in count register  
PtEOL:  add edi,COLS        ; Add column count to EDU  
    mov byte [edi],EOL  ; Store EOL char at end of row  
    loop PtEOL      ; Loop back if still more lines  
    pop edi         ; Restore caller's registers  
    pop ecx  
    pop eax  
    ret         ; and go home!  
  
WrtLn:  push eax    ; Save registers we change  
    push ebx  
    push ecx  
    push edi  
    cld     ; Clear DF for up-memory write  
    mov edi,VidBuff ; Load destination index with buffer address  
    dec eax     ; Adjust Y value down by 1 for address calculation  
    dec ebx     ; Adjust X value down by 1 for address calculation  
    mov ah,COLS ; Move screen width to AH  
    mul ah      ; Do 8-bit multiply AL*AH to AX  
    add edi,eax ; Add Y offset into vidbuff to EDI  
    add edi,ebx ; Add X offset into vidbuf to EDI  
    rep movsb   ; Blast the string into the buffer  
    pop edi     ; Restore registers we changed  
    pop ecx  
    pop ebx  
    pop eax  
    ret     ; and go home!  
  
WrtHB:  push eax    ; Save registers we change  
    push ebx  
    push ecx  
    push edi  
    cld     ; Clear DF for up-memory write  
    mov edi,VidBuff ; Put buffer address in destination register  
    dec eax     ; Adjust Y value down by 1 for address calculation  
    dec ebx     ; Adjust X value down by 1 for address calculation  
    mov ah,COLS ; Move screen width to AH  
    mul ah      ; Do 8-bit multiply AL*AH to AX  
    add edi,eax ; Add Y offset into vidbuff to EDI  
    add edi,ebx ; Add X offset into vidbuf to EDI  
    mov al,HBARCHR  ; Put the char to use for the bar in AL  
    rep stosb   ; Blast the bar char into the buffer  
    pop edi     ; Restore registers we changed  
    pop ecx  
    pop ebx  
    pop eax  
    ret     ; And go home!  
  
Ruler:  push eax    ; Save the registers we change  
    push ebx  
    push ecx  
    push edi  
    mov edi,VidBuff ; Load video address to EDI  
    dec eax     ; Adjust Y value down by 1 for address calculation  
    dec ebx     ; Adjust X value down by 1 for address calculation  
    mov ah,COLS ; Move screen width to AH  
    mul ah      ; Do 8-bit multiply AL*AH to AX  
    add edi,eax ; Add Y offset into vidbuff to EDI  
    add edi,ebx ; Add X offset into vidbuf to EDI  
; EDI now contains the memory address in the buffer where the ruler  
; is to begin. Now we display the ruler, starting at that position:  
    mov al,'1'  ; Start ruler with digit '1'  
DoChar: stosb   ; Note that there's no REP prefix!  
    add al,'1'  ; Bump the character value in AL up by 1  
    aaa         ; Adjust AX to make this a BCD addition  
    add al,'0'  ; Make sure we have binary 3 in AL's high nybble  
    loop DoChar ; Go back & do another char until ECX goes to 0  
    pop edi     ; Restore the registers we changed  
    pop ecx  
    pop ebx  
    pop eax  
    ret     ; And go home!  
  
;-------------------------------------------------------------------------  
; MAIN PROGRAM:  
      
_start:  
    nop     ; This no-op keeps gdb happy...  
  
; Get the console and text display text buffer ready to go:  
    ClearTerminal   ; Send terminal clear string to console  
    call ClrVid ; Init/clear the video buffer  
  
; Next we display the top ruler:  
    mov eax,1   ; Load Y position to AL  
    mov ebx,1   ; Load X position to BL  
    mov ecx,COLS-1  ; Load ruler length to ECX  
    call Ruler  ; Write the ruler to the buffer  
  
; Here we loop through the dataset and graph the data:  
    mov esi,Dataset ; Put the address of the dataset in ESI  
    mov ebx,1   ; Start all bars at left margin (X=1)  
    mov ebp,0   ; Dataset element index starts at 0  
.blast: mov eax,ebp ; Add dataset number to element index  
    add eax,STRTROW ; Bias row value by row # of first bar  
    mov cl,byte [esi+ebp]   ; Put dataset value in low byte of ECX  
    cmp ecx,0   ; See if we pulled a 0 from the dataset  
    je .rule2   ; If we pulled a 0 from the dataset, we're done  
    call WrtHB  ; Graph the data as a horizontal bar  
    inc ebp     ; Increment the dataset element index  
    jmp .blast  ; Go back and do another bar  
  
; Display the bottom ruler:  
.rule2: mov eax,ebp ; Use the dataset counter to set the ruler row  
    add eax,STRTROW ; Bias down by the row # of the first bar  
    mov ebx,1   ; Load X position to BL  
    mov ecx,COLS-1  ; Load ruler length to ECX  
    call Ruler  ; Write the ruler to the buffer  
  
; Thow up an informative message centered on the last line  
    mov esi,Message ; Load the address of the message to ESI  
    mov ecx,MSGLEN  ; and its length to ECX  
    mov ebx,COLS    ; and the screen width to EBX  
    sub ebx,ecx ; Calc diff of message length and screen width  
    shr ebx,1   ; Divide difference by 2 for X value  
    mov eax,ROWS-1  ; Set message row to Line 24  
    call WrtLn  ; Display the centered message  
  
; Having written all that to the buffer, send the buffer to the console:  
    call Show   ; Refresh the buffer to the console  
  
Exit:   mov eax,1   ; Code for Exit Syscall  
    mov ebx,0   ; Return a code of zero   
    int 80H     ; Make kernel call  

;圆柱条显示不出来，显示的是下划线，就凑合着看吧。