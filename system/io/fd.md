# FD

IO 是一种稀缺资源，存在多个进程同时访问的可能性。为了最大效率的利用 IO 设备的能力，同时保护数据不被别的进程访问和破坏。系统必须限制进程的 IO 访问，为进程提供虚拟的 IO 访问。操作系统将所有的 IO 访问抽象为文件。不同的进程可能打开同一个文件，系统并不会为每个进程新打开一个文件，这会浪费很多的系统资源。而是由系统维护打开一个文件，给发开该文件的进程添加一个对该文件的索引。每个进程都能打开不同的一组文件，系统为每个进程维护了一个描述符表（Descriptor table）。FD 就是描述符表的一个索引。

除非你对内核如何表示打开的文件有个清楚的蓝图，否则文件共享的可能会非常令人困惑。内核使用三个相关的数据结构表示打开的文件：


Descriptor table. Each process has its own separate descriptor table whose entries are indexed by the process's open file descriptors. Each open descriptor entry points to an entry in the file table.
File table. The set of open files is represented by a file table that is shared by all processes. Each file table entry consists of (for our purposes) the current file position, a reference count of the number of descriptor entries that currently point to it, and a pointer to an entry in the v-node table. Closing a descriptor decrements the reference count in the associated file table entry. The kernel will not delete the file table entry until its reference count is zero.
v-node table. Like the file table, the v-node table is shared by all processes. Each entry contains most of the information in the stat structure, including the st_mode and st_size members.



FD（File Descriptor）文件描述符在形式上是非负整数，它是一个索引值，指向内核为每个进程所维护的该进程打开文件的记录表。当程序打开一个现有文件或者创建一个新文件时，内核向进程返回一个文件描述符。在Linux系统中，一切设备都视作文件，文件描述符为Linux平台设备相关的编程提供了一个统一的方法。
FD作为文件句柄的实例，可以用来表示一个打开的文件，一个打开的网络流(socket)，管道或者资源（如内存块），输入输出(in/out/error)。

除了打开文件会申请fd之外，每打开一个socket都会增加一个fd，每次创建一个线程也会打开一个fd。系统中经常会有fd泄露的问题存在，所以O上发生NE时会将fd信息打印到tombstone文件中。对于JAVA的，只有自己想办法监控了。


相比较传统的内存泄漏，FD泄漏在大部分情况下不会出现内存不足的情况，所以出现问题的时候会更加隐晦。由于发生FD泄漏的时候内存可能不会出现不足，所以不会出发系统的GC操作，导致只有通过crash进程的方式去自我恢复。事实上在很多情况下，就算触发系统GC，也不一定能够回收已经创建的句柄文件。

如下Java层的Error Msg均有fd泄漏的嫌疑：

```
"Too many open files"\
"Could not allocate JNI Env"\
"Could not allocate dup blob fd"\
"Could not read input channel file descriptors from parcel"\
"pthread_create * "\
"InputChannel is not initialized"\
"Could not open input channel pair"
```
系统最大打开文件描述符数
```
cat /proc/sys/fs/file-max
```

进程最大打开文件描述符数，fd 限制

```
$ ulimit -n
32768
# 或者
$ cat /proc/16539/limits
Limit                     Soft Limit           Hard Limit           Units
...
Max open files            32768                32768                files
...
```
修改这个配置：
```
sudo vi /etc/security/limits.conf
写入以下配置,soft软限制，hard硬限制y

*                soft    nofile          65536
*                hard    nofile          100000
```

查看打开的文件描述符

```
$ ls -l /proc/<pid>/fd
PERMISSION  GROUP_ID USER_ID   CREATE_TIME  FD   FILE_NAME
```
或者
```

$ lsof -p <pid>
COMMAND   PID   USER   FD  TYPE   DEVICE  SIZE/OFF   NODE NAME
```

```
COMMAND：进程的名称
PID：进程标识符
USER：进程所有者
FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt等
TYPE：文件类型，如DIR、REG等
DEVICE：指定磁盘的名称
SIZE：文件的大小
NODE：索引节点（文件在磁盘上的标识）
NAME：打开文件的确切名称
```

## 常用文件描述符

```
lrwx------ 1 u0_a588 u0_a588 64 2023-08-31 11:20 0 -> /dev/null
权限          groupId userId     Date       Time  fd   file 

0   stdin              /dev/null
1   stdout             /dev/null
2   stderr             /dev/null
```

参考：

https://www.jianshu.com/p/43309f0dc669

08-31 15:52:18.272  6245  6245 E RTC-DEMO: socket fd num: 32755
08-31 15:52:18.272  6245  6245 E RTC-DEMO: socket fd num: 32756
08-31 15:52:18.272  6245  6245 E RTC-DEMO: socket fd num: 32758
08-31 15:52:18.272  6245  6245 E RTC-DEMO: socket fd num: -1


```
在包含sys/select.h之前，可能会增加FD_SETSIZE过度__FD_SETSIZE（在sys/types.h中定义）。

出发一样，我们可以设置FD_SETSIZE到2048：

#include <sys/types.h> 
#undef __FD_SETSIZE 
#define __FD_SETSIZE 2048 
#include <sys/select.h> 
#include <stdio.h> 

int main() 
{ 
    printf("FD_SETSIZE:%d sizeof(fd_set):%d\n",FD_SETSIZE,sizeof(fd_set)); 
    return 0; 
} 
会打印：

FD_SETSIZE：2048的sizeof（FD_SET）：128

但是，如果FD_SETSIZE是在修改后的值之后，sizeof（fd_set）应该是256（2048/8）而不是128（1024/8）。 这是因为包含sys/types.h已经用1024定义了fd_set。

为了使用更大fd_set，能够以限定延伸一个这样的：

#include <sys/select.h> 
#include <stdio.h> 

#define EXT_FD_SETSIZE 2048 
typedef struct 
{ 
    long __fds_bits[EXT_FD_SETSIZE/8/sizeof(long)]; 
} ext_fd_set; 

int main() 
{ 
    ext_fd_set fd; 
    int s; 
    printf("FD_SETSIZE:%d sizeof(fd):%ld\n", EXT_FD_SETSIZE, sizeof(fd)); 
    FD_ZERO(&fd); 
    while (((s=dup(0)) != -1) && (s < EXT_FD_SETSIZE)) 
    { 
     FD_SET(s, &fd); 
    } 
    printf("select:%d\n", select(EXT_FD_SETSIZE,(fd_set*)&fd, NULL, NULL, NULL)); 
    return 0; 
} 

考虑增加'FD_SETSIZE'是一件非常愚蠢的事情。 2048个并发连接（或者更确切地说，多于这个）恰好在'epoll_wait'远远优于'select'和'poll'的范围内，因为它不需要每次复制8千字节的数据，并且不需要每次遍历两千个描述符。
```
https://blog.csdn.net/j6915819/article/details/81015434/
https://zhuanlan.zhihu.com/p/554348972
https://blog.csdn.net/chuyouyinghe/article/details/130491976
https://blog.csdn.net/oncealong/article/details/103984096
https://juejin.cn/post/7058098018683191310
