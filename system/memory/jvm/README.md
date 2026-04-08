# 安卓虚拟机

- [Java 对象声明周期管理](lifecycle_management.md)
- [垃圾回收](gc.md)

- [虚拟机]
    - [虚拟机内存分配](create_object.md)
    - [内存管理](memory_manage.md)

- [安卓的特有特性](android.md)

JVM 虚拟机本身是一个 Native 程序。之所以称为虚拟机，在于其定义了完整的指令和调用约定，抽象了底层硬件的差异，抽象模型为一台虚拟的计算机。java 程序执行最终还是调用 native 程序完成对应的操作。

Android 最开始用的是 Dalvik，Dalvik 虚拟机是基于 apache 的 java虚拟机，并被改进以适应低内存，低处理器速度的移动设备环境。而 4.4 开始使用 ART 虚拟机。

> Dalvik 虚拟机相比通用虚拟机的差异

| Java虚拟机 |  Dalvik虚拟机 |
| --------- | ------------ |
| `java` 虚拟机基于栈，基于栈的机器必须使用指令来载入和操作栈上数据 | `Dalvik` 虚拟机基于寄存器 |
| `java` 虚拟机运行的是 `java` 字节码。（java 类会被编译成一个或多个字节码 `.class` 文件，打包到 `.jar` 文件中，`java` 虚拟机从相应的  `.jar` 包中读取　`.class` 文件获取字节码） | `Dalvik` 运行的是自己专属的 `.dex` 字节码格式。（`java` 类被编译成 `.class` 文件后，会通过一个 `dx` 工具将所有的 `.class` 文件转换成一个 `.dex` 文件，然后 `dalvik` 虚拟机会从其中读取指令和数据） |
| 一个进程可以运行多个虚拟机实例，应用在虚拟机内能实现隔离，一旦 JNI 调用到 Native 程序就无法隔离。| 一个进程对应一个虚拟机实例，能实现进程级的隔离 |
| `JVM` 在运行的时候为每一个类装载字节码 | `Dalvik` 程序包含一个或多个 `.dex` 文件，这个文件包含了程序中所有的类 |

之所以使用 dex 字节码也是因为上面这些改动 jvm 字节码已无法支持，所以进一步改进，将 jvm 字节码转换成 dex 字节码。

> Dalvik　与　Art（Android Runtime）的区别：

| Dalvik | ART（Android Runtime） |
| ------ | ---------------------- |
| 每次运行时，字节码都需要通过即时编译器（JIT）转换为机器码，会拖慢应用运行效率。 | 首次运行前将字节码编译成机器指令，运行时无需再次编译，运行效率更高。 |
| 占用空间相对更小。 | 占用空间更大（原生代码占用的存储空间更大），属于“空间换时间”。 |
| 解释执行，只有热点代码被编译，执行效率低。 | 一次编译，机器执行效率更高，电池续航表现更好。 |
| 应用启动和运行速度相对较慢。 | 应用启动更快、运行更快，体验更流畅、触感反馈更及时。 |


[Android Native 内存越用越多，会不会触发GC？](https://mp.weixin.qq.com/s/AIRwBlS3D3aPBF6M2qySbw)
[Java虚拟机基础——4内存回收机制](https://cloud.tencent.com/developer/article/1353027)
[ART虚拟机内存分配原理浅析](https://cloud.tencent.com/developer/article/2400064)
