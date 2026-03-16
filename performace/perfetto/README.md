# UI

- 左侧功能栏

- 右侧视图栏：整个 UI 是按照时间轴排列的。

    - 最上方是 CPU 热点图，显示 CPU 使用情况的概览。颜色越高亮表示 CPU 使用率越高。

    - 中间是系统信息
        - CPU Scheduling: 各个 CPU 的调度活动。
        - CPU Frequency: 各个 CPU 频率的变化。
        - FTrace Events: 系统内核的各种事件。
        - Memory: 系统内存使用情况。
        - Power: 各个硬件组件的功耗情况。
        - CPU: 显示各个 CPU 的状态。
        - System:
        - Hardware:
        - Android Logs: 显示系统日志。
        - Devide Stace:
        - Scheduler: 调度器的状态。
        - Kernel threads: 内核线程的活动。

    - 下方是各个进程的活动视图，收起时是进程的热点图。展开后是各个线程的活动视图。
        - Expected timeline 和 Actual timeline: 只有安卓 UI 应用才有，表示 UI 每一帧的预期时间和实际时间。
        - 每个线程分两个，第一个是这个线程的状态。第二行是实际的方法调用栈。包括 Runnable、Running、Sleeping 等状态。
        - 箭头表示线程间的交互，比如等待锁、唤醒等。一般是 Binder 线程间通信。
    


## 线程轨道

每个线程有两条。一条是线程的状态轨道，另一条是调用栈轨道。
状态：Sleeping, Runnable, Running, I/O wait, 等等。