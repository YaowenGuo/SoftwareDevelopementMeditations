# Art 虚拟机

Art 虚拟机包含几个部分：
1. 编译器：AOT (Ahead-Of-Time) 编译器，运行前将 Dex 编译为机器码。
2. 运行时：
    JIT (Just-In-Time) 编译器
    解释器 (Interpreter)。

即便程序已经通过 dex2oat 进行了 AOT（预编译），**在运行时依然需要 JIT**。
这听起来可能有些反直觉——既然已经有机器码了，为什么还要动态编译？这主要是因为 ART 采用的是**“全时段混合编译”**策略，原因如下：

**1. 解决“部分编译”问题（Profile-Guided Optimization）**

现在的 Android 为了兼顾安装速度和存储空间，通常不会在安装时把 APK 里的所有代码都编译成机器码。
- **初次安装**：系统可能只对启动相关的“热点”代码进行 AOT 编译（生成 Profile 文件）。
- **JIT 的角色**：在应用运行过程中，如果用户进入了 AOT 没覆盖到的“冷代码”区域，解释器会接管。此时 JIT 依然会监控这些代码，如果它们变热，JIT 会立即将它们编译成机器码，而不需要等待下一次系统空闲时的 AOT 扫描。

**2. 运行时动态优化（PGO 的闭环）**
JIT 不仅仅是编译工具，它还是一个**“数据收集器”**：
- JIT 在运行时会收集真实的调用轨迹（哪些方法是真正的高频调用）。
- 这些数据会被保存到 .prof（Profile）文件中。
- **重点**：即便某段代码已经有 AOT 机器码，JIT 有时仍会参与分析，以便在下次设备空闲充电时，让 dex2oat 根据这些最新的 Profile 数据生成更优的 AOT 代码。

**3. 处理内联和去优化（Deoptimization）**

虚拟机有时会进行一些**“激进优化”**（比如假设某个接口只有一个实现类并进行内联）。

- 如果在运行时，由于动态加载了新的类，导致之前的优化假设失效，虚拟机必须执行**“去优化”**，回退到解释模式。
- 这时，JIT 必须重新介入，根据新的环境重新编译代码。

```mermaid
graph TD
    %% 定义样式
    classDef runtime fill:#d4e1f5,stroke:#334455,stroke-width:2px;
    classDef engine fill:#fff2cc,stroke:#d6b656,stroke-width:2px;
    classDef memory fill:#d5e8d4,stroke:#82b366,stroke-width:2px;
    classDef storage fill:#f8cecc,stroke:#b85450,stroke-width:2px;

    subgraph "JNI 接口层"
        API[JavaVM / JNIEnv]
    end

    subgraph "Runtime 核心管理 (art/runtime)"
        RT[Runtime.cc 控制中枢]
        CL[ClassLinker 类加载器]
        TL[ThreadList 线程管理]
        RT --- CL
        RT --- TL
    end

    subgraph "执行引擎 (Execution Engine)"
        Interp[Interpreter 解释器]
        JIT[JIT/AOT 编译器]
        Stub[Runtime Stubs 汇编存根]
        Interp <--> JIT
    end

    subgraph "内存管理 (Heap & GC)"
        Alloc[Allocator 分配器]
        GC[Garbage Collector 垃圾回收]
        Mirror[Mirror Objects 内存对象模型]
        Alloc --- GC
        GC --- Mirror
    end

    subgraph "存储与编译产物"
        DEX[DEX/VDEX 文件]
        OAT[OAT/ELF 机器码]
        DEX --- OAT
    end

    %% 核心连接关系
    API --> RT
    CL --> DEX
    RT --> Interp
    Interp --> Alloc
    JIT --> OAT
    TL --> GC

    %% 应用类定义
    class RT,CL,TL runtime;
    class Interp,JIT,Stub engine;
    class Alloc,GC,Mirror memory;
    class DEX,OAT storage;
```

```
+-----------------------------------------------------------------------+

|                       JNI 外部接口层 (JNI Interface)                   |
|      (JNI_CreateJavaVM / JNIEnv / HostRuntime.cpp 调用入口)           |
+-------------------+---------------------------------------------------+

                    |
                    v
+-----------------------------------------------------------------------+
|                  ART 核心运行时 (art/runtime)                          |
|                                                                       |
|  [ Runtime.cc ] <----------+------> [ Class Linker ]                  |
|   (全局控制中枢)             |       (类加载/解析/DEX文件链接)           |
|          |                 |               |                          |
|          v                 |               v                          |
|  [ Thread List ]           |       [ Mirror Objects ]                 |
|   (线程管理/调度)            |       (Java 对象在 C++ 层的内存映射)       |
+----------+-----------------+---------------+--------------------------+

           |                                 |
           v                                 v
+-----------------------+         +-------------------------------------+

|   执行引擎 (Execution) |         |     内存管理 (Memory / Heap)        |
|                       |         |                                     |
|  [ Interpreter ]      |         |  [ Allocator ] (对象分配)            |
|   (Mterp 解释执行)     |         |                                     |
|          ^            |         |  [ Garbage Collector ]              |
|          | (热点切换)  | <-----> |   (CC GC / 用户态页故障回收)          |
|          v            |         |                                     |
|  [ JIT / AOT ]        |         |  [ Memory Spaces ]                  |
|   (编译器/优化)         |         |   (Zygote/Image/App 内存分区)       |
+----------+------------+         +-------------------------------------+

           |
           v
+-----------------------------------------------------------------------+
|                      底层存储与文件 (Storage)                          |
|                                                                       |
|   [ .DEX / .VDEX ]  <----------->  [ .OAT / .ELF ]                    |
|    (原始字节码)                     (本地机器码)                       |
+-----------------------------------------------------------------------+

```


初始化：
```C++
// frameworks/base/core/jni/AndroidRuntime.cpp
int AndroidRuntime::startVm(JavaVM** pJavaVM, JNIEnv** pEnv, bool zygote, bool primary_zygote) {
    ...
    JNI_CreateJavaVM(&mJavaVM, (void**)&mEnv, &options);
    ...
}
```

ark 实现 JNI_CreateJavaVM

```C++
```
