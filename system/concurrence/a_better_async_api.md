# 有了进程、线程为什么还需要协程？

要理解协程，就要先理解协同式，和协同式相对的就是抢占式。

抢占式： 是指多个并发程序的执行调度程序，进程正在执行过程中，系统立即中止正在执行中的程序，并保存执行的状态（用户恢复时使用），将处理器立刻分配给新的进程。进程和线程都是抢占式运行的。

协同式：协程的思想本质上就是控制流在运行到需要得地方时，由程序本身主动让出（yield）和恢复（resume），而不是被系统机制强制的抢占。


 “协程”（Coroutine）概念最早由 Melvin Conway 于 1958 年提出，最早的应用是在汇编语言中构建协同式程序，从概念上甚至是比进程（二十世纪60年代初）和线程(1967)的提出还要早。这就需要从计算机发展过程和实现机制上来解释，抢占式调度依赖于硬件的支持，因为调度器需要“剥夺”进程的执行权，就意味着调度器需要运行在比普通进程高的权限上，否则任何“流氓（rogue）”进程都可以去剥夺其他进程了。只有 CPU 支持了执行权限后，抢占式调度才成为可能。x86 系统从 80386 处理器开始引入 Ring 机制支持执行权限，这也是为何 Windows 95 和 Linux 其实只能运行在 80386 之后的 x86 处理器上的原因。在此之前，由于理念没有提出和硬件没有得到支持，任何的调度，多任务调度都是协同式的。

 在 Melvin Conway 的博士论文中给出了协程的定义

 > 数据在后续调用中始终保持（ The values of data local to a coroutine persist between successive calls 协程的局部）

 > 当控制流程离开时，协程的执行被挂起，此后控制流程再次进入这个协程时，这个协程只应从上次离开挂起的地方继续 （The execution of a coroutine is suspended as control leaves it, only to carry on where it left off when control re-enters the coroutine at some later stage）。

其实定义只是给出了一个粗略的出让，恢复的定义。由于现在的主流操作系统，都是抢占式的，虽然这个概念很早的提出，然而系统的安全性和功能需要，却让协同式失去了大部分系统级的应用，但是由于协同式轻量级、协同代码可读性好等优点，让它在应用级编程找到了用武之地，让这个理念换发了新的生机。


虽然协程的概念在操作系统内核中消失了，但是仍然残留着其历史的痕迹：系统调用。

当系统调用发生时，系统需要保存当前进程的状态，将当前进程挂起。例如进程发起了 I/O 请求或者调用了 sleep 函数。然后内核会在当前进程不满足运行条件的情况下，调度其它进程继续执行，从而提高 CPU 的利用率。


## 我们是否真的需要协程？

在官网上对协程的介绍，“协程可以被认为是轻量级线程”。**可以被认为是线程就需要提供线程一样的并发能力**:
```Kotlin
fun main() = runBlocking { // this: CoroutineScope
    launch { // launch a new coroutine and continue
        delay(1000L) // non-blocking delay for 1 second (default time unit is ms)
        println("World!") // print after delay
    }
    println("Hello") // main coroutine continues while a previous one is delayed
}
```

```
Hello
World!
```
协程是如何做到的？

```

```
可以看到协程就是运行在线程之上的 API。 

既然协程就是用的线程，①为什么说协程比线程轻的？②什么情况下确实能做到比线程快？什么情况下做不到？

### 更好的性能？

关于协程有点说法最多的就是比线程更加轻量级。Kotlin 的协程真的更轻量级吗？轻在哪？
在官网上有关于协程和线程的性能比较示例：

```Kotlin
import kotlinx.coroutines.*

fun main() = runBlocking {
    repeat(50_000) { // launch a lot of coroutines
        launch {
            delay(5000L)
            print(".")
        }
    }
}
```
> If you write the same program using threads (remove runBlocking, replace launch with thread, and replace delay with Thread.sleep), it will consume a lot of memory. Depending on your operating system, JDK version, and its settings, it will either throw an out-of-memory error or start threads slowly so that there are never too many concurrently running threads.

1. 创建
- 由于线程是一个系统调用，这会导致系统陷入内核，执行很多额外操作（例如上下文切换），而且有可能导致缓存失效而加剧性能损耗。
- 每个线程需要分配独立的栈地址，这会迅速消耗内存地址空间。

2. 运行
- 现代 CPU 虽然拥有多核处理器，但同一时间运行的线程数量是仍然是有限的。当就绪线程（除去被阻塞线程）数量大于 CPU 可以并行运行的线程数量时，创建更多的线程并不能增加 CPU 的利用率，反而会消耗系统资源，增加系统任务调度时间。

为了解决这样的问题，一些框架和并发 API 都使用了**线程池技术**。以便在并发场景中提供更好的性能，占用更少的系统资源。例如 RxJava 的 Schedulers，Java 的 Executors。

#### ②什么情况下确实能做到比线程快？什么情况下做不到？

1. 当需要执行 I/O 等（网络、sleep）阻塞操作时，协程不比线程快。

这是因为 I/O 等阻塞操作依靠的是系统能力，需要进行系统调用，这是阻塞的整个线程，此线程无法继续执行其它协程。需要系统调度其它线程继续执行，此时使用协程和直接使用线程是一样的。


2. 当不执行系统级 I/O，仅仅挂起当前协程时，当前线程可以继续执行其它协程，从而让整个时钟周期内都能执行任务。减少了上下文切换的频率，系统的整体吞吐量提高。

但是这里的比较究竟合理吗？

什么情况下会提升性能？性能更好的本质是什么？

当我们生产者和消费者关系。

这种比较看起来好像协程并没有什么优势，然而在实际的使用场景中却会出现不同的结果。

在两个不同的业务中，如果使用 Excuator, 由于业务独立，我们会分别在连个业务中创建两个独立的线程，此时，一个线程如果业务不饱和，就会主动让出 CPU，这增加了上下文切换和调度的频率，从而使性能下降。

而使用协程，不同的业务我们只需要创建两个协程。这些协程可以共用线程，当协程没有任务执行时，被挂起，此时线程可以继续执行其它的协程，并不会发生上下文切换，使用协程的上下文切换相比之下更接近时钟中断的周期。在携程越多的时候，性能更好。



可见，若是单考虑性能，和线程相比，也尽在运行 CPU 密集任务的时候有优势，一旦会有阻塞线程的操作，协程也进程也没有什么差别。与此同时，Java 也提供了其它线程池技术实现和协程一样（甚至更好）的性能。**那协程的优势究竟在哪里呢？**

## 更好的API



## 阻塞？


## 挂起？

## 遗憾

相比于其它语言对协程的语言级别支持，Kotlin 的协程是 API 级别，这导致协程的创建比较繁琐。
