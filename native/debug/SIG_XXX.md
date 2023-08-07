# 错误信息

错误信息包含三部分：
- 错误信号
- 寄存器信息
- 方法调用栈

## 常见的错误

- 野指针
- 空指针
- 数组越界
- 堆栈溢出
- 内存泄漏



### 错误信号

错误信号包括 `信号量` 和 `错误码`，例如 `signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x0` 中 `signal 11 (SIGSEGV)` 就是信号量，`code 1 (SEGV_MAPERR)` 就是错误码；然后是对错误码的详细描述。

SIG 是信号名的通用前缀, 可以使用 `kill -l` 查看该系统支持的信号量。结果中，编号为1 ~ 31的信号为传统UNIX支持的信号，是不可靠信号(非实时的)，编号为32 ~ 63的信号是后来扩充的，称做可靠信号(实时信号)。不可靠信号和可靠信号的区别在于前者不支持排队，可能会造成信号丢失，而后者不会。

Linux发行版中，有着 `/usr/include/**/signal.h` 这样的头文件，定义Linux系统中信号类型。Linux 中 32个信号及其含义如下：

```
信号	含义
#define SIGHUP 1	终端挂起或控制进程终止
#define SIGINT 2	终端中断(Ctrl+C 组合键)
#define SIGQUIT 3	终端退出(Ctrl+\组合键)
#define SIGILL 4	非法指令
#define SIGTRAP 5	debug 使用，由断点指令产生
#define SIGABRT 6	由 abort(3)发出的退出指令
#define SIGIOT 6	IOT 指令
#define SIGBUS 7	总线错误
#define SIGFPE 8	浮点运算错误
#define SIGKILL 9	杀死、终止进程
#define SIGUSR1 10	用户自定义信号 1
#define SIGSEGV 11	段违法访问(无效的内存段)
#define SIGUSR2 12	用户自定义信号 2
#define SIGPIPE 13	向非读管道写入数据
#define SIGALRM 14	闹钟
#define SIGTERM 15	软件终止
#define SIGSTKFLT 16	栈异常
#define SIGCHLD 17	子进程结束
#define SIGCONT 18	进程继续
#define SIGSTOP 19	停止进程的执行，只是暂停
#define SIGTSTP 20	停止进程的运行(Ctrl+Z 组合键)
#define SIGTTIN 21	后台进程需要从终端读取数据
#define SIGTTOU 22	后台进程需要向终端写数据
#define SIGURG 23	有"紧急"数据
#define SIGXCPU 24	超过 CPU 资源限制
#define SIGXFSZ 25	文件大小超额
#define SIGVTALRM 26	虚拟时钟信号
#define SIGPROF 27	时钟信号描述
#define SIGWINCH 28	窗口大小改变
#define SIGIO 29	可以进行输入/输出操作
#define SIGPOLL	SIGIO
#define SIGPWR 30	断点重启
#define SIGSYS 31	非法的系统调用
#define SIGUNUSED 32	未使用信号
```

> SIGSEGV(SEGV_MAPERR)

SEGV 是 segmentation violation 的缩写
在 POSIX 兼容的平台上，SIGSEGV 是当一个进程执行了一个无效的内存引用，或发生段错误时发送给它的信号。SIGSEGV 的符号常量在头文件 signal.h 中定义。因为在不同平台上，信号数字可能变化，因此符号信号名被使用。通常，它是信号11。


对于不正确的内存处理,如当程序企图访问 CPU 无法定址的内存区块时,计算机程序可能抛出 SIGSEGV。操作系统可能使用信号栈向一个处于自然状态的应用程序通告错误，由此，开发者可以使用它来调试程序或处理错误。
在一个程序接收到 SIGSEGV 时的默认动作是异常终止。这个动作也许会结束进程，但是可能生成一个核心文件以帮助调试，或者执行一些其他特定于某些平台的动作。
SIGSEGV可以被捕获。也就是说，应用程序可以请求它们想要的动作，以替代默认发生的动作。这样的动作可以是忽略它、调用一个函数，或恢复默认的动作。在一些情形下，忽略 SIGSEGV 导致未定义行为。
一个应用程序可能处理SIGSEGV的例子是调试器，它可能检查信号栈并通知开发者目前所发生的，以及程序终止的位置。

SIGSEGV通常由操作系统生成，但是有适当权限的用户可以在需要时使用kill系统调用或kill命令（一个用户级程序，或者一个shell内建命令）来向一个进程发送信号。


例如，空指针访问：

```
2022-05-10 12:06:40.549 23488-23488/? A/DEBUG: signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x0
2022-05-10 12:06:40.549 23488-23488/? A/DEBUG: Cause: null pointer dereference
```

没有分配的地址

```
T* pointer = (T*) 0x0000007ffbb43df0;
pointer->getValue();
```

```
022-05-10 12:26:44.739 3788-3788/? A/DEBUG: signal 11 (SIGSEGV), code 2 (SEGV_ACCERR), fault addr 0x7ffbb43e20
```
