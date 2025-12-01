# Proc 
Linux provides a clever mechanism, called the /proc filesystem, that allows user mode processes to access the contents of kernel data structures. The /proc filesystem exports the contents of many kernel data structures as a hierarchy of text files that can be read by user programs. 

/proc 目录是 Linux 系统的一个伪文件系统，它描述了系统和进程相关的各种信息，为访问内核数据结构提供了一个接口。我们可以通过打开这个目录下的一些文件来查看该进程的内存使用情况，例如：`cat /proc/1464/maps`。下面是内存相关的文件或目录：

Linux 操作系统会为每一个进程都在 /proc 目录下创建一个目录，目录名就是进程号。我们可以通过打开这个目录下的一些文件来查看该进程的内存使用情况，例如：

```
/proc
|-- 1               # [DIR] 进程目录，目录名是进程号
|   ...
|                   内存信息
|-- zoneinfo        # 内存的节点和区域信息，对于研究物理内存管理非常有用
|-- buddyinfo       # 伙伴系统信息
|-- pagetypeinfo    
|-- meminfo         # 整个内存的统计信息。
|-- vmallocinfo     # 提供 vmalloced/vmaped 的区间信息，每个区域一行。包含区域的虚拟地址空间、字节大小，创建者的调用信息、以及根据区间的类型的不同附加信息
|-- vmstat          # 当前系统虚拟内存的统计数据。
|-- swaps           # 交换空间使用率

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
|-- iomem           # IO 的映射信息
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


|-- kpagecgroup     # 该文件每个内存页保存一个所属 cgroup 的 64 位 inode.
|-- kpagecount      # 每一页包含一个64位计数，表示该页被映射的次数，按照 PFN 值索引。
|-- kpageflags      # 每一页包含一个64位的标志，表示该页的属性，按照 PFN 索引。


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


### [pid]/pagemap (since Linux 2.6.25)

该文件展示了进程的虚拟页向物理页或交换空间的映射。每个虚拟页对应一个 64 位的值，位的设置如下：

63: 如果设置了，则当前页在 RAM 中。
62: 如果设置，当前页在交换空间。
61: (since Linux 3.5) 当前页是文件映射页或者共享匿名页。
60–57: (since Linux 3.11) 置 0
56: (since Linux 4.2) 该页为独占页。
55: (since Linux 3.11) PTE is soft-dirty (see the kernel source file
                     Documentation/admin-guide/mm/soft-dirty.rst).
54–0: 如果该页面存在于RAM中（位63），然后这些位提供页帧号，可以用于索引 `/proc/kpageflags` 和 `/proc/kpageCount`。如果页面存在于交换区（位62），然后 4-0 位为交换类型，位54–5表示交换区的偏移。

为了高效的使用 `/proc/[pid]/pagemap`，可以通过 `/proc/[pid]/maps` 确定哪些内存空间实际映射了，从而跳过未使用的区域。

### [pid]/maps

```
地址区间                权限   偏移                  对应的文件
address               erms offset  dev   inode    pathname
00400000-00452000     -xp 00000000 08:02 173521   /usr/bin/dbus-daemon
...
```
每一行都是内核中一个虚拟内存区域VMA（Virtual Memory Area)。也可以理解为段。
各列的含义：
- 第一列地址区间: `00400000-00452000` 是该虚拟内存段的开始和结束位置，需要说明的是，该地址是前闭后开区间 `[start, end)`，即结束地址不是该断占用的，它可能是下一段的起始地址。
- 第二列内存权限: `r-xp` 内存段的权限，分别是可读、可写、可运行、私有或共享，最后一位p代表私有，s代表共享。例如程序段 `r-xs`，数据段 `r--p`，还有用户保护栈越界触发中断的 `---p`。
- 第三列文件偏移: `00000000` 该虚拟内存段起始地址在对应的映射文件中以页为单位的偏移量，对匿名映射，它等于0或者vm_start/PAGE_SIZE
- 第四列设备号  : `08:02` 文件的主设备号和次设备号。对匿名映射来说，没有对应的磁盘文件，所以没有设备号，始终为00:00。
- 第五列 innode: `173521` 被映射到虚拟内存的文件的索引节点号，通过该节点可以找到该文件，匿名映射的该列始终为00:00。
- 第六列映射文件: `/bin/bash` 被映射到虚拟内存的文件名称。后面带(deleted)的是内存数据，可以被销毁。对于文件映射，是映射的文件名。对匿名映射来说，是此段虚拟内存在进程中的角色：[stack]表示在进程中作为栈使用，[heap]表示堆。如果在申请时没有设置名称，也可能不显示名称。


### [pid]/smaps (Segment Maps)

/proc/{pid}/smaps 可以看做 /proc/<pid>/maps 的增强版。maps 只有虚拟地址空间占用情况, 而实际的具体的 memory 占用物理内存需要查看 proc/pid/smaps. smaps 文件是基于 maps 的扩展，展示进程的内存消耗的各种信息，比 maps 文件更为详细。当评估一个进程的内存占用时, 需要衡量它的虚拟内存空间占用, 物理内存占用, 以及它和其他进程的平均内存占用。

内存大小、Rss、Pss、Shared_Clean、Shared_Dirty、Private_Clean、Private_Dirty、Referenced、Anonymous、AnonHugePages、ShmemHugePages、ShmemPmdMapped、Swap、KernelPageSize、MMUPageSize、Locked、ProtectionKey、VmFlags等。

VSS- Virtual Set Size 虚拟耗用内存（包含共享库占用的内存）
RSS- Resident Set Size 实际使用物理内存（包含共享库占用的内存）
PSS- Proportional Set Size 实际使用的物理内存（比例分配共享库占用的内存）
USS- Unique Set Size 进程独自占用的物理内存（不包含共享库占用的内存）

这个文件显示每个进程映射的内存消耗。(pmap(1)命令以更容易解析的形式显示类似的信息。)对于每个映射，都有如以下所示一系列行:
映射中干净和脏私有页面的数量
```
00400000-0048a000 r-xp 00000000 fd:03 960637       /bin/bash # 跟 maps 里显示的映射信息一样
Size:                552 kB                                  # 就是第一行的地址区间的大小。由于内存的延迟分配策略，该值一般小于实际分配的物理空间。
Rss:                 460 kB                                  # 已经加载到物理内存的页。Rss=Shared_Clean+Shared_Dirty+Private_Clean+Private_Dirty
Pss:                 100 kB                                  #
Shared_Clean:        452 kB                                  # 映射中的干净页面。share/private：该页面是共享还是私有。
Shared_Dirty:          0 kB                                  # 映射中的脏页面。
Private_Clean:         8 kB                                  # 私有的干净页面
Private_Dirty:         0 kB                                  # 自由的脏页面
Referenced:          460 kB                                  # 当前页面被标记为已引用或者包含匿名映射，如果该标志设置了，就 不能将该页移出。
Anonymous:             0 kB                                  # 匿名映射的物理内存
AnonHugePages:         0 kB                                  #
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
Swap:                  0 kB                                  # 使用过但是被换出到交换区的内存大小
KernelPageSize:        4 kB                                  # 内核用于支持虚拟内存空间占用的页大小。绝大多数情况等于 MMU，一个反例是 ppc64内核，使用 64 kb 的页大小的内核尺寸仍可能使用 4kb 的 MMU 页面会不同。
MMUPageSize:           4 kB                                  # MMU使用的页面大小
Locked:                0 kB                                  # 常驻物理内存的大小，这些页不会被换出
ProtectionKey:         0                                     # X86 专用，保护键占用，详情查看 pkeys(7)
VmFlags: rd ex mr mw me dw                                   # 跟虚拟内存相关的内核标志位，详情如下：
```
第一行显示了与 `/proc/[pid]/maps` 文件中映射相同的信息，下面几行显示了映射的大小。

延迟分配：延迟分配就是当进程申请内存的时候，Linux 会给他先分配页，但是并不会区建立页与页框的映射关系，就是说并不会分配物理内存，而当真正使用的时候，就会产生一个缺页异常，硬件跳转page fault处理程序执行，在其中分配物理内存，然后修改页表(创建页表项)。异常处理完毕，返回程序用户态，继续执行。

share/private：该页面是共享还是私有。
dirty/clean：该页面是否被修改过，如果修改过（dirty），在页面被淘汰的时候，就会把该脏页面回写到交换分区（换出，swap out）。有一个标志位用于表示页面是否dirty。

share/private_dirty/clean 计算逻辑：
查看该 page 的引用数，如果引用>1，则归为shared，如果是1，则归为private，同时也查看该page的flag，是否标记为_PAGE_DIRTY，如果不是，则认为干净的。

举个计算Pss的例子：
如果进程A有x个private_clean页面，有y个private_dirty页面，有z个shared_clean仅和进程B共享，有h个shared_dirty页面和进程B、C共享。那么进程A的Pss为：
x + y + z/2 + h/3

"VmFlags" 行使用到的内核标志：
```
rd  - readable
wr  - writable
ex  - executable
sh  - shared
mr  - may read
mw  - may write
me  - may execute
ms  - may share
gd  - stack segment grows down
pf  - pure PFN range
dw  - disabled write to the mapped file
lo  - pages are locked in memory
io  - memory mapped I/O area
sr  - sequential read advise provided
rr  - random read advise provided
dc  - do not copy area on fork
de  - do not expand area on remapping
ac  - area is accountable
nr  - swap space is not reserved for the area
ht  - area uses huge tlb pages
sf  - perform synchronous page faults (since Linux 4.15)
nl  - non-linear mapping (removed in Linux 4.0)
ar  - architecture specific flag
wf  - wipe on fork (since Linux 4.14)
dd  - do not include area into core dump
sd  - soft-dirty flag (since Linux 3.13)
mm  - mixed map area
hg  - huge page advise flag
nh  - no-huge page advise flag
mg  - mergeable advise flag
um  - userfaultfd missing pages tracking (since Linux  4.3)
uw  - userfaultfd wprotect pages tracking (since Linux 4.3)
```

也可以查看 `[pid]/smaps_rollup` 来获取整个进程的汇总信息。smaps_rollup 的 输出和 smaps 的信息基本一致，只不过是不再分段，而是整个进程的。

### mem

This file can be used to access the pages of a process's memory through open(2), read(2), and lseek(2).

可以操作该文件实际修改另一个进程的数据。可以参看：
[五、替换进程的字符串](https://www.cnblogs.com/my_life/articles/12068025.html)

### [pic]/stack (since Linux 2.6.29)

这个文件提供了该进程的内核堆栈中的函数调用的符号跟踪。只有在使用 CONFIG_STACKTRACE 配置选项构建内核时才会提供此文件。


0x7f e67c 9000