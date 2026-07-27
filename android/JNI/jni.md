JNI是Java Native Interface的缩写，它提供了若干的[API](https://baike.baidu.com/item/API/10154)实现了Java和其他语言的通信（主要是[C](https://baike.baidu.com/item/C/7252092)&[C++](https://baike.baidu.com/item/C%2B%2B)）。从Java1.1开始，JNI标准成为java平台的一部分，它允许Java代码和其他语言写的代码进行交互。JNI一开始是为了本地已[编译](https://baike.baidu.com/item/编译)语言，尤其是C和C++而设计的，但是它并不妨碍你使用其他编程语言，只要调用约定受支持就可以了。使用java与本地已编译的代码[交互](https://baike.baidu.com/item/交互/6964417)，通常会丧失平台[可移植性](https://baike.baidu.com/item/可移植性)。但是，有些情况下这样做是可以接受的，甚至是必须的。例如，使用一些旧的库，与硬件、操作系统进行交互，或者为了提高程序的性能。JNI标准至少要保证[本地代码](https://baike.baidu.com/item/本地代码)能工作在任何Java [虚拟机](https://baike.baidu.com/item/虚拟机)环境。

对于 JNI 的误解：JNI 并不是给 Java 调用的接口，而是为 Java 定义的原生接口规范。遵循这套规范，任何语言都可以调用它。 JNI_ 开头的方法，JNI_ 是命名空间标记，表示的是"归属",不是"调用方向"。

JNI_CreateJavaVM 带 JNI_ 前缀,含义是:

▎ "这个符号是 JNI 这套规范定义的公共 C API 之一。"

它标识的是所属规范,跟"谁来调它"没有关系。这跟别的 C 库前缀是一个道理:

┌───────────────┬───────────────────────┬───────────────────┐
│     前缀      │      归属规范/库      │     前缀含义      │
├───────────────┼───────────────────────┼───────────────────┤
│ pthread_      │ POSIX Threads         │ 属于 pthread 规范 │
├───────────────┼───────────────────────┼───────────────────┤
│ gl / glGen... │ OpenGL                │ 属于 OpenGL       │
├───────────────┼───────────────────────┼───────────────────┤
│ SSL_          │ OpenSSL               │ 属于 OpenSSL      │
├───────────────┼───────────────────────┼───────────────────┤
│ JNI_          │ Java Native Interface │ 属于 JNI 规范     │
└───────────────┴───────────────────────┴───────────────────┘

pthread_create 带 pthread_ 不是因为"线程会调用它",而是"它是 pthread 规范的一员"。JNI_CreateJavaVM 同理——它是 JNI 规范里定义的一个入口函数, 所以按规范约定加 JNI_ 前缀。

而 JNI 规范本身就"两头都管"

一个反证:同样 JNI_ 开头,却是 JVM 回调 native

如果 JNI_ 前缀真的意味着"由 native 主动调",那下面这个就解释不通了:

// 你写在 so 里,但不是你调的——是 JVM 在 System.loadLibrary 时回调你的
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) { ... }
JNIEXPORT void JNICALL JNI_OnUnload(JavaVM* vm, void* reserved) { ... }

真正表示"Java→native 调用方向"的,不是 JNI_,而是另一个前缀 Java_。这俩别搞混:

// (1) Java_ 前缀:Java 声明的 native 方法,对应的 C 实现符号
//     方向:Java → Native   前缀 = 类名+方法名拼出来的
extern "C" JNIEXPORT void JNICALL
Java_com_example_Foo_bar(JNIEnv* env, jobject thiz) { ... }

跨语言调用的本质是什么？

跨语言调用的本质是在同一个进程的内存空间中，让两套不同的指令集、内存管理机制和调用约定（Calling Convention）达成一致，进行数据交换和控制流转移。
简单来说，就是让“说不同语言”的代码在底层能够看懂同一块内存，并用同一种方式执行函数。
------------------------------
## ⚙️ 跨语言调用的三大底层核心
跨语言调用（通常指非网络远程调用的本地调用，如 Java 调用 C++，Python 调用 C）必须在底层解决以下三个问题：
## 1. ABI（应用二进制接口）的对齐

