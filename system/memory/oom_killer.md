# OOM Killer

Root owned processes get a slight handicap — 30 is subtracted from the OOM score.

It is only triggered for low order allocations, e.g., 2³ or less。 trying to allocate a larger set of pages than would trigger OOM Killer when low on memory will cause Page Allocation Failure.

Pages are allocated in powers of 2 — so a 3rd order allocation would be 2³ (8) pages, with the total size being determined by your page size。
What causes this?

Most often, the system really is out of memory. If /proc/meminfo is showing swapFree and MemFree to ~1% or lower, this is likely the case.

(Much) More rarely, kernel data structure or memory leak can be the culprit — check /proc/meminfo for SwapFree and MemFree, and then /proc/slabinfo — telltale signs can be task_struct objects being high could indicate the system forking so many processes it ran out of kernel memory. You can also see the object utilizing most of the memory.

SwapFree can be misleading when a program uses mlock() or HugeTLB — It cannot be swapped if these are in use. SwapFree will not be relevant on most instances with default setups — very few have swap enabled.

Again, most cases are the system actually running out of memory. Tracking process memory usage and finding the offender is important.

Can also be triggered due to specific memory allocation requirements:

Specfic Memory zone
Specific GFP Flag
Specific allocation Order

## 是什么？

also kills any processes that share the mm_struct as the selected process.

## 什么机制

OOM score calculation is basically “How much of the available memory to the process is actually in use?” — 100% would result in a score of 1000(oom_score).


## 定位问题

```
dmesg -T| grep -E -i -B100 'killed process'
```
Where -B100 signifies the number of lines before the kill happened.

Omit -T on Mac OS.

真个 OOM Killer 的输出分为三大部分：

### OOM Killer 的信息

```
[Sun Aug 11 11:31:34 2024] oom_reaper: reaped process 4959 (a.out), now anon-rss:388kB, file-rss:128kB, shmem-rss:0kB
[Sun Aug 11 20:21:28 2024] kswapd0 invoked oom-killer: gfp_mask=0xcc0(GFP_KERNEL), order=0, oom_score_adj=0
[Sun Aug 11 20:21:28 2024] CPU: 5 PID: 111 Comm: kswapd0 Not tainted 6.9.8-orbstack-00170-g7b4100b7ced4 #1
[Sun Aug 11 20:21:28 2024] Hardware name: orbstack,virt (DT)
[Sun Aug 11 20:21:28 2024] Call trace:
[Sun Aug 11 20:21:28 2024]  dump_backtrace+0xe8/0x110
[Sun Aug 11 20:21:28 2024]  show_stack+0x1c/0x30
[Sun Aug 11 20:21:28 2024]  dump_stack_lvl+0x38/0x78
[Sun Aug 11 20:21:28 2024]  dump_stack+0x14/0x20
[Sun Aug 11 20:21:28 2024]  dump_header+0x44/0x120
[Sun Aug 11 20:21:28 2024]  oom_kill_process+0x1a4/0x300
[Sun Aug 11 20:21:28 2024]  out_of_memory+0x1dc/0x2c0
[Sun Aug 11 20:21:28 2024]  balance_pgdat+0x424/0x908
[Sun Aug 11 20:21:28 2024]  kswapd+0x260/0x398
[Sun Aug 11 20:21:28 2024]  kthread+0xd8/0x170
[Sun Aug 11 20:21:28 2024]  ret_from_fork+0x10/0x20
```

kswapd0 invoked oom-killer: 由谁触发的 OOM Killer, 

kswapd0本身是Linux系统中一个内核线程，负责虚拟内存管理。在系统不足时将不常用的页面从物理内存交换到swap space。网络攻击想要持久化。系统每个NUMA内存结点创建一个名为kswapd的内核线程

内核之所以要进行内存回收，主要原因有两个：

