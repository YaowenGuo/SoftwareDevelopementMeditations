# Process

1. Process 概念和使用
    1. 抽象和虚拟
    2. API
    3. 安全
2. Process 实现（机制）
    1. 机制和策略
    2. 上下文切换
    3. 时钟中断 

3. Process 调度（策略）

4. Process 查看工具

5. 进程间通信

6. 并发安全


When we run a program on a modern system, we are presented with the illusion that our program is the only one currently running in the system. Our program appears to have exclusive use of both the processor and the memory. The processor appears to execute the instructions in our program, one after the other, without interruption. Finally, the code and data of our program appear to be the only objects in the system's memory. These illusions are provided to us by the notion of a process.

The classic definition of a process is an instance of a program in execution. Each program in the system runs in the context of some process. The context consists of the state that the program needs to run correctly. This state includes the program's code and data stored in memory, its stack, the contents of its general purpose registers, its program counter, environment variables, and the set of open file descriptors.


It turns out that one often wants to run more than one program at once; for example, consider your desktop or laptop where you might like to run a web browser, mail program, a game, a music player, and so forth. In fact, a typical system may be seemingly running tens or even hundreds of processes at the same time. Doing so makes the system easy to use, as one never need be concerned with whether a CPU is available; one simply runs programs. Hence our challenge:


The key abstractions that a process provides to the application:

- An independent logical control flow that provides the illusion that our program has exclusive use of the processor.
- A private address space that provides the illusion that our program has exclusive use of the memory system.

内存的虚拟化是另一个巨大话题，在单独的内存主题中探讨，我们在这里仅关注进程及其执行流以及处理器的虚拟化。


想要实现虚拟化，需要底层机制（low-level machinery）和上层策略（high-level intelligence）的配合实现
- 底层
    - 程序的上线文切换
- 上层
    - 调度策略

## The Abstraction: A Process

The abstraction provided by the OS of a running program is something we will call a process. As we said above, a process is simply a running program; we can summarize a process by taking an inventory of the different pieces of the system it accesses or affects during the course of its execution.

To understand what constitutes a process, we thus have to understand its `machine state`: what a program can read or update when it is running. At any given time, what parts of the machine are important to the execution of this program?


## API

```
CRUX: HOW TO CREATE AND CONTROL PROCESSES
What interfaces should the OS present for process creation and control? How should these interfaces be designed to enable powerful functionality, ease of use, and high performance?
```

现代操作系统都为并发运行程序提供了进程，为了编写的程序能够在不同的系统上得到最好的可移植性，UNIX 规范制定了 Posix 规范，用于在不同的系统上对用户能够提供统一的用户接口。

一个进程该有的 API:

1. 创建：
2. 控制： Process control is available in the form of signals, which can cause jobs to stop, continue, or even terminate.  ensures users can only control their own
processes.
3. 结束进程
4. 销毁

### Create

The fork() system call is used to create a new process [C63]. However, be forewarned: it is certainly the strangest routine you will ever
call.
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

Now the interesting part begins. The process calls the fork() system call, which the OS provides as a way to create a new process. The odd part: the process that is created is an (almost) exact copy of the calling process. That means that to the OS, it now looks like there are two copies of the program p1 running, and both are about to return from the fork() system call. The newly-created process (called the child, in contrast to the creating parent) doesn’t start running at main(), like you might expect (note, the “hello, world” message only got printed out once); rather, it just comes into life as if it had called fork() itself.

You might have noticed: the child isn’t an exact copy. Specifically, although it now has its own copy of the address space (i.e., its own private
memory), its own registers, its own PC, and so forth, the value it returns
to the caller of fork() is different. Specifically, while the parent receives
the PID of the newly-created child, the child receives a return code of
zero. This differentiation is useful, because it is simple then to write the
code that handles the two different cases (as above).

You might also have noticed: the output (of p1.c) is not deterministic.
When the child process is created, there are now two active processes in
the system that we care about: the parent and the child. Assuming we
are running on a system with a single CPU (for simplicity), then either
the child or the parent might run at that point. In our example (above),
the parent did and thus printed out its message first. In other cases, the
opposite might happen, as we show in this output trace:

