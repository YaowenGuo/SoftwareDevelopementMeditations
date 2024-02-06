# 协程（Coroutine）OR 一个更好的异步 API

**系统没有协程的概念**，协程是在应用程实现的并发功能。

# 有了进程、线程为什么还需要协程？

要理解协程，就要先理解协同式，和协同式相对的就是抢占式。

抢占式： 是指多个并发程序的执行调度程序，进程正在执行过程中，系统立即中止正在执行中的程序，并保存执行的状态（用户恢复时使用），将处理器立刻分配给新的进程。进程和线程都是抢占式运行的。

协同式：协程的思想本质上就是控制流在运行到需要得地方时，由程序本身主动让出（yield）和恢复（resume），而不是被系统机制强制的抢占。

操作系统中有很多抢占式和协同式的案例：

- 抢占式：各种外部中断（时钟中断、键盘、串口接收中断（读取磁盘数据成功、网络数据到达、外部设备连接）），内部中断（除零错误、段保护错误、缺页错误、指令错误等 CPU 内部错误）会导致当前正在执行的流被中断，跳到内核执行。这种被动发生的事情就是抢占。

- 协同式：各种系统调用，例如 I/O 请求（read/write），sleep()，yield() 等。当系统调用发生时，系统需要保存当前进程的状态，处理进程的请求，如果进程发起的是一个耗时请求，系统就会将当前进程挂起，先运行其它线程，等到处理结果准备之后，再根据调度算法的调度，恢复线程的执行。例如程序调用了 sleep 函数进入内核后调度器就会挂起当前线程，先运行其它的线程，一直到 sleep 的时间到了，调度算法才会将这个线程放到要运行的线程队列中等待执行。在比如程序发起了一个 IO 请求 (read 一个文件)， 进入内核后，内核也会将当前线程挂起，然后向磁盘发出读数据的请求，由于读取磁盘是一个非常缓慢的过程，CPU 并不会等待数据到达，而是运行一个新的线程。等到数据到达后，会向 CPU 发送一个中断，此时内核才会准备好数据，并将发出读数据请求的线程放到调度队列。CPU 就是这样巧妙的利用抢占和协作让 CPU 尽可能的忙碌起来 ，从而提高 CPU 的利用率。


> 抢占
![抢占]()

> 协同
![协同]()

 “协程”（Coroutine）概念最早由 Melvin Conway 于 1958 年提出，最早的应用是在汇编语言中构建协同式程序，从概念上甚至是比进程（二十世纪60年代初）和线程(1967)的提出还要早。这就需要从计算机发展过程和实现机制上来解释，抢占式调度依赖于硬件的支持，因为调度器需要“剥夺”进程的执行权，就意味着调度器需要运行在比普通进程高的权限上，否则任何“流氓（rogue）”进程都可以去剥夺其他进程了。只有 CPU 支持了执行权限后，抢占式调度才成为可能。在此之前，由于理念没有提出和硬件没有得到支持，任何的调度，多任务调度都是协同式的。

 在 Melvin Conway 的博士论文中给出了协程的定义

 > 数据在后续调用中始终保持（ The values of data local to a coroutine persist between successive calls 协程的局部）

 > 当控制流程离开时，协程的执行被挂起，此后控制流程再次进入这个协程时，这个协程只应从上次离开挂起的地方继续 （The execution of a coroutine is suspended as control leaves it, only to carry on where it left off when control re-enters the coroutine at some later stage）。


其实定义只是给出了一个粗略的出让，恢复的定义。虽然协程这个概念很早的提出，然而系统的安全性和功能需要，协程始终未能在系统中得到广泛的实现，现代操作系统更是只提供进程、线程的概念。但是由于协同式轻量级、协同代码可读性好等优点，让它在应用级编程找到了用武之地，让这个理念换发了新的生机。


## 我们是否真的需要协程？

首先来看下创建协程的方式，我们有三种不同的方式来创建协程。

```Kotlin
// 方式一 runBlocking
val result = runBlocking { }

// 方式二 launch 
// 全局生命周期的协程，一般不使用
val job = <Scop>.launch {
}

// 方式三 sync
val result = <Scop>.async {
 
}
```
它们有更多的参数和作用域可以指定(Scope)，这里不是我们关注的重点。花括号中是我们要在协程中执行的内容。类比线程可以看所：

```Kotlin
val thread = Thread(Runnable{
})
// 最后一个参数可以协作 lamda 的形式
val thread = Thread {
}
thread.start()
```
不同的是 Java 的 thread 需要调用 start() 方法才能开始执行，而协程创建之后就开始执行。


