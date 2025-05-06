# ps(Process Status)

ps 是一个进程查看的基本命令，运用该命令可以确定有哪些进程正在运行和运行地状态、 进程是否结束、进程有没有僵死、哪些进程占用了过多地资源等等。总之大部分信息均为可以通过执行该命令得到地。

根据选项输出进程以及相关信息。使用方法 `ps [参数]`。 Linux ps 实现同时支持了 UNIX，BSD, GNU 格式的选项，这里只介绍 UNIX 格式的选项，其它格式的选项在不同系统上可能是不支持的。

ps 默认输出与当前用户相同用户id并且与当前终端关联的进程。


可用选项

1. 控制选择的进程范围
```
-A 或 -e    显示所有进程,环境变量
-a          除会话负责进程（命令行执行命令就是 bash 自身）以及没有与终端关联的进程（不是由终端创建的进程及子进程）之外的所有进程。
-d          除会话负责进程之外的所有进程。
-N          选择除满足指定条件外的所有过程(否定选择)。
```
2. 通过列表指定要选择的进程

使用空白或者逗号分割的列表指定要选择的进程。可以多次指定，例如：ps -p "1 2" -p 3,4。

```
-C cmdlist  列出命令名列表中的进程。注意，命令名和命令行不一样。
-G grplist  列出实际组名或组ID在grplist列表中的进程。真实组ID标识创建进程的用户组。
-g grplist  列出会话或者有效组名的所有进程。根据会话或有效组名选择。当 grplist 都是数字时，或当做会话处理。只有在 `--group` 指定了组名的情况下，才当做组 ID 处理。
-p pidlist  列出进程 ID 在 pidlist 列表中的所有进程。
-s sesslist 使用会话 ID 指定要列出的进程。
-t ttylist  列出所有与指定 ttylist 列表中的终端关联的进程。终端可以使用多种格式指定：/dev/ttyS1, ttyS1, S1。使用 “-” 筛选所有未与终端关联的进程。
-U userlist 筛选真实用户名或ID在userlist列表中的进程。真实用户是指创建该进程的用户。
-u userlist 筛选有效用户名或ID在userlist列表中的进程。The effective user ID describes the user whose file access permissions are used by the process (see geteuid(2)). Identical to U and --user.
```

3. 输出格式控制参数

这些选项用于选择 ps 输出的信息，输出可能因版本而不同。

```
-c          显示-l选项的不同调度器信息。
-f          完成的格式列表。该选项可以与很多 UNIX 风格的参数一起使用以增有有用的列。同时也会在列表中增加命令行参数输出。当和 `-L` 一起使用时，会增加 NLWP(number of threads)和 LWP(thread ID)列。
-F          同 -f，增加额外的信息。
-M          增加安全数据列。
-o format   跟 -o 类似，但是设置了默认的列。与 `-o pid,format,state,tname,time,command` 或 `-o pid,format,tname,time,cmd`相同。
-O format   指定数据输出格式。参数在 `输出格式指定` 中说明。
-P          Add a column showing psr.
```

4. 线程选项

```
-L          显示线程，一般通过 LWP 和 NLWP 列区分。
-m          在进程之后显示线程。
-T          显示线程，可能带有 SPID 列。
```

5. 输出格式指定

更详细说明参考 man 手册。

```
USER：创建进程的用户

PID：进程ID

%CPU：进程占用CPU的百分比

%MEM：进程占用物理内存的百分比

VSZ：进程占用虚拟内存的大小（单位KB）

RSS：进程占用实际物理内存的大小（单位KB）

TTY：进程在哪个终端运行。

STAT：进程状态
C   : CPU的占用率，格式为百分比。
START: 进程开始启动的时间

TIME：进程使用的CPU（运算）时间

COMMAND：调用进程的命令
```


查看进程
```
ps | grep <name>
```

USER    PID   PPID VSZ     RSS    WCHAN ADDR S NAME
u0_a355 19907 639  2441608 258964 0     0    S tech.yaowen.test

可以通过进程的pid或者user属性来查找相应进程下的线程

查看某进程下的线程
```
ps -T | grep [<USER>|<PID>]
```
USER 或者 PID 选其一即可。

## kill

kill 命令用于终止进程
例如： kill -9 [PID]
-9 表示强迫进程立即停止

通常用 ps 查看进程 PID ，用 kill 命令终止进程