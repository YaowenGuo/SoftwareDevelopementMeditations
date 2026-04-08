# Proc 
Linux provides a clever mechanism, called the /proc filesystem, that allows user mode processes to access the contents of kernel data structures. The /proc filesystem exports the contents of many kernel data structures as a hierarchy of text files that can be read by user programs. 

/proc 目录是 Linux 系统的一个伪文件系统，它描述了系统和进程相关的各种信息，为访问内核数据结构提供了一个接口。我们可以通过打开这个目录下的一些文件来查看该进程的内存使用情况，例如：`cat /proc/1464/maps`。下面是内存相关的文件或目录：

Linux 操作系统会为每一个进程都在 /proc 目录下创建一个目录，目录名就是进程号。我们可以通过打开这个目录下的一些文件来查看该进程的内存使用情况，例如：

```
/proc
|-- 1               # [DIR] 进程目录，目录名是进程号
|   ...
|                   内存信息
|-- meminfo         # 整个内存的统计信息。
|-- swaps           # 交换空间使用率
|-- zoneinfo        # 内存的节点和区域信息，对于研究物理内存管理非常有用
|-- buddyinfo       # 伙伴系统信息
|-- pagetypeinfo    
|-- vmallocinfo     # 提供 vmalloced/vmaped 的区间信息，每个区域一行。包含区域的虚拟地址空间、字节大小，创建者的调用信息、以及根据区间的类型的不同附加信息
|-- vmstat          # 虚拟内存的统计数据。
|-- iomem           # 物理内存的映射信息
|-- kpagecgroup     # 该文件每个内存页保存一个所属 cgroup 的 64 位 inode.
|-- kpagecount      # 每一页包含一个64位计数，表示该页被映射的次数，按照 PFN 值索引。
|-- kpageflags      # 每一页包含一个64位的标志，表示该页的属性，按照 PFN 索引。


                    内核和系统
|-- cmdline         # 内核的启动命令，包含启动内核的参数
|-- config.gz
|-- stat            # 系统启动以来的内核统计信息，
|-- kmsg            # 内核相关的信息，没有读取权限
|-- loadavg         # 最后1、5和15分钟的平均负荷
|-- locks           # 内核锁
|-- sys             # [DIR] 系统和内核信息，可以通过修改其内容更改内核中的参数。
|-- modules         # 加载模块列表

                    设备
|-- bus             # [DIR] 系统中
|-- consoles        # 有哪些控制台
|-- cpuinfo         # CPU 的相关信息
|-- devices         # 可用的设备（块和字符）
|-- diskstats
|-- partitions      # 系统已知的分区表
|-- driver          # [DIR] 各种驱动程序的分组
|-- ioports         # IO 的端口使用情况

                    安全
|-- crypto          # 加密信息
|-- execdomains     # execdomains，与安全相关

                    文件系统
|-- filesystems     # 支持的文件系统
|-- fs              # [DIR] 文件系统参数
|-- mounts          # 挂载的文件系统

                    中断
|-- interrupts      # 中断统计信息
|-- irq             # [DIR] ?
|-- softirqs        # 提供每个cpu自启动时间以来处理的软中断统计

|                   其它信息
|-- cgroups
|-- misc            # ?
|-- kallsyms
|-- key-users
|-- keys
|-- sysrq-trigger
|-- sysvipc         # Info of SysVIPC Resources (msg, sem, shm)	
|-- timer_list
|-- tty             # [DIR] tty 信息
|-- uptime          # 时间
`-- version         # 内核版本信息
```


每个进程有一个单独的目录，目录名就是该进程的 ID, 提供进程相关的信息

```
[PID]               程序相关
|-- comm            # command, 进程运行的程序的名字，如 bash、cp、cat
|-- exe             # link 该进程对应的程序的链接
|-- cmdline         # 该进程的启动命令
|-- attr            # [DIR] 进程相关的属性
|-- cwd             # 该进程启动的目录的链接
|-- environ         # 环境变量的值
|-- limits          # 当前进程的限制，包括内存，端口等等
|-- coredump_filter # 核心转储过滤设置


                    内存相关
|-- stat            # 进程的统计信息，ps 中的大部分信息都是来自该文件
|-- statm           # 提供有关内存使用情况(以页为度量单位)的信息。不易阅读
|-- status          # 用于代替 stat 和 statm
|-- map_files       # [DIR] 该目录包含与内存映射文件相对应的条目，就是 maps 中有实际映射文件。
|-- maps            # 虚拟内存的映射关系
|-- mem             # 当前进程所占用的内存空间，由open、read和lseek等系统调用使用，不能被用户读取；
|-- pagemap         # 这个文件显示每个进程的虚拟页到物理页帧或交换区域的映射。
|-- smaps           # 每个 VMA 的详细统计数据和标志位
|-- smaps_rollup

|-- oom_adj         # 2.6.36 开始，偏向使用 oom_score_adj
|-- oom_score       # 该文件显示内核为 OOM-killer 选择进程而给该进程的当前分数。
|-- oom_score_adj   # 这个文件可以用来调整 `badness heuristic` 用于在内存不足的情况下选择哪个进程会被终止的。

|-- autogroup       # 
|-- auxv
|-- cgroup
|-- clear_refs
|-- cpuset          # ？

|-- fd              # [DIR] 该进程的文件描述符目录，每个文件描述符对对应一个软连接，名字是描述符 ID.
|-- fdinfo          # [DIR] 文件描述符信息
|-- gid_map         
|-- io              

|-- mountinfo       
|-- mounts
|-- mountstats
|-- net
|-- ns
|-- personality
|-- projid_map
|-- root -> /       # 根目录的链接
|-- schedstat
|-- setgroups
|-- stack           # 这个文件提供了这个进程的内核堆栈中的函数调用的符号跟踪。
|-- syscall
|-- task            # [DIR] 线程信息，目录结构和进程基本一致，大部分都是和进程公用的。
|-- timens_offsets
|-- timers
|-- timerslack_ns
|-- uid_map
`-- wchan
```

参考：

https://www.kernel.org/doc/Documentation/filesystems/proc.txt
https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/proc.html
