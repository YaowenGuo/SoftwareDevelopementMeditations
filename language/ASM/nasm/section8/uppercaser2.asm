;program name:uppercaser2.asm
;version:1.0
;creat date:2/14/2016
;author:Bool
;descrabe:A simple program use assambly language for linux.
;show simple text input/output,to make uppercase use bfferspace
;and write it to output file
;
;how to ran it.
;uppercaser2 > (output file) <(input file)
;
;make & link
;nasm -f elf -g -F stabs uppercaser2.asm
;ld -o uppercaser2 uppercaser2.o
;
SECTION .bss		;segment contain uninit date

	BUFFLEN		equ	 1024	;buffer length
	Buff:	resb	BUFFLEN	;buffer

SECTION .data		;use for date segment

SECTION .text		;code segment
global _start		;linker use this lable to find enter point
_start:
	nop 			;do nothing

;read text to full buffer space:
read:
	mov eax,3		;use sys_read system call
	mov ebx,0		;file descrabe dign 0:standerd input
	mov ecx,Buff 	;buff address
	mov edx,BUFFLEN	;read byte number in once
	int 80h			;call sys_read to full buff
	mov esi,eax 	;copy sys_read's return to save
	cmp eax,0		;if eax=0,and sys_read have been the end of standerd input
	je Done         ;if equals zero then jump

;set regster for deal buffer:
	mov ecx,esi		;put number what have read form read in ecx register
	mov ebp,Buff    ;put buffer address in ebp register
	dec ebp			;adjust calculate for offset address 

;check up buffer,turn lowercase to uppercase:
Scan:
	cmp byte [ebp+ecx],61H	;test input character 
	jb 	Next	 			;if ASCII is less than 'a',it is not lowercase
	cmp byte [ebp+ecx],7aH 	;test input character,compare with 'z'
	ja  Next  				;if ASCII is biger than 'z',it's not lowercase

	;now we get a lowercase
Next:
	edc	ecx					;decrease counter
	jnz Scan 				;if still have character,continue circulate

;write text which have dealed to standerd output
Write:
	mov eax,4				;use sys_write system call
	mov ebx,1				;point file descraption sign 1:standard output
	mov ecx,Buff 			;get address of buffer zone
	mov edx,esi				;character num in buffer zone
	int 80h					;sys_write call
	jmp read 				;read another buffer zone text
;It's over,Now let's over this 'paty'
Done:
	mov eax,1				;sys_exit call's code
	mov ebx,0				;use 0 as return 
	int 80H					;cal sys_exit
	