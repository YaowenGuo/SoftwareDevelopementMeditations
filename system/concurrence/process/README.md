# Process

When we run a program on a modern system, we are presented with the illusion that our program is the only one currently running in the system. Our program appears to have exclusive use of both the processor and the memory. The processor appears to execute the instructions in our program, one after the other, without interruption. Finally, the code and data of our program appear to be the only objects in the system's memory. These illusions are provided to us by the notion of a process.

The classic definition of a process is an instance of a program in execution. Each program in the system runs in the context of some process. The context consists of the state that the program needs to run correctly. This state includes the program's code and data stored in memory, its stack, the contents of its general purpose registers, its program counter, environment variables, and the set of open file descriptors.


It turns out that one often wants to run more than one program at once; for example, consider your desktop or laptop where you might like to run a web browser, mail program, a game, a music player, and so forth. In fact, a typical system may be seemingly running tens or even hundreds of processes at the same time. Doing so makes the system easy to use, as one never need be concerned with whether a CPU is available; one simply runs programs. Hence our challenge:


The key abstractions that a process provides to the application:

- An independent logical control flow that provides the illusion that our program has exclusive use of the processor.
- A private address space that provides the illusion that our program has exclusive use of the memory system.

内存的虚拟化是另一个巨大话题，在单独的内存主题中探讨，我们在这里仅关注进程及其执行流以及处理器的虚拟化。

## Processor illusion

```
     THE CRUX OF THE PROBLEM:
HOW TO PROVIDE THE ILLUSION OF MANY CPUS?
Although there are only a few physical CPUs available, how can the OS provide the illusion of a nearly-endless supply of said CPUs?
```

The OS creates this illusion by virtualizing the CPU. By running one process, then stopping it and running another, and so forth, the OS can promote the illusion that many virtual CPUs exist when in fact there is only one physical CPU (or a few). This basic technique, known as time sharing of the CPU, allows users to run as many concurrent processes as they would like; the potential cost is performance, as each will run more slowly if the CPU(s) must be shared.

![Logical control flows](./README_img/logical_control_flows.png)

Each process executes a portion of its flow and then is preempted (temporarily suspended) while other processes take their turns. To a program running in the context of one of these processes, it appears to have exclusive use of the processor. The only evidence to the contrary is that if we were to precisely measure the elapsed time of each instruction, we would notice that the CPU appears to periodically stall between the execution of some of the instructions in our program. However, each time the processor stalls, it subsequently resumes execution of our program without any change to the contents of the program's memory locations or registers.


想要实现虚拟化，需要底层机制（low-level machinery）和上层策略（high-level intelligence）的配合实现
- 底层
    - 程序的上线文切换
- 上层
    - 调度策略

## API

创建一个进程的方式显得非常奇特，但是这样的设计其具有很好的灵活性：

```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    printf("Hello world (pid: %d)\n", (int)getpid());
    pid_t pid = fork();
    if (pid < 0) {
        fprintf(stderr, "Fork failed\n");
        exit(1);
    } else if (pid == 0) {
        printf("Hello, I am child (pid: %d)\n", (int)getpid());
    } else {
        printf("Hello, I am parent of %d (pid: %d)\n", pid, (int)getpid());
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

为了简化代码，我们将错误检查包装为一个同名的大写字母开头的函数。

```C
pid_t Fork(void)
{
	pid_t pid;
	if ((pid = fork())< 0)
		unix_error("Fork error");
	return pid;
}


