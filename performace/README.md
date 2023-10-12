# 性能

用户希望应用程序能够快速启动，呈现流畅，并且占用较少的内存和电池。本指南的各个部分提供了有关工具、库和最佳实践的信息和见解，帮助您实现更好的应用程序性能。以及你可以用来检查、改进和监控Android性能的最佳实践。

- inspect performance（开发时）
- improve performance（什么因素对于性能更加重要）
- monitor performance （生产环境）


Order File: https://developer.android.com/ndk/guides/orderfile
PGO: https://developer.android.com/ndk/guides/pgo

https://androidperformance.com/2022/01/07/The-Performace-1-Performance-Tools


谷歌官方在22年3月发布的33.0.1版本的platform-tools包中移除了systrace。在运行 Android 10（API 级别 29）或更高版本的设备上，跟踪文件以 Perfetto 格式保存，如本文档后面所示。在运行早期版本 Android 的设备上，跟踪文件以 Systrace 格式保存。
Perfetto 和 Systrace 是可互操作的：
在 Perfetto UI 中打开 Perfetto 文件和 Systrace 文件。在 Perfetto UI 中使用旧版 Systrace 查看器打开 Systrace 文件（使用 使用旧版 UI 打开链接）。