* 什么是 ABI：这是跨语言调用的数据总线。它规定了参数怎么传（放哪个寄存器？还是压入哪个栈？）、返回值怎么拿、堆栈由谁来清理（调用者还是被调用者）。
* 本质：几乎所有高级语言（Java, Python, Rust, Go）都可以编译或翻译为标准的 C 语言 ABI（C-ABI）。C 语言的调用约定是事实上的通用底层标准。跨语言调用本质上是各语言“伪装”成 C 语言来相互对话。

## 2. 内存模型的转换与映射

* 数据类型对齐：不同语言对同一个数据的定义不同。例如 Java 的 int 永远是 4 字节，而 C 语言的 long 在不同系统上可能是 4 字节或 8 字节。跨语言调用必须在内存中对这些数据进行精确的位（Bit）级对齐。
* 托管与非托管的冲突：Java/Python 有垃圾回收（GC），它们的内存对象在堆中会随时被 GC 移动位置。C/C++ 是非托管的，要求内存地址绝对固定。跨语言调用时，必须通过“内存锁定（Pinning）”或“内存拷贝（Copying）”来防止 GC 在执行过程中动了数据。

## 3. 控制流的转移（上下文切换）

* 运行 Java 时，CPU 执行的是 JVM 的字节码解释器或 JIT 编译出的代码，使用 JVM 维护的线程栈。
* 当调用 Native 瞬间，CPU 需要保存当前的 Java 栈帧状态，切换到操作系统的原生线程栈，并将 PC 寄存器（程序计数器）指向 Native 函数的绝对内存地址。

------------------------------
## 🛠️ 常见跨语言调用技术的底层运作
以你之前提到的 Java JNI（Java Native Interface） 为例，它的本质过程如下：

   1. 写声明：Java 中声明 native 方法，告诉 JVM 这是一个外部函数。
   2. 查表：JVM 在运行时加载 .so 或 .dll 动态链接库，建立一个映射表（把 Java 的方法名和 C 函数的内存指针绑定）。
   3. 跳板机制（Trampoline）：当调用发生时，JVM 会执行一段特殊的汇编代码（跳板）。这段代码负责把 Java 的参数转化为 C 语言看懂的结构，锁定相关内存，然后用汇编指令 call 直接跳到 C 函数的内存地址。
   4. 返回：C 函数执行完后，把结果放到指定寄存器，通过跳板代码解锁内存，恢复 Java 栈，继续执行 Java。

------------------------------
## ⚠️ 为什么跨语言调用会带来性能损耗和安全隐患？
正因为其底层本质，它必然伴随着以下代价：

* 性能损耗（Overhead）：参数在两种语言间拷贝（如 String 转换）、频繁的寄存器状态保存与恢复、破坏了 CPU 的指令缓存（JIT 无法对跨语言边界的代码进行内联优化）。
* 沙盒破裂（你提到的隔离问题）：C/C++ 代码可以直接操作裸指针（Bare Pointer），它们能绕过高级语言的一切安全检查，直接读写整个进程的任意内存。一旦 Native 代码写错，引发的就是无法捕获的段错误（Segmentation Fault），直接物理报废整个进程。

如果你想深入理解某一种具体的跨语言技术，我们可以继续探讨：

* JNI（老一代）与 Panama / FF&M API（Java 新一代高性能跨语言方案） 的本质区别？
* Python C Extensions 是如何与 C 语言进行交互的？



### JNI 包括相互调用的两部分：

