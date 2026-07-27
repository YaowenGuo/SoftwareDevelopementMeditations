# ART 虚拟机内存管理（深入源码系列）

以 Android 17（ART mainline 模块）为基线，从架构到源码细节，逐层拆解 ART 的内存管理。每篇正文按 What → Why → How 递进，文末附「课后验证」。

- [01 架构篇：进程内存全景](01_architecture_overview.md)
- [02 分区篇：Heap 的 Space 家族](02_heap_and_spaces.md)
- [03 分配篇：分配器与一次 `new` 的完整链路](03_allocation.md)
- [04 GC 原理篇：可达性、三色标记与屏障](04_gc_principles.md)
- [05 收集器演进篇：CMS → CC → CMC](05_gc_collectors.md)
- [06 实战篇：堆策略、调优与内存排查](06_tuning_and_debugging.md)
