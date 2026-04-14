# java 和 安卓中的异步 API

## Java 的线程
```Java
Thread thread = new Thread(() -> {
    System.out.println("child thread,");
});
thread.start();
```

其中 `Thread.start()` 的实现为

```Java
// java.lang.Thread
public synchronized void start() {
    ...
    try {
        start0();
        started = true;
    } finally {
       ...
    }
}
```
// 其 JDK 实现为
```
// https://github.com/openjdk/jdk/blob/739769c8fc4b496f08a92225a12d07414537b6c0/src/java.base/share/native/libjava/Thread.c

static JNINativeMethod methods[] = {
    {"start0",           "()V",        (void *)&JVM_StartThread},
    ...
};
```
安卓 4.4 开始引入 ART 虚拟机。

```C++
// https://android.googlesource.com/platform/art/+/master/openjdkjvm/OpenjdkJvm.cc
JNIEXPORT void JVM_StartThread(JNIEnv* env, jobject jthread, jlong stack_size, jboolean daemon) {
  art::Thread::CreateNativeThread(env, jthread, stack_size, daemon == JNI_TRUE);
}

// https://android.googlesource.com/platform/art/+/master/runtime/thread.cc

void Thread::CreateNativeThread(JNIEnv* env, jobject java_peer, size_t stack_size, bool is_daemon) {
  CHECK(java_peer != nullptr);
  ...
  Thread* child_thread = new Thread(is_daemon);
  ...
  if (child_jni_env_ext.get() != nullptr) {
    ...
    pthread_create_result = pthread_create(&new_pthread,
                                           &attr,
                                           Thread::CreateCallback,
                                           child_thread);
    ...
  }
  ...
}

```

## 数据一致性

数据一致性是寄存器的数据没有及时同步到内存，数据和不一致。其它线程读取内存的数据，和另一个线程持有的寄存器中的数据不一致。

## 保证数据一致性的手段

### 关中断

### 缓存一致性协议

缓存一致性是有硬件实现的。

在 CPU 和内存的访问速度速度之间差别太大，甚至有一百多倍，为了加快运算，在 CPU 和内存之间加入了访问速度快的缓存。

目前工业的实践基本是三级缓存，未来内存速度更快可能会减少，CPU 和 内存速度差别更大的话，可能会增加更多。


L1 L2 是和核共享的，每核一个，L3 是多核共享的，整个 CPU 只有一个。

每次读取数据到缓存中的数据块称为缓存行，目前三级缓存的情况下，工业实践缓存行大小为 64 字节为最佳。

不同核的缓存要保持一致。所以就出现了缓存一致性协议。最出名的就是Intel 的MESI协议，MESI协议保证了每个缓存中使用的共享变量的副本是一致的。它核心的思想是：当CPU写数据时，如果发现操作的变量是共享变量，即在其他CPU中也存在该变量的副本，会发出信号通知其他CPU将该变量的缓存行置为无效状态，因此当其他CPU需要读取这个变量时，发现自己缓存中缓存该变量的缓存行是无效的，那么它就会从内存重新读取。

JDK 1.7 LinkedBlockingQueue 使用了。

Disruptor RingBuffer 的实现。

JDK 1.8 增加了 @Contended, 保证注解的类的变量在单独一行中。同时要打开 JVM 的一项配置。

```JAVA
@Contended // 保证 x 位于单独缓存行中。
class T {
    public long x = 0L;
}
```

缓存一致性协议是硬件厂商决定的，有很多类型，例如 Intel 的 MESI。

### 系统屏障
### 总线/缓存锁

## synchronized 底层实现

synchronized 早期重量级，向系统申请。
后来改造，

执行时间长适合用系统锁/线程数量比较多。
执行时间短且线程数量比较少适合用自旋锁。

## Thread Executor, HandlerThread, AsyncTask 怎么选

如果想要执行后台任务，不与前台交互，可以使用, Thread 或者 Executor，而且推荐使用 Executor 线程池。

如果与前台频繁交互，例如下载进度条等则可以使用 AsyncTask，而 HandlerThread 基本没有什么使用场景。如果一次性交互，可以使用 Handler 或者其他切换线程的库。

Service 和 IntentService（带有单线程的后台一次性 Service，执行完后就自动退出了）。Servide 主要处理长时间的任务，除非用户为其他应用提供服务或者播放器等用户服务。否则都不建议使用，而是使用 DownloadManager 或者 TaskManager 代替。


## 实现 Rannable 接口的好处

1. 线程的任务从线程子类中分离处理，进行单独的封装，更符合面向对象的思想。
2. 避免 Java 单继承的局限性。


## 几种创建 Thread 的方法

