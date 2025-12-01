# 性能

用户希望应用程序能够快速启动，呈现流畅，并且占用较少的内存和电池。本指南的各个部分提供了有关工具、库和最佳实践的信息和见解，帮助您实现更好的应用程序性能。以及你可以用来检查、改进和监控Android性能的最佳实践。

- inspect performance（开发时）
- improve performance（什么因素对于性能更加重要）
- monitor performance （生产环境）
    - ProfilingManager




关注点：
- 启动时间
- 渲染缓慢（卡顿）
- 屏幕转换和导航的事件
- 长时任务
- 后台操作，如 I/O 和联网


Two tools: 
Prefetto and Android Studio Profiler。实际上 Android Studio  Profiler 也是基于 Prefetto 的采集技术，额外加了安卓框架中收集的数据。Android Studio Profiler 由于封装可能限制更多的自定义选项，而 Prefetto 则更灵活，


他们可以以各种方式使用
- Android 集成或者UI
- 命令工行
- 系统设置
