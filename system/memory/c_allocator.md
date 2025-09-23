# Android libc 内存分配器

[TOC]

libc、libc++ 内存的分配通常由 malloc 负责。即便是面向对象的new，其底层也是malloc。安卓的标准 C 库是专门开发的 Bionic，Bionic 的内存分配在安卓发展过程中经历了多次变化。

有很多用户空间 native 分配器，而且大多是开源的：

linux ptmalloc2(per-thread malloc): 未独立仓库，在 glic 中 
FreeBSD jemalloc（Jason Evans' malloc）: https://github.com/jemalloc/jemalloc
apple libmalloc: https://github.com/apple-oss-distributions/libmalloc 
google tcmalloc（thread-caching malloc）: https://github.com/google/tcmalloc
Google + LLVM Scudo: https://llvm.org/docs/ScudoHardenedAllocator.html?ref=blog.isosceles.com 或者 lib: https://github.com/llvm/llvm-project/tree/main/compiler-rt/lib/scudo

https://jasone.github.io/2025/06/12/jemalloc-postmortem/

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

## 架构

```
            申请内存
+-----------------------------+
|        tcache (线程本地缓存)  | -----------+
+-----------------------------+            |
              |                            |
              v                            |
+-----------------------------+            |
|    Arena/Huge Arena(只有一个)|            v
| ├─ Bin (小对象分配器)         |      +--------------+
| │   └─ Slab (小块内存池)      | ---> |  Base        | 元数据(jemallo 的内部数据、arena、Bins...)
| │       └─ Region           |      +--------------+
| ├─ large (大对象)            |           |
| └─ pa_shard (连续内存块)      |           |
+-----------------------------+           |
              |<----------------是----- 是否有hooks
              v                           |
+-----------------------------+           否
|           extent            |  对外界接口并不清晰，上层会有判断没有 hook 直接调用 mmap 的情况。
+-----------------------------+           |
|       hooks/default         |           | 内有 hooks 时，直接调用 extent_mmap 的接口，减少了函数调用。
+-----------------------------+           |
|   extent(mmap|bss)          | <---------+ 通过 mmap/sbrk 向操作系统申请
+-----------------------------+
```
- 用户申请的内存会优先从 tcatch 中获取，tcatch 是每个线程的缓存池，通过缓存池能避免线程之前的竞争、不需要加锁从而显著提高分配效率。

- 如果从 内存块较大或者从 tcatch 中没有分配到内存，则会回退到 arena 中分配内存，arena 是内存分配的抽象的概念。arena 会创建多个，几个线程共享一个 arena。从而减少线程之间的锁竞争，提高分配效率。

- base 模块是 jemalloc 的元数据管理模块，所有的元数据从 jemalloc 中申请内存创建，例如 arena、base 等数据结构本身需要的内存。

- hooks/default 是预留的接口，允许用户根据系统自定义内存分配方法。默认的 default 是对系统默认实现的包装。

- extent 是 jemallo 的基础分配，它是连续的内存块，使用 edata_t 描述。默认实现了 mmap 和 bas 内存分配，同时可以设置是优先使用 mmap 还是 bss 分配内存（默认 mmap 优先， bss 的系统调用太老了，有很多缺陷，甚至现在不是 POSIX 的标准接口）。


large 里的 edata_t：只描述当前属于该 arena 的、正在使用的大对象分配（large allocation）。
pa_shard 里的 edata_t：描述所有物理内存区间，包括 large、slab、dirty、retained 等，管理更全面、粒度更细。


## 核心数据结构

```
TSD(Thread-Specific Data 或者称为 TLS) 
 ├── tcache (线程本地缓存)
 └── Arena (内存分配池)
      ├── Bins (固定大小内存块)
      │    
      ├── large：大对象链表（edata_t 组织）
      └── pa_shard：页分配器,，管理所有 edata_t(extent data)
           
```
- 引用：jemalloc 的最新版本里没有所谓的 huge class，bin 中 slab 外面也不再套一个run的概念了，看其它人分享的文章时需要注意。

- 层级结构: Arena → Extent → Slab → Region

pa_shard_t 是 arena 的页分配器器，负责管理该 arena 的所有物理内存区间（extent），包括 slab、large、huge、dirty、retained 等多种状态的 extent。
extent 的元数据依然用 edata_t 结构体描述，但这些结构体的组织和管理都在 pa_shard 及其下属的 ecache、heap、list 等结构中完成。

> 核心数据结构

- tcache：定义：每个线程私有缓存，存储最近分配的小内存块（如 <32KB），避免频繁访问 Arena 的全局锁。

- Arena: 每个 Arena 独立管理一组内存块（extent），减少多线程环境下的锁竞争。arena 为了解决高并发场景下的锁竞争问题引入的概念，对比几个现代化（需要支持多内核的高并发场景）内存分配器的内存实现都有类似的概念。jemalloc 的 arena 并不会为每个线程分配一个，CPU 同时能运行的最大线程数量和 CPU 的逻辑核心数（例如4核8线程的 CPU 在操作系统看来是有8个逻辑核，最大能同时跑8个线程）一致，因此 jemalloc 会根据系统的可用核心数来设置 arena 的数量，最多不超过 1024 个。每个线程都会绑定到一个 arena 上，一个 arean 可以绑定0到多个线程。jemalloc 会在初始化的时候就创建多个 arena，即便该程序只有一个线程。另一方面，jemalloc 预留的接口，可以在编译时配置和运行时调整实际的 arena 数量。每个 arena 管理独立的内存池，采用分层结构。

	多 Arena 机制：默认数量为 CPU 核心数的 4 倍，通过轮询或哈希算法将线程绑定到不同 Arena，降低锁冲突。

	内存管理：管理三种堆（dirty、muzzy、retained），用于跟踪不同状态的空闲内存块（extent），按 LRU 策略回收。

	结构成员：
	- extents_dirty：最近释放的内存块，可快速复用。
	- extents_muzzy：待清理的内存块，通过后台线程回收。
	- extents_retained：长期保留的内存块（默认不归还操作系统）。

2. Extent（内存段）：Extent 是连续的虚拟内存段，取代旧版本中的固定大小 chunk，支持动态调整大小（页大小的整数倍）。
	- 灵活性：Extent 可合并或拆分，适应不同大小的分配请求。
	- 元数据分离：Extent 的元数据（如大小、状态）独立存储，避免与用户数据混用，提升安全性。
	- 生命周期：通过 mmap 申请，默认保留至进程结束（除非 opt_retain 设为 false）。

3. Bin（内存规格箱）：Bin 是按内存规格分类的管理单元，每个 Bin 对应特定大小类别的分配请求（如 8B、16B 等）。**Bin 本身是一个 Slab 分配器的数据结构，一个 Slab 分配器只能分配相同大小的数据块。一个 Slab 分配器中可以包含多个 Slab。Slab 被划分成相同大小的小对象用于分配。**

	结构：
	- slabcur：当前活跃的 slab（内存块），用于快速分配。
	- slabs_nonfull：非满 slab 的堆，按地址排序以优化缓存局部性。
	- slabs_full：已满 slab 的链表，等待释放后回收。

4. edata_t（内存块）：既 Slab，是 Extent 内部分割的固定大小区域，用于小对象分配（如 8B、16B）。
	- 每个 Slab 包含多个相同大小的 region（分配单元）。
	- 通过 slabcur 快速分配，用尽后移入 slabs_full，从 slabs_nonfull 选择新 Slab。

Arena 管理多个 Extent，Extent 动态分割为 Slab，Slab 进一步划分为固定大小的 Region（小对象）。

大对象（如 >4MB）直接通过 mmap 分配，不经过 Bin 和 Slab。

> 内存分配流程

小对象分配（<4KB）：

优先从 TCache 获取。

