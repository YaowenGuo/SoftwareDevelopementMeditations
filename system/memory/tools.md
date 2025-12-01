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

## Android 特有

 procrank, 根据进程占用内存进行排序。
 showmap: 根据 maps/smaps 进行统计排序

 dumpsys meminfo 打印全局或者某个进程的内存使用详细信息。

 参考：
[待整理：(2.2) 单个Process 数据源解析 ](https://zhuanlan.zhihu.com/p/109862930)