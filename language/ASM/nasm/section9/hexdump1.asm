; Executable name : hexdump1
; Version: 1.0
; Created date: 4/4/2009
; Last update: 4/4/2009
; Author: Jeff Duntemann
; Description: A simple program in assembly for Linux, using NASM 2.05,
;demonstrating the conversion of binary values to hexadecimal strings.
;It acts as a very simple hex dump utility for files, though without the
;ASCII equivalent column.
;
; Run it this way:
;hexdump1 < (input file)
;
; Build using these commands:
;nasm -f elf -g -F stabs hexdump1.asm
;ld -o hexdump1 hexdump1.o
;
SECTION .bss			; Section containing uninitialized data 
	BUFFLEN equ 16		; We read the file 16 bytes at a time
	Buff:	resb BUFFLEN; Text buffer itself

SECTION .data			; Section containing initialized data
	HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
	HEXLEN equ $-HexStr
	Digits: db “0123456789ABCDEF“

SECTION .text ; Section containing code
global _start ; Linker needs this to find the entry point!
_start:
	nop; This no-op keeps gdb happy...

; Read a buffer full of text from stdin:
Read:
	mov eax,3			; Specify sys_read call
	mov ebx,0			; Specify File Descriptor 0: Standard Input
	mov ecx,Buff 		; Pass offset of the buffer to read to
	mov edx,BUFFLEN 	; Pass number of bytes to read at one pass
	int 80h 			; Call sys_read to fill the buffer
	mov ebp,eax			; Save # of bytes read from file for later
	cmp eax,0			; If eax=0, sys_read reached EOF on stdin
	je Done 			; Jump If Equal (to 0, from compare)

; Set up the registers for the process buffer step:
	mov esi,Buff 		; Place address of file buffer into esi
	mov edi,HexStr 		;Place address of line string into edi
	xor ecx,ecx 		;Clear line string pointer to 0

; Go through the buffer and convert binary values to hex digits:
Scan:
	xor eax,eax			; Clear eax to 0

; Here we calculate the offset into HexStr, which is the value in ecx X 3
	mov edx,ecx			; Copy the character counter into edx
	shl edx,1 			; Multiply pointer by 2 using left shift
	add edx,ecx			; Complete the multiplication X3

; Get a character from the buffer and put it in both eax and ebx:
	mov al,byte [esi+ecx] ; Put a byte from the input buffer into al
	mov ebx,eax			; Duplicate the byte in bl for second nybble

; Look up low nybble character and insert it into the string:
	and al,0Fh			; Mask out all but the low nybble
	mov al,byte [Digits+eax]; Look up the char equivalent of nybble
	mov byte [HexStr+edx+2],al ; Write LSB char digit to line string

; Look up high nybble character and insert it into the string:
	shr bl,4			; Shift high 4 bits of char into low 4 bits
	mov bl,byte [Digits+ebx] ; Look up char equivalent of nybble
	mov byte [HexStr+edx+1],bl ; Write MSB char digit to line string


; Bump the buffer pointer to the next character and see if we’re done:
	inc ecx				; Increment line string pointer
	cmp ecx,ebp			; Compare to the number of chars in the buffer
	jna Scan 			; Loop back if ecx is <= number of chars in buffer

; Write the line of hexadecimal values to stdout:
	mov eax,4		;Specify sys_write call
	mov ebx,1		;Specify File Descriptor 1:Standard output
	mov ecx,HexStr 	;Pass offset fo line string
	mov edx,HEXLEN 	;Pass size of the line string
	int 80h			;Make kernel call to display line string
	jmp Read 		;Loop back and load file buffer again

;All done! Let's end this party:
Done:
	mov eax,1		;Code for exit Syscall
	mov ebx,0		;Return a code of zero
	int 80h			;Make kernel call
	