TCache 不足时，从绑定的 Arena 的 Bin 中获取 Slab，填充 TCache 并分配。

大对象分配（4KB–8MB）：

从 Arena 的全局红黑树中查找合适 Extent，分割后分配。

超大对象分配（≥8MB）：

直接调用 mmap 申请独立 Extent，不纳入常规管理。

> 内存释放流程
TCache 释放：内存暂存于 TCache，满后触发 GC，归还到 Arena 的 Bin 或 Extent。

Extent 回收：当 Slab 完全空闲时，Extent 可能被合并或通过 madvise 释放物理内存（保留虚拟地址）。

> 垃圾回收机制
TCache 回收：定期将多余缓存刷回 Arena，避免内存滞留5。

Extent 衰减：Dirty → Muzzy → Retained 堆的转移，逐步释放物理内存。


> jemalloc 的内存管理分为三层

- 线程本地缓存：tcache
- 分配区 arena
- 系统内存 分配超大对象或补充 arena 的内存池



分区：

在 jemalloc 中，内存分配的来源主要取决于分配请求的大小。具体来说：

1. 从 arena 中分配的内存
	小内存块（Small size classes）：

	小于等于 SC_SMALL_MAXCLASS 的内存块会从 arena 的 bin 中分配。
	这些内存块通常通过 slab 分配，即多个小内存块共享一个大页（slab）。
	SC_SMALL_MAXCLASS 的定义：

	SC_SMALL_MAXCLASS 是 slab 分配的最大内存块大小。它的值通常是 页面大小（PAGE）的倍数，具体取决于系统配置。

2. 从 arena 的 large allocation 分配
	大内存块（Large size classes）：

	大于 SC_SMALL_MAXCLASS 且小于等于 SC_LARGE_MAXCLASS 的内存块会从 arena 的 large allocation 中分配。这些内存块不通过 slab 分配，而是直接分配一块连续的内存。
	
	SC_LARGE_MAXCLASS 的定义： SC_LARGE_MAXCLASS 是 jemalloc 支持的最大内存块大小。
3. 从 huge allocator 分配
	超大内存块（Huge allocations）：
	大于 SC_LARGE_MAXCLASS 的内存块会直接通过 huge allocator 分配。这些内存块通常使用系统调用（如 mmap 或 VirtualAlloc）直接从操作系统获取。

总结
| 内存块大小 |	分配来源 |
| -------- | -------- |
| 小于等于 SC_SMALL_MAXCLASS |	从 arena 的 bin 中分配（slab 分配）。|
| 大于 SC_SMALL_MAXCLASS 且小于等于 SC_LARGE_MAXCLASS	| 从 arena 的 large allocation 中分配。|
| 大于 SC_LARGE_MAXCLASS |	通过 huge allocator 直接从操作系统分配。|


使用 TSD 来实现每个线程和 tcatch/arean 关联。

- Fast Path：
	如果 tcache 的 cache_bin 中有可用内存块，则直接分配内存，无需访问 arena。这是最优路径，性能非常高。tcache 允许的最大大小类上限为 8MiB

	分配时优先从 TCache 获取，缓存不足时从 Arena 的 Bin 中批量填充。

	释放时先缓存到 TCache，满后触发垃圾回收（GC），将内存归还 Arena57。

- Slow Path：
	如果 tcache 的 cache_bin 为空，则需要从 arena 获取内存块并填充到 cache_bin 中。这种情况会增加开销，但通过批量填充的方式，减少了频繁访问 arena 的次数。


> 三、设计优势与挑战

优势	挑战
多 Arena 减少锁竞争	Extent 动态管理复杂度高
TCache 提升线程局部性	默认不释放内存可能占用高
Extent 灵活合并/拆分	元数据分散增加调试难度
分层结构降低碎片率	配置参数调优依赖经验


- 8MB huge_arena 直接 mmap 分配：
```C
size_t oversize_threshold = OVERSIZE_THRESHOLD_DEFAULT;

JEMALLOC_ALWAYS_INLINE arena_t *
arena_choose_maybe_huge(tsd_t *tsd, arena_t *arena, size_t size) {
	if (arena != NULL) {
		return arena;
	}

	/*
	 * For huge allocations, use the dedicated huge arena if both are true:
	 * 1) is using auto arena selection (i.e. arena == NULL), and 2) the
	 * thread is not assigned to a manual arena.
	 */
	if (unlikely(size >= oversize_threshold)) {
		arena_t *tsd_arena = tsd_arena_get(tsd);
		if (tsd_arena == NULL || arena_is_auto(tsd_arena)) {
			return arena_choose_huge(tsd);
		}
	}

	return arena_choose(tsd, NULL);
}
```

malloc_init_hard_a0_locked 中会调用 pages_boot，pages_boot 主要检查系统是否支持 `页面自动填充功能` 以及`页面懒回收 (页面懒回收同时支持自动填充)`。
-（MADV_FREE 或 MADV_DONTNEED）把一块内存标记为“可回收”，但不立即清零，等到下次访问时才真正清零。

语义上的区别

- MADV_DONTNEED

	- 作用：告诉内核，这块内存可以被回收，下次访问时内容会被清零（变成全 0）。 
	- 行为：立即丢弃内容，下次访问时保证是全 0。
	- 兼容性：几乎所有 Unix/Linux 支持，但在某些虚拟化环境（如 QEMU）下，可能不会真的清零。

- MADV_FREE

	- 作用：告诉内核，这块内存可以被回收，但只有在物理内存紧张时才会丢弃内容。
	- 行为：懒惰清理，下次访问时内容可能还是原来的，直到内核真正回收为止。
	- 兼容性：只有较新的 Linux（4.5+）和 FreeBSD 支持，且行为和 MADV_DONTNEED 不完全一样


初始化调用 mmap
```C

* thread #1, name = 'test_malloc', stop reason = breakpoint 21.1
  * frame #0: 0x0000fffff7ce9e58 libjemalloc.so.2`madvise_MADV_DONTNEED_zeroes_pages at pages.c:67:16
    frame #1: 0x0000fffff7cebc64 libjemalloc.so.2`je_pages_boot at pages.c:770:40
    frame #2: 0x0000fffff7c4e334 libjemalloc.so.2`malloc_init_hard_a0_locked at jemalloc.c:1834:6
    frame #3: 0x0000fffff7c4ef30 libjemalloc.so.2`malloc_init_hard at jemalloc.c:2129:6
    frame #4: 0x0000fffff7c44fb8 libjemalloc.so.2`malloc_init at jemalloc.c:298:41
    frame #5: 0x0000fffff7c571b0 libjemalloc.so.2`jemalloc_constructor at jemalloc.c:4322:2


* thread #1, name = 'test_malloc', stop reason = breakpoint 23.1
  * frame #0: 0x0000fffff7cea0e0 libjemalloc.so.2`os_pages_map(addr=0x0000000000000000, size=4096, alignment=4096, commit=0x0000ffffffffdc3f) at pages.c:149:9
    frame #1: 0x0000fffff7cebd44 libjemalloc.so.2`je_pages_boot at pages.c:811:26
    frame #2: 0x0000fffff7c4e334 libjemalloc.so.2`malloc_init_hard_a0_locked at jemalloc.c:1834:6
    frame #3: 0x0000fffff7c4ef30 libjemalloc.so.2`malloc_init_hard at jemalloc.c:2129:6
    frame #4: 0x0000fffff7c44fb8 libjemalloc.so.2`malloc_init at jemalloc.c:298:41
    frame #5: 0x0000fffff7c571b0 libjemalloc.so.2`jemalloc_constructor at jemalloc.c:4322:2