1. 继承 Thread 类，重写 run 方法。
2. 实现 Runnable 接口。传递给 Thread 对象。同时覆盖和传递 runnable 将执行 Thread 自身覆盖的 `run` 方法。
3. ThreadFactory，其实内部还是自己 New Thread。只不过可以用与生产一批类似的线程。
4. Excturor 线程池，不用时及时关闭 shutdown。
    1. 单线程的线程池 singleThreadExecutor()。可以指定执行的顺序（FIFO,LIFO）/
    2. 固定数量线程池 fixedThreadExecutor()
    3. 可以动态增长的线程池 newCachePoolExecutor() 不限制数量
    4. newScheduledThreadPool 支持定时及周期执行任务。
5. Callable 有返回值的线程，通过 `Future.get()` 获取结果

## 结构

Thread and Runnable 的子类

- HandlerThread: 和 Thread and Runnable 一样，用于执行一次性的任务
- AsyncTask: 一次性的任务，具有进度和结束反馈的回调
- IntentService: 执行多个任务，但同一时刻只有一个在执行。

组件
- ThreadPoolExecutor: 在资源可用时自动执行，或者多个线程同时执行，ThreadPoolExecutor 提供了一个线程池。将任务放入队列，任务会在有可用线程时自动执行。（保证要在多个线程内执行的代码是线程安全的。）


## 非阻塞

由于实现不同，Kotlin 并没有实现 Python 迭代器类似的单线程非阻塞方式。 Kotlin 的非阻塞，其实是通过多线程实现的。


## 可重入

可重入是指已经获取锁的进程可以在内部调用另一个要获取同一把锁的代码。


```Java
class T {
    void synchronized a {
        b();
    }

    void synchronized b {

    }
}
```

a 和 b 要获取同一把锁，在同一个线程中 a 可以调用 b。 这是必须的。因为如果不允许可重入锁。继承的 synchronized 调用 super 将会导致死锁。

```Java
class T {
    protect void synchronized a {
        //...
    }
}

class V extends T {
    protect void synchronized a {
        super.a();
    }
}
```

如果不允许可重入，A.a 在调用 super.a() 时，因为获取不到锁，而产生死锁。因为此时都要获取 V 的对象。

## 获取锁程序产生异常，会释放锁。

如果不想释放锁，可以 catch 处理。

## 线程间通信

包括 wait(), notify(). notifyAll()，join(), yield()。

1. 这些方法都必须在同步代码块内使用。因为这些方法都是用于操作线程状态的方法，必须要明确到底要操作的是哪个锁上的线程。
2. 为什么这些方法内定义在了 Object 类中？ 因为这些方法是监视器方法，监视器可以是任意对象，任意对象都有的方法一定是在 Object 中。


## 线程阻塞

该线程放弃 CPU 的使用，暂停执行。只有等到导致阻塞的原因消除之后才能运行。

1. sleep(), wait(), yield(), join(),(suspend(), resume() 已废弃)
2. 执行一段代码无法获得相关锁。
3. IO 操作等待相关资源。

有争议的地方，Java 中对阻塞的定义


```
BLOCKED：Thread state for a thread blocked waiting for a monitor lock.
A thread in the blocked state is waiting for a monitor lock to enter a synchronized block/method or reenter a synchronized block/method after calling ｀Object.wait｀
```

## 线程的状态图

![Thread status transform](images/thread_status_transform.png)



## interrupt 和 stop 的区别，为什么 stop 被废弃。

- interrupt 是在线程中设置了一个标志位，需要在 `run` 方法中自己判断标志位来终止。`Thread.isInterrupe()` 会在返回之后，把标志位置为 true，这样方便下次再次执行；而 `isInterrupt()` 不会设置标志位。
- stop 方法类似将线程 kill 掉，结果不可预期。释放它已经锁定的所有监视器。可能产生数据的不一致性。已经被废弃。

