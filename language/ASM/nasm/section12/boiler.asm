[section .data]
    EatMsg: db "Eat at Joe's!",0

[section .bss]

[section .text]

EXTERN puts
GLOBAL _start
_start:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi


    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
