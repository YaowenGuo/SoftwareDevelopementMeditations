section .data   ;.data段用于保存已命名的数据项
section .text   ;.text段用于存放程序代码

    golbal _start ;真正需要的是一个标记未全局的起始点
    
    
_start:
        nop
        ;将你的实验内容放在两个nops指令之间进行...
        ;不包含任何指令的的可执行文件不会在linux上执行
        nop
    section .bss    ;bss段是非必要的但如果打算进行实验
    ;bss段可以用来保存未被初始化的数据，也就是说，该空间
    ;用于存放当程序开始运行时并没有接受任何初始值的数据项。
    ;