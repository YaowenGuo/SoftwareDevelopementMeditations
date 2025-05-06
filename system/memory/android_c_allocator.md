# Android libc 内存分配器

libc、libc++ 内存的分配通常由malloc负责。即便是面向对象的new，其底层也是malloc。安卓的标准 C 库是专门开发的 Bionic，Bionic 的内存分配在安卓发展过程中经历了多次变化。

有很多用户空间 native 分配器，而且大多是开源的：

linux ptmalloc2(per-thread malloc): 未独立仓库，在 glic 中 
FreeBSD jemalloc（Jason Evans' malloc）: https://github.com/jemalloc/jemalloc
apple libmalloc: https://github.com/apple-oss-distributions/libmalloc 
google tcmalloc（thread-caching malloc）: https://github.com/google/tcmalloc
Google + LLVM Scudo: https://llvm.org/docs/ScudoHardenedAllocator.html?ref=blog.isosceles.com

其中 jemalloc 和 tcmalloc 性能更出众，但应用场景不同，以及随着不断的发展，性能也在变化。如果想要做性能优化应该根据使用的仓库版本实际测试比较。


## Android malloc 的变化

安卓最早使用 dlmalloc(Doug Lea's memory allocator，诞生于1987，于2012停止更新)。其代码简单，适合学习。在多核处理器上性能不佳。

在 Android 5.0 首次引入了 jemalloc(3.6.0)，Android 10 引入了改进后的 `jemalloc new`（jemalloc 5+） 

为了增强安全性，Android 8.0 引入了新的安全分配器 Scudo，与 jemalloc 共存。Android 11 Scudo 作为默认分配器。由于其性能不如 jemalloc，许多设备（如三星 Galaxy S23）仍在使用 jemalloc 'new' 作为默认分配器。

由于手机厂商的定制，实际使用的分配器可能和官方的版本不一样。

## jemalloc

jemalloc 是 Jason Evans 为 FreeBSD 设计的内存分配器，于 2005 年首次引入 FreeBSD，2006 年作者还发表了论文 [A Scalable Concurrent malloc(3) Implementation for FreeBSD](https://www.bsdcan.org/2006/papers/jemalloc.pdf)。随着发展，jemalloc 已经成为一种通用的内存分配器实现，在避免碎片和可扩展的并发支持表现突出。正在进行的开发工作致力于使 jemalloc 成为适用于各种苛刻应用的最佳分配器，并消除/减轻对实际应用有影响的弱点。

jemalloc 在其生命周期中发生了很大的变化，这里主要学习内存分配器的设计和实现。因此使用最新的 jemalloc 5.3 版本，jemalloc 5.0 之前版本和新版本差别非常大。

jemalloc 借鉴了 tcmalloc 优秀的设计思路，所以在架构设计方面两者有很多相似之处，同样都包含 thread cache 的特性。但是 jemalloc 在设计上比 ptmalloc 和 tcmalloc 都要复杂，jemalloc 将内存分配粒度划分为 Small、Large、Huge 三个分类，并记录了很多 meta 数据，所以在空间占用上要略多于 tcmalloc，不过在大内存分配的场景，jemalloc 的内存碎片要少于 tcmalloc。tcmalloc 内部采用红黑树管理内存块和分页，Huge 对象通过红黑树查找索引数据可以控制在指数级时间。


## 核心数据结构

- arena 为了解决高并发场景下的锁竞争问题引入的概念，对比几个现代化（需要支持多内核的高并发场景）内存分配器的内存实现都有类似的概念。jemalloc 的 arena 并不会为每个线程分配一个，CPU 同时能运行的最大线程数量和 CPU 的逻辑核心数（例如4核8线程的 CPU 在操作系统看来是有8个逻辑核，最大能同时跑8个线程）一致，因此 jemalloc 会根据系统的可用核心数来设置 arena 的数量，最多不超过 1024 个。每个线程都会绑定到一个 arena 上，一个 arean 可以绑定0到多个线程。jemalloc 会在初始化的时候就创建多个 arena，即便该程序只有一个线程。另一方面，jemalloc 预留的接口，可以在编译时配置和运行时调整实际的 arena 数量。每个 arena 管理独立的内存池，采用分层结构。

- Chunk：大块内存单位（默认 4MB），通过 mmap 从系统申请。

- Run：Chunk 内部划分的连续内存区域，用于服务特定大小的分配请求（如 16B、32B 等）。

- Region：Run 内部分割的最小内存单元，直接分配给用户

```
Thread
 ├── tcache (线程本地缓存)
 └── Arena (内存分配池)
      ├── Bins (固定大小内存块)
      │    └── Runs (一组连续内存块)
      ├── Large Allocations (直接管理的较大内存块)
      └── Chunks (大块内存区域)
           └── Pages (基础分配单元)
```

TSD(Thread-Specific Data)



一、核心数据概念
1. Arena（分配区）
定义：Arena 是 jemalloc 的核心管理单元，每个 Arena 独立管理一组内存块（extent），减少多线程环境下的锁竞争35。

特点：

多 Arena 机制：默认数量为 CPU 核心数的 4 倍，通过轮询或哈希算法将线程绑定到不同 Arena，降低锁冲突67。

内存管理：管理三种堆（dirty、muzzy、retained），用于跟踪不同状态的空闲内存块（extent），按 LRU 策略回收7。

结构成员：

extents_dirty：最近释放的内存块，可快速复用。

extents_muzzy：待清理的内存块，通过后台线程回收。

extents_retained：长期保留的内存块（默认不归还操作系统）7。

2. Extent（内存段）
定义：Extent 是连续的虚拟内存段，取代旧版本中的固定大小 chunk，支持动态调整大小（页大小的整数倍）74。

特点：

灵活性：Extent 可合并或拆分，适应不同大小的分配请求。

元数据分离：Extent 的元数据（如大小、状态）独立存储，避免与用户数据混用，提升安全性7。

生命周期：通过 mmap 申请，默认保留至进程结束（除非 opt_retain 设为 false）7。

3. Bin（内存规格箱）
定义：Bin 是按内存规格分类的管理单元，每个 Bin 对应特定大小类别的分配请求（如 8B、16B 等）35。

结构：

slabcur：当前活跃的 slab（内存块），用于快速分配。

slabs_nonfull：非满 slab 的堆，按地址排序以优化缓存局部性。

slabs_full：已满 slab 的链表，等待释放后回收7。

4. Slab（内存块）
定义：Slab 是 Extent 内部分割的固定大小区域，用于小对象分配（如 8B、16B）7。

管理：

每个 Slab 包含多个相同大小的 region（分配单元）。

通过 slabcur 快速分配，用尽后移入 slabs_full，从 slabs_nonfull 选择新 Slab7。

5. TCache（线程本地缓存）
定义：每个线程私有缓存，存储最近分配的小内存块（如 <32KB），避免频繁访问 Arena 的全局锁35。

工作流程：

分配时优先从 TCache 获取，缓存不足时从 Arena 的 Bin 中批量填充。

释放时先缓存到 TCache，满后触发垃圾回收（GC），将内存归还 Arena57。

二、核心数据关系
1. 层级结构
Arena → Extent → Slab → Region

Arena 管理多个 Extent，Extent 动态分割为 Slab，Slab 进一步划分为固定大小的 Region（小对象）37。

大对象（如 >4MB）直接通过 mmap 分配，不经过 Bin 和 Slab5。

2. 内存分配流程
小对象分配（<4KB）：

优先从 TCache 获取。

TCache 不足时，从绑定的 Arena 的 Bin 中获取 Slab，填充 TCache 并分配57。

大对象分配（4KB–4MB）：

从 Arena 的全局红黑树中查找合适 Extent，分割后分配3。

超大对象分配（≥4MB）：

直接调用 mmap 申请独立 Extent，不纳入常规管理5。

3. 内存释放流程
TCache 释放：内存暂存于 TCache，满后触发 GC，归还到 Arena 的 Bin 或 Extent5。

Extent 回收：当 Slab 完全空闲时，Extent 可能被合并或通过 madvise 释放物理内存（保留虚拟地址）7。

4. 垃圾回收机制
TCache 回收：定期将多余缓存刷回 Arena，避免内存滞留5。

Extent 衰减：Dirty → Muzzy → Retained 堆的转移，逐步释放物理内存7。

三、设计优势与挑战
优势	挑战
多 Arena 减少锁竞争	Extent 动态管理复杂度高
TCache 提升线程局部性	默认不释放内存可能占用高
Extent 灵活合并/拆分	元数据分散增加调试难度
分层结构降低碎片率	配置参数调优依赖经验
四、应用场景
高并发服务：如 Redis、Nginx，利用多 Arena 和 TCache 提升性能13。

移动端系统：Android 10+ 采用 jemalloc 5.3 优化内存占用，减少 OOM 风险7。

大数据处理：通过 Extent 动态管理，适应频繁的大块内存分配需求6。

通过以上设计，jemalloc 5.3 在多线程性能和内存利用率之间实现了高效平衡，成为现代系统和高性能应用的首选内存分配器。



### 调试

方法1： 符号劫持（Symbol Hijacking）：
```shell
export LD_PRELOAD=/usr/local/lib/libjemalloc.so

# 或者只替换自己程序的库，仅对当前命令生效，如果参数较多，可以保存在脚本文件中。
LD_PRELOAD=/usr/local/lib/libjemalloc.so ./your_program
env LD_PRELOAD=/usr/local/lib/libjemalloc.so ./your_program
```
LD_PRELOAD 环境变量指定了一个共享库路径，系统在加载程序时优先加载该库，并覆盖其他库（如 libc.so）中的同名符号。

方法2：编译时指定动态链接 jemalloc

```
# -l 指定动态链接
gcc your_program.c -o your_program -ljemalloc
```




除此之外 jemalloc 内部也实现了一些调试方法：
```shell
export MALLOC_CONF="stats_print:true,prof:true,prof_leak:true"  # 输出统计信息和内存泄漏分析
export MALLOC_CONF="prof:true,prof_prefix:jemalloc_prof"  # 生成内存分析文件
# 程序运行时会生成 .heap 文件，使用 jeprof 工具可视化分析：
jeprof --show_bytes <可执行文件> jemalloc_prof.<pid>.<seq>.heap

# 检测内存错误：
export MALLOC_CONF="junk:true"  # 填充未初始化内存为特定模式（0xa5）
export MALLOC_CONF="abort:true"  # 检测到错误时直接终止程序
```

## 代码

入手
动态库的加载和卸载会默认调用一个函数，在 Unix 上使用如下标注
```C
__attribute__((constructor))  // 初始化函数
__attribute__((destructor))	// 析构函数
```
通过该属性能找到 jemalloc 的初始化函数 
```C
JEMALLOC_ATTR(constructor)
static void
jemalloc_constructor(void) {
	malloc_init();
}
```

参考：
https://blog.51cto.com/u_11529070/9161159
https://blog.csdn.net/weixin_42766184/category_12885143.html


https://zhuanlan.zhihu.com/p/423062509
https://juejin.cn/post/6914550038140026887