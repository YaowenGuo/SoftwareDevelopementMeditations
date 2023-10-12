# concurrence

A logical flow whose execution overlaps in time with another flow is called a concurrent flow, and the two flows are said to run concurrently. The general phenomenon of multiple flows executing concurrently is known as concurrency. 

Notice that the idea of concurrent flows is independent of the number of processor cores or computers that the flows are running on. If two flows overlap in time, then they are concurrent, even if they are running on the same processor. However, we will sometimes find it useful to identify a proper subset of concurrent flows known as parallel flows. If two flows are running concurrently on different processor cores or computers, then we say that they are parallel flows, that they are running in parallel, and have parallel execution.

并发在计算机的不同层次上都有体现。硬件异常处理、进程、进程的信号处理都是常见的示例。在操作系统内核中并发是运行多个应用的一种机制。但是并发的应用不仅限于内核中。它在应用编程中也扮演着重要的角色。例如：在应用运行过程中信号处理可以处理并发事件例如用户输入 Type+C 以及程序访问虚拟内存未定义的区域。应用级的并发在其它方面也很有用：


- **访问缓慢的 I/O 设备。**当应用在等待数据从缓慢的的 I/O 设备加载时（例如磁盘），内核会通过运行其他进程来利用 CPU 资源。单个应用程序也可以通过将有用的工作与 I/O 请求重叠，以类似的方式利用并发性。

- **与人交互。**与计算机交互的人需要同时执行多项任务的能力。例如，他们可能希望在打印文档时调整窗口的大小。现代窗口系统使用并发性来提供此功能。每次用户请求某些操作(例如，通过单击鼠标)时，将创建一个单独的并发逻辑流来执行该操作。

- **通过推迟工作来减少延迟。** 有时，应用程序可以使用并发性来延迟其他操作并并发地执行它们，从而减少某些操作的延迟。例如，动态存储分配器可以减少独立的释放操作的延迟。通过将其合并到低优先级的并发的回收流，以便在 CPU 空闲时再使用。

- **服务多个网络客户端。** 对于一个真实服务器，可以每秒服务数百或数千个客户端。通过并发将连接独立运行，可以防止慢速客户端独占服务器。

- **在多核机器上并行计算。**许多现代系统都配备了包含多个 CPU 的多核处理器。被划分为并发流的应用程序通常在多核机器上比在单处理器机器上运行得更快，因为流是并行执行的，而不是交错执行的。


使用应用级并发的程序被称为并发应用。现代操作系统为构建并发程序提供了三种基本方法：

- **进程。**通过这种方法，每个逻辑控制流都是一个由内核调度和维护的过程。由于进程具有单独的虚拟地址空间，想要相互通信的流必须使用某种显式进程间通信（IPC）机制。

- **I/O 多路复用。**：应用程序在单个进程的上下文中明确安排自己的逻辑流。逻辑流被建模为状态机，随着数据到达文件描述符，主程序随着在状态间转换。由于程序是单个进程，所以所有流共享相同的地址空间。

- **线程。**线程是在单个进程的上下文中运行的逻辑流，并由内核调度。您可以将线程视为其他两种方法的混合体，像进程一样由内核调度，像 I/O多路复用一样共享相同的虚拟地址空间。

此外，在应用层级，某些语言或者库还提供了协程。
- 协程

除了进程是使用单独的地址空间，其它都在一个进程中，使用相同的地址空间。





##  进程与线程

进程和线程的区别，就像雷锋和雷锋塔，或者 Java 和 JavaScript 不能说毫无关系，只能说关系不大。要理解两者的区别，从其原先的英语名字能更好的理解。毕竟其发明者的母语是英语。

进程: Process

是对处理器 Processor 的抽象。在早期的计算机上只能运行一个程序，它占有这个 CPU 全部内存空间和资源。一次只能运行一个程序无法满足人们的想要处理多个任务的需求。为了完成在同一台计算同时运行多个程序的目的，将运行的程序抽象为一个进程，CPU 通过快速的切换这些进程，表现的像多个程序同时运行的样子。对于这些程序来说，它们好像独占了 CPU，并不知道有其他程序在同一 CPU 上运行，所谓独占就是整个地址空间都是它自己的，比如 32 为计算机的地址是 0 ~ 4G，这所有的地址它都可以访问的。