* thread #1, name = 'test_malloc', stop reason = breakpoint 23.1
  * frame #0: 0x0000fffff7cea0e0 libjemalloc.so.2`os_pages_map(addr=0x0000000000000000, size=2097152, alignment=4096, commit=0x0000ffffffffdae7) at pages.c:149:9
    frame #1: 0x0000fffff7cea7b0 libjemalloc.so.2`je_pages_map(addr=0x0000000000000000, size=2097152, alignment=2097152, commit=0x0000ffffffffdae7) at pages.c:296:14
    frame #2: 0x0000fffff7cc51e8 libjemalloc.so.2`je_extent_alloc_mmap(new_addr=0x0000000000000000, size=2097152, alignment=2097152, zero=0x0000ffffffffdae6, commit=0x0000ffffffffdae7) at extent_mmap.c:24:14
    frame #3: 0x0000fffff7c700e8 libjemalloc.so.2`base_map(tsdn=0x0000000000000000, ehooks=0x0000ffffffffdc18, ind=0, size=2097152) at base.c:49:10
    frame #4: 0x0000fffff7c70e90 libjemalloc.so.2`base_block_alloc(tsdn=0x0000000000000000, base=0x0000000000000000, ehooks=0x0000ffffffffdc18, ind=0, pind_last=0x0000ffffffffdbe0, je_extent_sn_next=0x0000ffffffffdbe8, size=3992, alignment=16) at base.c:265:40
    frame #5: 0x0000fffff7c71444 libjemalloc.so.2`je_base_new(tsdn=0x0000000000000000, ind=0, extent_hooks=0x0000fffff7daf798, metadata_use_hooks=true) at base.c:360:24
    frame #6: 0x0000fffff7c71d14 libjemalloc.so.2`je_base_boot(tsdn=0x0000000000000000) at base.c:526:7
    frame #7: 0x0000fffff7c4e354 libjemalloc.so.2`malloc_init_hard_a0_locked at jemalloc.c:1837:6
    frame #8: 0x0000fffff7c4ef30 libjemalloc.so.2`malloc_init_hard at jemalloc.c:2129:6
    frame #9: 0x0000fffff7c44fb8 libjemalloc.so.2`malloc_init at jemalloc.c:298:41
    frame #10: 0x0000fffff7c571b0 libjemalloc.so.2`jemalloc_constructor at jemalloc.c:4322:2



* thread #1, name = 'test_malloc', stop reason = breakpoint 23.1
  * frame #0: 0x0000fffff7cea0e0 libjemalloc.so.2`os_pages_map(addr=0x0000000000000000, size=2097152, alignment=4096, commit=0x0000fffffffff156) at pages.c:149:9
    frame #1: 0x0000fffff7cea7b0 libjemalloc.so.2`je_pages_map(addr=0x0000000000000000, size=2097152, alignment=4096, commit=0x0000fffffffff156) at pages.c:296:14
    frame #2: 0x0000fffff7cc51e8 libjemalloc.so.2`je_extent_alloc_mmap(new_addr=0x0000000000000000, size=2097152, alignment=4096, zero=0x0000fffffffff155, commit=0x0000fffffffff156) at extent_mmap.c:24:14
    frame #3: 0x0000fffff7cb3610 libjemalloc.so.2`                                                 (tsdn=0x0000fffff7fee770, arena=0x0000fffff7801100, new_addr=0x0000000000000000, size=2097152, alignment=4096, zero=0x0000fffffffff155, commit=0x0000fffffffff156, dss_prec=dss_prec_secondary) at ehooks.c:36:13
    frame #4: 0x0000fffff7cb3790 libjemalloc.so.2`je_ehooks_default_alloc_impl(tsdn=0x0000fffff7fee770, new_addr=0x0000000000000000, size=2097152, alignment=4096, zero=0x0000fffffffff155, commit=0x0000fffffffff156, arena_ind=0) at ehooks.c:59:14
    frame #5: 0x0000fffff7cbda00 libjemalloc.so.2`ehooks_alloc(tsdn=0x0000fffff7fee770, ehooks=0x0000fffff78000c0, new_addr=0x0000000000000000, size=2097152, alignment=4096, zero=0x0000fffffffff155, commit=0x0000fffffffff156) at ehooks.h:197:9
    frame #6: 0x0000fffff7cc1520 libjemalloc.so.2`extent_grow_retained(tsdn=0x0000fffff7fee770, pac=0x0000fffff7803c18, ehooks=0x0000fffff78000c0, size=32768, alignment=4096, zero=true, commit=0x0000fffffffff2c7) at extent.c:672:14
    frame #7: 0x0000fffff7cc1c20 libjemalloc.so.2`extent_alloc_retained(tsdn=0x0000fffff7fee770, pac=0x0000fffff7803c18, ehooks=0x0000fffff78000c0, expand_edata=0x0000000000000000, size=32768, alignment=4096, zero=true, commit=0x0000fffffffff2c7, guarded=false) at extent.c:791:11
    frame #8: 0x0000fffff7cbf880 libjemalloc.so.2`je_ecache_alloc_grow(tsdn=0x0000fffff7fee770, pac=0x0000fffff7803c18, ehooks=0x0000fffff78000c0, ecache=0x0000fffff780d4d0, expand_edata=0x0000000000000000, size=32768, alignment=4096, zero=true, guarded=false) at extent.c:104:19
    frame #9: 0x0000fffff7ce889c libjemalloc.so.2`pac_alloc_real(tsdn=0x0000fffff7fee770, pac=0x0000fffff7803c18, ehooks=0x0000fffff78000c0, size=32768, alignment=4096, zero=true, guarded=false) at pac.c:124:11
    frame #10: 0x0000fffff7ce8bc0 libjemalloc.so.2`pac_alloc_impl(tsdn=0x0000fffff7fee770, self=0x0000fffff7803c18, size=32768, alignment=4096, zero=true, guarded=false, frequent_reuse=false, deferred_work_generated=0x0000fffffffff482) at pac.c:178:11
    frame #11: 0x0000fffff7ce3698 libjemalloc.so.2`pai_alloc(tsdn=0x0000fffff7fee770, self=0x0000fffff7803c18, size=32768, alignment=4096, zero=true, guarded=false, frequent_reuse=false, deferred_work_generated=0x0000fffffffff482) at pai.h:43:9
    frame #12: 0x0000fffff7ce3ec0 libjemalloc.so.2`je_pa_alloc(tsdn=0x0000fffff7fee770, shard=0x0000fffff7803c00, size=32768, alignment=4096, slab=false, szind=39, zero=true, guarded=false, deferred_work_generated=0x0000fffffffff482) at pa.c:139:11
    frame #13: 0x0000fffff7c62f8c libjemalloc.so.2`je_arena_extent_alloc_large(tsdn=0x0000fffff7fee770, arena=0x0000fffff7801100, usize=28672, alignment=4096, zero=true) at arena.c:338:19
    frame #14: 0x0000fffff7cdb8d4 libjemalloc.so.2`je_large_palloc(tsdn=0x0000fffff7fee770, arena=0x0000fffff7801100, usize=28672, alignment=4096, zero=true) at large.c:37:42
    frame #15: 0x0000fffff7c65f54 libjemalloc.so.2`je_arena_palloc(tsdn=0x0000fffff7fee770, arena=0x0000fffff7801100, usize=28672, alignment=4096, zero=true, tcache=0x0000000000000000) at arena.c:1230:10
    frame #16: 0x0000fffff7d3b040 libjemalloc.so.2`ipallocztm(tsdn=0x0000fffff7fee770, usize=28672, alignment=4096, zero=true, tcache=0x0000000000000000, is_internal=true, arena=0x0000fffff7801100) at jemalloc_internal_inlines_c.h:80:8
    frame #17: 0x0000fffff7d3d9dc libjemalloc.so.2`je_tsd_tcache_data_init(tsd=0x0000fffff7fee770) at tcache.c:717:14
    frame #18: 0x0000fffff7d3d58c libjemalloc.so.2`je_tsd_tcache_enabled_data_init(tsd=0x0000fffff7fee770) at tcache.c:644:3
    frame #19: 0x0000fffff7d44adc libjemalloc.so.2`tsd_data_init(tsd=0x0000fffff7fee770) at tsd.c:244:9
    frame #20: 0x0000fffff7d44ed8 libjemalloc.so.2`je_tsd_fetch_slow(tsd=0x0000fffff7fee770, minimal=false) at tsd.c:297:5
    frame #21: 0x0000fffff7d43ec4 libjemalloc.so.2`tsd_fetch_impl(init=true, minimal=false) at tsd.h:422:10
    frame #22: 0x0000fffff7d43f44 libjemalloc.so.2`tsd_fetch at tsd.h:448:9
    frame #23: 0x0000fffff7d45234 libjemalloc.so.2`je_malloc_tsd_boot0 at tsd.c:446:8
    frame #24: 0x0000fffff7c4ef68 libjemalloc.so.2`malloc_init_hard at jemalloc.c:2135:8
    frame #25: 0x0000fffff7c44fb8 libjemalloc.so.2`malloc_init at jemalloc.c:298:41
    frame #26: 0x0000fffff7c571b0 libjemalloc.so.2`jemalloc_constructor at jemalloc.c:4322:2