在官网上对协程的介绍，[“协程可以被认为是轻量级线程”](https://kotlinlang.org/docs/coroutines-basics.html#coroutines-are-light-weight):
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

官网然后说：
> 如果你使用线程编写相同的代码（移除 runBlocking，使用线程替代 launch，同时使用 Thread.sleep 替换 delay），将会耗费大量的内存。根据你的操作系统、JDK版本及其设置，它要么抛出内存不足错误，要么启动线程非常缓慢，以至于不会有太多并发运行的线程。

然后往上有人说，这个比较不合理。它对比的对象应该是 Executors，如果换成 Executors，应该是如下的代码。


在官网上有关于协程和线程的性能比较示例：

```Kotlin
fun main() {
    val start = System.currentTimeMillis();
    val executor = Executors.newSingleThreadScheduledExecutor()
    val runnable = java.lang.Runnable {
        print(".")
    }

    repeat(50_000) {
        executor.schedule(runnable, 0, TimeUnit.SECONDS)
    }
    executor.schedule(java.lang.Runnable{
        println()
        println("Used time: ${System.currentTimeMillis() - start}")
    }, 0, TimeUnit.SECONDS)
}
```
对比性能我们会发现，使用 executor 甚至能获得比协程更好的性能。

看了这个对比之后我们不禁要问：究竟应该和谁比较？要是追求性能，Executors 似乎还要好那么一点点，我们还需要协程码？

### 究竟应该和谁比较？

首先我们需要明确，要是想和线程比较就要提供和线程一样的并发能力。

协程能够像线程一样提供并发能力，即便它运行在一个单一的线程之上。

例一：协程运行在一个线程
```Kotlin
fun main(): Unit = runBlocking(CoroutineName("main")) {
    launch {
        println(Thread.currentThread().name)
        for (i in 0 until  1000) {
            println("A")
        }
    }

    launch {
        println(Thread.currentThread().name)
        for (i in 0 until  1000) {
            println("B")
        }
    }
}
```

```
main
A
A
A
...
main
B
B
...
```
可以看到，多个协程运行在单个线程中并没有并发执行，而是顺序运行的。

例二：多个协程运行在多个线程

```Kotlin
fun main(): Unit = runBlocking(CoroutineName("main")) {
    launch(Dispatchers.IO) {
        println(Thread.currentThread().name)
        for (i in 0 until  1000) {
            println("A")
        }
    }

    launch(Dispatchers.IO) {
        println(Thread.currentThread().name)
        for (i in 0 until  1000) {
            println("B")
        }
    }
}
```
```
DefaultDispatcher-worker-1
A
A
...
A
A
DefaultDispatcher-worker-3
B
B
B
A
A
...
```
可以看到在第二个协程执行之后，两个协程的输出是随机的，两个协程是并发执行的。那运行在单个线程中的写成真的就无法并发执行了吗？

例三：单线程的一个生产者消费者模型实现
```
fun main(): Unit = runBlocking {
    val channel = Channel<Int>()
    println("Thread in main: ${Thread.currentThread()}")
    launch {
        println("Thread in cor1: ${Thread.currentThread()}")
        channel.consumeEach {
            println("receive: $it")
        }
    }


    launch {
        println("Thread in cor2: ${Thread.currentThread()}")
        for (x in 0 until 6) {
            println("send $x")
            channel.send(x)
        }
        channel.close()
    }
}
```

可以看到，在主动出让的情况下，协程也能实现并发。只不过这种并发是可预测的。即何时，在哪里发生切换可以很明确的知道。可以看下面一个更简单的例子：
```Kotlin
fun main() = runBlocking { // 创建了一个协程
    launch { // 创建第二个协程
        delay(1000L)     // 主动出让。挂起了这个协程。
        println("World!")
    }
    println("Hello")
}
```
```
Hello
World!
```

从上面的例子中我们可以得出如下的结论：

- 运行在不同线程之上的协程具有并发能力
- 运行在相同线程之上的协程，主动出让才会具有并发能力，否则是顺序执行的。
- **由于线程是系统提供运行的基本单位，协程必然运行在线程之中。**Kotlin 协程是建立在多线程之上的一个实现。

### 协程是如何提高性能的？

既然协程的本质也是运行的线程，我们就会有一个疑问，协程的切换总是和线程切换来比较，协程不也是运行在线程之上的吗，也会发生线程的切换呀。都是使用线程为什么协程提高了性能？或者说协程轻在哪里？

既然协程就是用的线程，①为什么说协程比线程轻的？②什么情况下确实能做到比线程快？什么情况下做不到？使用协程应该避免哪些行为才能提高性能。

1. 创建
- 由于线程是一个系统调用，这会导致系统陷入内核，执行很多额外操作（例如上下文切换），而且有可能导致缓存失效而加剧性能损耗。
- 每个线程需要分配独立的栈地址，这会迅速消耗内存地址空间。

而协程使用线程池技术，避免创建巨量的线程，同时会复用线程，避免因一个逻辑流结束就需要销毁线程的这部分性能损失。


2. 运行
我们常常说协程切换比线程切换更轻量，来看下比较的哪部分。我们以单线程中两个协程实现的生产者消费者和两个线程实现的生产者消费者为例：




**可以被认为是线程就需要提供线程一样的并发能力。**很多协程为了实现这种并发，会隐藏线程的概念，完全使用协程提供并发能力，例如 go 语言。

1. 当需要执行 I/O 等（网络、sleep）阻塞操作时，协程不比线程快。

这是因为 I/O 等阻塞操作依靠的是系统能力，需要进行系统调用，这是阻塞的整个线程，此线程无法继续执行其它协程。需要系统调度其它线程继续执行，此时使用协程和直接使用线程是一样的。


2. 当不执行系统级 I/O，仅仅挂起当前协程时，当前线程可以继续执行其它协程，从而让整个时钟周期内都能执行任务。减少了上下文切换的频率，系统的整体吞吐量提高。

但是这里的比较究竟合理吗？

什么情况下会提升性能？性能更好的本质是什么？

当我们生产者和消费者关系。

这种比较看起来好像协程并没有什么优势，然而在实际的使用场景中却会出现不同的结果。



而使用协程，不同的业务我们只需要创建两个协程。这些协程可以共用线程，当协程没有任务执行时，被挂起，此时线程可以继续执行其它的协程，并不会发生上下文切换，使用协程的上下文切换相比之下更接近时钟中断的周期。在携程越多的时候，性能更好。


### 我们还需要协程吗？

可见，若是单考虑性能，和线程相比，也仅在运行 CPU 密集任务的时候有优势，一旦会有阻塞线程的操作，协程和进程也没有什么差别。与此同时，Java 也提供了其它线程池技术实现和协程一样（甚至更好）的性能。既然 Executors 比协程好像还要快一点点，我们还需要协程吗？


在实际的业务开发中，有大量的逻辑需要异步执行，然后获得执行的结果。例如一个网络请求，我们需要在一个新的线程中处理 I/O 请求，然后将结果在 UI 线程中渲染。使用线程导致复杂的回调地狱：

```Java
Thread {
    @Override
    fun run() {
        for (folder in folders) {
            val files = folder.listFiles()
            for (file in files) {
                if (file.name.endsWith(".png")) {
                    val bitmap: Bitmap = getBitmapFromFile(file)
                    getActivity().runOnUiThread(Runnable {
                            
                    })
                }
            }
        }
    }
}.start()
```

为此很多异步编程框架应运而生，在安卓上应用最广泛的因该是就是 Rxjava 了。它可以将回调扁平化，同时不用处理线程同步问题：

```Java
Observable.fromIterable(folders)
    .flatMap { file -> Observable.fromArray(*file.listFiles()) }
    .filter { file -> file.name.endsWith(".png") }
    .map { file -> getBitmapFromFile(file) }
    .subscribeOn(Schedulers.io())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe { bitmap -> imageCollectorView.addImage(bitmap) }
```

这看起来是如此美好，然而事实并非总是如此，当程序变得复杂后，它的流程不符合开发语言的一般习惯。

1. `subscribeOn` 和 `observeOn` 设置线程对于整个流不是显而易见的，特别是添加了 doOnSubscribe 等更多操作符之后。当时查看文档后可能清楚，稍微过一段时间一切又变得模糊起来。

2. 不知道你是否有这样的经历，因为参数和泛型而频繁提醒语法错误。过多的操作符组合，返回类型和传入参数常常使人迷惑。

3. 这些操作符中的语句的顺序和他们的顺序不是完全相关，还和他们的操作符本身有关。过多操作符实在难以记忆，而且有些操作符和语言本身的 for 等功能是重复的。 

终于，我们有了更好的 `async` + `await` API组合，让我们能够像以往编写同步代码一样来处理异步逻辑。并且以一套简单的 API 应对更多的场景。其最早出现在 C# 5.0 中，为异步编程提供了更直观、易读的语法，使得开发者能够更方便地编写和管理异步代码。`async` + `await` 的创新为异步代码编写解开了新篇章，许多主流语言都已经原生支持 `async` + `await` 关键字，有些则以函数的形式进行支持。

```Kotlin
val bitmapLoader = CoroutineScope(Dispatchers.IO).async {
    val bitmapList = ArrayList<Bitmap>()
    folders.flatMap { it.listFiles().toList() }
        .filter { it.name.endsWith(".png") }
        .map { getBitmapFromFile(it) }
}
imageCollectorView.addImages(bitmapLoader.await())
```

在 `async` 调用发出后，`async` 中的代码在另一个线程异步执行，并不会阻塞当前协程。直到 `await()` 被调用，当前协程在被挂起。直到 async 中的结果返回，被 `await()` 挂起的协程将自动恢复执行。此时 `mageCollectorView.addImages()` 被执行。

不要小看这一点点改变，其让异步代码组合变得异常简单。假设这样一个利用第三方登录场景，获得用户的账号后，需要利用三方的平台登录，然后将账号和三方 token 发送服务器获取用户的信息和好友列表。

```Kotlin
CoroutineScope(Dispatchers.IO).launch {
    val userAccount = "123@email.com"
    val token = thirdPartyLogin(userAccount).await()
    val userLoader = userInfo(userAccount, token)
    val friendLoader = friendList(userAccount, token)
    val userInfo = userLoader.await()
    val friendLoader = friendLoader.await()
    withContext(Dispatchers.Main) {
        renderUser(userInfo, friendLoader)
    }
}
```

上面的异步使用 RxJava 可以改为如下代码：

```Kotlin
val userAccount = "123@email.com"
thirdPartyLogin(userAccount)
    .flatMap {
        Single.zip(userInfo(userAccount, token), friendList(userAccount, token)) { userRsp, friendRsp ->
          UserAndFriends(userRsp.data(), friendRsp.data())
        })
    }
    .subscribeOn(Schedulers.io())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe {
        renderUser(it.getUser(), it.getFriends())
    }
```
可以看到，即便是使用了 RxJava，其依然没有协程写出的代码简洁。最重要的是，它不符合程序编写的一般直觉，设置线程的 `subscribeOn` 代码更靠后，却修改了前面的代码的线程。async 和 await 的改变可能不是从 1 到 100 那样巨大，然而它却是从 0 到 1 的改变，看起来是一个小小的改变将使异步编程发生质的改变。


## 阻塞？

阻塞是指在**一个调用返回之前，后面的代码无法继续执行**。例如一个 I/O 请求，sleep() 调用。

```sleep

```
在协程中也有阻塞的方法，其阻塞的是协程本身，在协程阻塞时，当前线程被调度出去，继续用于执行其它协程。

```
```

在协程中我们需要区分是阻塞线程还是阻塞协程。如果在协程中调用了一个阻塞线程的方法，将导致协程的性能退化到跟使用线程一样。**在 Kotlin 中非常方便区分，其协程是有单独的核心库实现的。协程库中提供的阻塞方法都是阻塞协程本身的。其它阻塞方法则是阻塞线程**因此在协程中，如果协程提供了实现相同功能的方法时，应该使用协程的方法来实现。


## 挂起？

挂起是挂起整个协程，f行，而是转而执行其他协程。


### 挂起函数

并不是执行到这个函数就挂起了，而是函数内部可能包含有能够使携程挂起的代码，在函数内的代码执行到挂起代码的时候，携程被挂起。被 `suspend` 修饰的函数不应定有挂起代码，也不定会时携程挂起。由于挂起只能出现在携程内部，该修饰符就是为了给编译器标识函数万一有挂起函数，只能用于携程内部，用于安全检查的。

## 遗憾

相比于其它语言对协程的语言级别支持，Kotlin 的协程是 API 级别，这导致协程的创建比较繁琐。

- 首先，协程可以让你顺序地写异步代码，极大地降低了异步编程带来的负担；
- 其次，协程更加高效。多个协程可以共用一个线程。一个 App 可以运行的线程数是有限的，但是可以运行的协程数量几乎是无限的；

协程实现的基础是可挂起的方法（suspending functions）。可挂起的方法可以在任意的地方被挂起，直到该方法被恢复执行。
运行在协程中的可挂起的方法（通常情况下）不会阻塞当前线程，之所以是通常情况下，因为这取决于我们的使用方式（必须使用协程提供的方法挂起）。


--------------->

关于并发的定义在 CSAPP8.2.2 中定义非常简单：

> A logical flow whose execution overlaps in time with another flow is called a concurrent flow, and the two flows are said to run concurrently. More precisely, flows X and Y are concurrent with respect to each other if and only if X begins after Y begins and before Y finishes, or Y begins after X begins and before X finishes.


## 创建


调度器

1. Dispatchers.Unconfined
2. Dispatchers.IO 对 IO 操作做了优化
3. Dispatchers.Default 适用于 CPU 密集型操作
5. Dispatchers.Main  安卓库独有


这里有篇文章将协称分为[有栈、无栈协程](https://blog.csdn.net/weixin_39875941/article/details/110592519)。我看不过是栈是由系统在栈区分配，还是由用户在堆分配空间作为栈使用的区别。因为**函数调用的入栈规则不改变，就不可能没有栈。**
