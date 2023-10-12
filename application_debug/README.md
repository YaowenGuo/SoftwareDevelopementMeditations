# 应用层调试

程序在运行中发生崩溃是经常发生的事情，根据崩溃信息，有些我们能够很快定位的发生问题的原因，而另外一些则不然，其发生原因很难确定。为了定位问题我们需要有一些帮助信息和调试工具：

1. 在崩溃时记录信息：Crash dump or tombstone。以及程序主动打印的日志。

2. 使用崩溃信息和调试工具帮助定位问题发生的地方和原因：
    ndk-stack

3. 通过检测工具提前发现错误。


## [1. 日志](log.md)
## [2. bug reports](android_bugreport.d)


## 2. 调试工具

Android Studio 图形调试前端

ndk-lldb 命令行调试

或者可以在崩溃后使用 adb bugreport 将日志拉取到本地查看日志文件。

帮助工具：
SDK
ndk-stack


## 3. 检测工具

### 内存

#### Address Sanitizer (HWASan/ASan)
HWAddress Sanitizer (HWASan) and Address Sanitizer (ASan) are similar to Valgrind, but significantly faster and much better supported on Android.

These are your best option for debugging memory errors on Android.

#### Malloc debug
See Malloc Debug and Native Memory Tracking using libc Callbacks for a thorough description of the C library's built-in options for debugging native memory issues.

#### Malloc hooks
If you want to build your own tools, Android's libc also supports intercepting all allocation/free calls that happen during program execution. See the malloc_hooks documentation for usage instructions.

#### Malloc statistics
Android supports the mallinfo(3) and malloc_info(3) extensions to <malloc.h>.

The malloc_info functionality is available in Android 6.0 (Marshmallow) and higher and its XML schema is documented in Bionic's malloc.h header.


### CPU

For CPU profiling of native code, you can use [Simpleperf](https://developer.android.com/ndk/guides/simpleperf).