- 正在 `sleep` 的线程，被执行 `interrupt()` 将会终止休眠，同时抛出 `InterruptedException`，此时捕获异常可以做一些善后工作。
- Android 中有个 `SystenClock.sleep()` 不会抛出 ｀InterruptedException`，同时也不会被打断休眠状态，可以用于特殊情况。

```
try {
    Thread.sleep(1000)
} catch (ex: InterruptedException) {
    // 正在睡的时候，执行了 `interrupt` 将会直接被激活，然后抛出 `InterruptedException`
}
```

## 线程停止方法的比较。

1. stop 方法不安全，已经使用 interrupt 代替。
2. run 方法结束，或者判断`isInterrupt`标记位。线程可能被 wait 后进入到冻结动态，无法恢复或者判断标记位。可以使用 interrupt() 将线程中冻结或者休眠状态激活重新获得执行资格。

## 线程操作方法介绍

> join

在一个线程中调用另一个线程的 `join`，会等待另一个线程执行完毕之后，才执行后面的代码。join 的线程并不会立即执行，而是和其他具有执行权的线程进入分配队列等待线程调度。

> yield()

正在执行的线程获取到了执行时间片，执行 `yield()` 时，会主动让出时间片，然后到排队等待的队列中等待下一个时间片。

> setDeamon(true)

设置线程为守护线程。普通线程会阻塞进程，所有线程都结束后才会结束进程。而守护线程优先级比较低，不会阻塞进程结束。

1. 开启和任何操作都和普通线程一样。只需要设置线程 `setDeamon(true)`

> 优先级

获取 CPU 执行的记录，即线程调度的权重。1~10

MAX_PRIORITY = 10
NORM_PRIORITY = 5
MIN_PRIORITY = 1

> 线程组

在构造函数中指定，可以集体判断等操作处理。

## 多生产者多消费者关系

1. 为了防止被同类唤醒，而又不需要运行，要循环判断标记位。
2. 为了防止循环判断成立时有进入等待状态，从而全部进入等待状态，而进入死锁，要用 notifyAll 唤醒所有线程，一定会唤醒对象线程。


## wait 和 sleep 的区别

1. wait 可以指定时间，也可以不同指定。
2. 在同步中时，对 cup 的执行权的实例方式不同。wait 释放执行权，释放锁。sleep 释放执行权，但不释放锁。


## 加锁的类型

1. 同步代码快
2. 同步函数。
    1. 并不是所有内容都可以放在同步函数中。
    2. 同步函数的锁不是 Object，而是 this 对象。
3. 静态同步函数
    锁的是当前类的字节码。this.getClasss(). 或者 <类名>.class
    t.getClass() 和 Ticket.class 等价

## synchronized 修饰的类型

1. 修饰方法
2. 修饰代码块

两者等价

```java
public synchronized void method()
{
   // todo
}

public void method()
{
   synchronized(this/object) {
      // todo
   }
}

```

3. 修饰静态方法
4. 修饰类 `synchronized(ClassName.class) {}`

两者是等价的


## 不能继承

synchronized关键字不能继承。
虽然可以使用synchronized来定义方法，但synchronized并不属于方法定义的一部分，因此，synchronized关键字不能被继承。如果在父类中的某个方法使用了synchronized关键字，而在子类中覆盖了这个方法，在子类中的这个方法默认情况下并不是同步的，而必须显式地在子类的这个方法中加上synchronized关键字才可以。当然，还可以在子类方法中调用父类中相应的方法，这样虽然子类中的方法不是同步的，但子类调用了父类的同步方法，因此，子类的方法也就相当于同步了。

## Lock 优点

原锁为一个块的封装体，对锁的操作是隐式的，无法进行灵活的操作。到了 v1.5 将锁对象化，将隐式操作显式化，可以灵活地获取释放锁。

```
Lock lock = new ReetrantLock(); 可重入的互斥锁。
```

Lock.unLock() 要放在 `finally` 块中。

Condation 将 Object 监视方法（wait(),notify,notifyAll) 分解为截然不同的对象，以便将这些对象与任意 lock 实现组合，为每个对象提供多个等待的 set, 其中 Lock 代替了原有 synchronized 关键字的使用。condation 代替了 Ojeect 监视器方法的使用。

方法名的改变

wait －> await
notify  －> signal
notifyAll －> signalAll


## 安卓上的异步 API

### 获取线程/进程 Id

在分析多线程或多进程的时候，知道当前的在哪个线程或进程执行对于分析有很大帮助

```
Log.e("process Id: ", "" + android.os.Process.myPid())
Log.e("thread Id", "" + Thread.currentThread().id)
```

### 切换到主线程

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


## 安卓的线程

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


## 案例 

### Java DCL 为什么必须加 valatile

不加 volatile 的 DCL 会出现办初始化的对象。

1. `volatile` 关键字防止指令重排

除了双重检查外，变量还要加 `volatile` 关键字防止指令重排，这是因为 Java 的编译方式和 JVM 的运行方式导致的。

Java 的实例化过程 `INSTANCE = new Singleton6();` 在 Java 代码中仅一行代码，但是它不是一个原子操作（要么全部执行完，要么全部不执行，不能执行一半），这行代码被编译成8条汇编指令，大致做了3件事情：

1.给 Singleton6 的实例分配内存。

2.初始化 Singleton6 的构造器

3.将 INSTANCE 对象指向分配的内存空间（注意到这步完成 INSTANCE 就非null了）。

由于Java编译器允许处理器乱序执行（out-of-order），以及JDK1.5之前JMM（Java Memory Medel）中Cache、寄存器到主内存回写顺序的规定，上面的第二点和第三点的顺序是无法保证的，也就是说，执行顺序可能是1-2-3也可能是1-3-2，如果是后者，并且在3执行完毕、2未执行之前，被切换到线程二上，这时候 INSTANCE 因为已经在线程一内执行过了第三点，INSTANCE 已经是非空了，所以线程二直接拿走 INSTANCE，然后使用，然后顺理成章地报错，而且这种难以跟踪难以重现的错误估计调试上一星期都未必能找得出来。


**另一个方面来看，其实是临界区对象的访问没有完全的做到互斥访问，第一个判空在加锁之外。此时的访问对象并不能和加锁内的对象赋值形成互斥，仍然是不安全的。**
