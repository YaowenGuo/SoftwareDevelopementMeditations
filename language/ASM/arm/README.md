# ARM64 汇编

## Hello Wrold

[Mac 系统](https://medium.com/@gamedev0909/how-to-set-up-and-program-arm-64-assembly-on-apple-silicon-part-1-ac3c7d110195)
```assembly
# hello.s
.global _main
.align 2
_main:
    mov X0, #1
    adr X1, msg
    mov X2, #13
    mov X16, #4
    svc #0x80
    mov X0, #0
    mov X16, #1
    svc #0x80
msg: .ascii "Hello World!\n"
```

[Linux](https://peterdn.com/post/2020/08/22/hello-world-in-arm64-assembly/)
```assembly
.data
msg:
    .ascii        "Hello World!\n"
len = . - msg

.text
.globl _start
_start:
    /* syscall write(int fd, const void *buf, size_t count) */
    mov     x0, #1      /* fd := STDOUT_FILENO */
    ldr     x1, =msg    /* buf := msg */
    ldr     x2, =len    /* count := len */
    mov     w8, #64     /* write is syscall #64 */
    svc     #0          /* invoke syscall */

    /* syscall exit(int status) */
    mov     x0, #0      /* status := 0 */
    mov     w8, #93     /* exit is syscall #93 */
    svc     #0          /* invoke syscall */
```

```shell
$ as -o hello.o hello.s
$ ld -o hello hello.o
$ ./hello
Hello World!
```
