fun:
    push rbp
    mov rbp, rsp
    push 1
    mov rsp, rbp
    pop rbp
    ret
先用命令set disassembly-flavor intel设置反汇编后显示什么类型的汇编代码，默认是AT&T类型的。左边的=>表示代码执行处。