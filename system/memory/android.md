# Android 内存使用最佳实践

1. 开发注意、避免
2. 运行检测
3. 线上监控，预警。收集调试信息



## 1. 开发注意避免


1. 清楚内存使用的限制是多少，

2. 使用占用内存少的数据结构

3. 避免内存泄露

**不同于 native 的内存泄露是丢失引用，忘记释放。Java 具有垃圾回收器，其内存泄露的原因是持有引用没有释放（以及持有的引用超出了使用的生命周期）**。因此及时释放应用是关键。


1. 静态变量引用不释放
    1. 单例
2. 常量引用
3. 线程任务完成没有及时结束。
4. 线程声明周期超过了使用其执行任务的 Activity。
5. 


## 问题分析

https://zhuanlan.zhihu.com/p/109862930

Linux provides a clever mechanism, called the /proc filesystem, that allows user mode processes to access the contents of kernel data structures. The /proc filesystem exports the contents of many kernel data structures as a hierarchy of text files that can be read by user programs. 