#  Java 虚拟机 / Android ART (Android 17)

JVM 虚拟机本身是一个 Native 程序。之所以称为虚拟机，在于其定义了完整的指令和调用约定，抽象了底层硬件的差异，抽象模型为一台虚拟的计算机。Java 程序执行最终还是调用 native 程序完成对应的操作。

Android 最开始用的是 Dalvik，Dalvik 虚拟机是基于 Apache 的 Java 虚拟机，并被改进以适应低内存、低处理器速度的移动设备环境。ART 虚拟机在 4.4 开始引入 ，5.0 起成为唯一运行时。


## Dalvik 与 JVM / ART 的区别

> Dalvik 虚拟机相比通用 JVM 的差异

| Java虚拟机 |  Dalvik虚拟机 |
| --------- | ------------ |
| `java` 虚拟机基于栈，基于栈的机器必须使用指令来载入和操作栈上数据 | `Dalvik` 虚拟机基于寄存器 |
| `java` 虚拟机运行的是 `java` 字节码。（java 类会被编译成一个或多个字节码 `.class` 文件，打包到 `.jar` 文件中，`java` 虚拟机从相应的  `.jar` 包中读取　`.class` 文件获取字节码） | `Dalvik` 运行的是自己专属的 `.dex` 字节码格式。（`java` 类被编译成 `.class` 文件后，会通过一个 `dx` 工具将所有的 `.class` 文件转换成一个 `.dex` 文件，然后 `dalvik` 虚拟机会从其中读取指令和数据） |
| `JVM` 在运行的时候为按需装载类的字节码 | `Dalvik` 程序包含一个或多个 `.dex` 文件，这个文件包含了程序中所有的类，需要在文件中按需读取。 |

之所以使用 dex 字节码，也是因为上面这些改动 jvm 字节码已无法支持，所以进一步改进，将 jvm 字节码转换成 dex 字节码。

> **标准对 `JNI_CreateJavaVM` 定义模糊**，没有规定一个进程可创建的实例数量，但一进程多实例极其罕见且官方不推荐（不像 JS 的 runtime）——几乎所有商用 JVM 都是进程与实例 1:1 对应。


> Dalvik 与 ART（Android Runtime）的区别：

| Dalvik | ART（Android Runtime） |
| ------ | ---------------------- |
| 每次运行时，字节码都需要通过即时编译器（JIT）转换为机器码，会拖慢应用运行效率。 | 首次运行前将字节码编译成机器指令，运行时无需再次编译，运行效率更高。 |
| 占用空间相对更小。 | 占用空间更大（原生代码占用的存储空间更大），属于“空间换时间”。 |
| 解释执行，只有热点代码被编译，执行效率低。 | 一次编译，机器执行效率更高，电池续航表现更好。 |
| 应用启动和运行速度相对较慢。 | 应用启动更快、运行更快，体验更流畅、触感反馈更及时。 |

> ART 的执行引擎并非纯 AOT，而是 AOT / JIT / 解释器「全时段混合编译」，原因见 [架构篇](architecture.md#混合编译aot--jit--解释器三者共存)。

## 文档导航

| 主题 | 说明 |
|---|---|
| [ART 虚拟机架构](architecture.md) | ART 由哪几个模块组成、各自职责与协作关系（内存外的模块只做概览） |
| [ART 虚拟机创建流程](startup.md) | `init` → `app_process` → `Zygote` → `JNI_CreateJavaVM` → `Runtime` 的启动链路 |
| [App 从编译到运行的全过程](build_to_run.md) | 源码 → `.class` → `.dex` → APK → 安装 `dex2oat` → 运行，逐个工具可手动复现 |
| [**内存管理专题**](heap_manage/README.md) | **本仓库重点**：Heap/Space、对象分配、GC 原理与收集器演进、调优排查 |

## 文档链接
    
- 内存管理：
    - [01 架构篇：进程内存全景](heap_manage/01_architecture_overview.md)
    - [02 分区篇：Heap 的 Space 家族](heap_manage/02_heap_and_spaces.md)
    - [03 分配篇：分配器与一次 `new` 的完整链路](heap_manage/03_allocation.md)
    - [04 GC 原理篇：可达性、三色标记与屏障](heap_manage/04_gc_principles.md)
    - [05 收集器演进篇：CMS → CC → CMC](heap_manage/05_gc_collectors.md)
    - [06 实战篇：堆策略、调优与内存排查](heap_manage/06_tuning_and_debugging.md)
    - [对象创建：一次 `new` 从字节码到 `Heap::AllocObject` 的完整链路](heap_manage/07_create_object.md)
    - [垃圾回收算法基础：标记清除 / 复制 / 标记整理 / 分代](heap_manage/08_gc_algorithms.md)
    - [09 镜像篇：ImageSpace 的加载操作全过程（动画式讲解 boot.art 的 mmap 与重定位）](heap_manage/09_image_space.md)


## 参考链接

- [Android Native 内存越用越多，会不会触发GC？](https://mp.weixin.qq.com/s/AIRwBlS3D3aPBF6M2qySbw)
- [Java虚拟机基础——4内存回收机制](https://cloud.tencent.com/developer/article/1353027)
- [ART虚拟机内存分配原理浅析](https://cloud.tencent.com/developer/article/2400064)
