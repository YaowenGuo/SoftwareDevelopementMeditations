# 内存使用总结

1. Android 没有 swap 磁盘分区，因此只有文件映射才能被换出内存，数据无法被换出。这是因为移动端的IO代价太大。

2. 此外android上还使用了一种特殊的ZRAM机制来压缩一些物理内存上的page，但是并不把他们swap-out到disk上，而是仍然在ram中，这是一段被压缩了的page，系统会选择压缩一些page存储在内存中以腾出一些物理内存的占用

## 使用建议

1. 开发注意、避免
2. 运行检测
3. 线上监控，预警。收集调试信息


//java thread
6f5b0b2000-6f5b0b3000 ---p 00000000 00:00 0 [anon:thread stack guard]
6f5b0b3000-6f5b0b4000 ---p 00000000 00:00 0 
6f5b0b4000-6f5b1b0000 rw-p 00000000 00:00 0 
pthread stack 大小是1M - 16K. guard 是 4K. 注意的是java thread 在art 里面还会再隔离一个page, 判断收到的SIGSEGV 是否为StackOverflowError. 【在新版本的 maps 中并为出现，应该不是普遍现象。】

安卓 art 内存管理， https://developer.android.com/topic/performance/memory-overview

https://mp.weixin.qq.com/s/BMRC_0n-lfznr352A1bLBw