由于每个进程都有独立的地址空间，一个进程不可能直接能访问到另一个进程中的内容，也即资源，这也是为什么说进程是分配资源的基本单位。

关于进程的定义有很多，一个经典的定义是一个执行中程序的实例，进程是程序的动态表现。


线程: Thread

从名字看出来 Thread 和 Process 完全是两个概念。在一个程序内部（也就是一个进程）也有同时运行多个任务的需求，例如在一个音乐软件，即便播放音乐，还要能让人继续浏览其他的内容。并发的任务，其实就是并发执行的多个程序片段。为了在同一软件中同时执行多个任务，计算机研究的先驱为了抽象这种同时执行的程序，提出了 Thread 的概念。由于这些线程在同一个程序内，他们共享地址空间。这也是他们共享资源的根本原因，直接可以通过地址访问到当前进程的任何资源。


进程是60年代初首先由麻省理工学院的 MULTICS 系统和 IBM 公司的CTSS/360系统引入的。

80年代，出现了能独立运行的基本单位——线程（Threads）

## 进程和线程的详细区别

进程有父进程和子进程关系，但是线程没有父子关系。

进程无父子关系，各个进程是独立的。
线程有父子关系，父线程终止，全部子线程被迫终止(没有了资源)。子线程终止不会影响父线程。
谁说的对？


## 进程能不创建线程吗？

计算机硬件不区分什么是进程，什么是线程，只是运行的片段。进程和线程是操作系统的概念，在没有线程支持系统上，调度单位是进程。在以线程为调度单位的现代 OS 上，其进程的执行部分就是线程，也即主线程。
以 Linux 为例，其进程和线程都是同一个数据结构：

```C
struct task_struct {
    ...
	pid_t				pid;
	pid_t				tgid; //thread group id
    ...
}
```

Linux 2.6 开始实现 NPTL 模型的线程。 task_struct 结构中增加了一个tgid(thread group id)字段，表示线程组。

从内核的角度看，每个线程都有自己的 ID, 使用的是 pid 字段（个人猜测是因为历史原因，Linux 2.6 之前线程的实现的是 LWP(轻量级进程)，也即每个线程都一个进程在调度，使用的是进程 ID.），其实命名为 tid 更合适。而进程 ID 则使用 tgid 字段。如果一个进程是主进程时，其 `pid` 等于 `tgid`。

```
// https://stackoverflow.com/questions/9305992/if-threads-share-the-same-pid-how-can-they-be-identified

                         USER VIEW
                         vvvv vvvv
              |
<-- PID 43 -->|<----------------- PID 42 ----------------->
              |                           |
              |      +---------+          |
              |      | process |          |
              |     _| pid=42  |_         |
         __(fork) _/ | tgid=42 | \_ (new thread) _
        /     |      +---------+          |       \
+---------+   |                           |    +---------+
| process |   |                           |    | process |
| pid=43  |   |                           |    | pid=44  |
| tgid=43 |   |                           |    | tgid=42 |
+---------+   |                           |    +---------+
              |                           |
<-- PID 43 -->|<--------- PID 42 -------->|<--- PID 44 --->
              |                           |
                        ^^^^^^ ^^^^
                        KERNEL VIEW
```



每个 task_struct 的 pid 都不同。所以从内核调度来看，线程和进程没什么区别。

