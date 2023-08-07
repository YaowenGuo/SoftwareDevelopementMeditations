[section .data]
    EatMsg: db "Eat at Joe's!",0

[section .bss]

[section .text]

EXTERN puts
GLOBAL main
main:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    push EatMsg
    call puts
    add esp, 4

    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret