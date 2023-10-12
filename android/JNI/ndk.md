# NDK

NDK 不仅仅是一个单一功能的工具，还是一个包含了 API 、交叉编译器、调试器、构建工具等得综合工具集。

NDK 跟目录下的结构。

- ndk-build: 该 Shell 脚本是 Android NDK 构建系统的起始点，一般在项目中仅仅执行这一个命令就可以编译出对应的动态链接库了。
- ndk-lldb: 该 Shell 脚本允许用 GUN 调试器调试 Native 代码，并且可以配置到 AS 中，可以做到像调试 Java 代码一样调试 Native 代码。
- ndk-stack: 该 Shell 脚本可以帮组分析 Native 代码崩溃时的堆栈信息。
- build: 该目录包含 NDK 构建系统的所有模块。
- platforms: 该目录包含支持不同 Android 目标版本的头文件和库文件， NDK 构建系统会根据具体的配置来引用指定平台下的头文件和库文件。
- toolchains: 该目录包含目前 NDK 所支持的不同平台下的交叉编译器 - ARM 、X86、MIPS ，目前比较常用的是 ARM 。构建系统会根据具体的配置选择不同的交叉编译器。


NDK 是安卓提供的一套用于开发、编译、链接、调试 C/C++ 程序的工具集合。NDK 开发主要用于以下场景：


- 实现软件低延迟或计算密集型程序的性能。例如游戏或者物理模拟程序。

- 复用已有的 C/C++ 库。

- 开发跨平台的软件库。

```
C/C++ 源码 --(ndk编译) ------┐
                            ├- 原生库 -- (gradle 打包) --> Java 调用
定义 JNI 代码 --(ndk 编译) ---┘
```

## 编译

Android Studio 提供了多种方式编译 C/C++ 代码的方式。

- `CMake` 是 Andriod Studio 的默认方式，对于支持 CMake 的库和新建库，尽量以 CMake 的方式编译。

- `ndk-build` 适用于已经使用 make 的软件库。可以使用这种方式编译。

- 辅助工具，例如 `CCache`很少使用，根据特殊需要可以使用。

- [使用其它构建系统构建已有的代码库，通常用于不是安卓特有的三方库，例如 OpenGL 和 libbzip2](build_third_library.md)。



使用 NDK 开发，你甚至可以完全使用 Native 开发应用（完全不使用 Java 和 Kotlin），但是你需要慎重的考虑为什么这样做，毕竟安卓提供的组件很方便的实现 UI 的操作和控制。跟多的是需要考虑的哪些部分使用 Native 开发，哪些使用 Java 开发。

### CPU 架构和 ABI

原生代码直接运行在物理机上，因编译过程中就要生成对应 CPU 架构的二进制指令。本部分介绍了在构建时如何面向特定的架构和 CPU，如何使用 ARM NEON 扩展指令集，以及在运行时如何使用 cpufeatures 库查询可选功能。

不同的 CPU 支持不同的指令集， CPU和指令集的每种组合都有其自己的应用 ABI（ Application Binary Interface ）。ABI包含以下信息：

- 可以使用的CPU指令集(和扩展)。
- 运行时内存存储和加载的字节顺序。Android 始终是 little-endian（小字端）。
- 在应用和系统之间传递数据的规范（包括对齐限制），以及系统调用函数时如何使用堆栈和寄存器。
- 可执行二进制文件（例如程序和共享库）的格式，以及它们支持的内容类型。Android 始终使用 ELF。如需了解详情，请参阅 ELF System V 应用二进制接口。
- 如何重整 C++ 名称。如需了解详情，请参阅 Generic/Itanium C++ ABI。

ABI 还可以指 CPU 平台支持的原生 API。

NDK 支持的 ABI 有

- armeabi-v7a (armabi 从 NDK17 已不再支持，主要因为从 Android 4.0 开始就不再支持 armabi 处理器，已经没有这方面的设备了。)
- arm64-v8a
- x86
- x86-64


# 编译参数和区别

## 目标平台

Clang targets with ARM
When building for ARM, Clang changes the target based on the presence of the -march=armv7-a and/or -mthumb compiler flags:

Table 1. Specifiable -march values and their resulting targets.

| -march value | Resulting target |
| ------------ | ------------ |
| -march=armv7-a |	armv7-none-linux-androideabi |
| -mthumb |	thumb-none-linux-androideabi |
| Both -march=armv7-a and -mthumb | thumbv7-none-linux-androideabi |

You may also override with your own -target if you wish.

clang and clang++ should be drop-in replacements for gcc and g++ in a makefile. When in doubt, use the following options when invoking the compiler to verify that they are working properly:

- -v to dump commands associated with compiler driver issues
- -### to dump command line options, including implicitly predefined ones.
- -x c < /dev/null -dM -E to dump predefined preprocessor definitions
- -save-temps to compare *.i or *.ii preprocessed files.
ABI Compatibility


## Flow

The general flow for developing a native app for Android is as follows:

1. Design your app, deciding which parts to implement in Java, and which parts to implement as native code.

Note: While it is possible to completely avoid Java, you are likely to find the Android Java framework useful for tasks including controlling the display and UI.

2. Create an Android app Project as you would for any other Android project.

3. If you are writing a native-only app, declare the NativeActivity class in AndroidManifest.xml. For more information, see the Native Activities and Applications.

4. Create an Android.mk file describing the native library, including name, flags, linked libraries, and source files to be compiled in the "JNI" directory.

5. Optionally, you can create an Application.mk file configuring the target ABIs, toolchain, release/debug mode, and STL. For any of these that you do not specify, the following default values are used, respectively:

    - ABI: all non-deprecated ABIs
    - Toolchain: Clang
    - Mode: Release
    - STL: system

6. Place your native source under the project's jni directory.

7. Use ndk-build to compile the native (.so, .a) libraries.

8. Build the Java component, producing the executable .dex file.

9. Package everything into an APK file, containing .so, .dex, and other files needed for your app to run.



## 设计准则

尽量减小 JNI 层的空间占用（注意：JNI 层不是 Native 等，也不是 java 代码。而是两者之间的调用层。）按照重要程度从高到低：

1. 尽量减小跨 JNI 层资源编组的大小。 跨 JNI 的编组消耗巨大，设计接口应该尽量减少数据传递和降低频率。

2. 尽可能减少跨 JNI 的异步调用。这样能简化 JNI 的流程。比如，使用 Java 开启线程调用阻塞的 JNI 函数显然比调用一个异步的 JNI 接口，再次回调要好。

3. 最小化接触 JNI 的线程和被回调的线程数量。如果必须使用线程池，在线程池所有者之间而不是每个线程之间进行 JNI 调用。

4. 将 JNI 接口和 Java 接口封装在一个位置，保持最少的接口数量，以便将来进行重构。考虑在适当的时候使用JNI自动生成库。


## JNI 数据结构

JNI 定义了两个关键的数据结构 `JavaVM` 和 `JNIEnv`，它们本质上都是指向函数的指针表。在c++中，它们是带有一个指向函数表的指针的类，并且具有通过该函数通过表进行间接调用的每个JNI函数的成员函数。 `JavaMV` 提供了 `调用接口` 函数，用于创建和销毁 `JavaVM`。理论上你可一个在同一个进程中创建多个 `JavaVm`，但 Android 中仅允许一个。

`JNIEnv` 提供了大量 JNI 函数，JNI 调用的本地方法的第一个参数都是 `JNIEnv`。

`JNIEnv` 用于 `thread-local` 存储，因此它无法在线程间共享。如果在一段代码中没有其他方法获取 `JNIEnv` 时，可以共享 `JavaVM`，并通过它的 `getEnv` 获取。

C 中的 `JNIEnv` 和 `JavaVM` 声明与 C++ 中的不同。根据被导入到 C++ 中还是 C 中 `jni.h` 提供不同的类型。因此，在两种语言都包含的头文件中导入 `JNIEnv` 参数是错误的做法（换句话说，如果你的头文件需要 `#ifdef __cplusplus`, 并且在头文件中引用了 `JNIEnv` 你需要做一些额外工作）。


## NDK 的一些版本问题

**Android NDK: The armeabi ABI is no longer supported. Use armeabi-v7a.**

ARM 处理器的版本

- armeabi-v7a: 第7代及以上的 ARM 处理器，使用硬件浮点运算。2010年起以后的生产的大部分Android设备都使用它.

- arm64-v8a: 第8代、64位ARM处理器，很少设备，三星 Galaxy S6是其中之一。
- armeabi: 第5代、第6代的ARM处理器，早期的手机用的比较多。使用软件浮点运算，通用性强，速度慢。
- x86: 平板、模拟器用得比较多。
- x86_64: 64位的平板。


[NDK 17 不再支持 armabi 和 mips，同时将默认的编译器从 gcc 改为了 clang](https://github.com/android/ndk/wiki/Changelog-r17)


[Adroid 4.0 (API 14)默认不再支持 armeabi。](https://www.jianshu.com/p/4b1c2dd3c87f)
[Android 4.4 (API 19)之后强制要求armv7处理器。](https://stackoverflow.com/questions/10920747/android-cpu-arm-architectures)