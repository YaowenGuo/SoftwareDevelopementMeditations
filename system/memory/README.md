# 内存专家

内存之于程序，犹如空气、空间之于人类——好像从未关注过它，也没有研究过它的运行规律，却是无处不在。内存是如此重要，[任何Unix内核的核心都是内存管理](Understand Linux Kernel page 4, 概述)。这话不仅适用于 Unix 系统，同样适用于所有的计算机操作系统。操作系统本身运行需要加载到内存；应用程序运行需要占用内存；CPU 执行的每一条指令，都需要占用内存，内存管理如此重要，是其它软件模块的基石。就跟空间一样，使用内存看起来我们使用它是如此自然、随意，然而深究起来，却不是那么简单。


在实际的使用中，好像内存用起来没有什么困难，遇到内存问题，实际决绝起来会发现内存牵涉到的东西又非常多，扒开一层还有一层，扒开一层还有一层。举几个简单的例子：

- 为什么我的电脑内存只有 4GB，但是内存地址却能使用远超 4GB?

- 当申请的内存大小大于 4GB 的时候会发生什么？

- 软件报内存不够用了(OOM)，我的系统是 64 位的，既然可以虚拟内存可以使用超过物理内存的大小，按道理我的程序可以使用 2^64 大小的内存，现在远没有达到这么大，为什么报 OOM？

这些问题会打起来，我们好像能会一些，但是好像又经不起更深的追问？
比如第一个问题。你能回答上来，我们的程序使用的是虚拟内存，内存会将地址转化为实际的物理地址。

- 虚拟地址和物理地址是如何转化的？会不会影响速度？
- 既然可以超过物理内存，我一次申请 8GB 的内存可以吗？
- 如果我访问这 8GB 的内存可以吗？访问会发生什么？

内存关联的内容非常多。它牵涉到、应用、编程语言（编译器、解释器或者虚拟机）、操作系统、物理硬件。每层都负责了一部分内存相关的内容，又和其它层有关联。

由于我们大部分人接触底层较少，我们将从应用层开始，逐渐深入底层内存管理。

> 在整个学习中，我们将设计如下内容

- 自上而下，先用应用开发者的角度开始了解内存。一步步深入系统和底层。这样更符合我们的直观印象。

- 分析对比不同技术、不同的解决方案。比较他们的优缺点、方便我们在实际使用中根据场景选择何时的方案。

- 对于每个技术点，举例说明其应用（我们会反问自己，我为什么要花时间知道这个？知道这个玩意儿有什么用🤪？）。这样不至于过分理论化，学了之后从来不知道怎么用。同时根据案例，我们自己也方便我们做一些延伸和变通，更可能在实际开发中使用。


作为应用开发者，我们首先会问，应用程序本身在内存中是怎样的？

- [虚拟内存](1.virtual_memory_layout.md)
- [栈](stack.md)
- [堆](heep.md)
- [mmap](mmap.md)
- [动态库](shared_lib.md)
- [链接](link.md)

0. 程序运行的准备

1. 程序运行时，它的内存排布是怎样的？或者说，程序指令是如何定位的？

2. 程序中的地址是何时确定的？如何计算这些地址？

3. 程序何时分配内存的？

4. 计算机如何实现虚拟地址的？MCU 寻址

5. 为什么线程安全的本质




看起来我们使用内存时一个简单的 `new Object()`，其背后内存的管理牵涉到计算机硬件，操作系统、编译器、编程语言共同协作才能完成。因此想要弄清楚全部的细节不是几句话就能讲清楚的。


底层的内存管理复杂而晦涩，由于现代计算机系统系统的抽象抽象，应用开发者不会直接对内存硬件进行管理。 因此我们自上而下从最常接触到的开始，先从应用的角度来看内存组成，作为应用开发者，这也是我们对内存最直观的印象。

创建的内存错误：

进程崩溃、内存访问错误、SIGSEGV、double free、内存泄漏等与内存相关的错误时


> (1). 内存的整体使用情况.


要分析 memory leaks, 你需要知道总体的内存使用情况和划分. 以判断内存泄露是发生在user space, kernel space, mulit-media 等使用的memory, 从而进一步去判断具体的memory leaks.

user space 使用的memory 即通常包括从进程直接申请的memory, 比如 malloc: 先mmap/sbrk 整体申请大块Memory 后再malloc 细分使用, 比如stack memory, 直接通过mmap 从系统申请; 以及因user space 进程打开文件所使用的page cache, 以及使用ZRAM 压缩 user space memory 存储所占用的memory.

kernel space 使用的 memory 通常包括 kernel stack, slub, page table, vmalloc, shmem 等.

mulit-media 使用的memory 通常使用的方式包括 ion, gpu 等.

其他方式的memory 使用, 此类一般直接从buddy system 中申请出以page 为单位的memory, android 中比较常见如ashmem.

而从进程的角度来讲, 通常情况下进程所使用的 memory, 都会通过mmap 映射到进程空间后访问使用(注: 也会一些非常特别异常的流程, 没有mmap 到进程空间), 所以进程的memory maps 资讯是至关重要的. 对应在AEE DB 里面的file 是 PROCESS_MAPS

## 内存模型

内存模型主要用于解决并发问题而引入的，放到并发中。


Nowadays Magisk is commonly used for rooting.