prompt> ./p1
hello world (pid:29146)
hello, I am child (pid:29147)
hello, I am parent of 29147 (pid:29146)
prompt>

The CPU scheduler, a topic we’ll discuss in great detail soon, determines which process runs at a given moment in time; because the scheduler is complex, we cannot usually make strong assumptions about what it will choose to do, and hence which process will run first. This nondeterminism, as it turns out, leads to some interesting problems, particularly in multi-threaded programs; hence, we’ll see a lot more nondeterminism when we study concurrency in the second part of the book.

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



### Reaping Child Processes

When a process terminates for any reason, the kernel does not remove it from the system immediately. Instead, the process is kept around in a terminated state until it is reaped by its parent. When the parent reaps the terminated child, the kernel passes the child's exit status to the parent and then discards the terminated process, at which point it ceases to exist. A terminated process that has not yet been reaped is called a zombie.

When a parent process terminates, the kernel arranges for the init process to become the adopted parent of any orphaned children. The init process, which has a PID of 1, is created by the kernel during system start-up, never terminates, and is the ancestor of every process. If a parent process terminates without reaping its zombie children, then the kernel arranges for the init process to reap them. However, long-running programs such as shells or servers should always reap their zombie children. Even though zombies are not running, they still consume system memory resources.

A process waits for its children to terminate or stop by calling the waitpid function.

Sometimes, it is quite useful for a parent to wait for a child process to finish what it has been doing(block the parent iteslf). This task is accomplished with the wait() system call;

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

The execve function loads and runs a new program in the context of the current process. This system call is useful when you want to run a program
that is different from the calling program,

So unlike fork, which is called once but returns twice, execve is called once and never returns.

```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
    printf("hello world (pid:%d)\n", (int) getpid());
    int rc = fork();
    if (rc < 0) { // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc == 0) { // child (new process)
        printf("hello, I am child (pid:%d)\n", (int) getpid());
        char *myargs[3];
        myargs[0] = strdup("wc"); // program: "wc" (word count)
        myargs[1] = strdup("p3.c"); // argument: file to count
        myargs[2] = NULL; // marks end of array
        execvp(myargs[0], myargs); // runs word count
        printf("this shouldn’t print out");
    } else { // parent goes down this path (main)
        int rc_wait = wait(NULL);
        printf("hello, I am parent of %d (rc_wait:%d) (pid:%d)\n", rc, rc_wait, (int) getpid());
    }
    return 0;
}
```

In this example, the child process calls execvp() in order to run the program wc, which is the word counting program. In fact, it runs wc on the source file p3.c, thus telling us how many lines, words, and bytes are found in the file:

The fork() system call is strange; its partner in crime, exec(), is not
so normal either. What it does: given the name of an executable (e.g., wc),
and some arguments (e.g., p3.c), it loads code (and static data) from that executable and overwrites its current code segment (and current static
data) with it; the heap and stack and other parts of the memory space of
the program are re-initialized. Then the OS simply runs that program,
passing in any arguments as the argv of that process. Thus, it does not
create a new process; rather, it transforms the currently running program
(formerly p3) into a different running program (wc). After the exec()
in the child, it is almost as if p3.c never ran; a successful call to exec()
never returns.

```
TIP: GETTING IT RIGHT (LAMPSON’S LAW)
As Lampson states in his well-regarded “Hints for Computer Systems
Design” [L83], “Get it right. Neither abstraction nor simplicity is a substitute for getting it right.” Sometimes, you just have to do the right thing,
and when you do, it is way better than the alternatives. There are lots
of ways to design APIs for process creation; however, the combination
of fork() and exec() are simple and immensely powerful. Here, the
UNIX designers simply got it right. And because Lampson so often “got
it right”, we name the law in his honor.
```

- On Linux, there are six variants of exec(): execl, execlp(), execle(),
execv(), execvp(), and execvpe(). Read the man pages to learn more.

### Why? Motivating The API

