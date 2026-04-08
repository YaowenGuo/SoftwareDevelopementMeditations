# mmap

mmap 使用中的问题和解决方案

## [mmap 引发的崩溃](https://mp.weixin.qq.com/s?__biz=MzkzNjI3ODkyNQ==&mid=2247495565&idx=1&sn=c8378b87c4583111b77a886ef7769544&chksm=c3b3bb2444f0bb7c145818a1ff3ca3b6b733f74e44d84fe25d82a38fd9eafb6ff1ecee33da4a&mpshare=1&scene=24&srcid=0822u3b5BIPDHxQIoynK2d9b&sharer_shareinfo=118181f3c6169a071a240a486d429995&sharer_shareinfo_first=118181f3c6169a071a240a486d429995#rd)

同样是访问 mmap映射的内存引发了程序崩溃，为什么有时操作系统会发送 SIGSEGV(Segmentation Fault) 信号，而有时又会发送 SIGBUS(Bus Error) 信号？这两种信号看似相似，其背后的根源却截然不同。理解它们的区别，是编写健壮、可靠的系统级软件的关键一步。

- SIGSEGV的根本原因是程序试图访问虚拟地址空间中未被映射 (unmapped)的区域。这是一个地址本身非法的问题。

- SIGBUS的根本原因是访问的地址在虚拟地址空间中是合法的（已被映射），但当内核尝试为这个地址加载对应的物理页时失败了。这是一个地址合法但其背后对应的物理实体（如文件数据）丢失的问题。需要抢到的是，读取是只要超过了文件的边界，就会发生崩溃，不一定非得大于页大小。例如映射了 12 字节的数据，读取时只剩 10 字节。读取时加载数据发现数据不够了，就会引发 SIGBUS 崩溃。


## mmap 使用的风险

mmap 太过于强大以至于使用不当会引发很多问题。

- mmap 可以用于进程共享，一个进程出现问题会影响道其它进程。
- 共享内存时，多进程或线程需通过信号量、锁等机制同步访问，否则导致数据竞争（Data Race）或脏读，这显然会影响所有共享这块内存的进程。
- mmap 分配内存可以指定内存的权限（如PROT_EXEC）。如果分配的内存权限不正确，可能会引发安全问题，被黑客注入恶意代码。
[mmap 使用教程](https://mp.weixin.qq.com/s/Clam2h-Z3Ybq1OSz_DwMPg)