# Process

## 虚拟化

It turns out that one often wants to run more than one program at once; for example, consider your desktop or laptop where you might like to run a web browser, mail program, a game, a music player, and so forth. In fact, a typical system may be seemingly running tens or even hundreds of processes at the same time. Doing so makes the system easy to use, as one never need be concerned with whether a CPU is available; one simply runs programs. Hence our challenge:

```
     THE CRUX OF THE PROBLEM:
HOW TO PROVIDE THE ILLUSION OF MANY CPUS?
Although there are only a few physical CPUs available, how can the OS provide the illusion of a nearly-endless supply of said CPUs?
```

The OS creates this illusion by virtualizing the CPU. By running one process, then stopping it and running another, and so forth, the OS can promote the illusion that many virtual CPUs exist when in fact there is only one physical CPU (or a few). This basic technique, known as time sharing of the CPU, allows users to run as many concurrent processes as they would like; the potential cost is performance, as each will run more slowly if the CPU(s) must be shared.


想要实现虚拟化，需要底层机制（low-level machinery）和上层策略（high-level intelligence）的配合实现
- 底层
    - 程序的上线文切换
- 上层
    - 调度策略



创建一个进程的方式显得非常奇特，但是这样的设计其具有很好的灵活性：

```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    printf("Hello world (pid: %d)\n", (int)getpid());
    int rc = fork();
    if (rc < 0) {
        fprintf(stderr, "Fork failed\n");
        exit(1);
    } else if (rc == 0) {
        printf("Hello, I am child (pid: %d)\n", (int)getpid());
    } else {
        printf("Hello, I am parent of %d (pid: %d)\n", rc, (int)getpid());
    }
    
    return 0;
}
```

```
$ ./a.out
Hello world (pid: 26454)
Hello, I am parent of 26459 (pid: 26454)
Hello, I am child (pid: 26459)
```


[进入 Main 函数之前发生的事，以及 main 函数 return 之后，是如何调用 exit 结束进程的](https://stackoverflow.com/questions/29694564/what-is-the-use-of-start-in-c)
http://dbp-consulting.com/tutorials/debugging/linuxProgramStartup.html

## User and Kernel Modes

In order for the operating system kernel to provide an airtight process abstraction, the processor must provide a mechanism that restricts the instructions that an application can execute, as well as the portions of the address space that it can access.

Processors typically provide this capability with a mode bit in some control register that characterizes the privileges that the process currently enjoys. When the mode bit is set, the process is running in kernel mode (sometimes called supervisor mode). A process running in kernel mode can execute any instruction in the instruction set and access any memory location in the system.



## IPC

在UNIX中，文件（File）、信号（Signal）、无名管道（Unnamed Pipes）、有名管道（FIFOs）是传统IPC功能；新的IPC功能包括消息队列（Message queues）、共享存储段（Shared memory segment）和信号量（Semapores）。以及 Socket 可以在不同主机的进程间进行通信。


## 系统调用

为什么应用开发时系统调用就像普通的函数调用一样？

系统调用遵循特殊的约定，需要使用汇编或者内嵌汇编的形式来处理参数和返回值的顺序以及存放位置。有人已经替我们做了这样的工作：标准库。通过将系统调用的细节和不同平台差异隐藏在标准库中。应用开发者可以不用关系这些繁杂细节的使用系统调用。例如文件操作函数 `open()` 就会在内部进行一个系统调用，由系统来进行文件操作。