void unix_error(char *msg) /* Unix-style error */
{
	fprintf(stderr, "%s: %s\n", msg, strerror(errno));
	exit(0);
}
```

The newly created child process is almost, but not quite, identical to the parent. The child gets an identical (but separate) copy of the parent's user-level virtual address space, including the code and data segments, heap, shared libraries, and user stack. The child also gets identical copies of any of the parent's open file descriptors, which means the child can read and write any files that were open in the parent when it called fork. The most significant difference between the parent and the newly created child is that they have different PIDs.

The fork function is interesting (and often confusing) because it is called once but it returns twice: once in the calling process (the parent), and once in the newly created child process. In the parent, fork returns the PID of the child. In the child, fork returns a value of 0. Since the PID of the child is always nonzero, the return value provides an unambiguous way to tell whether the program is executing in the parent or the child.

- **Call once, return twice.** The fork function is called once by the parent, but it returns twice: once to the parent and once to the newly created child. This is fairly straightforward for programs that create a single child. But programs with multiple instances of fork can be confusing and need to be reasoned about carefully.

- **Concurrent execution.** The parent and the child are separate processes that run concurrently. The instructions in their logical control flows can be interleaved by the kernel in an arbitrary way. 

- **Duplicate but separate address spaces.** If we could halt both the parent and the child immediately after the fork function returned in each process, we would see that the address space of each process is identical. Each process has the same user stack, the same local variable values, the same heap, the same global variable values, and the same code. Thus, in our example program, local variable x has a value of 1 in both the parent and the child when the fork function returns in line 6. However, since the parent and the child are separate processes, they each have their own private address spaces.

- Shared files. When we run the example program, we notice that both parent and child print their output on the screen. The reason is that the child inherits all of the parent's open files. When the parent calls fork, the stdout file is open and directed to the screen. The child inherits this file, and thus its output is also directed to the screen.



[进入 Main 函数之前发生的事，以及 main 函数 return 之后，是如何调用 exit 结束进程的](https://stackoverflow.com/questions/29694564/what-is-the-use-of-start-in-c)
http://dbp-consulting.com/tutorials/debugging/linuxProgramStartup.html


1. exit(status) 的状态值和 main 函数renturn 的结果等价。

### Reaping Child Processes

When a process terminates for any reason, the kernel does not remove it from the system immediately. Instead, the process is kept around in a terminated state until it is reaped by its parent. When the parent reaps the terminated child, the kernel passes the child's exit status to the parent and then discards the terminated process, at which point it ceases to exist. A terminated process that has not yet been reaped is called a zombie.

When a parent process terminates, the kernel arranges for the init process to become the adopted parent of any orphaned children. The init process, which has a PID of 1, is created by the kernel during system start-up, never terminates, and is the ancestor of every process. If a parent process terminates without reaping its zombie children, then the kernel arranges for the init process to reap them. However, long-running programs such as shells or servers should always reap their zombie children. Even though zombies are not running, they still consume system memory resources.

A process waits for its children to terminate or stop by calling the waitpid function.

```
#include <sys/types.h>
#include <sys/wait.h>
pid_t waitpid(pid_t pid, int *statusp, int options);
		
