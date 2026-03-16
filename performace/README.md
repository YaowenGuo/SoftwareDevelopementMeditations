质量：
- 外形规格
- 稳定性
    - 崩溃率
    - ANR
    - bug 报告
- 性能
- 资源使用
    - 电池
    - 网络
    - 应用大小

# 性能

用户希望应用程序能够快速启动，呈现流畅，并且占用较少的内存和电池。本指南的各个部分提供了有关工具、库和最佳实践的信息和见解，帮助您实现更好的应用程序性能。以及你可以用来检查、改进和监控Android性能的最佳实践。

- inspect performance（开发时）
    - 手动检查
        Perfetto and Android Studio Profiler
    - 自动测试
        - Benchmark libraries

- improve performance（什么因素对于性能更加重要）
    - Continuous integration：在推送更新给用户之前，将基准测试作为配置项流水线的一部分，跟踪性能的长期变化，并识别性能回归或改进。

- monitor performance （生产环境）
    - ProfilingManager
    - Android vitals （google play）
    - Firebase Performance Monitoring (Goolge)
    - JankStats Library (系统库)

The Macrobenchmark library


关注点：
- 应用启动时间
- 呈现速度缓慢（卡顿）
- 屏幕转换和导航的事件
- 长时任务
- 后台操作，如 I/O 和联网




Two tools: 
Prefetto and Android Studio Profiler。实际上 Android Studio  Profiler 也是基于 Prefetto 的采集技术，额外加了安卓框架中收集的数据。Android Studio Profiler 由于封装可能限制更多的自定义选项，而 Prefetto 则更灵活，


他们可以以各种方式使用
- Android 集成或者UI
- 命令工行
- 系统设置

性能剖析（Profiling） vs 追踪（Tracing）
latency： 延迟
jank： 卡顿

TODO:
性能调试的深度介绍系列视频: https://www.youtube.com/playlist?list=PLWz5rJ2EKKc-xjSI-rWn9SViXivBhQUnp&hl=zh-cn