* 允许你把一个[JVM](https://baike.baidu.com/item/JVM)嵌入到原生程序中。

* native 程序可以链接一个实现了JVM的 native 库，然后使用“调用接口”执行JAVA语言编写的软件模块。

### JNI的副作用

一旦使用JNI，JAVA程序就丧失了JAVA平台的两个优点：

1、程序不再[跨平台](https://baike.baidu.com/item/跨平台)

。要想跨平台，必须在不同的系统环境下重新编译本地语言部分。

2、程序不再是绝对安全的，本地代码的不当使用可能导致整个程序崩溃。一个通用规则是，你应该让本地方法集中在少数几个[类](https://baike.baidu.com/item/类/6824577)当中。这样就降低了JAVA和C之间的[耦合性](https://baike.baidu.com/item/耦合性)。

### 实现步骤

#### 1，使用 native 修饰一个想要在调用本地方法的抽象方法。

```java
public class HelloJNI {
    public static void main(String[] args) {
    new HelloJNI().displayHelloWorld();
    }

    // 载入本地库
    static {
        System.loadLibrary("nativeLib");
    }
    // 所有使用native关键字修饰的都是对本地方法的声明。
    public native int displayHelloWorld();
}
```

声明[native](https://baike.baidu.com/item/native/13128691)方法：如果你想将一个方法做为一个本地[方法](https://baike.baidu.com/item/方法/3009367)的话，那么你就必须声明该方法为native的，并且不能实现。其中方法的参数和返回值在后面讲述。 Load动态库：System.loadLibrary\("hello"\);加载[动态库](https://baike.baidu.com/item/动态库)（我们可以这样理解：我们的方法 displayHelloWorld\(\)没有实现，但是我们在下面就直接使用了，所以必须在使用之前对它进行初始化）这里一般是以[static](https://baike.baidu.com/item/static)块进行加载的。同时需要注意的是System.[loadLibrary](https://baike.baidu.com/item/loadLibrary)\(\);的参数“hello”是动态库的名字。



#### 2，编译

没有什么好说的了

[javac](https://baike.baidu.com/item/javac) HelloJNI.java -d .



#### 3，生成扩展名为h的c/c++头文件

使用指令 javac -h &lt;生成的头文件放置目录&gt;  &lt;源文件&gt;

如：javac -h .  HelloJNI.java

生成如下

```c
/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class hellojni_HelloJNI */

#ifndef _Included_hellojni_HelloJNI
#define _Included_hellojni_HelloJNI
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     hellojni_HelloJNI
 * Method:    displayHelloWorld
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_hellojni_HelloJNI_displayHelloWorld
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif
```

（这里我们可以这样理解：这个h文件相当于我们在java里面的接口，这里声明了一个Java\_HelloWorld\_displayHelloWorld \(JNIEnv \*, jobject\);方法，然后在我们的本地方法里面实现这个方法，也就是说我们在编写[C/C++](https://baike.baidu.com/item/C%2FC%2B%2B)程序的时候所使用的方法名必须和这里的一致）。

在上面的代码中看到了JNIEXPORT和JNICALL关键字，这两个关键字是两个宏定义，他主要的作用就是说明该函数为JNI函数，在Java虚拟机加载的时候会链接对应的native方法，JNIEXPORT 表示输出类型；JNICALL表示参数的压栈顺序；貌似都可以省略.

#### 4，**实现由**javah命令生成的头文件里面声明的方法。

jni.h是定义了很多我们使用的JNI函数和结构体，jint是JNI定义的数据类型，因为Java层和C/C++的数据类型或者对象不能直接相互的引用或者使用，JNI层定义了自己的数据类型，用于衔接Java层和JNI层，至于这些数据类型我们在后面介绍。这里的jint对应Java的int数据类型，该函数返回的int表示当前使用的JNI的版本，其实类似于Android系统的API版本一样，不同的JNI版本中定义的一些不同的JNI函数。该函数会有两个参数，其中\*jvm为Java虚拟机实例，JavaVM结构体定义了以下函数：

so动态链接库，so文件是linux下的c/c++动态链接库。Java虚拟机会在运行时动态加载so库，并运行。

\#\#gcc -I /&lt;HelloWorld.c  b.c c.c .... &gt; -fPIC -shared -o libtest.so

但是需要指定jni库和jni\_mk库，一般在PATH里并没有配置。需要根据平台单独指定

gcc -I /Library/Java/JavaVirtualMachines/jdk-9.0.1.jdk/Contents/Home/include  -I /Library/Java/JavaVirtualMachines/jdk-9.0.1.jdk/Contents/Home/include/darwin/ HelloWorld.c -fPIC -shared -o libtest.so



JAVA\_HOME:

/Library/Java/JavaVirtualMachines/jdk1.8.0\_25.jdk/Contents/Home

If you don't know where jni\_md.h is, use `find`:

find / -name jni\_md.h 2&gt;/dev/null
