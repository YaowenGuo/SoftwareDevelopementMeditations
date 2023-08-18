# Linux 中申请内存的方法

作为一种稀缺硬件资源（对运行程序来说），内存也需要由操作系统管理。所有的内存分配都需要向内存申请。Linux 上内存申请区分内核申请和用户申请。

内核空间中如何申请内存有 kmalloc()、kzalloc()、vmalloc() 等。而用户空间申请和释放内存有 brk/sbrk、mmap/mummap.


## 用户空间内存申请

在用户空间的内存申请，无论用户 API 调用什么，最终都会调用 `brk/sbrk` 或者 `mmap/mummap` 这两组函数向系统申请内存空间。`brk/sbrk` 用于增加或者减少从低地址空间的内存增长。而 `mmap/mummap` 用户从高地址申请和释放内存。**两者从两头相向的申请方式最大化的较少内存空间的浪费，避免需要一个大的连续空间时，出现地址空间不够用的情况。brk/sbrk 申请的空间是连续的，而 mmap/mummap 申请的空间一块一块的，可能会因为释放而增加很多未使用的地址块。**


```
--------------------> +--------------------------+--------------------------
0000:007f:ffff:ffff   |       Main Stack         |
                      +--------------------------+ - - - - - - - - - - - - -
                      |            |             |
                      |            ∨             | <----------- mmap/munmap 
                      |                          | 
                      |                          |
                      |   (unallocated memory)   |
                      |                          |
                      |                          |
User address space    |                          |
                      |            ∧             |
                      |            |             |                    ∧
                      +--------------------------+< Program Break - brk/sbrk 
                      |           Heap           |                    ∨
                      |     (grows upwards)      |
                      +--------------------------+
                      | Uninitialized data (bss) |
                      +--------------------------+
                      |    Initialized data      |
                      +--------------------------+
0000:0000:0000:0000   |    Text (program code)   |
--------------------> +--------------------------+--------------------------
```


## brk/sbrk

brk() 和 sbrk() 都可以用来改变 `program break` 的位置，`program break` 定义了进程数据段的结束为止（也就是说，`program break`是未初始化的数据段结束后的第一个位置）。增大 `program break` 增加进程申请的内存，减小则释放内存。

```c
#include <unistd.h>

/**
 * 使用地址指定 'program break' 的位置。
 * addr: new program break address.
 * return: success -> 0; error -> -1
 */
int brk(void *addr);

/**
 * 使用偏移移动 'program break' 的位置。
 * increment: 大于 0 则申请内存，小于 0 较少内存，等于 0 用于获取当前 的 program break 位置。
 * return: program break address between change.
 */
void *sbrk(intptr_t increment);
```

brk 和 sbrk 均可以用于申请和释放内存，但是常使用 `sbrk` 申请内存。其返回之前的 `program break` 位置，可以使用变量保存该位置。然后在不需要增加的内存时，将其传入 `brk` 释放内存。

**malloc 也是调用 brk/sbrk 来申请内存。用户程序尽量使用 malloc 来申请内存，brk/sbrk 是系统调用，会陷入内核切换运行环境，影响程序的性能。而且需要自己考虑内存页的问题，以及处理内存碎片的回收。malloc 会一次性向系统申请一块内存，在程序使用时逐渐分配给用户，只有在现有的空间不够时才调用 sbrk 想系统申请内存。**

## mmap()与munmap()


mmap 是 POSIX 规范中的一个函数，在 Unix 都有实现。详细使用方法可以查看 man 文档，这里不多赘述。这里只简述一下其使用场景和优势。**mmap 的使用非常广泛，例如线程栈的申请，动态库的内存申请，多个线程之间实现内存共享通信，甚至腾讯的 MMKV 也是使用 mmap 实现的**。其用于在调用进程的地址空间和文件或者设备之间建立映射。这样程序就可以直接对内存进行操作，系统会在释放内存时将其修改保存到文件。从而达到以几乎以修改内存的速度修改文件的目的。其也讲一段内存映射到多个进程，从而其修改被多个进程可见。更详细的优势原理可以查看这篇文章：https://www.jianshu.com/p/57fc5833387a


### 缺点

1. mmap 只能整页申请内存页。当文件比较小时，会浪费物理内存页。

2. 只支持定长文件（为了支持变长文件，可能可以使用 mremap，但是我几乎没见过有人这样做）。