内核需要为任何时刻突发到来的内存申请提供足够的内存，以便cache的使用和其他相关内存的使用不至于让系统的剩余内存长期处于很少的状态。
内核使用内存中的page cache对部分文件进行缓存，以便提升文件的读写效率。所以内核有必要设计一个周期性回收内存的机制，以便cache的使用和其他相关内存的使用不至于让系统的剩余内存长期处于很少的状态。
当真的有大于空闲内存的申请到来的时候，会触发强制内存回收。
所以内核针对这两种回收的需求，分别实现了两种不同的机制。

针对第①种，Linux系统设计了kswapd后台程序，当内核分配物理页面时，由于系统内存短缺，没法在低水位情况下分配内存，因此会唤醒kswapd内核线程来异步回收内存
针对第②种，Linux系统会触发直接内存回收(direct reclaim)，在内核调用页分配函数分配物理页面时，由于系统内存短缺，不能满足分配请求，内核就会直接触发页面回收机制，尝试回收内存来解决问题

系统每过一定时间就会唤醒kswapd，看看内存是否紧张，如果不紧张，则睡眠，在kswapd中，有2个阀值,pages_hige和pages_low,当空闲内存页的数量低于pages_low的时候,kswapd进程就会扫描内存并且每次释放出32个free pages,直到free page的数量到达pages_high.


gfp_mask: 进程请求内存时使用的 GFP（Get Free Pages）掩码。GFP 掩码用于指定内核在内存分配时应该遵循的一系列规则和属性。不同的 GFP 掩码代表了不同的内存分配类型和属性。以下是常见的 GFP 掩码类型及其含义：

- GFP_KERNEL：该掩码用于普通的内核内存分配请求。当进程需要从内核中分配内存时，通常会使用该掩码。这种分配可以等待，因此内核可能会尝试通过回收内存或交换内存页来满足请求。

- GFP_ATOMIC：该掩码用于请求不可阻塞的、原子级别的内存分配。这种分配是非阻塞的，因此如果没有可用内存，内核将立即返回失败，而不是等待。通常用于处理中断上下文或者在内核关键路径上。

- GFP_DMA：该掩码用于请求可用于 DMA（直接内存访问）的内存。DMA 内存通常要求物理地址连续，因此需要使用特定的内存分配方法。

- GFP_HIGHUSER：该掩码用于请求高优先级用户内存。这种分配通常用于用户空间应用程序，例如驱动程序或用户态工具，这些应用程序需要较低的延迟和可预测的内存分配性能。

- GFP_NOIO：该掩码用于请求不会导致 IO 操作的内存分配。这种分配通常用于处理 IO 系统调用或者在不能阻塞 IO 的上下文中。

- GFP_NOFS：该掩码用于请求不会引发文件系统操作的内存分配。这种分配通常用于在文件系统代码中防止递归调用导致的死锁。

- GFP_NOFAIL：该掩码用于请求不会失败的内存分配。如果无法分配所需内存，则内核会尝试使用 OOM Killer 终止其他进程以释放内存。

- GFP_THISNODE：该掩码用于请求在当前 NUMA 节点上分配内存。

order：请求的页面数量的对数，0 是 2 的 0 次方个页面，内核中的内存的分配是以页为单位的，Linux 支持 4KB、16kB、4MB 的页，具体看系统配置。

接着是系统和硬件环境：应该是说运行在索引为 0 的处理器上，进程 ID 是 111，Comm: kswapd0 Not tainted 6.9.8-orbstack-00170-g7b4100b7ced4 #1 [是指内核没有被污染](https://www.cnblogs.com/skynext/p/4793627.html)

Call trace: 是 OOM Killer 的调用栈，从中可以分析 OOM Killer 引起的大致起因。例如本例中就是由 kswapd 发起的。kswapd 是负责页面换入换出的线程，其发起 OOM Killer 很可能磁盘的交换分区已经满了。

### 内存信息（MemInfo）