参考 [Linux的进程和线程的现状及其发展史简述](https://www.cnblogs.com/yudidi/p/12417285.html)
[](https://blog.csdn.net/adcxf/article/details/3940982)


> 为什么仍然有人坚称 Linux 的内核没有线程的概念，内核调度是是进程，而不是线程？

个人观点：Linux 实现了线程。
原因：
线程还是进程，都是认为规定的概念，首先看下定义：进程是资源分配的基本单位，线程是调度的基本单位。Linux 没有在一诞生就实现多线程，实际上任何系统也不可能一诞生就是功能完备的。早起确实 Linux 只有进程，因此调度的也是进程。在实现线程的过程中，Linux 简化了实现，首先是用轻量级进程（LWP）实现的。所以后来 NPTL 实现，仍有人按照原来的说法，认为内核调度的是轻量级进程，而且 Linux 仍然沿用了 task_struct 的数据结构。但是首先要说明的是，数据结构不是能代表它是线程还是进程，而是人们对于线程和进程的定义：”进程是资源分配的基本单位“，当一个程序加载进内存，创建 task_struct 并分配地址空间，则它是一个进程。在程序进入调度，开始运行，则它是一个线程。因为“线程是调度的基本单位”。

另一个支持 Linux 只有进程的说法是：不是只有线程可以调度，进程也是可以调度的。这个我是同意的，因为在没有线程的系统上，进程确实是调度的基本单位，这也是早起 Linux 的实现方式。然而，这很容易反驳，线程是空闲资源的，根本就是共享内存空间。如果创建一个 task_struct，它跟已有的 task 共享了内存空间，那它就共享资源，也即创建的是一个线程。


Linux 的进程和线程同时用一个数据结构表示，完全不违反任何概念，没有谁说进程和线程是完全独立，不可相连的。而使用同一数据结构有其历史原因（历史上实现的进程调度），也有其 KISS 的设计理念，使整个系统的实现变得简单。


## 为什么线程比进程高效？

从 Linux 的实现上看，进程和线程都使用了同样的数据结构。而任务的切换都是保存执行现场（寄存器的内容），看起来两者的代码是一样的，为什么常听说线程比进程更高效？哪里高效？

要比较两者的效率，需要从两方面来比较：

- 创建
- 调度

1. 用户空间的信息，地址空间
2. 内核空间 PCB


### 创建

### 为什么线程调度比进程调度轻量？

支持多线程的系统，即便是多进程，调度的单位也是线程，那为什么线程要比进程高效？

1. 创建开销
2. 调度开销（调度时，线程和进程都是指针切换，都是要保存寄存器的状态，为什么说线程比进程高效？）


线程切换不需要更换页表，而进程切换需要。
页表切换缓存失效，性能低

进程切换比线程切换开销大是因为进程切换时要切页表，而且往往伴随着页调度，因为进程的数据段代码段要换出去，以便把将要执行的进程的内容换进来。本来进程的内容就是线程的超集。而且线程只需要保存线程的上下文（相关寄存器状态和栈的信息）就好了，动作很小

2、另外一个隐藏的损耗是上下文的切换会扰乱处理器的缓存机制。简单的说，一旦去切换上下文，处理器中所有已经缓存的内存地址一瞬间都作废了。还有一个显著的区别是当你改变虚拟内存空间的时候，处理的页表缓冲（processor's Translation Lookaside Buffer (TLB)）或者相当的神马东西会被全部刷新，这将导致内存的访问在一段时间内相当的低效。但是在线程的切换中，不会出现这个问题。


协程编程模型更好？
协程能够取代线程？
为什么系统不引入协程？
多个线程的实际堆栈是怎样的？


> 如何达到最好的运行效率？

协称是在线程之上的，它怎么就比线程高效了？多少个线程能在单个系统上达到最高的运行效率？

线程切换的效率，当线程少的时候，是否能独占系统，不用切换？
当线程多的时候，是否效率会变化？切换的时间片是否根据线程数量改变？


### 线程上下文

一个整数线程 ID
栈
栈指针
程序计数器
通用目的的寄存器和条件码？


与同一进程中的其它线程共享整个进程的虚拟地址空间
包括代码、数据区域、堆、共享库、和打开的文件。

线程的上下文要比进程的上下文小得多，线程上线文切换要比进程上下文切换快的多。
不同于进程的严格父子层次关系组织，一个进程内的线程组成一个线程对等池。对等影响是，一个线程可以杀死任意的线程，或者等待其结束。每个对等线程都可以读写共享的数据。

**寄存器是从不共享的，而虚拟存储器总是共享的**




### QA

1. 多核处理器是有多个时钟中断吗？如果只有一个，是所有的运行的核都停止运行吗？

2. 如果系统正在运行，发生了时钟中断怎么办？

3. 

> 什么是协程（Coroutine）

- 简单来说，协程像是轻量级的线程，但并不完全是线程。
- 首先，协程可以让你顺序地写异步代码，极大地降低了异步编程带来的负担；
- 其次，协程更加高效。多个协程可以共用一个线程。一个 App 可以运行的线程数是有限的，但是可以运行的协程数量几乎是无限的；

协程实现的基础是可中断的方法（suspending functions）。可中断的方法可以在任意的地方中断协程的执行，直到该可中断的方法返回结果或者执行完成。
运行在协程中的可中断的方法（通常情况下）不会阻塞当前线程，之所以是通常情况下，因为这取决于我们的使用方式。具体下面会讲到。


# 安卓的线程

在 App 启动的时候，会创建一个主线程，也就是UI线程，在这个线程中分发用户的操作，到适当的组件。

因为 UI 线程是用于显示绘制和响应用户操作的（超过5s, 系统会弹出是否杀死 APP的提示，即 ANR 问题），因此

> 不要再 UI 线程中执行耗时工作 （小于16ms）

同时 UI 线程是非线程安全的，因此，

> 不能在其他线程中进行UI设置操作，否则会抛出异常。

基于上面两个原因，想要处理一个耗时工作，在安卓中并不是一个简单的过程。但是安卓提供了一些方法，来帮助快速完成这些工作。



Thread & Handler -> AsyncTask -> RxJava

有几种方式用于后台任务

> java 原生进程/HandlerThread & [Handler](handler.md)：

- 自己处理子线程和主线程消息传递，来进行 UI 操作
- 代码分散，阅读性差
- HandlerThread 是Java 原生Thread 封装了Handler. 适用于 API callback，从 API1 就有。
- ThreadPool 执行许多并行任务 -> WorkManager
- Future & Callable 也是 Java 原生的新类。? 待考证


> AsyncTask

- 如果销毁了创建AsyncTask的 Activity(如旋转屏幕)，则AsyncTask不会随之被销毁。新创建的Activity 并不能方便的关联。
- Activity 销毁时，AsyncTask 并不会自动销毁，容易引发内存泄漏。

- 短暂或可被终止的任务。
- 不需要向UI或用户报告结果的任务。
- 低优先级，可以可以放任不结束的任务。

使用Loader，及子类AsyncTaskLoader。已经被（ViewModel + LiveData（数据观察者模式）代替，不再记录）

***无论是 AsyncTask 已经不用于 View 更新，仅将执行的结果放到 LiveData 中，使用 LiveData 来更新 UI, 而ViewModel 用于缓存跟 UI 相关的所有数据。***

> RxJava

- 流式调用
- IntendService 理想的后台任务， 或在 UI 线程之外获取 Intent.



？ 加锁
？ LiveData 用法，能否和 Rxjava 结合使用？


## 进程与线程

默认情况下，当 APP 启动时，系统为它创建一个进程，和一个主线程，主线程用于 UI 的绘制和交互处理。这个主线程也叫 UI 线程。UI线程主要执行绘制UI并使应用程序响应用户输入。如果需要，可以在应用程序中安排不同的组件在不同的进程中运行，并且可以为任何进程创建其他线程。

默认情况下，同一应用程序的所有组件都在同一进程中运行，大多数应用程序不应更改此设置。但是，如果发现需要控制某个组件所属的进程，则可以在 `manifest` 文件中执行此操作。

每种类型的组件元素 - <activity>, <service>, <receiver>, 和 <provider> 的 manifest 条目 - 支持`android：process`属性，该属性可以指定应该运行该组件的进程。您可以设置此属性，以便每个组件在其自己的进程中运行，或者使某些组件共享进程，而其他组件则不共享。您还可以设置`android：process`，以便不同应用程序的组件在同一进程中运行 - 前提是应用程序共享相同的Linux用户ID并使用相同的证书进行签名。

<application>元素还支持android：process属性，用于设置适用于所有组件的默认值。



如果在UI线程上进行所有事情，则网络访问或数据库查询等长时间操作可能会阻止整个UI。从用户的角度来看，应用程序似乎会挂起。更糟糕的是，如果UI线程被阻止超过几秒钟（当前约5秒），则将向用户呈现“应用程序未响应”（ANR）对话框。用户可能决定退出应用并将其卸载。

Android的线程模型有两个规则：
- 不要阻止UI线程。每个UI操作在不到16毫秒的时间内完成所有工作。
- 仅在UI线程上处理 UI 操作，因为 UI 线程是非线程安全的，在子线程更新 UI 会引起异常。

不要在UI线程上运行异步任务和其他长时间运行的任务。相反，使用AsyncTask（用于简短或可中断任务）或AsyncTaskLoader（用于高优先级的任务或需要向用户或UI反馈的任务）在后台线程上实现任务。


## 异步处理方法

### 1. java 线程 + handler

代码分散，阅读性差


### 2. AsyncTask

AsyncTask 是一个抽象类，它包含一个在子线程中执行的 `doInBackground` 方法，和几个在 UI 线程中执行的回调方法。使用它只需要重写响应的方法，它会自己处理子线程和主线程的通信和回调，从而开发者只需关注业务逻辑。


![AsyncTask](./images/dg_asynctask.png)

1. onPreExecute() is invoked on the UI thread before the task is executed. This step is normally used to set up the task, for instance by showing a progress bar in the UI.
2. doInBackground(Params...) is invoked on the background thread immediately after onPreExecute() finishes. This step performs a background computation, returns a result, and passes the result to onPostExecute(). The doInBackground() method can also call publishProgress(Progress...) to publish one or more units of progress.
3. onProgressUpdate(Progress...) runs on the UI thread after publishProgress(Progress...) is invoked. Use onProgressUpdate() to report any form of progress to the UI thread while the background computation is executing. For instance, you can use it to pass the data to animate a progress bar or show logs in a text field.
4. onPostExecute(Result) runs on the UI thread after the background computation has finished. The result of the background computation is passed to this method as a parameter.

> 使用注意

- 调用 cancel() 终止，返回 false 表示不能停止，通常是因为已经执行结束了。
- isCancelled() 查看是否已经被终止了。如果任务在正常完成之前被取消，则isCancelled（）方法返回true。
- cancel 后，onPostExecute() 不会调用，而是调用  onCancelled(Object)。
- 默认情况下，允许进程内任务完成。
要允许cancel（）中断正在执行任务的线程，请为mayInterruptIfRunning的值传递true。

**AsyncTask 创建的线程并不是独立的，即不会创建多个线程。当创建多个 AsyncTask 时，他们都在同一个线程中执行，因此会阻塞后创建的任务**

2. 引用导致内存泄漏。

3. Activity 销毁时要自己终止任务，终止时要先判断是否已经终止


#### Limitations of AsyncTask

对于某些用例，AsyncTask是不切实际的：

> 对设备配置的更改会导致问题。

当AsyncTask正在运行时设备配置发生更改时，例如，如果用户更改了屏幕方向，则会销毁并重新创建创建AsyncTask的活动。AsyncTask无法访问新创建的活动，并且不会发布AsyncTask的结果。旧的AsyncTask对象保持不变，您的应用程序可能会耗尽内存或崩溃。

> 如果销毁了创建AsyncTask的 Activity，则AsyncTask不会随之被销毁。

例如，如果您的用户在AsyncTask启动后退出应用程序，则AsyncTask会继续使用资源，除非您调用cancel（）。

何时使用AsyncTask：

- 短期或可中断的任务。
- 不需要向UI或用户报告的任务。
- 可以保留未完成的低优先级任务。
- 对于所有其他情况，请使用AsyncTaskLoader，它是下面描述的Loader框架的一部分。




## 结构

Thread and Runnable 的子类

- HandlerThread: 和 Thread and Runnable 一样，用于执行一次性的任务
- AsyncTask: 一次性的任务，具有进度和结束反馈的回调
- IntentService: 执行多个任务，但同一时刻只有一个在执行。

组件
- ThreadPoolExecutor: 在资源可用时自动执行，或者多个线程同时执行，ThreadPoolExecutor 提供了一个线程池。将任务放入队列，任务会在有可用线程时自动执行。（保证要在多个线程内执行的代码是线程安全的。）


## 获取线程/进程 Id

在分析多线程或多进程的时候，知道当前的在哪个线程或进程执行对于分析有很大帮助

```
Log.e("process Id: ", "" + android.os.Process.myPid())
Log.e("thread Id", "" + Thread.currentThread().id)
```

## 切换到主线程

```
if (Looper.myLooper() != Looper.getMainLooper()) {
    // If we finish marking off of the main thread, we need to
    // actually do it on the main thread to ensucorrect ordering.
    Handler mainThread = new Hand(Looper.getMainLooper());
    mainThread.post(new Runnable() {
        @Override
        public void run() {
            mEventLog.add(tag, threadId);
            mEventLog.finish(this.toString());
        }
    });
}
```

## 非阻塞

由于实现不同，Kotlin 并没有实现 Python 迭代器类似的单线程非阻塞方式。 Kotlin 的非阻塞，其实是通过多线程实现的。
