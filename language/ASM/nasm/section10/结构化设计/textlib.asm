;library name: textlib
;version: 1.0
;create data: 6/17/2016
;alter data: 6/17/2016
;Author: Bool
;Descrabe: A library use for text process
;
;Greate execute program:
;   yasm -f elf -g dwarf2 textlib.asm
;


SECTION .data   ;Section containing initillized data

;Here we have two parts of a single useful data structure,implementing
;the text line of a hex dump utility.The first part displays 16 words in
;hex separated by spaces.Immediately following is a 16-character line
;delimited by vertical bar characters.Because they are adjacent,the tow
;parts can be referenced sepatately or as a single contigous unit.
;Remember that if DumpLin is to be used sepatately,you must append an
;EOF before sending it to the Linux console.
    DumpLin:    db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    DUMPLEN     EQU $-DumpLin
    ASCLin:     db "|................|",10
    ASCLEN      EQU $-ASCLin
    FULLLEN     EQU $-DumpLin

    ;The HexDigits table is used to convert mumeric values to their hex
    ;equivalents.Index by nybble without s scale:[HexDigits+eax]
    HexDigits:  db "0123456789ABCDEF"

    ;This table is used for ASCII character translation,into the ASCII
    ;portion of the hex dump line,via XLAT or ordinary memory lookup.
    ;All printable characters "play through." as themselves.The high 128
    ;characters are translated to ASCII period(2Eh).The non-printable
    ;characters in the low 128 are also translated to ASCII eriod,as is
    ;chat 127.
    DotXlat:
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
        db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
        db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4dH,4Eh,4Fh
        db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5dH,5Eh,5Fh
        db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6dH,6Eh,6Fh
        db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7dH,7Eh,7Fh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

SECTION .text   ;Section contain code

GLOBAL ClearLine, DumpChar, PrintLine
;--------------------------------------------------------------------------
;  CleraLine: Clear a hex dump line string to 16 0 values
;  UPDATE:  6/5/2016
;  In:      Nothing
;  RETURN:  Nothing
;  MOFIFIES:    Nothing
;  CALLS:   DumpChar
;  DESCRIPTION: The hex dump line is cleared to binary 0 by
;   calling DumpChar 16 times, passing it 0 each time.

ClearLine:
    pushad              ; Save all calle's GP registers
    mov edx,15          ; we are going to go 16 pokes, counting from 0
.poke:mov eax, 0        ; TellDumpChar to poke a '0'
    call DumpChar       ; Insert the '0' into the hex dump string
    sub edx,1           ; DEC doesn't affet CF!
    jae .poke           ; Loop back if EDX >= 0
    popad               ; Restore all caller's GP registers
    ret                 ; Go home

;---------------------------------------------------------------------------------------
; DumpChar:     "Poke" a value into the hex dump line string.
; UPDATE:           6/13/2016
; IN:               Pass the 8-bit value to be poked in EAX.
;               Pass the value's position in the line (0-15) in EDX
; RETURNS:      Nothing
; MODIFIES:     EAX, ASCLin, DumpLin
; CALLS:            Nothing
; DESCRIPTION:  The value passed in EAX will be put in both the hex
;               portion and in the ASCII portion,At the position passed 
;               in EDX, represented by a space where it is not a 
;               printable  character.

DumpChar:
    push ebx                ; Save caller's EBX
    push edi                ; Save caller's EDI
    ; First we insert the input char into the ASCII portion of the dump line
    mov bl, byte [DotXlat+eax]  ; Translate nonprintables to '.'
    mov byte [ASCLin + edx + 1], bl ;Write to ASCII portion
    ; Next we insert the hex equivalent of the input char in the hex portion
    ; of the hex dump line:
    mov ebx, eax            ; Save  a second copy of the input char
    lea edi, [ edx*2+edx ]  ; Calc offset into line strng (EDX*3)
    ; Look up low nybble chatacter and insert it into the string:
    and eax, 0fH            ; Mask out all but the low nybble
    mov al, byte [ HexDigits + eax ]    ;Look up the char equiv. of nybble
    mov byte [ DumpLin + edi + 2 ], al  ;Write the char equiv. to line string
    ; Look up high nybble character and insert it into the string:
    and ebx, 0f0H           ; Must out all the but second-lowest nybble
    shr ebx, 4              ; Shift hight 4 bits of byte into low 4 bits
    mov bl, byte [ HexDigits + ebx ]    ; Look up char equiv. of nybble
    mov  byte [ DumpLin + edi + 1 ], bl ; Write the char equiv. to line string
    ; Done! Let's go home:
    pop edi                 ; Restore caller's EDI
    pop ebx                 ; Restore caller's EBX
    ret                     ; Return ro caller


;---------------------------------------------------------------------------------------------------------------------
; PrintLine:        Displays DumpLin to stdout
; UPDATED:      6/24/2016
; IN:               Nothing
; RETURNS:      Nothing
; MODIFIES:     Nothing
; CALLS:            Kernel sys_write
; DESCRIPTION:  The hex dump line string DumpLin is displayed to stdout
;               using INT 80H sys_write. All GP registers are reserved.

PrintLine:
    pushad                  ; Save all caller's GP registers
    mov eax, 4              ; Specify sys_write call 
    mov ebx, 1              ; Specify File Description 1: Standard output
    mov ecx, DumpLin        ; Pass offset of line string
    mov edx, FULLLEN        ; Pass size of the line sting
    int 80h                 ; Make kernel call to display line string
    popad                   ; Restore all caller's GP registers
    ret                     ; Return to caller