牛逼的 Linux 性能剖析—perf

- 查看该进程的 maps 和 smaps 文件。并解释细节
- 查找资料，确认 /proc 目录下面各个文件的作用。

> 页表存在哪里？

1. 所有进程的页表都是关键数据，只有内核才有权限修改，所以页表都是存在内核空间的。每个进程的管理结构里（也在内核空间）都会记录自己的页表。
2. 进程切换时会把目标进程的页表起始地址送进cr3寄存器，这样目标进程页表就可以起作用了。显然这个也只能在内核里才能做。

映射的过程，是由 CPU 的内存管理单元 (Memory Management Unit, MMU) 自动完成的，但它依赖操作系统设置的页表。


https://www.cnblogs.com/sevenyuan/p/13305420.html

安卓 art 内存管理， https://developer.android.com/topic/performance/memory-overview


PIC PIE
https://blog.csdn.net/zat111/article/details/46738649
https://mropert.github.io/2018/02/02/pic_pie_sanitizers/
https://www.anquanke.com/post/id/177520#h2-4
https://zhuanlan.zhihu.com/p/109862930
https://blog.csdn.net/bemind1/article/details/111942222
http://nickdesaulniers.github.io/blog/2016/11/20/static-and-dynamic-libraries/

http://thinkiii.blogspot.com/2014/02/arm64-linux-kernel-virtual-address-space.html
[Arm64 内存分配](https://www.kernel.org/doc/html/latest/arm64/memory.html)
[Arm64 支持的页面大小](https://www.kernel.org/doc/Documentation/arm64/memory.txt)
[Virtual kernel memory layout 是内核启动时打印的，已经被删掉了](https://blog.csdn.net/yhb1047818384/article/details/104621500)

一个变量要经过编译器、链接器、加载器和操作系统的进程管理，然后再经过 CPU 的 MMU 模块，才能最终出现在真正的物理内存里。

这样，当你遇到进程 crash 时，分析 coredump、查看内存映射等都能游刃有余。

此外，CPU 在与外设交互时，最重要的机制就是中断，内存、磁盘 IO、网络 IO 有很多功能都是依赖中断完成的


## 内存使用分层

- Language
- Compiler
- 操作系统
- Hardware


## 检测工具

native 检测工具 ASan
java 检测工具 profile

例如，我就曾经遇到过一个性能很差的程序，经过 perf 工具分析后，我发现是因为缺页中断过多导致的。这个时候，那么掌握页的结构和映射过程的知识就非常有必要了。所以我也想跟你来探讨一下这方面的内容。

1. 开发注意、避免
2. 运行检测
3. 线上监控，预警。收集调试信息


## QA:

- 代码段和数据段的权限不同，会放在同一页吗？如果不能放在同一页是否有很多内存浪费？

- 用户程序向内核申请内存是否只能整页申请？

- 用户内存是否真


## TODO 

三个目标：

1. 开发时避免
2. 开发完能检测：ASan
3. 线上监控

### 1. Java 内存泄露和 Native 内存泄露。

目标

1. 定位内存占用较高的原因，包括 java 和 native 对内存的使用，优化对内存的使用

2. 了解Android系统内存使用的正常范围与OOM的边界

输出结果

1.优化直播课页面对内存的使用

2.输出内存占用问题的排查文档

3.输出内存优化的最佳实践文档

1. 内存各个区域分布，各个部分使用和容易引起的问题
2. Native 内存问题检测工具  的使用，排查问题的方法。
3. Java 内存问题工具 CPU Profile，Track 定位问题的方法和监测工具。
4. Truman  内存占用过多问题排查。

C++

2. C/C++ 对象内存分配的方式，以及避免内存泄漏的编程方法。

    1. 浅拷贝的对象只有的对象，只释放一个，持有对象会不会被释放？

    2. 移动构造函数

    3. RVO, NRVO

    4. 指针传递给一个对象，何时释放问题。比如一个对象 A 传给一个函数，不确定这个函数会不会释放 A, 自己主动释放，如果 函数启动新线程，使用了 A 就会崩溃。如果函数先释放了 A, 自己再次释放，又会引起重复释放问题。

3. 类、操作符重载与类型转换

    目标：深入掌握 C/C++, 能够快速定位 Native  问题

    输出结果：

    定位 Native  问题的工具和方法

    Native  内存泄漏原因和检测的工具。

    一些常用语言特性的文档：宏、模板编程、现代化避免程序错误的方法(如 C++11 shared_ptr 和 WebRTC 中 rtc::scoped_refptr 智能指针)、函数指针
   
    深入理解 C/C++ 对象的内存分配和释放，内存分配。避免内存泄漏的方法。

4. 模板编程与 STL的常用类。

    目标：深入掌握 C/C++, 能够快速定位 Native  问题

    输出结果：

    定位 Native  问题的工具和方法

    Native  内存泄漏原因和检测的工具。

    一些常用语言特性的文档：宏、模板编程、现代化避免程序错误的方法(如 C++11 shared_ptr 和 WebRTC 中 rtc::scoped_refptr 智能指针)、函数指针

    深入理解 C/C++ 对象的内存分配和释放，内存分配。避免内存泄漏的方法。

5. 指针和强转，函数指针，安全使用方案

6. 编译、链接的流程和常用参数。
7. LLDB 的使用方法