```
[Sun Aug 11 20:21:28 2024] Mem-Info:
[Sun Aug 11 20:21:28 2024] active_anon:1008777 inactive_anon:1455290 isolated_anon:0
[Sun Aug 11 20:21:28 2024]  active_file:22 inactive_file:332 isolated_file:0
[Sun Aug 11 20:21:28 2024]  unevictable:0 dirty:0 writeback:0
[Sun Aug 11 20:21:28 2024]  slab_reclaimable:2777 slab_unreclaimable:25908
[Sun Aug 11 20:21:28 2024]  mapped:375 shmem:0 pagetables:5462164
[Sun Aug 11 20:21:28 2024]  sec_pagetables:0 bounce:0
[Sun Aug 11 20:21:28 2024]  kernel_misc_reclaimable:0
[Sun Aug 11 20:21:28 2024]  free:91529 free_pcp:671 free_cma:0
[Sun Aug 11 20:21:28 2024] Node 0 active_anon:4036276kB inactive_anon:5821160kB active_file:380kB inactive_file:744kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1500kB dirty:0kB writeback:0kB shmem:0kB shmem_thp:0kB shmem_pmdmapped:0kB anon_thp:0kB writeback_tmp:0kB kernel_stack:5376kB pagetables:21849240kB sec_pagetables:0kB all_unreclaimable? no
[Sun Aug 11 20:21:28 2024] DMA free:125364kB boost:0kB min:5472kB low:7464kB high:9456kB reserved_highatomic:0KB active_anon:3000kB inactive_anon:679196kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:2097152kB managed:1993984kB mlocked:0kB bounce:0kB free_pcp:752kB local_pcp:0kB free_cma:0kB
[Sun Aug 11 20:21:28 2024] lowmem_reserve[]: 0 0 30091 30091
[Sun Aug 11 20:21:28 2024] Normal free:238836kB boost:0kB min:84636kB low:115448kB high:146260kB reserved_highatomic:151552KB active_anon:4036668kB inactive_anon:5139216kB active_file:356kB inactive_file:812kB unevictable:0kB writepending:0kB present:31457280kB managed:30813364kB mlocked:0kB bounce:0kB free_pcp:1292kB local_pcp:0kB free_cma:0kB
[Sun Aug 11 20:21:28 2024] lowmem_reserve[]: 0 0 0 0
[Sun Aug 11 20:21:28 2024] DMA: 3*4kB (UM) 1*8kB (U) 13*16kB (UM) 1075*32kB (UM) 877*64kB (UM) 271*128kB (UM) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 125444kB
[Sun Aug 11 20:21:28 2024] Normal: 120*4kB (UMEH) 81*8kB (UEH) 8337*16kB (UMH) 3094*32kB (UMH) 28*64kB (UMH) 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 235448kB
[Sun Aug 11 20:21:28 2024] 1528 total pagecache pages
[Sun Aug 11 20:21:28 2024] 1301 pages in swap cache
[Sun Aug 11 20:21:28 2024] Free swap  = 4kB
[Sun Aug 11 20:21:28 2024] Total swap = 33855916kB
[Sun Aug 11 20:21:28 2024] 8388608 pages RAM
[Sun Aug 11 20:21:28 2024] 0 pages HighMem/MovableOnly
[Sun Aug 11 20:21:28 2024] 186771 pages reserved
```

