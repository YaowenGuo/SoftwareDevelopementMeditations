# 工具及监控

掌握前面的内存知识能帮我们在开发中避免内存使用陷阱、高效的利用内存。也了解了系统提供的信息，及时没有任何工具的情况也也能定位内存问题。本章将丰富内存信息的工具箱，介绍一些提高效率的工具以及内存监控的手段和工具帮助高效的发现和定位问题。

## 内存问题定位工具

free 用于查看物理内存的使用情况。除此外 `/proc/meminfo` 也提供了相关的物理内存使用情况。
可以使用 `cat /proc/self/maps` 和 `cat /proc/<process id>/maps` 获得更多内存信息。

adb shell dumpsys meminfo xxx.xxx.xx 安卓进程的内存统计。

pmap 命令本质上是一个用于解析和友好显示 /proc/<pid>/maps 文件内容的工具

 /kernel/Documentation/filesystems/proc.txt

 MemAvailable = free - kernel reserved memory + ative file + inactive file + SReclaimable - 2 * zone low water mark
Cached = All file page - buffers - swapping = Active file + Inactive file + Unevictable file - Buffers
Slab = SReclaimable + SUnreclaimable
Active = Active(anon) + Active(file)
Inactive = Inactive(anon) + Inactive(file)
AnonPages + Buffers + Cached = Active + Inactive
Buffers + Cached = Active(file) + Inactive(file)
SwapTotal = SwapFree + SwapUsed(Not SwapCached)
KernelStack = the number of kernel task * Stack Size(16K)
Kernel Memory Usage = KernelStack + Slab + PageTables + Shmem + Vmalloc
Native Memory Usage = Mapped + AnonPages + Others

（1）三大核心工具

- slabtop：实时查看Slab分配器各对象缓存情况，定位异常增长的内核对象（如dentry、buffer_head），排查内存泄漏。

- cat /proc/iomem：查看内核空间各区域的占用情况，识别模块加载区、固定映射区的地址冲突。

- perf mem：追踪页错误和TLB失效，量化内存布局缺陷对性能的影响，例如频繁页错误可能是内存布局不合理导致。（2）深度调试工具ftrace：跟踪__alloc_pages调用栈，定位高频内存分配热点，优化分配策略。crash：系统崩溃后分析mm_struct和page结构，查看页标志（脏页、不可回收页），定位崩溃原因。KASAN：编译内核时启用，检测内存越界、使用后释放等错误，精准定位内核空间非法访问。

(1)Linux命令行工具之top/htop 命令：top 命令是 Linux 系统中常用的性能分析工具，就像一个实时监控系统的 “指挥官”，可以实时显示系统中各个进程的资源占用状况，类似于 Windows 的任务管理器 。它的界面主要分为两个部分，前 5 行展示的是系统的整体性能，包括系统运行时间、平均负载、CPU 使用率、内存使用情况等；光标下面部分是系统中每个进程的具体信息，如进程 ID、所属用户、CPU 使用率、内存使用率、进程运行时间等。执行top命令后，按下Shift + M键，就可以按照内存使用量对进程进行降序排列，这样排在最前面的进程就是占用内存最多的进程。

比如，通过 top 命令，我们可以直观地看到哪个进程占用了大量的 CPU 和内存资源。如果发现某个进程的 % MEM（内存使用率）持续上升，那就很可能是这个进程导致了内存问题。而且，我们还可以使用 top -Hp pid 命令查看具体线程使用系统资源情况，深入了解线程级别的资源占用。

(2)Linux命令行工具之vmstat 命令：vmstat 是一款指定采样周期和次数的功能性监测工具，它不仅能统计内存的使用情况，还可以观测到 CPU 的使用率、swap 的使用情况 。虽然它一般很少用来单独查看内存的使用情况，但在观察进程的上下文切换方面却非常有用。

比如，当我们怀疑系统存在大量的进程上下文切换，导致系统性能下降时，就可以使用 vmstat 命令来查看 cs（每秒上下文切换数）的值。如果这个值过高，说明系统在频繁进行上下文切换，可能存在性能问题。通过分析 vmstat 命令的输出结果，我们还可以了解到系统的内存分配、CPU 负载、磁盘 I/O 等情况，为排查内存问题提供多方面的信息。

(3)Linux命令行工具之pidstat 命令：之前的 top 和 vmstat 两个命令都是监测进程的内存、CPU 以及 I/O 使用情况，而 pidstat 命令则更进了一步，深入到线程级别 。它可以详细地展示每个线程的 CPU、内存和 I/O 使用情况，让我们对线程的资源占用有更细致的了解。

比如，使用 pidstat -p pid -t 命令，可以查看指定进程下各个线程的统计信息，包括线程 ID、% usr（用户空间占用 CPU 的百分比）、% system（内核空间占用 CPU 的百分比）、% CPU（进程占用 CPU 的百分比）等。通过这些信息，我们能够找出占用资源较多的线程，进而分析线程的执行逻辑，判断是否存在内存泄漏或其他内存问题。



## Android 特有

 procrank, 根据进程占用内存进行排序。
 showmap: 根据 maps/smaps 进行统计排序

 [dumpsys](https://mp.weixin.qq.com/s?__biz=Mzg5OTMwOTQ3MQ==&mid=2247484031&idx=1&sn=6c6a086410a99d2948a0b19d66114e32&chksm=c1d15a55a6c4df3bbe0ec9d5df5cf2dfd5ad9e24739026419b9dffdd7ec79f2e3357f15906a6&mpshare=1&scene=24&srcid=1223fjGgdx80xnc89EABMv0Q&sharer_shareinfo=9874440ca792efe7b109a0300779d440&sharer_shareinfo_first=9874440ca792efe7b109a0300779d440#rd) meminfo 打印全局或者某个进程的内存使用详细信息。
 

 参考：

[Android Profiler 官方教程](https://mp.weixin.qq.com/s/or2RJKTwgcaaLDf_WBvgXw)
