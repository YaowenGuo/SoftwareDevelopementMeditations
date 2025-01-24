# 内存管理

引导程序将内核和设备树文件 DTB 拷贝进内存，Linux 内核肩负着内存管理的责任，而其自身也存储在内存中，为了管理内存，内核需要小心翼翼、一步一步的逐步开启内存管理的功能（虚拟内存 MMU），初始化内存管理模块。这其中主要经历几个阶段：

1. 开启 MMU。
	1. 为了解决开启 MMU 前后的虚拟地址和物理地址的关系，建立恒等映射表 init_idmap_pg_dir
	2. 开启 MMU，切换到虚拟地址运行。此时运行的内核代码地址在用户地址空间。
	3. 将内核自身映射到虚拟内存空间，建立内核自身的地址映射的 `页表` `init_pg_dir`，最终拷贝到 `swapper_pg_dir`， 将 swapper_pg_dir赋值给页表指针 ttbr1。
	4. 设置页表指针，切换到虚拟内存运行，此时运行的代码地址才到了内核地址空间。

2. 解析 DTB
	1. 为 DTB 建立固定映射。内核需要管理的设备信息通过 DTB 中，而内存的信息也存储在 DTB 中，为了解析 DTB，需要
	2. 解析内存信息

3. 初始化内存管理模块
	1. 初始化早期内存分配器 memblock 。
	2. 初始化页分配器 paging_init，伙伴系统分配器
	2. 初始化内存管理区，Slub 内存管理器


建立固定映射，

## 内存管理的初始化流程

1. MMU 之前，只能使用物理地址，直接操作内存

2. MMU 开启之后，可以通过页表问内存已经映射的内存。

3. memblock 初始化，能够通过 memblock 来管理内存


4. buddy 系统建立，可以通过伙伴系统来访问内存。

5. Zoon Allocator 和 Slub 分配器初始化。


This document describes the virtual memory layout used by the AArch64
Linux kernel. The architecture allows up to 4 levels of translation
tables with a 4KB page size and up to 3 levels with a 64KB page size.

AArch64 Linux uses either 3 levels or 4 levels of translation tables
with the 4KB page configuration, allowing 39-bit (512GB) or 48-bit
(256TB) virtual addresses, respectively, for both user and kernel. With
64KB pages, only 2 levels of translation tables, allowing 42-bit (4TB)
virtual address, are used but the memory layout is the same.

ARMv8.2 adds optional support for Large Virtual Address space. This is
only available when running with a 64KB page size and expands the
number of descriptors in the first level of translation.

User addresses have bits 63:48 set to 0 while the kernel addresses have
the same bits set to 1. TTBRx selection is given by bit 63 of the
virtual address. The swapper_pg_dir contains only kernel (global)
mappings while the user pgd contains only user (non-global) mappings.
The swapper_pg_dir address is written to TTBR1 and never written to
TTBR0.

0000 ffff ffff ffff
3 * 4 * 4 = 48
47 
AArch64 Linux memory layout with 4KB pages + 4 levels (48-bit)::
```
						  Virtual Memory Layout	  
                      +--------------------------+<---------------
0000 0000 0000 0000	  |         		         |
					  |         		         |
					  |            		         |
					  |            		         |
					  |           user           |              256T
					  |            		         |
					  |            		         |
					  |            		         |
0000 ffff ffff ffff	  |            		         |  
                      +--------------------------+<---------------+
                      ~                          ~
                      +--------------------------+<---------------+
ffff 0000 0000 0000   |                          |
					  |                          |
					  |kernel logical memory map |
					  |                          |              128T
					  |             	         |
                      +-----------------------+  |
ffff 6000 0000 0000	  | kasan shadow region 32TB |
                      +--------------------------+<----------------+
ffff 8000 0000 0000   |         modules          |  2GB
                      +--------------------------+ KIMAGE_VADDR
ffff 8000 8000 0000   |                          | 内核文件映射区，会有一个随机偏移
					  |            		         |
                      |         vmalloc          |
					  |        124TB-2GB         |                 128T
					  |            		         |
                      +--------------------------+     
end - vmemmap size    |         vmemmap          |  地址空间页数 * sizeof(struct page)
                      +--------------------------+<-----+  
ffff ffff c000 0000   |      [guard region]      | 8MB  |
                      +--------------------------+      |
ffff ffff c080 0000   |       PCI I/O space      | 16MB |
                      +--------------------------+     1GB
ffff ffff c180 0000   ~   				         ~      |
                      +--------------------------+      |
ffff ffff ff40 0000   | fixed mappings (top down)| 4MB  |
                      +--------------------------+      |
ffff ffff ff80 0000   |      [guard region]      | 8MB  |
ffff ffff ffff ffff   +--------------------------+<------------------+

#define VA_BITS			(CONFIG_ARM64_VA_BITS)
#define _PAGE_OFFSET(va)	(-(UL(1) << (va)))
#define PAGE_OFFSET		(_PAGE_OFFSET(VA_BITS))
#define KIMAGE_VADDR		(MODULES_END)
#define MODULES_END		(MODULES_VADDR + MODULES_VSIZE)
#define MODULES_VADDR		(_PAGE_END(VA_BITS_MIN))
#define MODULES_VSIZE		(SZ_2G)
#define VMEMMAP_START		(VMEMMAP_END - VMEMMAP_SIZE)
#define VMEMMAP_END		(-UL(SZ_1G))
#define PCI_IO_START		(VMEMMAP_END + SZ_8M)
#define PCI_IO_END		(PCI_IO_START + PCI_IO_SIZE)
#define FIXADDR_TOP		(-UL(SZ_8M))
```

**不同体系架构即便是相同位的地址总线，因为设计不同，可用的地址空间大小也不一样。例如 X86 计算机的 48 位地址总线，由于是根据 48 位的最高位判断是用户还是系统地址空间，因此用户和内核地址空间可用的大小各 128TB。在Arm64 上，是用 64 位的最高位判断是用户还是内核地址空间，因此用户和内核地址空间各 256TB。**

