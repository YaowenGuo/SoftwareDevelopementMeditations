// ARM64 汇编休眠程序
// 编译: as -o sleep.o sleep.s && ld -o sleep sleep.o
// 运行: ./sleep

.text
.global _start

_start:
    // 在栈上创建 timespec 结构
    mov x0, #300          // tv_sec = 300 秒
    mov x1, #0            // tv_nsec = 0 纳秒
    stp x0, x1, [sp, -16]! // 将 timespec 压入栈并调整栈指针
    
    // nanosleep 系统调用 (ARM64 系统调用号: 101)
    mov x8, #101          // nanosleep 系统调用号
    mov x0, sp            // 第一个参数: 栈上的 timespec 结构
    mov x1, #0            // 第二个参数: rem (剩余时间) 设为 NULL
    svc #0                // 执行系统调用
    
    // 恢复栈指针
    add sp, sp, #16
    
    // 退出程序
    mov x8, #93           // exit 系统调用号
    mov x0, #0            // 退出码 0
    svc #0                // 执行系统调用