Of course, one big question you might have: why would we build
such an odd interface to what should be the simple act of creating a new
process? Well, as it turns out, the separation of fork() and exec() is
essential in building a UNIX shell, because it lets the shell run code after
the call to fork() but before the call to exec(); this code can alter the
environment of the about-to-be-run program, and thus enables a variety
of interesting features to be readily built.

The shell is just a user program. It shows you a prompt and then
waits for you to type something into it. You then type a command (i.e.,
the name of an executable program, plus any arguments) into it; in most
cases, the shell then figures out where in the file system the executable
resides, calls fork() to create a new child process to run the command,
calls some variant of exec() to run the command, and then waits for the
command to complete by calling wait(). When the child completes, the
shell returns from wait() and prints out a prompt again, ready for your
next command.
The separation of fork() and exec() allows the shell to do a whole
bunch of useful things rather easily. For example:

In the example above, the output of the program wc is redirected into
the output file newfile.txt (the greater-than sign is how said redirection is indicated). The way the shell accomplishes this task is quite simple: when the child is created, before calling exec(), the shell closes
standard output and opens the file newfile.txt. By doing so, any output from the soon-to-be-running program wc are sent to the file instead
of the screen.

Figure 5.4 (page 8) shows a program that does exactly this. The reason
this redirection works is due to an assumption about how the operating
system manages file descriptors. Specifically, UNIX systems start looking
for free file descriptors at zero. In this case, STDOUT FILENO will be the
first available one and thus get assigned when open() is called. Subsequent writes by the child process to the standard output file descriptor,
for example by routines such as printf(), will then be routed transparently to the newly-opened file instead of the screen.

Here is the output of running the p4.c program:
```
prompt> ./p4
prompt> cat p4.output
32 109 846 p4.c
prompt>
```


You’ll notice (at least) two interesting tidbits about this output. First,
when p4 is run, it looks as if nothing has happened; the shell just prints
the command prompt and is immediately ready for your next command.
However, that is not the case; the program p4 did indeed call fork() to
create a new child, and then run the wc program via a call to execvp().
You don’t see any output printed to the screen because it has been redirected to the file p4.output. Second, you can see that when we cat the
output file, all the expected output from running wc is found. Cool, right?

UNIX pipes are implemented in a similar way, but with the pipe()
system call. In this case, the output of one process is connected to an inkernel pipe (i.e., queue), and the input of another process is connected
to that same pipe; thus, the output of one process seamlessly is used as
input to the next, and long and useful chains of commands can be strung
together. As a simple example, consider looking for a word in a file, and
then counting how many times said word occurs; with pipes and the utilities grep and wc, it is easy; just type grep -o foo file | wc -l
into the command prompt and marvel at the result.

Finally, while we just have sketched out the process API at a high level,
there is a lot more detail about these calls out there to be learned and
digested; we’ll learn more, for example, about file descriptors when we
talk about file systems in the third part of the book. For now, suffice it
to say that the fork()/exec() combination is a powerful way to create
and manipulate processes.

### fork 资源

After accepting the connection request, the server forks a child, which gets a complete copy of the server's descriptor table. 

Since the connected descriptors in the parent and child each point to the same file table entry, it is crucial for the parent to close its copy of the connected。

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

Beyond fork(), exec(), and wait(), there are a lot of other interfaces for interacting with processes in UNIX systems. For example, the
kill() system call is used to send signals to a process, including directives to pause, die, and other useful imperatives. For convenience,
in most UNIX shells, certain keystroke combinations are configured to
deliver a specific signal to the currently running process; for example,
control-c sends a SIGINT (interrupt) to the process (normally terminating
it) and control-z sends a SIGTSTP (stop) signal thus pausing the process
in mid-execution (you can resume it later with a command, e.g., the fg
built-in command found in many shells).

The entire signals subsystem provides a rich infrastructure to deliver
external events to processes, including ways to receive and process those
signals within individual processes, and ways to send signals to individual processes as well as entire process groups. To use this form of communication, a process should use the signal() system call to “catch”
various signals; doing so ensures that when a particular signal is delivered to a process, it will suspend its normal execution and run a particular piece of code in response to the signal. Read elsewhere [SR05] to learn
more about signals and their many intricacies.