// huage malloc

* thread #1, name = 'test_malloc', stop reason = breakpoint 21.1
  * frame #0: 0x0000fffff7cea0e0 libjemalloc.so.2`os_pages_map(addr=0x0000000000000000, size=2097152, alignment=4096, commit=0x0000fffffffff007) at pages.c:149:9
    frame #1: 0x0000fffff7cea7b0 libjemalloc.so.2`je_pages_map(addr=0x0000000000000000, size=2097152, alignment=2097152, commit=0x0000fffffffff007) at pages.c:296:14
    frame #2: 0x0000fffff7cc51e8 libjemalloc.so.2`je_extent_alloc_mmap(new_addr=0x0000000000000000, size=2097152, alignment=2097152, zero=0x0000fffffffff006, commit=0x0000fffffffff007) at extent_mmap.c:24:14
    frame #3: 0x0000fffff7c700e8 libjemalloc.so.2`base_map(tsdn=0x0000fffff7fee770, ehooks=0x0000fffffffff138, ind=32, size=2097152) at base.c:49:10
    frame #4: 0x0000fffff7c70e90 libjemalloc.so.2`base_block_alloc(tsdn=0x0000fffff7fee770, base=0x0000000000000000, ehooks=0x0000fffffffff138, ind=32, pind_last=0x0000fffffffff100, je_extent_sn_next=0x0000fffffffff108, size=3992, alignment=16) at base.c:265:40
    frame #5: 0x0000fffff7c71444 libjemalloc.so.2`je_base_new(tsdn=0x0000fffff7fee770, ind=32, extent_hooks=0x0000fffff7daf798, metadata_use_hooks=true) at base.c:360:24
    frame #6: 0x0000fffff7c673e0 libjemalloc.so.2`je_arena_new(tsdn=0x0000fffff7fee770, ind=32, config=0x0000fffff7daf998) at arena.c:1607:10
    frame #7: 0x0000fffff7c45418 libjemalloc.so.2`arena_init_locked(tsdn=0x0000fffff7fee770, ind=32, config=0x0000fffff7daf998) at jemalloc.c:415:10
    frame #8: 0x0000fffff7c454e8 libjemalloc.so.2`je_arena_init(tsdn=0x0000fffff7fee770, ind=32, config=0x0000fffff7daf998) at jemalloc.c:443:10
    frame #9: 0x0000fffff7c5e870 libjemalloc.so.2`arena_get(tsdn=0x0000fffff7fee770, ind=32, init_if_missing=true) at jemalloc_internal_inlines_a.h:68:10
    frame #10: 0x0000fffff7c67998 libjemalloc.so.2`je_arena_choose_huge(tsd=0x0000fffff7fee770) at arena.c:1721:16
    frame #11: 0x0000fffff7c5fdc0 libjemalloc.so.2`arena_choose_maybe_huge(tsd=0x0000fffff7fee770, arena=0x0000000000000000, size=33554432) at arena_inlines_b.h:34:11
    frame #12: 0x0000fffff7c65d74 libjemalloc.so.2`je_arena_malloc_hard(tsdn=0x0000fffff7fee770, arena=0x0000000000000000, size=33554432, ind=80, zero=false) at arena.c:1196:11
    frame #13: 0x0000fffff7c40f40 libjemalloc.so.2`arena_malloc(tsdn=0x0000fffff7fee770, arena=0x0000000000000000, size=33554432, ind=80, zero=false, tcache=0x0000fffff7feeac8, slow_path=true) at arena_inlines_b.h:162:9
    frame #14: 0x0000fffff7c42c84 libjemalloc.so.2`iallocztm(tsdn=0x0000fffff7fee770, size=33554432, ind=80, zero=false, tcache=0x0000fffff7feeac8, is_internal=false, arena=0x0000000000000000, slow_path=true) at jemalloc_internal_inlines_c.h:55:8
    frame #15: 0x0000fffff7c4f86c libjemalloc.so.2`imalloc_no_sample(sopts=0x0000fffffffff540, dopts=0x0000fffffffff568, tsd=0x0000fffff7fee770, size=33554432, usize=33554432, ind=80) at jemalloc.c:2398:9
    frame #16: 0x0000fffff7c50094 libjemalloc.so.2`imalloc_body(sopts=0x0000fffffffff540, dopts=0x0000fffffffff568, tsd=0x0000fffff7fee770) at jemalloc.c:2573:16
    frame #17: 0x0000fffff7c505a8 libjemalloc.so.2`imalloc(sopts=0x0000fffffffff540, dopts=0x0000fffffffff568) at jemalloc.c:2694:10
    frame #18: 0x0000fffff7c50624 libjemalloc.so.2`je_malloc_default(size=33554432) at jemalloc.c:2722:2
    frame #19: 0x0000fffff7c43a3c libjemalloc.so.2`imalloc_fastpath(size=33554432, fallback_alloc=(libjemalloc.so.2`je_malloc_default at jemalloc.c:2700:29)) at jemalloc_internal_inlines_c.h:266:10
    frame #20: 0x0000fffff7c50788 libjemalloc.so.2`malloc(size=33554432) at jemalloc.c:2746:9
    frame #21: 0x0000aaaaaaaa07f4 test_malloc`main at test_malloc.c:5:25
    frame #22: 0x0000fffff7a984c4 libc.so.6`___lldb_unnamed_symbol3097 + 116
    frame #23: 0x0000fffff7a98598 libc.so.6`__libc_start_main + 152
    frame #24: 0x0000aaaaaaaa06f0 test_malloc`_start + 48


