section .bss
	Buff resb 1

section .data

section .text
	global _start

_start
	nop 	;This commend will make debuger very happy because 
	;it has nothing to do.
Read: 
	mov eax,3	;use sys_read system call
	mov ebx,0	;fill descrabe sige 0:standed input
	mov ecx,Buff;date buffer address
	mov edx,1	;tell sys_read read one from stamded input
	int 80h		;call sys_read
	cmp eax,0	;test sys_read's return in EAX
	je  Exit    ;if is 0 (EOF)jump to Exit.
				;or not 0,Test it is o lowercase
	cmp byte [Buff],61h	;camp input capital with 'a'
	jb  Write			;if it's ASCII littler than a,It's not lowercase
	cmp byte [Buff],7ah ;text input capital with 'z',
	ja  Write			;if it's ASCII biger then 'z',ti's not lowercase
						;then we got one lowercase 
	sub byte [Buff],20h	;
						;and then write it to standed output


write:
	mov eax,4	;point sys_write call
	mov ebx,1	;fill descrabe flag 1:standed output
	mov ecx,Buff;address of output capital
	mov edx,1	;num of capital output
	int 80h		;sys_write
	jmp Read  	;jump to begin,get anther capital

Exit:
	mov eax,1	;exit system call's code
	mov ebx,0	;return 0
	int 80h     ;system call
	

