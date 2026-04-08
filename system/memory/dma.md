## 内核共享内存

DMA(Direct Memory Access 直接内存访问) 建立设备与内存之间直接数据传输通道。DMA 不是什么新技术，早在上个世纪 70 年代就已经出现了。早期的 CPU 必须亲自搬运硬盘或网卡的数据，导致 CPU 占用率极高。为了解放 CPU，工程师发明了 DMA 控制器。当时的 DMA 还停留在系统内部使用，没有开放给应用开发。

另一点是，早期的 DMA 内存是独占的。在 2011 年以前，DMA 主要用于“一个硬件 ↔ 内存”的单线联系。例如拍照功能，由于各硬件驱动是独立的，摄像头驱动申请的 DMA 内存，显卡驱动“看不懂”也“拿不到”。如果你想把摄像头画面传给显卡，必须让 CPU 做中转，进行昂贵的内存拷贝。如何制定一个标准，**让各硬件驱动之间可以共享内存，减少内存拷贝**，这就是 DMA-BUF 标准诞生的初衷。它不是发明了 DMA，而是发明了一种“标准合同”（以文件描述符 FD 的形式）。它让不同的驱动程序之间可以互相转让 DMA 内存的“使用权”，实现了跨设备的零拷贝（Zero-copy）。


Android 4.0 引入了 ION，是 Google 早期为了解决多媒体内存分配而设计的。Android 12 开始开始被 DMA 替代。

从内存所有者的角度看，DMA 分配的内存属于系统，它是由内核驱动分配的。它们在  /proc/[pid]/smaps 没有相关信息，因此 top 和 ps 无法看到（这就是为什么你会发现：所有进程的 PSS 加起来，远小于系统已用内存——差额很大一部分就是被驱动占用的 Graphics 内存。）；但是从内存使用的角度看，DMA 分配的内存属于应用，它是由应用使用并申请的。例如一个 App 为了渲染复杂的 3D 场景申请了 500MB 的显存（Graphic Buffer），虽然这块地是驱动代为申请的，但罪魁祸首是这个 App。如果 Android 把这 500MB 全算在内核头上，那 App 就可以通过疯狂消耗图形资源来逃避 OOM Killer 的制裁，而系统看起来却像是内核“漏了”。因此安卓 `sysdump memeinfo` 有专门的 graphic 部分统计该部分内容。Android 强行将其折算给应用，以便 OOM Killer 能精准打击那个“资源大户”。

- 在 dumpsys meminfo 中，graphic 的数据有 3 部分：
    - **Gfx dev：** 绘制时分配，并且已经映射到应用进程虚拟内存中。这里需要注意的是，只有高通的芯片才会将这一块的内存放在 /dev/kgsl-3d0 路径，并映射到进程的虚拟内存中，其他的芯片不会放在这个路径。在上面的 load_maps 方法中，我们也可以看到对这一块内存数据的解析逻辑。

    - **GLmtrack：** 绘制时分配，没有映射到应用地址空间，包括纹理、顶点数据、shader program 等。

    - **EGLmtrack：** 应用的 Layer Surface，通过 gralloc 分配，没有映射到应用地址空间。不熟悉 Layer Surface 的话，可以将一个界面理解成一个 Layer Surface，Surface 存储了界面的数据，并交给 GPU 绘制。

    **Gfx dev：** GPU 驱动为你的进程分配的内存（纹理、着色器）。**EGL mtrack / GL：** 用于显示合成的缓冲区。如果 Gfx dev 或 EGL mtrack 高：说明你的 UI 渲染（图片太多、图层太厚、纹理没释放）有问题。

- 在 Linux 内核上也有相关的统计信息：

    - **fdinfo 接口：**
    在现代 Linux 内核（5.4+）中，你可以查看 /proc/[pid]/fdinfo/[FD编号]。如果是 DMA-BUF，内核会明确标注其 size（字节数）。

    - **dmabuf_dump 工具：**
    这是一个较新的工具，专门用来遍历系统中所有进程的文件描述符，找出所有的 DMA-BUF 并汇总。

    - **sysfs 全局视角：**
    内核在 /sys/kernel/debug/dma_buf/bufinfo 中提供了一个“上帝视角”，记录了全系统每一块活跃的 DMA-BUF 到底在谁手里。


## 应用层 API


1. 分配路径：应用层部分：应用进程并不直接拥有这块物理内存，它拥有的是一个 文件描述符 (File Descriptor, FD)。通过这个 FD，应用可以 mmap 把内存映射到自己的虚拟空间进行操作。



## 安卓的封装

通过 Gralloc/HardwareBuffer 屏蔽细节
Graphic 层：真正的像素数据（那 100MB）存放在 显存/图形内存 中。


不可交换性 (Unswappable)：
普通的进程数据可以被压缩进 zRAM。但图形缓冲区（Frame Buffers）通常是不能被压缩或交换的，因为渲染显示对实时性要求极高。这意味着 Graphic 内存比普通内存更“沉重”，对系统的压力更大。








## 其它：

[Linux DMA 驱动 API 的使用](https://mp.weixin.qq.com/s?__biz=Mzg4NDQ0OTI4Ng==&mid=2247492104&idx=1&sn=a7fbbd3a3c048cf995452e425cc3a87a&chksm=ce11ac08240537c5b7908f99deb0e1c6343aea01d0ef03e6efea23e23148fd8ea2a07b33130f&mpshare=1&scene=24&srcid=0522JfYl4SMirmTFSMiQGVl2&sharer_shareinfo=8bba5dc9318e24ad04704787311b3024&sharer_shareinfo_first=8bba5dc9318e24ad04704787311b3024#rd)

[DMA buffers (dmabuf): These are special buffers used for sharing memory between different hardware components (e.g., the CPU, GPU, and camera). This is common in graphics-intensive applications. You can track dmabuf allocations by enabling the dmabuf_heap/dma_heap_stat ftrace events in your trace configuration.](https://perfetto.dev/docs/getting-started/memory-profiling)