* thread #1, name = 'test_malloc', stop reason = breakpoint 21.1
  * frame #0: 0x0000fffff7cea0e0 libjemalloc.so.2`os_pages_map(addr=0x0000000000000000, size=41943040, alignment=4096, commit=0x0000ffffffffef66) at pages.c:149:9
    frame #1: 0x0000fffff7cea7b0 libjemalloc.so.2`je_pages_map(addr=0x0000000000000000, size=41943040, alignment=4096, commit=0x0000ffffffffef66) at pages.c:296:14
    frame #2: 0x0000fffff7cc51e8 libjemalloc.so.2`je_extent_alloc_mmap(new_addr=0x0000000000000000, size=41943040, alignment=4096, zero=0x0000ffffffffef65, commit=0x0000ffffffffef66) at extent_mmap.c:24:14
    frame #3: 0x0000fffff7cb3610 libjemalloc.so.2`extent_alloc_core(tsdn=0x0000fffff7fee770, arena=0x0000fffff7001080, new_addr=0x0000000000000000, size=41943040, alignment=4096, zero=0x0000ffffffffef65, commit=0x0000ffffffffef66, dss_prec=dss_prec_secondary) at ehooks.c:36:13
    frame #4: 0x0000fffff7cb3790 libjemalloc.so.2`je_ehooks_default_alloc_impl(tsdn=0x0000fffff7fee770, new_addr=0x0000000000000000, size=41943040, alignment=4096, zero=0x0000ffffffffef65, commit=0x0000ffffffffef66, arena_ind=32) at ehooks.c:59:14
    frame #5: 0x0000fffff7cbda00 libjemalloc.so.2`ehooks_alloc(tsdn=0x0000fffff7fee770, ehooks=0x0000fffff70000c0, new_addr=0x0000000000000000, size=41943040, alignment=4096, zero=0x0000ffffffffef65, commit=0x0000ffffffffef66) at ehooks.h:197:9
    frame #6: 0x0000fffff7cc1520 libjemalloc.so.2`extent_grow_retained(tsdn=0x0000fffff7fee770, pac=0x0000fffff7003b98, ehooks=0x0000fffff70000c0, size=33558528, alignment=64, zero=false, commit=0x0000fffffffff0d7) at extent.c:672:14
    frame #7: 0x0000fffff7cc1c20 libjemalloc.so.2`extent_alloc_retained(tsdn=0x0000fffff7fee770, pac=0x0000fffff7003b98, ehooks=0x0000fffff70000c0, expand_edata=0x0000000000000000, size=33558528, alignment=64, zero=false, commit=0x0000fffffffff0d7, guarded=false) at extent.c:791:11
    frame #8: 0x0000fffff7cbf880 libjemalloc.so.2`je_ecache_alloc_grow(tsdn=0x0000fffff7fee770, pac=0x0000fffff7003b98, ehooks=0x0000fffff70000c0, ecache=0x0000fffff700d450, expand_edata=0x0000000000000000, size=33558528, alignment=64, zero=false, guarded=false) at extent.c:104:19
    frame #9: 0x0000fffff7ce889c libjemalloc.so.2`pac_alloc_real(tsdn=0x0000fffff7fee770, pac=0x0000fffff7003b98, ehooks=0x0000fffff70000c0, size=33558528, alignment=64, zero=false, guarded=false) at pac.c:124:11
    frame #10: 0x0000fffff7ce8bc0 libjemalloc.so.2`pac_alloc_impl(tsdn=0x0000fffff7fee770, self=0x0000fffff7003b98, size=33558528, alignment=64, zero=false, guarded=false, frequent_reuse=false, deferred_work_generated=0x0000fffffffff292) at pac.c:178:11
    frame #11: 0x0000fffff7ce3698 libjemalloc.so.2`pai_alloc(tsdn=0x0000fffff7fee770, self=0x0000fffff7003b98, size=33558528, alignment=64, zero=false, guarded=false, frequent_reuse=false, deferred_work_generated=0x0000fffffffff292) at pai.h:43:9
    frame #12: 0x0000fffff7ce3ec0 libjemalloc.so.2`je_pa_alloc(tsdn=0x0000fffff7fee770, shard=0x0000fffff7003b80, size=33558528, alignment=64, slab=false, szind=80, zero=false, guarded=false, deferred_work_generated=0x0000fffffffff292) at pa.c:139:11
    frame #13: 0x0000fffff7c62f8c libjemalloc.so.2`je_arena_extent_alloc_large(tsdn=0x0000fffff7fee770, arena=0x0000fffff7001080, usize=33554432, alignment=64, zero=false) at arena.c:338:19
    frame #14: 0x0000fffff7cdb8d4 libjemalloc.so.2`je_large_palloc(tsdn=0x0000fffff7fee770, arena=0x0000fffff7001080, usize=33554432, alignment=64, zero=false) at large.c:37:42
    frame #15: 0x0000fffff7cdb770 libjemalloc.so.2`je_large_malloc(tsdn=0x0000fffff7fee770, arena=0x0000fffff7001080, usize=33554432, zero=false) at large.c:17:9
    frame #16: 0x0000fffff7c65df0 libjemalloc.so.2`je_arena_malloc_hard(tsdn=0x0000fffff7fee770, arena=0x0000fffff7001080, size=33554432, ind=80, zero=false) at arena.c:1205:9
    frame #17: 0x0000fffff7c40f40 libjemalloc.so.2`arena_malloc(tsdn=0x0000fffff7fee770, arena=0x0000000000000000, size=33554432, ind=80, zero=false, tcache=0x0000fffff7feeac8, slow_path=true) at arena_inlines_b.h:162:9
    frame #18: 0x0000fffff7c42c84 libjemalloc.so.2`iallocztm(tsdn=0x0000fffff7fee770, size=33554432, ind=80, zero=false, tcache=0x0000fffff7feeac8, is_internal=false, arena=0x0000000000000000, slow_path=true) at jemalloc_internal_inlines_c.h:55:8
    frame #19: 0x0000fffff7c4f86c libjemalloc.so.2`imalloc_no_sample(sopts=0x0000fffffffff540, dopts=0x0000fffffffff568, tsd=0x0000fffff7fee770, size=33554432, usize=33554432, ind=80) at jemalloc.c:2398:9
    frame #20: 0x0000fffff7c50094 libjemalloc.so.2`imalloc_body(sopts=0x0000fffffffff540, dopts=0x0000fffffffff568, tsd=0x0000fffff7fee770) at jemalloc.c:2573:16
    frame #21: 0x0000fffff7c505a8 libjemalloc.so.2`imalloc(sopts=0x0000fffffffff540, dopts=0x0000fffffffff568) at jemalloc.c:2694:10
    frame #22: 0x0000fffff7c50624 libjemalloc.so.2`je_malloc_default(size=33554432) at jemalloc.c:2722:2
    frame #23: 0x0000fffff7c43a3c libjemalloc.so.2`imalloc_fastpath(size=33554432, fallback_alloc=(libjemalloc.so.2`je_malloc_default at jemalloc.c:2700:29)) at jemalloc_internal_inlines_c.h:266:10
    frame #24: 0x0000fffff7c50788 libjemalloc.so.2`malloc(size=33554432) at jemalloc.c:2746:9
    frame #25: 0x0000aaaaaaaa07f4 test_malloc`main at test_malloc.c:5:25
    frame #26: 0x0000fffff7a984c4 libc.so.6`___lldb_unnamed_symbol3097 + 116
    frame #27: 0x0000fffff7a98598 libc.so.6`__libc_start_main + 152
    frame #28: 0x0000aaaaaaaa06f0 test_malloc`_start + 48
```



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
编译
```shell
apt install xsltproc docbook-xsl # 用于生成文档
export CFLAGS="-O0"
./autogen.sh  --disable-cxx # 简单起见，禁用 --disable-cxx， 不然会导致 jemalloc 先被调用。因为 C++ 对象初始化。 --enable-debug 会导致不走 tcatch

bear -- make

