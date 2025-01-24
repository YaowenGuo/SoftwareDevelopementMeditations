# [物理内存和交换分区的统计信息](https://man7.org/linux/man-pages/man5/proc_meminfo.5.html)

https://www.cnblogs.com/liulianzhen99/articles/18005637

- All Physical Memory
    - Reserved Memory
    - MemTotal
        - Free Memory
        - Used Memory
            - 内核黑洞
            - Kernel
            - User

**以上这些都是在物理内存页上的分配上的分类。**

1. `MemTotal` 和 `Reserved Memory`： 系统从加电开始到引导完成，firmware/BIOS要保留一些内存，kernel本身要占用一些内存(内核所用内存的静态部分，比如内核代码、页描述符等数据在引导阶段就分配了)，最后剩下可供kernel支配的内存就是 MemTotal。这个值在系统运行期间一般是固定不变的。Reserved 中包括内核的代码，
    注：请把Page Table与Page Frame（页帧）区分开，物理内存的最小单位是page frame，每个物理页对应一个描述符(struct page)，在内核的引导阶段就会分配好、保存在mem_map[]数组中，mem_map[]所占用的内存被统计在dmesg显示的reserved中，/proc/meminfo的MemTotal是不包含它们的。（在NUMA系统上可能会有多个mem_map数组，在node_data中或mem_section中）。

2. MemTotal = MemFree + Used Memory: 表示系统尚未使用的内存。`MemTotal-MemFree` 就是已被用掉的内存。

3. 内存黑洞：
    追踪Linux系统的内存使用一直是个难题，很多人试着把能想到的各种内存消耗都加在一起，kernel text、kernel modules、buffer、cache、slab、page table、process RSS…等等，却总是与物理内存的大小对不上，这是为什么呢？因为Linux kernel并没有滴水不漏地统计所有的内存分配，kernel动态分配的内存中就有一部分没有计入/proc/meminfo中。

    通过alloc_pages分配的内存不会自动统计，除非调用alloc_pages的内核模块或驱动程序主动进行统计，否则我们只能看到free memory减少了，但从/proc/meminfo中看不出它们具体用到哪里去了。

**其它的数据没有那么多严格的层次分类，不同类型的信息是不同用途的统计。**


## 内核

内核所用内存的静态部分，比如内核代码、页描述符等数据在引导阶段就分配掉了，并不计入MemTotal里，而是算作Reserved(在dmesg中能看到)。而内核所用内存的动态部分，是通过上文提到的几个接口申请的，其中通过alloc_pages申请的内存有可能未纳入统计，就像黑洞一样。


### Slub 分配的内存

通过slab分配的内存被统计在以下三个值中：

SReclaimable: slab中可回收的部分。调用kmem_getpages()时加上SLAB_RECLAIM_ACCOUNT标记，表明是可回收的，计入SReclaimable，否则计入SUnreclaim。
SUnreclaim: slab中不可回收的部分。
Slab: slab中所有的内存，等于以上两者之和。


### Vmalloc 函数分配的内存

VmallocTotal:   135288315904 kB
VmallocUsed:      140404 kB
VmallocChunk:          0 kB ?


#### kernel modules 


### PageTables

Page Table用于将内存的虚拟地址翻译成物理地址，随着内存地址分配得越来越多，Page Table会增大，/proc/meminfo中的PageTables统计了Page Table所占用的内存大小。

注：请把Page Table与Page Frame（页帧）区分开，物理内存的最小单位是page frame，每个物理页对应一个描述符(struct page)，在内核的引导阶段就会分配好、保存在mem_map[]数组中，mem_map[]所占用的内存被统计在dmesg显示的reserved中，/proc/meminfo的MemTotal是不包含它们的。（在NUMA系统上可能会有多个mem_map数组，在node_data中或mem_section中）。

而Page Table的用途是翻译虚拟地址和物理地址，它是会动态变化的，要从MemTotal中消耗内存。

### KernelStack
每一个用户线程都会分配一个kernel stack（内核栈），内核栈虽然属于线程，但用户态的代码不能访问，只有通过系统调用(syscall)、自陷(trap)或异常(exception)进入内核态的时候才会用到，也就是说内核栈是给kernel code使用的。在x86系统上Linux的内核栈大小是固定的8K或16K（可参阅我以前的文章：内核栈溢出）。

Kernel stack（内核栈）是常驻内存的，既不包括在LRU lists里，也不包括在进程的RSS/PSS内存里，所以我们认为它是kernel消耗的内存。统计值是/proc/meminfo的KernelStack。

### Bounce
有些老设备只能访问低端内存，比如16M以下的内存，当应用程序发出一个I/O 请求，DMA的目的地址却是高端内存时（比如在16M以上），内核将在低端内存中分配一个临时buffer作为跳转，把位于高端内存的缓存数据复制到此处。这种额外的数据拷贝被称为“bounce buffering”，会降低I/O 性能。大量分配的bounce buffers 也会占用额外的内存。


## 用户空间




MemAvailable:   32069444 kB

Buffers:             320 kB
Cached:           219520 kB
SwapCached:            0 kB

Active:           258664 kB
Inactive:          21416 kB
Active(anon):      71792 kB
Inactive(anon):        0 kB
Active(file):     186872 kB
Inactive(file):    21416 kB

Unevictable:           0 kB
Mlocked:               0 kB

SwapTotal:      33855916 kB
SwapFree:       33855916 kB

Dirty:                 0 kB
Writeback:             0 kB

AnonPages:         60308 kB
Mapped:           113972 kB

Shmem:             11520 kB
KReclaimable:       8956 kB

KernelStack:        5040 kB

SecPageTables:         0 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    50259588 kB
Committed_AS:     545460 kB


Percpu:             2832 kB
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
FileHugePages:         0 kB
FilePmdMapped:         0 kB

> 物理内存有多大？

MemTotal 并不是实际的物理内存总量，而是供整个系统使用的物理内存大小，已经减去了 Reserved Page.
MemFree：MemTotal 中未被分配的内存。
MemAvailable：包括 Free 和 可以被回收的内存，但是不包括被换出到磁盘的。
https://www.cnblogs.com/cxj2011/p/17455096.html
https://blog.51cto.com/u_14987/11127764

> 实际可用的内存有多大？

可用这个词含义有点模糊，加上不同的定语有不同的含义

MemTotal 代表着系统可供分配的内存，是实际的物理内存减去 Reserved Page 的大小。
MemFree 表示 MemTotal 中未被分配的内存。
MemAvailable 包含了创建新进程可用的内存，这部分还包括可被回收的 Catch 等，但是不包括可被换出的页。
所以，可用看从哪个层面上来考虑，供谁使用。

> 已经分配了多少内存？

MemTotal - MemFree 代表已经分配的内存，这其中包含了很多详细的分类： 

有多少内存可以分配？
哪些内存可以被换出？