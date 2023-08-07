;program name: hexdump3
;version: 1.0
;create data: 7/17/2016
;alter data: 7/17/2016
;Author: Bool
;Descrabe: A simple hex dump utility demonstrating using of
;           separately assembled code libraries via EXTERN
;
; Build using these commands:
;   yasm -f elf -g dwarf2 hexdump3.asm -o hexdump3.o
;   ld -m elf_i386 -o hexdump3 hexdump3.o <path>/textlib.o
;
; RUN:  #./hexdump3 < filename

SECTION .bss    ; Section containing uninitialized data
    BUFFLEN EQU 10
    Buff resb BUFFLEN

SECTION .data   ;Section containing initillized data

SECTION .text   ;Section contain code

EXTERN ClearLine, DumpChar, PrintLine

;--------------------------------------------------------------------------------------------------------------
; LoadBuff:     Fills a buffer with data from stdin via INT 80H sys_read
; UPDATED:      6/26/2016
; IN                Nothing
; RETURNS           of bytes read in EBP
; MODIFIES:     ECX, EBP, Buff
; CALLS:            Kernel sys_read
; DESCRIPTION:  Loads a buffer full of data (BUFFLEN bytes) from stdin
;               using INT 80H sys_read and places it in Buff. buffer
;               offset counter ECX is zeroed, Because we're starting in
;               on a new buffer full of dat. Caller must test value in 
;               EBP:if EBP contains zero on return, we git EOF on stdin.
;               Less than 0 in EBP on return indiccates some kind of error.

LoadBuff:
    push eax                ; Save caller's EAX
    push ebx                ; Save caller's EBX
    push edx
    mov eax, 3              ; Specify sys_read call 
    mov ebx, 0              ; Specify File Descriptor 0: Standard Input
    mov ecx, Buff           ; Pass offset of the buffer to read to
    mov edx, BUFFLEN        ; Pass number of bytes to read at one pass
    int 80H
    mov ebp, eax            ; Save of bytes read from file for later
    xor ecx, ecx            ; Clear buffer pointer ECX to 0
    pop edx
    pop ebx
    pop eax
    ret

GLOBAL _start
;-----------------------------------------------------------------------------------------------
; MAIN PROGRAM BEGINS HERE
;-----------------------------------------------------------------------------------------------
_start:
    ; Whatever initialization needs doing before the loop scan loop starts in here:
    xor esi, esi            ; Recored the all characters have translated
    call LoadBuff           ; Read first buffer of data from stdin
    cmp ebp, 0              ; IF ebp==0,sys_read reached EOF on stdin
    jbe Exit                ; If reached EOF go to end program directly

    ; Go through the buffer and cover the binary byte values to hex digits:
Scan:
    xor eax, eax            ; Clear EAX  to 0 to calculate the buffer character number
    mov al, byte [ Buff + ecx ]; Get a byte from the buffer into AL
    mov edx, esi            ; Copy total counter into EDX
    and edx, 0000000fH      ; On 16 modulo,ensure that the offset in the length of HexDigits range.
    call DumpChar           ; Call the char poke procedure

    ; Bump the buffer pointer to the next character and see if buffer's done:
    inc esi                 ; Increment total chars processed counter
    inc ecx                 ; Increment buffer pointer
    cmp ecx, ebp            ; Compare all char in buffer  have processed 
    jb .modTest             ; If not,jump over reload character to buffer
    call LoadBuff           ; go fill the buffer again
    cmp ebp, 0              ; If ebp= 0, sys_read reached EOF on stdin
    jbe Done                ; If get EOF,Exit this program

    ; See if we're at the and of a block of 16 need to display a line:
.modTest:
    test esi, 0000000fH     ; Because esi records all processed all number of characters,
                            ;- we nee to work out whether the count is an interger muitiple of 16
    jnz Scan                ; If counter is not modulo 16, Skip print line
    call PrintLine          ; - otherwise print the line
    call ClearLine          ; Clear hex dump line to 0's
    jmp Scan                ; Continue scanning the buffer

    ; All done! Let's end this party:
Done:
    call PrintLine          ; Print the 'leftvoers' line
Exit: 
    mov eax, 1              ; Code for Exit Syscall
    mov ebx, 0              ; Return a code of zero
    int 0x80                ; Make kernel call