```

## 代码

自定义数据类型命名风格：数据结构定义（结构体）以 `_s` 结尾，然后将该类型定义为 `_t` 结尾的类型。例如 `typedef struct tsd_s tsd_t`。


### size class

在 base 之前，需要先讲解一下 jemalloc 的 size class. 由于内存硬件的对齐和地址要求，以及减少内存的碎片化的设计，jemalloc并不会分配任意大小的内存，而是根据设计了满足对齐要求的不同大小类型，这些固定的大小被称为尺寸类型（size class）. 将内存的大小转为一个不小于申请 size 的最小 size class。 

Size class 计算规则：

除了最开始的几个 size class 外，剩下的 size class 可以被分成等长的组。一个组覆盖一个 2 的幂次范围的分配请求；这个幂次称为该组的 base（基准），组内的 size class 能满足 (base, base * 2] 这个左开右闭区间。每组有 SC_NGROUP 个 size class，在这个区间内均等分布，因此每个 size class 能覆盖 base / SC_NGROUP 种可能的分配大小；其值（base / SC_NGROUP）称为该组的 delta（步长）。每个 size class 比前一个大 delta（包括组内第一个 size class，它比 base 大 delta，也比上一组最大 size class 大 delta）。

为了让数学公式完美运行，我们要求 SC_NGROUP 是 2 的幂，并用 SC_LG_NGROUP 来定义它。我们经常会用 lg_base 和 lg_delta 这两个参数来描述。对于每一组 size class，都有 lg_delta = lg_base - SC_LG_NGROUP(从 delta = base / SC_NGROUP 推导)。

在每组中，已知 lg_base 和 lg_delta（实际上可以通过 lg_base 推导出 lg_delta），该组的 size class 依次为：
```
	base + 1 * delta
	 覆盖 (base, base + 1 * delta] 区间的分配请求
	base + 2 * delta
	 覆盖 (base + 1 * delta, base + 2 * delta] 区间
	base + 3 * delta
	 覆盖 (base + 2 * delta, base + 3 * delta] 区间
	...
	base + SC_NGROUP * delta（即 2 * base）
	 覆盖 (base + (SC_NGROUP - 1) * delta, 2 * base] 区间.
	（注意，目前 SC_NGROUP 总是 4，所以实际上“...”部分为空。）
```
需要注意的是，每组的最后一个 size class 恰好是下一组的 base，这样可以保证递推到下一组时 delta 的选择是正确的。由此，我们就可以推导出下一组的 delta 是什么（base / SC_NGROUP）。

现在，让我们开始考虑最前面的几个 size class。在这里有两个额外的常量需要注意：LG_QUANTUM 和 SC_LG_TINY_MIN。LG_QUANTUM 用于保证平台的正确对齐；所有大于等于 (1 << LG_QUANTUM) 的对象，都要求这少是 (1 << LG_QUANTUM) 对齐的。这可以通过让 (1 << LG_QUANTUM) 等于平台所需的最大对齐值，来确保我们不会返回未正确对齐的内存。而对于小于 (1 << LG_QUANTUM) 的分配，我们可以更灵活一些（因为我们不支持类型对齐大于其自身大小的平台）。为了支持这类分配（又不浪费空间），我们引入了 tiny size class；每个 2 的幂一个，直到达到 quantum 大小。因此，总共有 LG_QUANTUM - SC_LG_TINY_MIN 个 tiny size class。

接着就是一个 (1 << LG_QUANTUM) 的 size class，它无法作为我们上面描述的组的开始（覆盖一个2的幂次），因为将其均匀分配计算 delta，得到的 delta 小于了(1 << LG_QUANTUM)，违反了对齐的规则。

第一个被 SC_NGROUP 整除不小于 (1 << LG_QUANTUM) 的 base 是 SC_NGROUP * (1 << LG_QUANTUM)。我们可以在其之前设置 SC_NGROUP 个 size class，并将间隔设置为 (1 << LG_QUANTUM) 。这些 size class 分别是：
 1 * (1 << LG_QUANTUM)
 2 * (1 << LG_QUANTUM)
 3 * (1 << LG_QUANTUM)
 ...（实际上，这里的“...”在实际中是空的）
 SC_NGROUP * (1 << LG_QUANTUM)


### extent 


hooks 接口定义包含了 alloc、dalloc、destroy、commit、decommit、purge_lazy、purge_forced、split 和 merge。
```C
// jemalloc.h
struct extent_hooks_s {
	extent_alloc_t		*alloc;
	extent_dalloc_t		*dalloc;
	extent_destroy_t	*destroy;
	extent_commit_t		*commit;
	extent_decommit_t	*decommit;
	extent_purge_t		*purge_lazy;
	extent_purge_t		*purge_forced;
	extent_split_t		*split;
	extent_merge_t		*merge;
};
```
jemalloc 自己使用的是默认实现：
```C
// ehooks.c
const extent_hooks_t ehooks_default_extent_hooks = {
	ehooks_default_alloc,
	ehooks_default_dalloc,
	ehooks_default_destroy,
	ehooks_default_commit,
	ehooks_default_decommit,
#ifdef PAGES_CAN_PURGE_LAZY
	ehooks_default_purge_lazy,
#else
	NULL,
#endif
#ifdef PAGES_CAN_PURGE_FORCED
	ehooks_default_purge_forced,
#else
	NULL,
#endif
	ehooks_default_split,
	ehooks_default_merge
};

```



## 线程本地数据：

```C
/* The actual tsd. */
struct tsd_s {
	/*
	 * The contents should be treated as totally opaque outside the tsd
	 * module.  Access any thread-local state through the getters and
	 * setters below.
	 */

#define O(n, t, nt)							\
	t TSD_MANGLE(n);

	TSD_DATA_SLOW
	/*
	 * We manually limit the state to just a single byte.  Unless the 8-bit
	 * atomics are unavailable (which is rare).
	 */
	tsd_state_t state;
	TSD_DATA_FAST
	TSD_DATA_SLOWER
#undef O
};

/*
 * Wrapper around tsd_t that makes it possible to avoid implicit conversion
 * between tsd_t and tsdn_t, where tsdn_t is "nullable" and has to be
 * explicitly converted to tsd_t, which is non-nullable.
 */
struct tsdn_s {
	tsd_t tsd;
};

typedef struct tsd_s tsd_t;
typedef struct tsdn_s tsdn_t;
```
然后定义了两个线程本地数据：
```C
JEMALLOC_TSD_TYPE_ATTR(tsd_t) tsd_tls = TSD_INITIALIZER;
pthread_key_t tsd_tsd;

atomic_p_t		arenas[MALLOCX_ARENA_LIMIT];
/* NB: Arena index bias decreases the maximum number of arenas by 1. */
#define MALLOCX_ARENA_LIMIT	((1 << MALLOCX_ARENA_BITS) - 1)
#define MALLOCX_ARENA_BITS	12

```

Arena

```C
struct arena_s {
	/*
	 * Number of threads currently assigned to this arena.  Each thread has
	 * two distinct assignments, one for application-serving allocation, and
	 * the other for internal metadata allocation.  Internal metadata must
	 * not be allocated from arenas explicitly created via the arenas.create
	 * mallctl, because the arena.<i>.reset mallctl indiscriminately
	 * discards all allocations for the affected arena.
	 *
	 *   0: Application allocation.
	 *   1: Internal metadata allocation.
	 *
	 * Synchronization: atomic.
	 */
	atomic_u_t		nthreads[2];

	/* Next bin shard for binding new threads. Synchronization: atomic. */
	atomic_u_t		binshard_next;

	/*
	 * When percpu_arena is enabled, to amortize the cost of reading /
	 * updating the current CPU id, track the most recent thread accessing
	 * this arena, and only read CPU if there is a mismatch.
	 */
	tsdn_t		*last_thd;

	/* Synchronization: internal. */
	arena_stats_t		stats;

	/*
	 * Lists of tcaches and cache_bin_array_descriptors for extant threads
	 * associated with this arena.  Stats from these are merged
	 * incrementally, and at exit if opt_stats_print is enabled.
	 *
	 * Synchronization: tcache_ql_mtx.
	 */
	ql_head(tcache_slow_t)			tcache_ql;
	ql_head(cache_bin_array_descriptor_t)	cache_bin_array_descriptor_ql;
	malloc_mutex_t				tcache_ql_mtx;

	/*
	 * Represents a dss_prec_t, but atomically.
	 *
	 * Synchronization: atomic.
	 */
	atomic_u_t		dss_prec;

