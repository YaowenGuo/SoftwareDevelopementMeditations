# 安卓的特殊知识

1. Android 没有 swap 磁盘分区，因此只有文件映射才能被换出内存，数据无法被换出。这是因为移动端的IO代价太大。

2. 此外android上还使用了一种特殊的ZRAM机制来压缩一些物理内存上的page，但是并不把他们swap-out到disk上，而是仍然在ram中，这是一段被压缩了的page，系统会选择压缩一些page存储在内存中以腾出一些物理内存的占用


//java thread
6f5b0b2000-6f5b0b3000 ---p 00000000 00:00 0 [anon:thread stack guard]
6f5b0b3000-6f5b0b4000 ---p 00000000 00:00 0 
6f5b0b4000-6f5b1b0000 rw-p 00000000 00:00 0 
pthread stack 大小是1M - 16K. guard 是 4K. 注意的是java thread 在art 里面还会再隔离一个page, 判断收到的 SIGSEGV 是否为StackOverflowError. 【在新版本的 maps 中并为出现，应该不是普遍现象。】


## 映射

ART 虚拟机 Java 字节码被编译成本地代码，在运行时同样经过映射进内存，并能够在 maps 文件中查看。编译后的代码通常存储在 /data/dalvik-cache 目录下的 .oat 或 .vdex 文件中。

主要涉及的文件与内存映射：

1. boot.oat / boot.art / boot.vdex
系统框架类库的预编译镜像。Zygote 启动时 mmap 进来。随后通过 fork 共享给所有 app（COW）。

2. App 自身的 base.odex / base.vdex（目录多在 /data/app/<pkg>/oat/arm64/）
.odex (或 .oat) 里包含已经 AOT 的方法机器码段（TEXT 段为 r-xp）。
vdex 保存经过验证、优化 reordering 的 dex 字节码/quickened 指令。

3. JIT Code Cache
运行期热点方法编译成机码放在匿名或 memfd 映射里：标记常见为
[anon:dalvik-jit-code-cache] 或 /memfd:/jit-cache (Android 11+ 常见)。
权限一般为 r-xp（可执行）。

4. Dex 文件本身
原始 classes.dex（打包在 APK 里，APK 本质 zip）可以被 ART 直接 mmap 一层（可能通过 zip 虚拟偏移），也可只部分映射（有时看到 .../base.apk 的 r--p 映射）。

5. JNI/NDK 动态库
.so 文件同样由动态链接器 mmap，并在 maps 中清晰显示。（这与 Java/ART 运行时无关，但同属“映射加载”机制。）


## 