This naturally raises the question: who can send a signal to a process,
and who cannot? Generally, the systems we use can have multiple people
using them at the same time; if one of these people can arbitrarily send
signals such as SIGINT (to interrupt a process, likely terminating it), the
usability and security of the system will be compromised. As a result,
modern systems include a strong conception of the notion of a user. The
user, after entering a password to establish credentials, logs in to gain
access to system resources. The user may then launch one or many processes, and exercise full control over them (pause them, kill them, etc.).
Users generally can only control their own processes; it is the job of the
operating system to parcel out resources (such as CPU, memory, and disk)
to each user (and their processes) to meet overall system goals.

```
ASIDE: THE SUPERUSER (ROOT)
A system generally needs a user who can administer the system, and is
not limited in the way most users are. Such a user should be able to kill
an arbitrary process (e.g., if it is abusing the system in some way), even
though that process was not started by this user. Such a user should also
be able to run powerful commands such as shutdown (which, unsurprisingly, shuts down the system). In UNIX-based systems, these special abilities are given to the superuser (sometimes called root). While most users
can’t kill other users processes, the superuser can. Being root is much like
being Spider-Man: with great power comes great responsibility [QI15].
Thus, to increase security (and avoid costly mistakes), it’s usually better
to be a regular user; if you do need to be root, tread carefully, as all of the
destructive powers of the computing world are now at your fingertips.
```

## 进程的状态




## User and Kernel Modes

In order for the operating system kernel to provide an airtight process abstraction, the processor must provide a mechanism that restricts the instructions that an application can execute, as well as the portions of the address space that it can access.

Processors typically provide this capability with a mode bit in some control register that characterizes the privileges that the process currently enjoys. When the mode bit is set, the process is running in kernel mode (sometimes called supervisor mode). A process running in kernel mode can execute any instruction in the instruction set and access any memory location in the system.


## IPC

在UNIX中，文件（File）、信号（Signal）、无名管道（Unnamed Pipes）、有名管道（FIFOs）是传统IPC功能；新的IPC功能包括消息队列（Message queues）、共享存储段（Shared memory segment）和信号量（Semaphore）。以及 Socket 可以在不同主机的进程间进行通信。


## 系统调用

为什么应用开发时系统调用就像普通的函数调用一样？

系统调用遵循特殊的约定，需要使用汇编或者内嵌汇编的形式来处理参数和返回值的顺序以及存放位置。有人已经替我们做了这样的工作：标准库。通过将系统调用的细节和不同平台差异隐藏在标准库中。应用开发者可以不用关系这些繁杂细节的使用系统调用。例如文件操作函数 `open()` 就会在内部进行一个系统调用，由系统来进行文件操作。


## Useful Tools

There are many command-line tools that are useful as well. For example, using the ps command allows you to see which processes are running; read the man pages for some useful flags to pass to ps. The tool top
is also quite helpful, as it displays the processes of the system and how
much CPU and other resources they are eating up. Humorously, many
times when you run it, top claims it is the top resource hog; perhaps it is
a bit of an egomaniac. The command kill can be used to send arbitrary signals to processes, as can the slightly more user friendly killall. Be
sure to use these carefully; if you accidentally kill your window manager,
the computer you are sitting in front of may become quite difficult to use.
Finally, there are many different kinds of CPU meters you can use to
get a quick glance understanding of the load on your system; for example,
we always keep MenuMeters (from Raging Menace software) running on
our Macintosh toolbars, so we can see how much CPU is being utilized
at any moment in time. In general, the more information about what is
going on, the better.

## Other

关于 fork 的改进观点：“A fork() in the road” by Andrew Baumann, Jonathan Appavoo, Orran Krieger, Timothy Roscoe. HotOS ’19, Bertinoro, Italy. A fun paper full of fork()ing rage. Read it to get an opposing viewpoint on the UNIX process API. Presented at the always lively HotOS workshop, where systems researchers go to present extreme opinions in the hopes of pushing the community in new directions.