	/*
	 * Extant large allocations.
	 *
	 * Synchronization: large_mtx.
	 */
	edata_list_active_t	large;
	/* Synchronizes all large allocation/update/deallocation. */
	malloc_mutex_t		large_mtx;

	/* The page-level allocator shard this arena uses. */
	pa_shard_t		pa_shard;

	/*
	 * A cached copy of base->ind.  This can get accessed on hot paths;
	 * looking it up in base requires an extra pointer hop / cache miss.
	 */
	unsigned ind;

	/*
	 * Base allocator, from which arena metadata are allocated.
	 *
	 * Synchronization: internal.
	 */
	base_t			*base;
	/* Used to determine uptime.  Read-only after initialization. */
	nstime_t		create_time;

	/*
	 * The arena is allocated alongside its bins; really this is a
	 * dynamically sized array determined by the binshard settings.
	 */
	bin_t			bins[0];
};
typedef struct arena_s arena_t

/*
 * Arenas that are used to service external requests.  Not all elements of the
 * arenas array are necessarily used; arenas are created lazily as needed.
 *
 * arenas[0..narenas_auto) are used for automatic multiplexing of threads and
 * arenas.  arenas[narenas_auto..narenas_total) are only used if the application
 * takes some action to create them and allocate from them.
 *
 * Points to an arena_t.
 */
JEMALLOC_ALIGNED(CACHELINE)
atomic_p_t		arenas[MALLOCX_ARENA_LIMIT];
#define MALLOCX_ARENA_LIMIT	((1 << MALLOCX_ARENA_BITS) - 1
#define MALLOCX_ARENA_BITS	1

static atomic_u_t	narenas_total; /* Use narenas_total_*(). */
/* Below three are read-only after initialization. */
static arena_t		*a0; /* arenas[0]. */
unsigned		narenas_auto;
unsigned		manual_arena_base;

// arena 0.
static base_t *b0

```
`malloc_init_narenas` 对其进行初始化。





入口

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

初始化

```C
static bool
malloc_init_hard(void) {
	tsd_t *tsd;
     ... // 装填判断，是否已经初始化过。
	/* Recursive allocation relies on functional tsd. */
	tsd = malloc_tsd_boot0(); // 申请 tsd.
	if (tsd == NULL) {
		return true;
	}
	if (malloc_init_hard_recursible()) { // 注册 fork 调用的回调，用户管理在多线程中执行 fork 可能引起的资源问题。
		return true;
	}

	malloc_mutex_lock(tsd_tsdn(tsd), &init_lock);
	/* Set reentrancy level to 1 during init. */
	pre_reentrancy(tsd, NULL);
	/* Initialize narenas before prof_boot2 (for allocation). */
	if (malloc_init_narenas()
	    || background_thread_boot1(tsd_tsdn(tsd), b0get())) {
		UNLOCK_RETURN(tsd_tsdn(tsd), true, true)
	}
	if (config_prof && prof_boot2(tsd, b0get())) {
		UNLOCK_RETURN(tsd_tsdn(tsd), true, true)
	}

	malloc_init_percpu();

	if (malloc_init_hard_finish()) {
		UNLOCK_RETURN(tsd_tsdn(tsd), true, true)
	}
	post_reentrancy(tsd);
	malloc_mutex_unlock(tsd_tsdn(tsd), &init_lock);

	witness_assert_lockless(witness_tsd_tsdn(
	    tsd_witness_tsdp_get_unsafe(tsd)));
	malloc_tsd_boot1();
	/* Update TSD after tsd_boot1. */
	tsd = tsd_fetch();
	if (opt_background_thread) {
		assert(have_background_thread);
		/*
		 * Need to finish init & unlock first before creating background
		 * threads (pthread_create depends on malloc).  ctl_init (which
		 * sets isthreaded) needs to be called without holding any lock.
		 */
		background_thread_ctl_init(tsd_tsdn(tsd));
		if (background_thread_create(tsd, 0)) {
			return true;
		}
	}
#undef UNLOCK_RETURN
	return false;
}
```

```C
malloc_tsd_boot0(void) {
	tsd_t *tsd;
	... 加锁
	if (tsd_boot0()) { // 初始化 tsd_tsd
		return NULL;
	}
	tsd = tsd_fetch(); // 获取 tsd_tls 的地址。第一次会初始化 tsd_tls, 将其设置给 tsd_tsd(在 tsd_set() 方法中)。
	return tsd;
}
```
有个疑问：为什么使用了两种 TLS 方法？ tsd_tsd 和 tsd_tls 都是做线程本地数据的方式。为什么重复使用两者？而且 `tsd_tsd` 存的就是 `tsd_tls`.

答：主要是为了用 PThread TLS 的释放功能，在线程释放时根据状态不同，释放数据。但同时不用调用 pthread_getspecific 获取 TLS 数据，直接通过变量，效率更高。


```C
imalloc_fastpath(size_t size, void *(fallback_alloc)(size_t)) {
	// 开启 debug 会导致从这里进入慢速路径。
	/*
	 * Check for events and tsd non-nominal (fast_threshold will be set to
	 * 0) in a single branch.
	 */
	if (unlikely(allocated_after >= threshold)) {
		return fallback_alloc(size);
	}
	... 
}

static void
malloc_slow_flag_init(void) {
	/*
	 * Combine the runtime options into malloc_slow for fast path.  Called
	 * after processing all the options.
	 */
	malloc_slow_flags |= (opt_junk_alloc ? flag_opt_junk_alloc : 0)
	    | (opt_junk_free ? flag_opt_junk_free : 0)
	    | (opt_zero ? flag_opt_zero : 0)
	    | (opt_utrace ? flag_opt_utrace : 0)
	    | (opt_xmalloc ? flag_opt_xmalloc : 0);

	malloc_slow = (malloc_slow_flags != 0);
}

static uint8_t
tsd_state_compute(tsd_t *tsd) {
	if (!tsd_nominal(tsd)) {
		return tsd_state_get(tsd);
	}
	/* We're in *a* nominal state; but which one? */
	if (malloc_slow || tsd_local_slow(tsd) || tsd_global_slow()) {
		return tsd_state_nominal_slow;
	} else {
		return tsd_state_nominal;
	}
}