Returns: PID of child if OK, 0 (if WNOHANG), or -1 on error”
```

> Aside Why are terminated children called zombies?
    In folklore, a zombie is a living corpse, an entity that is half alive and half dead. A zombie process is similar in the sense that although it has already terminated, the kernel maintains some of its state until it can be reaped by the parent.

The waitpid function is complicated. By default (when options = 0), waitpid suspends execution of the calling process until a child process in its wait set terminates. If a process in the wait set has already terminated at the time of the call, then waitpid returns immediately. In either case, waitpid returns the PID of the terminated child that caused waitpid to return. At this point, the terminated child has been reaped and the kernel removes all traces of it from the system.

#### Determining the Members of the Wait Set
The members of the wait set are determined by the pid argument:

- If pid > 0, then the wait set is the singleton child process whose process ID is equal to pid.
- If pid = -1, then the wait set consists of all of the parent's child processes.

The waitpid function also supports other kinds of wait sets, involving Unix process groups, which we will not discuss.

#### Modifying the Default Behavior

The default behavior can be modified by setting options to various combinations of the WNOHANG, WUNTRACED, and WCONTINUED constants:

- WNOHANG. Return immediately (with a return value of 0) if none of the child processes in the wait set has terminated yet. The default behavior suspends the calling process until a child terminates; this option is useful in those cases where you want to continue doing useful work while waiting for a child to terminate.

- WUNTRACED. Suspend execution of the calling process until a process in the wait set becomes either terminated or stopped. Return the PID of the terminated or stopped child that caused the return. The default behavior returns only for terminated children; this option is useful when you want to check for both terminated and stopped children.

- WCONTINUED. Suspend execution of the calling process until a running process in the wait set is terminated or until a stopped process in the wait set has been resumed by the receipt of a SIGCONT signal. (Signals are explained in Section 8.5.)

You can combine options by oring them together. For example:

- WNOHANG | WUNTRACED: Return immediately, with a return value of 0, if none of the children in the wait set has stopped or terminated, or with a return value equal to the PID of one of the stopped or terminated children.

#### Checking the Exit Status of a Reaped Child

If the statusp argument is non-NULL, then waitpid encodes status information about the child that caused the return in status, which is the value pointed to by statusp. The wait.h include file defines several macros for interpreting the status argument:

- WIFEXITED(status). Returns true if the child terminated normally, via a call to exit or a return.

- WEXITSTATUS(status). Returns the exit status of a normally terminated child. This status is only defined if WIFEXITED() returned true.

- WIFSIGNALED(status). Returns true if the child process terminated because of a signal that was not caught.

- WTERMSIG(status). Returns the number of the signal that caused the child process to terminate. This status is only defined if WIFSIGNALED() returned true.

- WIFSTOPPED(status). Returns true if the child that caused the return is currently stopped.

- WSTOPSIG(status). Returns the number of the signal that caused the child to stop. This status is only defined if WIFSTOPPED() returned true.

- WIFCONTINUED(status). Returns true if the child process was restarted by receipt of a SIGCONT signal.

#### Error Conditions
If the calling process has no children, then waitpid returns -1 and sets errno to ECHILD. If the waitpid function was interrupted by a signal, then it returns -1 and sets errno to EINTR.


### Loading and Running Programs

The execve function loads and runs a new program in the context of the current process.



### Progress group

Every process belongs to exactly one process group, which is identified by a positive integer process group ID. The progress group is made for manage several progress simply. The getpgrp function returns the process group ID of the current process.

```C
#include <unistd.h>
pid_t getpgrp(void);
// Returns: process group ID of calling process
```

By default, a child process belongs to the same process group as its parent. A process can change the process group of itself or another process by using the setpgid function:
```C
#include <unistd.h>
int setpgid(pid_t pid, pid_t pgid);
// Returns: 0 on success, -1 on error
```
The setpgid function changes the process group of process pid to pgid. If pid is zero, the PID of the current process is used. If pgid is zero, the PID of the process specified by pid is used for the process group ID. For example, if process 15213 is the calling process, then creates a new process group whose process group ID is 15213, and adds process 15213 to this new group.



### Other

此外还有很多进程的操作函数，例如 `sleep`, `snooze`, `pause`, `wait` 等，你可以使用 `man <function>` 来查看这些函数的文档。

## 进程的状态




## User and Kernel Modes

In order for the operating system kernel to provide an airtight process abstraction, the processor must provide a mechanism that restricts the instructions that an application can execute, as well as the portions of the address space that it can access.

Processors typically provide this capability with a mode bit in some control register that characterizes the privileges that the process currently enjoys. When the mode bit is set, the process is running in kernel mode (sometimes called supervisor mode). A process running in kernel mode can execute any instruction in the instruction set and access any memory location in the system.



## IPC

在UNIX中，文件（File）、信号（Signal）、无名管道（Unnamed Pipes）、有名管道（FIFOs）是传统IPC功能；新的IPC功能包括消息队列（Message queues）、共享存储段（Shared memory segment）和信号量（Semaphore）。以及 Socket 可以在不同主机的进程间进行通信。


## 系统调用

为什么应用开发时系统调用就像普通的函数调用一样？

系统调用遵循特殊的约定，需要使用汇编或者内嵌汇编的形式来处理参数和返回值的顺序以及存放位置。有人已经替我们做了这样的工作：标准库。通过将系统调用的细节和不同平台差异隐藏在标准库中。应用开发者可以不用关系这些繁杂细节的使用系统调用。例如文件操作函数 `open()` 就会在内部进行一个系统调用，由系统来进行文件操作。