即便是相同体系结构的CPU，地址空间的分配也可能不同，例如 ARM64 48位地址空间，如果是采用了 16K 的页面，则内核地址空间是从 `ffff 8000 0000 0000` 开始，内核地址空间只占了 128TB。但总体的布局是不变的。如果想要查看具体的划分，[可以自己编译内核，打开内核的地址空间调试](https://docs.kernel.org/arch/arm64/ptdump.html)，在 `/sys/kernel/debug/kernel_page_tables` 文件中可以看到实际的内核的地址空间使用情况。




Arm64 内核地址空间中的区域：

- kernel logical memory map 和 kasan shadow region 共用了 128T。
	- kernel logical memory map 即线性映射区，和物理内存存在线性关系，不需要查找页表即可进行物理地址和虚拟地址的快速转换。这部分区域在内核启动时即将物理内存全部映射，实际使用多少根据物理内存大小而定，实际上由于可以使用大页映射，页表并不会占用太多内存。这样设计是为了访问效率，内核可以直接使用这些地址，不需要映射再使用。
	**虽然内核映射了全部物理内存，但并不是代表物理内存被占用了，实际物理内存占用在 slab 中管理。**

	- kasan shadow region：如果启用了KASAN内存错误检测，这个区域用于存储阴影内存以检测内存错误。

- modules：用于映射内核模块，加载内核模块时动态映射。
- vmalloc：内核分配内存的区域，在分配时动态映射，Linux 内核镜像也被映射到这个区域。
- vmemmap：这部分用于管理物理内存，也是在内核启动时就建立映射，在物理内存大小发生变化时才会更新（例如内存热插拔）。
- PCI I/O space： 预留给 IO 设备的映射区。 
- fixed mappings：启动时用于临时映射内核的区域。启动后不再使用了？

linux 内核运行时动态分配内存都是从线性映射区（kmalloc()）和 vmalloc(vmalloc())区分配，其它 modules、vmemmap、PCI I/O space 虽然也会发生变化，但都是用于特定用途的区域。你可能像我一样疑惑，为什么线性映射区已经映射了所有的物理内存，还需要 vmalloc 区域，看起来kmalloc 和 vmalloc 只是分配策略的不同，也不至于使用不同区域的地步。实际上是因为 [32 位机器的历史原因](https://stackoverflow.com/questions/58837677/memory-mapping-in-linux-kernel-use-of-vamlloc-and-kmalloc)。32 位 Linux 内核将 4GB 空间 3GB 留给用户空间，内核使用 1GB(据说也可以在编译是调整大小为 2GB用户2GB内核)，早期内存比较小（不超过 1GB），全部内存可以直接映射到内核空间，Linux 采用线性映射来映射所有物理内存。随着硬件技术的发展，物理内存大小很快突破了 1GB，此时 1GB 的内核地址继续使用线性映射已经无法访问全部的物理内存了，这样的内核显然不合格。Linux 的解决方案是，将一部分还使用线性映射。留一部分可以动态映射到物理内存的任意位置，动态映射部分使用后释放可以映射到其它位置，这样就可以访问全部的物理内存了。线性映射的部分别设置为 896MB，这部分线性映射到物理内存开始的 896MB，这部分物理内存也被称为低端内存，高于 896MB 的内存称为高端内存。到了 64位内存地址机器上，地址空间足够大了，以至于可以预见的将来，单机的物理内存大小都无法超过 64 位地址空间。现在主流的机器实际使用了 48 位物理地址，即便如此也达到了 256TB。此时内核地址空间足以线性映射全部的物理内存。然而 vmalloc 区仍然被保留了下来。stackoverflow 上的一个回答说 vmalloc 区域不再必要了。（注意，这里是说内核 vmalloc 区域不再必要，而不是 vmalloc() 函数调用的分配策略，个人认为他们可以使用同一映射区，是指分配策略不同。）


ARM64 为 EL1、EL2、EL3 三级异常级的每个异常级都有单独的寄存器来指向地址映射表。这样不同异常级的切换不必修改寄存器，可以提高效率。

同时每个异常级都有两个寄存器，以 EL1 为例，ttbr0_el1 和 ttbr1_el1, ttbr0 指向 0 开始的低地址地址映射表，ttbr1 指向 1 开始的高地址空间。如上，Linux 的内存布局将内核分配到了高地址空间，即 ttbr1 存放。ttbr0 和 ttbr1 两个寄存器分别指向内核空间和内核空间的映射表可以在进程切换时，只修改 ttbr0。而 ttbr1 无需任何修改，这样内核就自动映射到了新的进程地址空间。


```
---[ Linear Mapping start ]---
 
0xffF0000000000000

0xffff80 00 0000 0000-0xffff800000210000        2112K PTE       RW NX SHD AF            UXN    MEM/NORMAL-TAGGED
0xffff800000210000-0xffff800002000000       30656K PTE       ro NX SHD AF            UXN    MEM/NORMAL
0xffff800002000000-0xffff800004000000          32M PMD       ro NX SHD AF        BLK UXN    MEM/NORMAL
0xffff800080000000-0xffff801000000000          62G PMD
0xffff801000000000-0xffffb00000000000       49088G PGD
---[ Linear Mapping end ]---
---[ Kasan shadow start ]---
0xffffb00000000000-0xffffb00010000000         256M PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffffb00010000000-0xffffb01000000000       65280M PMD
0xffffbff7f7ef8000-0xffffbff7f7f00000          32K PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffffbff7f7f00000-0xffffc00000000000       32897M PTE       ro NX SHD AF            UXN    MEM/NORMAL
---[ Kasan shadow end ]---
---[ Modules start ]---
0xffffc00000000000-0xffffc00080000000           2G PMD
---[ Modules end ]---
---[ vmalloc() area ]---
0xffffc00080000000-0xffffc00080008000          32K PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffffc00080008000-0xffffc00080010000          32K PTE
0xffffffbfbf7e8000-0xffffffbfbf800000          96K PTE       RW NX SHD AF            UXN    MEM/NORMAL
---[ vmalloc() end ]---
0xffffffbfbf800000-0xffffffbfc0000000           8M PTE
---[ vmemmap start ]---
0xffffffbfc0000000-0xffffffbfc0800000           8M PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffffffbfc0800000-0xffffffbfc2000000          24M PTE
0xffffffbfc2000000-0xffffffc000000000         992M PMD
0xffffffc000000000-0xfffffff000000000         192G PGD
0xfffffff000000000-0xffffffffc0000000          63G PMD
---[ vmemmap end ]---
0xffffffffc0000000-0xffffffffc0800000           8M PTE
---[ PCI I/O start ]---
0xffffffffc0800000-0xffffffffc0810000          64K PTE       RW NX SHD AF            UXN    DEVICE/nGnRE
0xffffffffc0810000-0xffffffffc1800000       16320K PTE
---[ PCI I/O end ]---
0xffffffffc1800000-0xffffffffc2000000           8M PTE
0xffffffffc2000000-0xfffffffffe000000         960M PMD
0xfffffffffe000000-0xffffffffff400000          20M PTE
---[ Fixmap start ]---
0xffffffffff400000-0xffffffffff5f8000        2016K PTE
0xffffffffff5f8000-0xffffffffff6f8000           1M PTE       ro NX SHD AF            UXN    MEM/NORMAL
0xffffffffff6f8000-0xffffffffff800000        1056K PTE
---[ Fixmap end ]---
0xffffffffff800000-0x0000000000000000           8M PTE
```

```
---[ Linear Mapping start ]---
0xffff000000000000-0xffff000000210000        2112K PTE       RW NX SHD AF            UXN    MEM/NORMAL-TAGGED
0xffff000000210000-0xffff000000400000        1984K PTE       ro NX SHD AF            UXN    MEM/NORMAL
0xffff000000400000-0xffff000004000000          60M PMD       ro NX SHD AF        BLK UXN    MEM/NORMAL
0xffff000004000000-0xffff000004020000         128K PTE       ro NX SHD AF            UXN    MEM/NORMAL
0xffff00007ffff000-0xffff000080000000           4K PTE F     RW NX SHD AF            UXN    MEM/NORMAL-TAGGED
0xffff000080000000-0xffff008000000000         510G PUD
0xffff008000000000-0xffff600000000000       97792G PGD
---[ Linear Mapping end ]---
---[ Kasan shadow start ]---
0xffff600000000000-0xffff600010000000         256M PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffff600010000000-0xffff600040000000         768M PMD
0xffff7fbff7e00000-0xffff7fbff7efd000        1012K PTE
0xffff7fbff7efd000-0xffff7fbff7f00000          12K PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffff7fbff7f00000-0xffff800000000000      262273M PTE       ro NX SHD AF            UXN    MEM/NORMAL
---[ Kasan shadow end ]---
---[ Modules start ]---
0xffff800000000000-0xffff800080000000           2G PUD
---[ Modules end ]---
---[ vmalloc() area ]---
0xffff800080000000-0xffff800080008000          32K PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xffff800080008000-0xffff800080009000           4K PTE
0xfffffdffbf7e8000-0xfffffdffbf7fa000          72K PTE       RW NX SHD AF            UXN    MEM/NORMAL
0xfffffdffbf7fa000-0xfffffdffbf800000          24K PTE
---[ vmalloc() end ]---
0xfffffdffbf800000-0xfffffdffc0000000           8M PMD

---[ vmemmap start ]---
0xfffffdffc0000000-0xfffffdffc2000000          32M PMD       RW NX SHD AF        BLK UXN    MEM/NORMAL
0xfffffdffc2000000-0xfffffe0000000000         992M PMD
0xfffffe0000000000-0xffffff8000000000        1536G PGD
0xffffff8000000000-0xffffffffc0000000         511G PUD
---[ vmemmap end ]---
0xffffffffc0000000-0xffffffffc0800000           8M PMD
---[ PCI I/O start ]---
0xffffffffc0800000-0xffffffffc0810000          64K PTE       RW NX SHD AF            UXN    DEVICE/nGnRE
0xffffffffc0810000-0xffffffffc0a00000        1984K PTE
0xffffffffc0a00000-0xffffffffc1800000          14M PMD
---[ PCI I/O end ]---
0xffffffffc1800000-0xffffffffff400000         988M PMD
0xffffffffff400000-0xffffffffff430000         192K PTE
---[ Fixmap start ]---
0xffffffffff430000-0xffffffffff5fe000        1848K PTE
0xffffffffff5fe000-0xffffffffff6fe000           1M PTE       ro NX SHD AF            UXN    MEM/NORMAL
0xffffffffff6fe000-0xffffffffff800000        1032K PTE
---[ Fixmap end ]---
0xffffffffff800000-0x0000000000000000           8M PMD
```

在内核启动的过程中，有三次地址映射：

1. 恒等映射：虚拟地址和物理地址相同的映射

2. 固定映射

3. 任意映射

由于内核代码已被映射到虚拟空间，CPU 便可以开始执行内核启动函数 start_kernel()。它先执行 early_fixmap_init() 初始化固定映射区，固定映射区是内核虚拟空间的一段区间，在编译期间就确定好的。接着执行 fixmap_remap_fdt 将 dtb文件 映射到 固定映射区的FDT区域。

## 页表

ARM64 支持 4KB 16KB 和 64KB 的页面大小，以及不同的虚拟地址空间，最高支持五级页表。但也不是任意组合，可以的配置有：

```C
// arch/arm64/Kconfig
config PGTABLE_LEVELS
	int
	default 2 if ARM64_16K_PAGES && ARM64_VA_BITS_36
	default 2 if ARM64_64K_PAGES && ARM64_VA_BITS_42
	default 3 if ARM64_64K_PAGES && (ARM64_VA_BITS_48 || ARM64_VA_BITS_52)
	default 3 if ARM64_4K_PAGES && ARM64_VA_BITS_39
	default 3 if ARM64_16K_PAGES && ARM64_VA_BITS_47
	default 4 if ARM64_16K_PAGES && (ARM64_VA_BITS_48 || ARM64_VA_BITS_52)
	default 4 if !ARM64_64K_PAGES && ARM64_VA_BITS_48
	default 5 if ARM64_4K_PAGES && ARM64_VA_BITS_52
```
页表层级 `CONFIG_PGTABLE_LEVELS` 是根据页大小和虚拟地址位数计算得到的，可以看到目前 Arm64 支持五级页表，


无论那种大小的页面，各层级的页表项的大小都是 8 字节，而页表的寻址是 `页面的物理基址` + `表项索引`，因此页表必须存放在一个页面内。表项的数量 = 2^(Page number - 3)。而表项索引的位数就是 `(Page number - 3)`。

不同级别的页表名称：
页表级别：PGD -> P4D -> PUD -> PMD -> PTE。
PGD（Page Global Directory ）页全局目录
P4D（Page 4th Directory ）页四级目录
PUD（Page Upper Directory）页上级目录
PMD（Page Middle Directory）页中级目录
PTE（Page Table Entry）   页表

那对于小于 5 级的页表，如何映射呢？


## 1. 映射

### 页表的变化

1. __enable_mmu 在开启 MMU前，指定 EL1 的页表。init_idmap_pg_dir 加载到 ttbr0_el1，reserved_pg_dir 加载到 ttbr1_el1。此时 reserved_pg_dir 为空，没有实际的功能。

2. early_map_kernel 初始化内核页表，map_kernel 将 swapper_pg_dir 赋值给 ttbr1_el1, `swapper_pg_dir` 就是最终的内核页表的入口。

QA:

1. 为什么不直接在 __enable_mmu 的时候不直接使用 swapper_pg_dir 赋值 ttbr1_el1?

2. 为什么 swapper_pg_dir 不只用使用 init_pg_dir 的首页，而是分别申请空间，然后再将 init_pg_dir
拷贝到 swapper_pg_dir?

3. 内核虚拟地址加载到哪里？



### 恒等映射

为什么需要恒等映射？

Linux 内存管理的需要开启 MMU，并创建页表。而且内核本身也需要通过页表访问，但内核最开始时加载到物理内存的。

对于支持 MMU 的 CPU，CPU 刚启动的时候并没有开启 MMU，这时候对 CPU 的访问都是直接访问的物理地址，一旦开启 MMU，CPU 将使用虚拟地址，任何对内存的操作将经 MMU 转换，变为物理地址。如何解决 MMU 开启前后的地址变化导致的程序执行问题呢？那就是先建立一个临时的页表，将`虚拟地址`映射到相同`物理地址`。这样开启 MMU 之前的物理地址在开启 MMU 之后被当做虚拟地址解析，但会得到相同的物理地址。

Linux 的恒等映射

填充 init_idmap_pg_dir 和 init_pg_dir 页表，这个时候的映射是以块为单位的，每个块大小为2M。在开启 MMU 时，init_idmap_pg_dir会被加载到ttbr0。

init_idmap_pg_dir 用于恒等映射，就是虚拟地址和物理地址相同的映射。linux-6.1 的init_idmap_pg_dir 替代了早期版本的 idmap_pg_dir。idmap_pg_dir 只会映射 idmap.text 段，而 init_idmap_pg_dir 会映射整个内核镜像，在内核镜像之后，还会映射 FDT，所以init_idmap_pg_dir 映射的空间会比内核镜像大一些。
create_idmap 首先将整个区间（包含内核镜像和FDT）映射为RX属性，再将init_pg_dir~init_pg_end 重新映射为 RW 属性，最后把 FDT 以RW属性映射到内核镜像之后。



在体系结构相关的汇编初始化阶段，我们会准备二段地址的页表：一段是 identity mapping，其实就是把地址等于物理地址的那些虚拟地址mapping到物理地址上去，打开MMU相关的代码需要这样的mapping（别的CPU不知道，但是ARM ARCH强烈推荐这么做的）。第二段是 kernel image mapping，内核代码欢快的执行当然需要将kernel running需要的地址（kernel txt、rodata、data、bss等等）进行映射了。具体的映射情况可以参考下图：


启动MMU的汇编代码是 .idmap.text 段，在链接时被连接到 ELF 的 `.rodata.text` 段。

```
 .rodata.text : {
  ...
  *(.idmap.text) __idmap_text_end = .;
 }
```




内核镜像 和 DTB 文件 拷贝到 物理内存，且 对应的物理地址 通过 内核启动参数 告知给 内核，那么内核是如何 初始化内存呢？

```
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 1] .head.text        PROGBITS        ffff800080000000 010000 010000 00  AX  0   0 65536
  [ 2] .text             PROGBITS        ffff800080010000 020000 10f0000 00  AX  0   0 65536
  [ 3] .rodata           PROGBITS        ffff800081100000 1110000 a62468 00 WAMS  0   0 4096
  [ 4] .rodata1          PROGBITS        ffff800081b62468 1b72468 000000 00  WA  0   0  1
  [ 5] .pci_fixup        PROGBITS        ffff800081b62470 1b72470 002e10 00   A  0   0 16
  [ 6] .builtin_fw       PROGBITS        ffff800081b65280 1b75280 000000 00   A  0   0  8
  [ 7] __ksymtab         PROGBITS        ffff800081b65280 1b75280 00ff54 00   A  0   0  4
  [ 8] __ksymtab_gpl     PROGBITS        ffff800081b751d4 1b851d4 018054 00   A  0   0  4
  [ 9] __kcrctab         PROGBITS        ffff800081b8d228 1b9d228 000000 00   A  0   0  1
  [10] __kcrctab_gpl     PROGBITS        ffff800081b8d228 1b9d228 000000 00   A  0   0  1
  [11] __ksymtab_strings PROGBITS        ffff800081b8d228 1b9d228 04471a 01 AMS  0   0  1
  [12] __init_rodata     PROGBITS        ffff800081bd1942 1be1942 000000 00   A  0   0  1
  [13] __param           PROGBITS        ffff800081bd1948 1be1948 004ba0 00   A  0   0  8
  [14] __modver          PROGBITS        ffff800081bd64e8 1be64e8 000828 00  WA  0   0  8
  [15] __ex_table        PROGBITS        ffff800081bd6d10 1be6d10 003060 00   A  0   0  4
  [16] .notes            NOTE            ffff800081bd9d70 1be9d70 000054 00   A  0   0  4
  [17] .hyp.rodata       PROGBITS        ffff800081bda000 1bea000 005000 00 WAMS  0   0  8
  [18] .got              PROGBITS        ffff800081bdf000 1bef000 000068 00  WA  0   0  8
  [19] .rodata.text      PROGBITS        ffff800081bdf800 1bef800 005800 00  AX  0   0 2048
  [20] .init.text        PROGBITS        ffff800081bf0000 1c00000 08f014 00  AX  0   0  4
  [21] .exit.text        PROGBITS        ffff800081c7f014 1c8f014 00b2e8 00  AX  0   0  4
  [22] .altinstructions  PROGBITS        ffff800081c8a2fc 1c9a2fc 0721e0 00   A  0   0  1
  [23] .init.data        PROGBITS        ffff800081d08000 1d18000 0dab90 00 WAMS  0   0 4096
  [24] .data..percpu     PROGBITS        ffff800081de3000 1df3000 00e1e8 00  WA  0   0 64
  [25] .hyp.data..percpu PROGBITS        ffff800081df2000 1e02000 002480 00  WA  0   0 16
  [26] .hyp.reloc        PROGBITS        ffff800081df4480 1e04480 000280 00   A  0   0  4
  [27] .rela.dyn         RELA            ffff800081df4700 1e04700 000090 18   A  0   0  8
  [28] .relr.dyn         RELR            ffff800081df4790 1e04790 023bc0 08   A  0   0  8
  [29] .data             PROGBITS        ffff800081e20000 1e30000 48bb00 00  WA  0   0 4096
  [30] __bug_table       PROGBITS        ffff8000822abb00 22bbb00 028ff8 00  WA  0   0  4
  [31] .mmuoff.data.write PROGBITS       ffff8000822d5000 22e5000 000008 00  WA  0   0 2048
  [32] .mmuoff.data.read PROGBITS        ffff8000822d5800 22e5800 000008 00  WA  0   0  8
  [33] .pecoff_edata_padding PROGBITS    ffff8000822d5808 22e5808 0001f8 00  WA  0   0  1
  [34] .sbss             PROGBITS        ffff8000822d6000 22e5a00 000000 00  WA  0   0  1
  [35] .bss              NOBITS          ffff8000822d6000 22e6000 0bb388 00  WA  0   0 4096
```


```
						Virtual Address												Physical Address
ffff:8000:0000:0000 ->+--------------------------+                           +--------------------------+
					  |         		         | 0x80000000(2G)            |                          |
ffff:8000:8000:0000   +--------------------------+ _text    ---------------> +--------------------------+ 4020:0000  +
   				      |   .head.text             | 0x10000(64K)              |          ID msp          |            |
					  +--------------------------+ _stext                    |                          |            |
ffff:8000:8001:0000   |   .text                  | 0x10f1000(64K对齐，why?)   |                          |            |
ffff:8000:8111:0000   |   .rodata                | 0x00a624a0                |                          |            |
ffff:8000:81b7:24a0   |   .pci_fixup(.rodata1)   | 0x2df0                    |                          |            |
ffff:8000:81b7:5290   |   __ksymtab(.builtin_fw) | 0xff84                    |                          |            |
ffff:8000:81b8:5214   |   __ksymtab_gpl          | 0x18060                   |                          |            |
ffff:8000:81b9:d274   |__ksymtab_strings(__kcrctab,__kcrctab_gpl) |4477e     |                          |            |
ffff:8000:81be:19f2   |   __init_rodata          | 0                         |                          |            |
ffff:8000:81be:19f8   |   __param                | 0x4bc8                    |                          |            |
ffff:8000:81be:65c0   |   __modver               | 0x828                     |                          |            |
ffff:8000:81be:6de8   |   __ex_table             | 0x3060                    |                          |            |
ffff:8000:81be:9e48   |   .notes                 | 0x54                      |                          |            |
ffff:8000:81be:a000   |   .hyp.rodata            | 0x5000                    |                          |            |
ffff:8000:81be:f000   |   .got                   | 0x68                      |                          |            |
ffff:8000:81be:f800 ->+--------------------------+                           |                          |            |
					  |  .rodata.text       	 | 0x5800(2G)                |                          |            |
                      +--------------------------+                           |                          |            |
   				      |  idmap_pg_dir            | 4K(1 << 12)               |                          |            |
					  +--------------------------+                           |                          |            |
   				      |  tramp_pg_dir            | 4K(1 << 12)               |                          |            |
					  +--------------------------+                           |                          |            |
   				      |  reserved_pg_dir         | 4K(1 << 12)               |                          |            |
					  +--------------------------+                           |                          |            |
   				      |  swapper_pg_dir          | 4K(1 << 12)               |                          |            |
ffff:8000:81c0:0000 ->+--------------------------+ __init_begin、__inittext_begin|                      |            |
   				      |   .init.text             | 0x8f088                   |                          |            |
ffff:8000:81c8:f088 ->+--------------------------+                           |                          |            |
                      |   .exit.text             | 0xb208                    |                          |            |
ffff:8000:81c9:a290 ->+--------------------------+                           |                          |            |
                      |   .altinstructions       | 0x7224c                   |                          |            |
					  +--------------------------+                           |                          |            |
					  :                          : ALIGN(0x00010000)         |                          |            |
					  +--------------------------+ __inittext_end、__initdata_begin、init_idmap_pg_dir|  |            |
					  |    恒等映射的页表          | INIT_IDMAP_DIR_SIZE       |                          |            |
					  +--------------------------+ init_idmap_pg_end         |                          |            |
ffff:8000:81d1:8000   |   .init.data             | 0xdab90                   |                          |            |
ffff:8000:81df:3000   |   .data..percpu          | 0xe528                    |                          |            |
ffff:8000:81e0:2000   |   .hyp.data..percpu      | 0x2480                    |                          |            |
ffff:8000:81e0:4480   |   .hyp.reloc             | 0x280                     |                          |            |
ffff:8000:81e0:4700   |   .rela.dyn              | 0x90                      |                          |            |
ffff:8000:81e0:4790   |   .relr.dyn              | 0x23bb0                   |                          |            |
ffff:8000:81e3:0000   |   .data                  | 0x48b7c0                  |                          |            |
ffff:8000:822b:b7c0   |   __bug_table            | 0x29034                   |                          |            |
ffff:8000:822e:4800   |   .mmuoff.data.write     | 0x8                       |                          |            |
ffff:8000:822e:5000   |   .mmuoff.data.read      | 0x8                       |                          |            |
ffff:8000:822e:5008   |   .pecoff_edata_padding  | 0x1f8                     |                          |            |
ffff:8000:822e:6000   |   .sbss                  | 0                         |                          |            |
ffff:8000:822e:6000   |   .bss                   | 0xbb3c8                   |                          |            |
--------------------> +--------------------------+                           |                          |            |
					  |							 | SZ_4K                     |                          |            |
					  +--------------------------+ early_init_stack          |                          |            |
					  |							 | ALIGN(SEGMENT_ALIGN)      |                          |            |
					  +--------------------------+ _end -------------------->+--------------------------+------------+
```

ffff 8000 81bf 40e0 T primary_entry

`head.S` 启动程序中的 `.idmap.text` **汇编段**并没有放到 ELF 的 `.head.text` 中，而是放到了 `.rodata.text` 段中。 `__idmap_text_start` 和 `__idmap_text_end` 分别是 `.rodata.text` 的开始的结束位置。

**Linux 进项使用的是虚拟地址，在内核刚开始，没有打开MMU之前，虚拟地址直接作为物理地址使用，因此，内核刚开始的汇编代码基本上是PIC（位置无关）的。**

要开启 MMU，内核首先需要定位到页表的位置，然后在页表中填入kernel image mapping和identity mapping的页表项。

init_idmap_pg_dir用于恒等映射，即虚拟地址和物理地址相同的映射。init_idmap_pg_dir 会映射整个内核镜像，在内核镜像之后，还会映射FDT，所以init_idmap_pg_dir映射的空间会比内核镜像大一些。
大小为：INIT_IDMAP_DIR_SIZE

```C
#define INIT_IDMAP_DIR_SIZE	((INIT_IDMAP_DIR_PAGES + EARLY_IDMAP_EXTRA_PAGES) * PAGE_SIZE)

/*
 * The initial ID map consists of the kernel image, mapped as two separate
 * segments, and may appear misaligned wrt the swapper block size. This means
 * we need 3 additional pages. The DT could straddle a swapper block boundary,
 * so it may need 2.
 */
#define EARLY_IDMAP_EXTRA_PAGES		3

#define PAGE_SIZE		(1 << PAGE_SHIFT)  // PAGE_SHIFT = 12 即页大小
#define PAGE_SHIFT		CONFIG_PAGE_SHIFT  // 12
#define CONFIG_PAGE_SHIFT 12

#define INIT_IDMAP_DIR_PAGES	(EARLY_PAGES(INIT_IDMAP_PGTABLE_LEVELS, KIMAGE_VADDR, _end, 1))
#define INIT_IDMAP_DIR_SIZE	((INIT_IDMAP_DIR_PAGES + EARLY_IDMAP_EXTRA_PAGES) * PAGE_SIZE)


#define INIT_IDMAP_PGTABLE_LEVELS	(IDMAP_LEVELS - SWAPPER_SKIP_LEVEL) // 
#define IDMAP_LEVELS		ARM64_HW_PGTABLE_LEVELS(IDMAP_VA_BITS)      // (((48) - 4) / (12 - 3))
/*
 * Number of page-table levels required to address 'va_bits' wide
 * address, without section mapping. We resolve the top (va_bits - PAGE_SHIFT)
 * bits with (PAGE_SHIFT - 3) bits at each page table level. Hence:
 *
 *  levels = DIV_ROUND_UP((va_bits - PAGE_SHIFT), (PAGE_SHIFT - 3))
 *
 * where DIV_ROUND_UP(n, d) => (((n) + (d) - 1) / (d))
 *
 * We cannot include linux/kernel.h which defines DIV_ROUND_UP here
 * due to build issues. So we open code DIV_ROUND_UP here:
 *
 *	((((va_bits) - PAGE_SHIFT) + (PAGE_SHIFT - 3) - 1) / (PAGE_SHIFT - 3))
 *
 * which gets simplified as :
 */
#define ARM64_HW_PGTABLE_LEVELS(va_bits) (((va_bits) - 4) / (PAGE_SHIFT - 3))
#define IDMAP_VA_BITS		48
#define SWAPPER_SKIP_LEVEL	1

#define KIMAGE_VADDR		(MODULES_END)

#define MODULES_END		(MODULES_VADDR + MODULES_VSIZE)
#define MODULES_VADDR		(_PAGE_END(VA_BITS_MIN))
#define _PAGE_END(va)		(-(UL(1) << ((va) - 1)))
#define VA_BITS_MIN		(VA_BITS)
#define VA_BITS			(CONFIG_ARM64_VA_BITS)
#define CONFIG_ARM64_VA_BITS 52

#define EARLY_PAGES(lvls, vstart, vend, add) (1 	/* PGDIR page */				\
	+ EARLY_LEVEL(3, (lvls), (vstart), (vend), add) /* each entry needs a next level page table */	\
	+ EARLY_LEVEL(2, (lvls), (vstart), (vend), add)	/* each entry needs a next level page table */	\
	+ EARLY_LEVEL(1, (lvls), (vstart), (vend), add))/* each entry needs a next level page table */

#define SPAN_NR_ENTRIES(vstart, vend, shift) \
	((((vend) - 1) >> (shift)) - ((vstart) >> (shift)) + 1)

#define EARLY_ENTRIES(vstart, vend, shift, add) \
	(SPAN_NR_ENTRIES(vstart, vend, shift) + (add))

#define EARLY_LEVEL(lvl, lvls, vstart, vend, add)	\
	(lvls > lvl ? EARLY_ENTRIES(vstart, vend, SWAPPER_BLOCK_SHIFT + lvl * (PAGE_SHIFT - 3), add) : 0)

#define SWAPPER_BLOCK_SHIFT	PAGE_SHIFT // ((12 - 3) * (4 - (2)) + 3)

((((((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 3 * (12 - 3))) - (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 3 * (12 - 3))) + 1) + (1))

#define SWAPPER_BLOCK_SHIFT	PMD_SHIFT
#define PMD_SHIFT		ARM64_HW_PGTABLE_LEVEL_SHIFT(2)
#define ARM64_HW_PGTABLE_LEVEL_SHIFT(n)	((PAGE_SHIFT - 3) * (4 - (n)) + 3)


```

```
init_idmap_pg_dir = .;
 . +=
(
	(
		(1 
		+ (
			(((((48) - 4) / (12 - 3)) - 1)) > 3 
			? ((((((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 3 * (12 - 3))) - (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 3 * (12 - 3))) + 1) + (1)) 
			: 0
		  )
		+ (
			(((((48) - 4) / (12 - 3)) - 1)) > 2 
			? ((((((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 2 * (12 - 3))) - (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 2 * (12 - 3))) + 1) + (1)) 
			: 0
		  ) 
		+ (
			(((((48) - 4) / (12 - 3)) - 1)) > 1 
			? (
				(
					(
						(((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 1 * (12 - 3))
					) 
					- (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 1 * (12 - 3))
					)
					+ 1
				)
				+ (1)
			  ) 
			: 0
		  )
		)
 	)
 
  	+ 3
)
 
* (1 << 12);
 init_idmap_pg_end = .;
```



### [固定映射](https://blog.51cto.com/u_7784550/6041302)

所谓固定映射，是值内核虚拟地址空间的一段固定区域。在内核初始化过程中，有些模块需要使用申请内存，但此时内存子系统还未建立，甚至内存内核地址空间的页表还不完整。固定映射就是用于摆脱内核初始化过程中的这种窘境。

fixmap虚拟地址空间又被平均分成两个部分permanent fixed addresses和temporary fixed addresses。permanent fixed addresses是永久映射，temporary fixed addresses是临时映射。永久映射是指在建立的映射关系在kernel阶段不会改变，仅供特定模块一直使用。临时映射就是模块使用前创建映射，使用后解除映射。

fixmap 按功能划分成几个更小的部分，对应 fixed_addresses 的枚举。物理内存分配是以页为单位的，因此恒等映射也以页为单位划分，fixed_addresses 的枚举值恰恰是不同页的索引。

```C
enum fixed_addresses {
	FIX_HOLE,	// 保留

	/*
	 * FDT 映射区，比 FDT 的最大支持大小大一页，额外的空间确保不超过
	 * MAX_FDT_SIZE 限制的 FDT 即使在不以页对齐的是偶也能够被映射。
	 *（我怎么看多了两页呢？FIX_FDT_END 一页，+1 一页，Why》）
	 */
	FIX_FDT_END,
	FIX_FDT = FIX_FDT_END + DIV_ROUND_UP(MAX_FDT_SIZE, PAGE_SIZE) + 1,

	FIX_EARLYCON_MEM_BASE,	// early console使用，大小1页。1页虚拟地址空间完全够了，毕竟串口操作相关寄存器没有几个。
	FIX_TEXT_POKE0,
	// 以下内容为可配置项，暂不深入
#ifdef CONFIG_ACPI_APEI_GHES
	/* Used for GHES mapping from assorted contexts */
	FIX_APEI_GHES_IRQ,
	FIX_APEI_GHES_SEA,
#ifdef CONFIG_ARM_SDE_INTERFACE
	FIX_APEI_GHES_SDEI_NORMAL,
	FIX_APEI_GHES_SDEI_CRITICAL,
#endif
#endif /* CONFIG_ACPI_APEI_GHES */

#ifdef CONFIG_UNMAP_KERNEL_AT_EL0
#ifdef CONFIG_RELOCATABLE
	FIX_ENTRY_TRAMP_TEXT4,	/* one extra slot for the data page */
#endif
	FIX_ENTRY_TRAMP_TEXT3,
	FIX_ENTRY_TRAMP_TEXT2,
	FIX_ENTRY_TRAMP_TEXT1,
#define TRAMP_VALIAS		(__fix_to_virt(FIX_ENTRY_TRAMP_TEXT1))
#endif /* CONFIG_UNMAP_KERNEL_AT_EL0 */

	__end_of_permanent_fixed_addresses,	// 永久映射结束
	/*
	 * 临时映射，early_ioremap 使用。
	 */
	FIX_BTMAP_END = __end_of_permanent_fixed_addresses,
#define NR_FIX_BTMAPS		(SZ_256K / PAGE_SIZE)
#define FIX_BTMAPS_SLOTS	7
#define TOTAL_FIX_BTMAPS	(NR_FIX_BTMAPS * FIX_BTMAPS_SLOTS)
	FIX_BTMAP_BEGIN = FIX_BTMAP_END + TOTAL_FIX_BTMAPS - 1,

	/*
	 * Used for kernel page table creation, so unmapped memory may be used
	 * for tables.
	 */
	FIX_PTE,
	FIX_PMD,
	FIX_PUD,
	FIX_P4D,
	FIX_PGD,

	__end_of_fixed_addresses	// 固定映射结束。+1 作为页数量使用，巧妙。
};
```
Linux 6.9 节点 b730b0f2b1fcfbdaed81 将固定映射移到了内核空间的末尾(Fixmap 的末尾到地址空间结束留有 8MB 的防护区)。
```C
#define SZ_8M				0x00800000
#define FIXADDR_TOP		(-UL(SZ_8M)) 	// 计算为 0xFFFFFFFFFF800000
```

Fixmap 区域的大小根据 `fixed_addresses` 计算而得，总体而言约 4M 的大小。
```C
#define FIXADDR_SIZE		(__end_of_permanent_fixed_addresses << PAGE_SHIFT)	// 页数 * 页大小 = 实际大小
#define FIXADDR_START		(FIXADDR_TOP - FIXADDR_SIZE)	// 
#define FIXADDR_TOT_SIZE	(__end_of_fixed_addresses << PAGE_SHIFT)
#define FIXADDR_TOT_START	(FIXADDR_TOP - FIXADDR_TOT_SIZE)
```

形成如下的布局：
```
ffff ffff f000 0000   |   
                      +--------------------------+ <--- FIXADDR_TOT_START
ffff ffff fe00 0000   |   				         |
                      +--------------------------+ <--- FIXADDR_START
                      | 						 | 
ffff ffff ff80 0000   +--------------------------+ <--- FIXADDR_TOP
                      |   [guard region]         |  8MB
ffff ffff ffff ffff   +--------------------------+
```

由于整个内存映射是固定的，可以直接通过索引获得地址：

```C
#define __fix_to_virt(x)	(FIXADDR_TOP - ((x) << PAGE_SHIFT))
#define __virt_to_fix(x)	((FIXADDR_TOP - ((x)&PAGE_MASK)) >> PAGE_SHIFT)
```

1. early_fixmap_init() 初始化固定映射区，

2. 接着执行 fixmap_remap_fdt 将 dtb文件 映射到固定映射区的FDT区域。

3. DTB文件被映射后，CPU 就可以解析 dtb 文件了。CPU通过 分析DTB文件、获取内存的物理信息，并将物理内存添加到 早期内存分配器 memblock中。

这里就有个问题，固定映射区的页目录和页表所需的内存从哪里获取？答：此时还没有内存分配器，因此，在内核的全局变量中为 fixmap页表 静态定义了一段页表项内存 ，即 bm_pte, bm_pmd, bm_pud，它们会被编译进内核镜像的bss 段，当然，页全局目录还是 init_pg_dir。


Fixmap 的代码都在 `arch/arm64/mm/fixmap.c` 文件中，

```
start_kernel
	-> setup_arch
		-> early_fixmap_init 	fixmap区域建立PUD/PMD/PTE页表
		-> early_ioremap_init 	early ioremap初始化
		-> setup_machine_fdt
			-> fixmap_remap_fdt	创建FDT映射
```

```C
static pte_t bm_pte[NR_BM_PTE_TABLES][PTRS_PER_PTE] __page_aligned_bss;
static pmd_t bm_pmd[PTRS_PER_PMD] __page_aligned_bss __maybe_unused;
static pud_t bm_pud[PTRS_PER_PUD] __page_aligned_bss __maybe_unused;
```

### early_fixmap_init

```C

/*
 * The p*d_populate functions call virt_to_phys implicitly so they can't be used
 * directly on kernel symbols (bm_p*d). This function is called too early to use
 * lm_alias so __p*d_populate functions must be used to populate with the
 * physical address from __pa_symbol.
 */
void __init early_fixmap_init(void)
{
	unsigned long addr = FIXADDR_TOT_START;
	unsigned long end = FIXADDR_TOP;

	pgd_t *pgdp = pgd_offset_k(addr);	
	p4d_t *p4dp = p4d_offset_kimg(pgdp, addr);

	early_fixmap_init_pud(p4dp, addr, end);
}

// 获取内核空间 pgd 的快捷别名
#define pgd_offset_k(address)		pgd_offset(&init_mm, (address))

#ifndef pgd_offset
#define pgd_offset(mm, address)		pgd_offset_pgd((mm)->pgd, (address))
#endif

static inline pgd_t *pgd_offset_pgd(pgd_t *pgd, unsigned long address)
{
	return (pgd + pgd_index(address));
};

#ifndef pgd_index
/* Must be a compile-time constant, so implement it as a macro */
#define pgd_index(a)  (((a) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))
#endif
```

0xffff800081c33078
0xffff800081c33ff8

### early_ioremap_init

### setup_machine_fdt



参考：https://zhuanlan.zhihu.com/p/552604696

## 2. memblock 管理

### 初始化




## 3. 伙伴系统


## 4. Zoon Allocator 和 Slub 分配器




## 参考


https://zhuanlan.zhihu.com/p/632442549?utm_id=0

https://blog.51cto.com/u_7784550/6041302

TODO：

1. Image 的开始和结束到底是哪里？ ELF 都有哪些段是程序，被加载到内存？