```

## base

采用 pairing heap 管理所有未用空间，分配时优先复用，空间不足时新分配大块
块内分配采用 bump pointer 算法，极快且无碎片。
回收只在整体销毁时发生，平时通过空间复用避免碎片。

- base_t：管理所有元数据空间，包含 block 链表（base_block_t *blocks）、未用空间堆（edata_heap_t avail[SC_NSIZES]）、统计信息等。
- base_block_t：每个 block 是一块大虚拟内存，头部有元数据（block 大小、下一个 block 指针、一个 edata_t 描述主空间）。
- edata_t：描述一段内存区间（extent），用于管理未用空间、分配和回收。

- base_extent_bump_alloc_helper / base_extent_bump_alloc 配对
	- base_extent_bump_alloc_helper 采用 bump pointer 算法分配，即从 extent 起始处“切”出一块空间，剩余部分重新描述并入堆。
	- base_extent_bump_alloc_post 将剩余空间插入 avail 堆，并更新统计信息

创建 base 

```C
base_new(tsdn_t *tsdn, unsigned ind, const extent_hooks_t *extent_hooks,
    bool metadata_use_hooks) {
    ...
	// 申请一个块内存，直接将地址转为了 base_block_t *，因此 base_block_t 就存在这块内存的开始位置。
	base_block_t *block = base_block_alloc(tsdn, NULL, &fake_ehooks, ind,
	    &pind_last, &extent_sn_next, sizeof(base_t), QUANTUM);
	if (block == NULL) {
		return NULL;
	}
	...
	// 从 block 上取一块内存存储 base.
	base_t *base = (base_t *)base_extent_bump_alloc_helper(&block->edata,
	    &gap_size, base_size, base_alignment);
	// 初始化 base 内容
	...

}
```

## arena

1. 其它 arena 何时、如何初始化。
2. 何时走到 arena 
3. small、large、huge 的分配路径。

数量：
如果指定了 opt_narenas，优先按指定的数量。
没指定数量指定了 opt_narenas_ratio 就按照 `cpu 数量 * opt_narenas_ratio` 四舍五入取整数。 opt_narenas_ratio 默认值是 4。

```C
static bool
malloc_init_narenas(void) {
	...
	if (opt_narenas == 0) {
		opt_narenas = malloc_narenas_default();
	}
	assert(opt_narenas > 0);
	narenas_auto = opt_narenas;

	if (narenas_auto >= MALLOCX_ARENA_LIMIT) {
		// 数量限制在最大数量减1，给 huge arena 留一个位置。
		narenas_auto = MALLOCX_ARENA_LIMIT - 1;
		malloc_printf("<jemalloc>: Reducing narenas to limit (%d)\n",
		    narenas_auto);
	}
	narenas_total_set(narenas_auto);
	// huge arena 放在普通 arena 的后面，如果有 huge arena，数量加一。
	if (arena_init_huge()) {
		narenas_total_inc();
	}
	// jemalloc 允许用户自己创建和销毁 arena，manual_arena_base 指定用户自己创建 arena 的开始位置。
	manual_arena_base = narenas_total_get();
	return false;
}
```

jemalloc 启动时（malloc_init_hard_a0_locked），只会初始化 arena 0（a0），其它自动 arena（arenas[1..narenas_auto-1]）并不会立即分配和初始化。
当新线程第一次分配内存时，会通过 arena_choose_hard() 选择一个负载最轻的 arena。如果该 arena 还没有被初始化（即 arenas[i] == NULL），就会调用 arena_init_locked() 创建并初始化这个 arena。
这样做的好处是节省内存和初始化开销，只有真正需要时才分配和初始化 arena。

```C
// jemalloc.c
arena_t *arena_choose_hard(tsd_t *tsd, bool internal) {
    ...
    for (i = 1; i < narenas_auto; i++) {
        if (arena_get(tsd_tsdn(tsd), i, false) == NULL) {
            // 记录第一个未初始化的 arena 索引
            first_null = i;
        }
    }
    ...
    // 如果需要新建 arena
    if (arena == NULL) {
        arena = arena_init_locked(tsd_tsdn(tsd), choose[j], &arena_config_default);
        ...
    }
    ...
}
```

### slab 分配器

系统硬件设计为分配内存只能整页分配，但程序使用过程中往往只需要一小块内存。并且，小块内存的分配非常频繁。slab 分配器是为了应对小块内存而设计的，内存分配以Byte为单位

- slab 每次从系统申请连续的 N 页，称为一个 SLAB, slab 被划分成相同大小的内存块，每个内存块被称为一个 object. 所以 slab 是为相同大小内存分配而设计的分配器，在处理相同尺寸的对象的分配上特别高效。





## thread catch (线程缓存)

为了减少多线程内存分配与释放的锁竞争、从而提高分配速度，jemalloc 的设计为每个线程单独的缓存。如果缓存内直接能够分配和释放内存，既不用加锁、而且缓存采用栈数据结构，能够做到 O(1)的分配效率。

模型：栈
TODO: 示意图。


5. 分配和释放算法。
1. 如何初始化？
2. 内存不够了怎么办？
3. 超过缓存大小限制了怎么办？
4. 增大了缓存空间，释放如何回收。


## 内存分类流程

```C
JEMALLOC_ALWAYS_INLINE void *
imalloc_fastpath(size_t size, void *(fallback_alloc)(size_t)) {
	LOG("core.malloc.entry", "size: %zu", size);
	if (tsd_get_allocates() && unlikely(!malloc_initialized())) {
		return fallback_alloc(size);
	}

	tsd_t *tsd = tsd_get(false);
	// 大小大于 SC_LOOKUP_MAXCLASS 直接走 malloc_default
	if (unlikely((size > SC_LOOKUP_MAXCLASS) || tsd == NULL)) {
		return fallback_alloc(size);
	}
	/*
	 * The code below till the branch checking the next_event threshold may
	 * execute before malloc_init(), in which case the threshold is 0 to
	 * trigger slow path and initialization.
	 *
	 * Note that when uninitialized, only the fast-path variants of the sz /
	 * tsd facilities may be called.
	 */
	szind_t ind;
	/*
	 * The thread_allocated counter in tsd serves as a general purpose
	 * accumulator for bytes of allocation to trigger different types of
	 * events.  usize is always needed to advance thread_allocated, though
	 * it's not always needed in the core allocation logic.
	 */
	size_t usize;
	sz_size2index_usize_fastpath(size, &ind, &usize);
	/* Fast path relies on size being a bin. */
	assert(ind < SC_NBINS);
	assert((SC_LOOKUP_MAXCLASS < SC_SMALL_MAXCLASS) &&
	    (size <= SC_SMALL_MAXCLASS));

	uint64_t allocated, threshold;
	te_malloc_fastpath_ctx(tsd, &allocated, &threshold);
	uint64_t allocated_after = allocated + usize;
	/*
	 * The ind and usize might be uninitialized (or partially) before
	 * malloc_init().  The assertions check for: 1) full correctness (usize
	 * & ind) when initialized; and 2) guaranteed slow-path (threshold == 0)
	 * when !initialized.
	 */
	if (!malloc_initialized()) {
		assert(threshold == 0);
	} else {
		assert(ind == sz_size2index(size));
		assert(usize > 0 && usize == sz_index2size(ind));
	}
	/*
	 * Check for events and tsd non-nominal (fast_threshold will be set to
	 * 0) in a single branch.
	 */
	if (unlikely(allocated_after >= threshold)) {
		return fallback_alloc(size);
	}
	assert(tsd_fast(tsd));

	tcache_t *tcache = tsd_tcachep_get(tsd);
	assert(tcache == tcache_get(tsd));
	cache_bin_t *bin = &tcache->bins[ind];
	bool tcache_success;
	void *ret;

	/*
	 * We split up the code this way so that redundant low-water
	 * computation doesn't happen on the (more common) case in which we
	 * don't touch the low water mark.  The compiler won't do this
	 * duplication on its own.
	 */
	ret = cache_bin_alloc_easy(bin, &tcache_success);
	if (tcache_success) {
		fastpath_success_finish(tsd, allocated_after, bin, ret);
		return ret;
	}
	ret = cache_bin_alloc(bin, &tcache_success);
	if (tcache_success) {
		fastpath_success_finish(tsd, allocated_after, bin, ret);
		return ret;
	}

	return fallback_alloc(size);
}
```

## 内存分配整体策略：

1. 多申请、换释放。不会浪费空间，因为操作系统物理内存分配采用的是延迟分配，只有访问的时候才分配实际的物理内存。而且内存分配是按页的，及时只使用一个字节，也需要分配一页。因此多申请、缓释放能够显著提高程序速度。

2. 能线程内部分配的，在线程内部分配，减少访问相同数据结构需要的加锁行为。

3. 使用 TLS(线程本地存储) 来实现线程数据的无锁化。


## 其它

- 在 glibc 中 malloc 分配大内存的时候会用到匿名映射。这里所谓的“大”表示是超过了 MMAP_THRESHOLD 设置的字节数，它的缺省值是 128 kB，可以通过 mallopt() 去调整这个设置值。
 


参考：
https://blog.51cto.com/u_11529070/9161159
https://blog.csdn.net/weixin_42766184/category_12885143.html


https://zhuanlan.zhihu.com/p/423062509
https://juejin.cn/post/6914550038140026887