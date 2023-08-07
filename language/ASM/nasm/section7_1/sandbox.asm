section .data   ;.data段用于保存已命名的数据项
section .text   ;.text段用于存放程序代码

global  _start ;真正需要的是一个标记未全局的起始点
    
    
_start:
        nop
        ;将你的实验内容放在两个nops指令之间进行...
        ;不包含任何指令的的可执行文件不会在linux上执行
        nop
        mov eax, 1       ; 系统调用号(sys_exit)
        ;4、设置系统调用参数
        mov ebx, 0       ; 参数一：退出代码
        int 0x80         ; 调用内核功能 

section .bss    ;bss段是非必要的但如果打算进行实验
    ;bss段可以用来保存未被初始化的数据，也就是说，该空间
    ;用于存放当程序开始运行时并没有接受任何初始值的数据项。
    ;当程序被加载时，linux知道该程序有多长，它允许
    ;执行不存在任何指令的程序

