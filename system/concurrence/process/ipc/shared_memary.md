# 共享内存

[Linux IPC 内核之争：为什么说 mmap 本质是“文件 I/O”，而 shm 才是“纯血”共享内存？](https://baijiahao.baidu.com/s?id=1840550873619592921&wfr=spider&for=pc)

**shm_open/shm_unlink 是 shmget/shmdt 更现代的替代品，它们更符合 POSIX 标准，并且可以用于更广泛的场景，没有理由再使用 shmget/shmdt。另外 Linux 还提供了 memfd_create 方式。**

[Linux四种共享内存技术：SystemV、POSIX mmap、memfd_create、dma-buf](https://blog.csdn.net/Rong_Toa/article/details/109863040)