这里，我们先解释最后三行，`8388608 pages RAM` 表示所有的内存数量，计算一下（8388608 * 4KB / 1024^3）正是实际的 32 GB 内存，而 186771 表示系统的[保留内存](https://www.quora.com/What-is-reserved-memory-in-Linux)，这部分用于内核代码和其它用处，不能被用于普通的内存分配。剩余的内存是用户使用的内存，这部分就是 `/proc/meminfo` 中的 MemTotal。

`186771 pages reserved` 就是各个 Zone 保留的总和，在 `/proc/zoneinfo` 中各个区的 `present - managed` 的总和。

managed_pages = present_pages - reserved_page
reserved_pages。有一些文章上直接给出了 reserved_pages 的计算方法，在我的系统上计算并不正确，可能是不同版本有所差异。在内核的代码找到一个注释：reserved_pages includes pages allocated by the bootmem allocator。

1. 为什么 OOM Killer 显示的保留内存和启动时打印的不一样？总内存也和 meminfo 中的不一样。是动态的？`dmesg -T | grep "Memory:"`

2. 保留内存是供内核使用的内存？大小由什么确定？变化了之后还能从其它数据里确定哪些是从保留内存里分配的吗？

3. 为什么 Mem-Info 后的内容相加和非保留内存对不上？是有内存也不可用吗？如何得出哪些不可用？


HighMem 是高端内存，只有在 32 位系统上存在。MovableOnly 是支持热插拔的内存，可以被移除掉。




### 任务信息（Tasks state，进程+线程）

```
[Sun Aug 11 20:21:28 2024] Tasks state (memory values in pages):
[Sun Aug 11 20:21:28 2024] [  pid  ]   uid  tgid total_vm      rss rss_anon rss_file rss_shmem pgtables_bytes swapents oom_score_adj name
[Sun Aug 11 20:21:28 2024] [    215]   100   215     2186      128       96       32         0    53248       64          -950 chronyd
[Sun Aug 11 20:21:28 2024] [    216]     0   216     1684       64       64        0         0    53248       64          -950 udevd
[Sun Aug 11 20:21:28 2024] [    217]     0   217   316253      554      554        0         0   172032      957          -950 scon
[Sun Aug 11 20:21:28 2024] [    237]   101   237      286       32        0       32         0    36864        0          -950 dnsmasq
[Sun Aug 11 20:21:28 2024] [    244]     0   244   314870      126      102       24         0   139264     1184          -950 scon
[Sun Aug 11 20:21:28 2024] [    245]     0   245      215        0        0        0         0    36864        0          -500 docker-init
[Sun Aug 11 20:21:28 2024] [    263]     0   263      730        0        0        0         0    36864        0             0 simplevisor
[Sun Aug 11 20:21:28 2024] [    298]     0   298   654798      923      763      160         0   434176     8687             0 dockerd
[Sun Aug 11 20:21:28 2024] [    299]     0   299   308576        0        0        0         0   102400     1024             0 orbstack-helper
[Sun Aug 11 20:21:28 2024] [    323]     0   323   317789      220       60      160         0   200704     3264             0 containerd
[Sun Aug 11 20:21:28 2024] [    520]     0   520   310469      843      747       96         0   139264      544             1 containerd-shim
[Sun Aug 11 20:21:28 2024] [    539]     0   539   297439        0        0        0         0   106496      832             0 bash
[Sun Aug 11 20:21:28 2024] [    564]     0   564     1366        0        0        0         0    49152       32          -950 fpll
[Sun Aug 11 20:21:28 2024] [    585]     0   585   297502      128       96       32         0   110592      896             0 bash
[Sun Aug 11 20:21:28 2024] [   4810]     0  4810   310405      903      903        0         0   139264      733             1 containerd-shim
[Sun Aug 11 20:21:28 2024] [   4830]     0  4830     1074       64        0       64         0    57344      128             0 bash
[Sun Aug 11 20:21:28 2024] [   4852]     0  4852     1624       32        0       32         0    53248       32          -950 fpll
[Sun Aug 11 20:21:28 2024] [   4875]     0  4875     1101       32        0       32         0    49152      128             0 bash
[Sun Aug 11 20:21:28 2024] [   5071]     0  5071 2791357842  2461248  2461216       32         0 22374600704  8441856             0 a.out
[Sun Aug 11 20:21:28 2024] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,global_oom,task_memcg=/scon.container.01GQQVF6C60000000000DOCKER.17qk8ev/child/docker/9338c8be733c89d753e9dcb886e469803da8e99e1e048d5da1b6a7ac9a346aad,task=a.out,pid=5071,uid=0
[Sun Aug 11 20:21:28 2024] Out of memory: Killed process 5071 (a.out) total-vm:11165614668kB, anon-rss:9845504kB, file-rss:128kB, shmem-rss:0kB, UID:0 pgtables:21850556kB oom_score_adj:0
```

shmem: 共享内存











参考：

https://blog.csdn.net/keeprunper/article/details/139561402