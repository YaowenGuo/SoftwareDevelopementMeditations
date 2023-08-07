;The executable program name: eatsyscall
;version:1.0
;Creation date:2/29/2016
;Last modified date:2/29/2016
;Author:Bool
;Description:A simple plications under Linux,use NASM 2.10.09,
;demonstrates how to use Linux INT 80H system call to display 
;text.
;
;Use command to generate an executable program.
; nasm -f elf -g -F stabs eatsyscall.asm
; ld -o eatsyscall eatsyscall.o  -melf_i386
;
; nasm -f elf64 -g -F stabs eatsyscall.asm
; ld -o eatsyscall eatsyscall.o
SECTION .data   ;Containing mission data portion.
EatMsg: db "Eat at Jos's!", 10
EatLen: equ $-EatMsg

SECTION .bss    ;It contains an uninitiallized data section.

SECTION .text   ;It contains the code.
global _start   ;Linker based on its need to find the enter point/

_start:
    nop          ;Misuse instruction.
    mov eax,    4   ;Specifies sys_write system call.
    mov ebx,    1   ;Specify File Descriptor 1: Standard output
    mov ecx,    EatMsg  ;Pass offset of the message
    mov edx,    EatLen  ;Pass the length of the message
    int 80H         ;Make syscall to output the text to stdout

    mov eax,    1   ;Specify Exit syscall
    mov ebx,    0   ;Return a code of zero
    int 80H         ;Make systemcall to terminate the program
    

