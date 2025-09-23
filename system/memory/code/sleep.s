// ARM64 汇编休眠程序
// 编译: as -o sleep.o sleep.s && ld -o sleep sleep.o
// 运行: ./sleep

.text
.global _start

_start:
    // nanosleep 系统调用 (ARM64 系统调用号: 101)
    mov x8, #101          // 将 nanosleep 的系统调用号放入 x8
    ldr x0, =timespec     // 第一个参数: timespec 结构体地址
    mov x1, #0            // 第二个参数: rem (剩余时间) 设为 NULL
    svc #0                // 执行系统调用

    // 退出程序
    mov x8, #93           // exit 系统调用号
    mov x0, #0            // 退出码 0
    svc #0                // 执行系统调用

.data
timespec:
    .word 300             // tv_sec: 300 秒 (5分钟)
    .word 0               // tv_nsec: 0 纳秒cat