# 对象声明周期管理

内存是系统的稀缺资源，充分利用内存可以提高系统性能；但是无节制的使用内存会导致系统性能下降，甚至系统崩溃。理想情况下我们应该在内存资源充足时利用内存来提高程序性能，在内存不足时及时释放内存资源。想象以下场景：

- 缓存场景：我们希望在内存足够时尽量多缓存数据以提高性能。后继系统内存不足时及时的缩小缓存池，让出内存以避免真正需要内存的地方无法分配对象而导致 OOM。内存充足时尽量命中，内存紧张时可回收，降低 OOM 风险。该如何让这种弹性的内存管理方便实现？我们自己实现是不是需要一套复

- 感知对象的回收周期：Java 是可以引用 Native 资源的，早期 Java 使用类中自带的 finalize()方法。这个方法是在垃圾回收器准备回收对象之前调用的，用来执行一些清理 native 资源操作。然而由于 finalize() 方法的执行时机不可预测，且可能导致性能问题，它在Java 9中被标记为废弃，并在后续版本中被移除。该如何感知对象的回收清理资源？

- 临时对象场景：使用的临时对象，在用完之后应该立即回收，避免占用过多内存。

为了精细化控制对象的声明周期，实现更细粒度的内存策略。Java 1.2 引入引用类型，它把对象的引用强度划分了明确的等级，可以让开发者和 GC 协作，主动控制对象的回收时机
实现对内存使用的管理。ThreadLocal、本地缓存、堆外内存管理、OOM兜底方案都可以通过引用类型来实现。

## Java 引用类型

| 引用类型 | 回收时机 | `get()` 行为 | 典型用途 | 风险与注意点 |
| ------- | ------- | ----------- | ------- | ----------- |
| 强引用（StrongReference） | 只要强引用链可达，GC 不会回收。 | 返回真实对象。 | 业务核心对象、必须存活的数据。 | 持有不当容易导致内存泄漏。 |
| 软引用（SoftReference） | 内存紧张时会被回收（通常在抛出 OOM 前）。 | 未回收前返回对象，回收后为 `null`。 | 内存敏感缓存。 | 回收时机受 GC 策略影响，不适合做强一致缓存。 |
| 弱引用（WeakReference） | 只要发生 GC 且对象仅被弱引用可达，就会被回收。 | 回收前可取到对象，回收后为 `null`。 | `WeakHashMap`、避免键或监听对象被长时间持有。 | 生命周期很短，不能依赖其长期存活。 |
| 虚引用（PhantomReference） | 对象即将被回收时入队（需配合 `ReferenceQueue`）。 | 永远返回 `null`。 | 跟踪回收、对象销毁后清理堆外资源。 | 不能通过它访问对象本体，必须依赖队列机制。 |

## 使用示例

### 1) 强引用（默认引用）

变量引用的作用域结束（栈内创建的变量），或者手动将对象设置为 null 时，才会释放强引用。
```java
Object strong = new Object();
// strong 持有期间，对象不会被 GC 回收。
strong = null; // 手动将对象设置为 null 时，才会释放强引用。或者等到变量引用的作用域结束。
```


只要对象引用处于GC Roots可达的链路中，GC永远不会回收该对象。哪怕JVM内存严重不足，抛出OOM异常，也不会回收存活的强引用对象。

GCRoots包括：
- 虚拟机栈（线程栈帧中的局部变量）引用的对象。
- 方法区中类静态属性引用的对象。
- 方法区中常量引用的对象。
- native 对象通过 JNI 引用的对象。
- 正在被执行的 native 方法引用的对象。

强引用是内存泄漏的罪魁祸首，长生命周期的对象（比如静态集合、单例、线程池核心线程），持有业务中已无用的短生命周期对象的强引用，导致其永远无法被回收，最终引发OOM。

其它内存泄漏的原因包括：
- native 程序内存泄漏
    - 虚拟机可以通过 JNI 调用原生（native）程序，这部分内存不归 JVM 管理，如果合理的管理会导致内存泄漏。
    - DirectByteBuffer 分配和管理堆外内存（堆外内存是在 JVM 视角的叫法，其本质是在 native 程序的堆中申请内存。DirectByteBuffer对象本身存储在JVM堆内，但其持有的数据存储在‌JVM堆外的 Native 内存中‌）。会导致物理内存耗尽，尽管堆空间（Java 堆）看起来还很空闲。

- 资源
TODO：补充其他内存泄漏的原因


### 2) 软引用（内存敏感缓存）

```java
import java.lang.ref.SoftReference;

SoftReference<byte[]> imageCache = new SoftReference<>(new byte[1024 * 1024]);
byte[] data = imageCache.get();
if (data == null) {
    // 说明缓存已被回收，需要重新加载
    data = new byte[1024 * 1024];
    imageCache = new SoftReference<>(data);
}
```

**JVM底层优化**：JVM不会无脑回收软引用，会根据软引用的创建时间、最近访问时间、当前堆内存使用率，动态决定回收优先级：空闲时间越长、内存越紧张，越先被回收。可通过-XX:SoftRefLRUPolicyMSPerMB参数调整回收策略（默认值1000，代表每MB空闲堆内存，软引用保留1000ms）。

**核心适用场景**：内存敏感型的本地缓存，比如图片缓存、大数据查询结果缓存、非核心接口响应缓存。内存足够时保留缓存提升性能，内存不足时自动清理兜底，从根源避免OOM。



### 3) 弱引用（避免对象被容器强持有）

```java
import java.util.Map;
import java.util.WeakHashMap;

Map<Object, String> map = new WeakHashMap<>();
Object key = new Object();
map.put(key, "value");

key = null; // 不再持有强引用
System.gc(); // 仅用于演示，生产代码不依赖该调用
// 后续某次 GC 后，该 entry 可能被自动清理
```

**核心GC规则**: 弱引用不被认为是对象的“有效引用”，不会对对象的生命周期造成影响。如果一个对象只被弱引用指向，那么在垃圾回收的时候，这个对象可能会被回收掉。弱引用完全不会阻止GC回收对象，其生命周期最长只能到下一次GC触发。

软引用是“内存不足才回收”，适合长期存活的缓存；弱引用是“GC来了就回收”，适合临时的映射关系，核心目标是避免内存泄漏。

应用场景： Java 线程本地数据的实现。

Java 的线程本地数据给每个线程分配一个独立的内存空间，具体的实现 ThreadLocalMap。 Map 中的 Key 是 WeakReference 的 ThreadLocal 对象。

```Java
static class ThreadLocalMap {

    static class Entry extends WeakReference<ThreadLocal<?>> {
        /** The value associated with this ThreadLocal. */
        Object value;

        Entry(ThreadLocal<?> k, Object v) {
            super(k);
            value = v;
        }
    }
}
```

**普通的 Map 也能在 remove 时清理 key 和 value 的引用，为什么这里 Key 设计成弱引用？**

之所以这么设计是为了防止忘记调用 remove() 方法导致内存泄漏。

如果 ThreadLocalMap 的 Key 是强引用，当 ThreadLocal 局部变量引用丢失后，忘了调用 remove()。线程内部的 Map 依然强引用着这个 ThreadLocal 对象， 导致 Value 无法被回收而内存泄漏。

使用弱引用之后，当 ThreadLocal 的强引用丢失之后，GC 之后再通过弱引用的 get() 方法获取到 null，此时我们便能知道没有引用再能获取这个 value 了，从而可以清除 value 的引用从而释放 value 的内存。

具体的时机就是：再次调用该线程的 ThreadLocal 的 get() 或 set() 方法时。

- get: 如果直接命中（Hash 一次就中）则不清理；，否则才会顺便清理路上的过期 Key。
- set: 无论如何都会尝试清理一部分（cleanSomeSlots），如果内存快满了则全表清理（rehash）。

既然有“自动清理”，为什么还要强调手动 remove(),否则就会**内存泄漏**？

- 清理不及时：自动清理只有在调用 get/set 时才会触发。如果你的线程存了大数据后进入了长时间的等待（或者后续不再调用该 ThreadLocal），那个 [null, Value] 就会一直占着坑。
- 无法保证触发：如果**线程池里**的线程处理完任务后一直空闲，或者处理的其它任务不不再使用线程本地数据处理逻辑了，自动清理逻辑就永远不会执行。

Java 设计者也知道手动 remove() 是最优解，但他们不能保证每个程序员都记得写 finally { remove(); }。弱引用 Key 是为了在程序员忘记清理时，提供一种“兜底补偿机制”，让 JVM 能够识别并尝试回收那些已经无用的数据。如果不这样设计，ThreadLocal 将会成为 Java 中最危险、最容易瞬间撑爆内存的组件。


**软引用可以判断对象是否还有强引用，从而可以删除何其关联的对象。** 用到 ThreadLocalMap 这里就是 Key 的引用没有了之后，就可以找机会清理 Value 了。


### 4) 虚引用（配合队列感知回收）

虚引用 get()永远返回null，无法通过 get() 方法获取到被包装的对象——哪怕对象还存活。

必须配合引用队列 ReferenceQueue使用，当对象被GC完全回收、内存释放之后，JVM会把对应的虚引用对象（注意是引用对象，例如上面的代码是 PhantomReference phantom， 而不是 Object）加入到绑定的引用队列中，给开发者发送一个100%可靠的“对象已回收”通知。

```java
import java.lang.ref.PhantomReference;
import java.lang.ref.Reference;
import java.lang.ref.ReferenceQueue;

ReferenceQueue<Object> queue = new ReferenceQueue<>();
Object target = new Object();
PhantomReference<Object> phantom = new PhantomReference<>(target, queue);

target = null; // 移除强引用
System.gc();   // 仅用于演示

Reference<?> ref = queue.poll(); // 返回的是 ReferenceQueue 对象，而不是原始对象本身。
if (ref == phantom) {
    // target 已进入可回收后的通知阶段，可执行关联资源清理。例如 native 内存、文件、Socket 等。
    release some resources
}
```

**与finalize()的核心区别**：finalize()方法可以感知对象即将被回收，但执行时间不确定，甚至可能复活对象，完全不可靠，JDK9已被标记为过时；而虚引用的入队，代表对象已经被完全回收，内存已经释放，是Java中唯一可靠的回收跟踪机制。

核心应用场景：

- **堆外内存自动释放**：这是虚引用最核心的应用。JDK NIO的DirectByteBuffer，就是通过虚引用的子类Cleaner实现堆外内存释放。DirectByteBuffer本身在堆内，却持有堆外内存的地址，当它被GC回收后，Cleaner会被加入引用队列，同步执行堆外内存的释放逻辑，避免堆外内存泄漏。
- **资源释放兜底**：文件句柄、Socket连接、数据库连接的兜底释放，当业务对象被回收时，确保对应的资源被关闭。
- **GC监控与调优**：通过虚引用跟踪对象的回收情况，统计对象生命周期、GC频率，定位内存泄漏问题。
GC监控与调优：通过虚引用跟踪对象的回收情况，统计对象生命周期、GC频率，定位内存泄漏问题。

## finalize 代替

### try-with-resources

用于确保在使用完资源（如文件流、数据库连接、网络套接字等）后自动关闭它们，避免资源泄漏。JDK 9 中被标记为过时，推荐使用虚引用代替。Java 提供了 AutoCloseable 接口。

1. 必须实现 java.lang.AutoCloseable 接口（或其子接口 java.io.Closeable）的类
2. 在 try-with-resources 语句中自动关闭资源

```Java
try (ResourceType resource = new ResourceType()) {
    // 使用资源的代码
} catch (ExceptionType e) {
    // 异常处理
}
```

✅ ‌自动关闭‌：无论是否发生异常，资源都会在 try 块结束时自动关闭。
✅ ‌代码简洁‌：无需手动编写 finally 块调用 close()。
✅ ‌异常安全‌：若 try 块和 close() 都抛出异常，try 块的异常为主异常，close() 的异常被抑制，可通过 e.getSuppressed() 获取。

资源变量在 try 块内‌不能重新赋值‌（隐式 final）。
多资源依赖时，‌声明顺序影响关闭顺序‌，应确保依赖资源最后声明（如先声明底层流，再包装流）。

### Cleaner

java.lang.ref.Cleaner 和 java.lang.ref.Cleanable 是 Java 9 引入的 Object.finalize() 的现代替代方案。Cleaner 的底层实现是一个“虚引用（PhantomReference） + 引用队列（ReferenceQueue） + 守护线程”的闭环系统。

当一个对象不再被引用，自动清理其持有的资源。

```Java
import java.lang.ref.Cleaner;

public class MyResource implements AutoCloseable {
    // 1. 创建一个静态 Cleaner（全局或每个类一个即可）
    private static final Cleaner CLEANER = Cleaner.create();

    // 2. 定义清理动作：必须是静态类，不能引用 MyResource 的 'this'
    private static class State implements Runnable {
        private final long nativePtr; // 假设是 Native 指针

        State(long ptr) { this.nativePtr = ptr; }

        @Override
        public void run() {
            // 这里编写具体的清理逻辑（释放内存、关闭连接等）
            System.out.println("正在释放 Native 内存: " + nativePtr);
        }
    }

    private final State state;
    private final Cleaner.Cleanable cleanable;

    public MyResource(long ptr) {
        this.state = new State(ptr);
        // 3. 注册对象及其清理动作
        this.cleanable = CLEANER.register(this, state);
    }

    @Override
    public void close() {
        // 4. 手动触发清理逻辑（通常在 try-with-resources 中调用）
        cleanable.clean();
    }
}
```

**防止对象复活**：在 finalize() 中，你可以通过 this 把对象重新赋值给某个静态变量让它“复活”。而 Cleaner 的清理逻辑在独立类中，拿不到原对象的引用，彻底杜绝了复活可能。

**性能更优**：finalize() 会显著拖慢 GC 速度，而 Cleaner 机制由专门的后台线程处理，对 GC 核心流程影响较小。

**确定性更高**：通过 Cleanable.clean()，你可以手动、即时地触发清理，且保证逻辑只跑一遍。

**安全兜底**：AutoCloseable 用在释放时机确定的场景，开发者主动释放。而大型项目，特别是多线程场景，资源的释放时机不是特别明确，确保在所有引用都失效后，资源被释放。Cleaner 通常作为 AutoCloseable 接口的补充。如果用户忘记调用 close()，Cleaner 会在对象被 GC 时触发清理逻辑。

**1. 只用 Cleaner（不推荐）**

如果你只注册了 Cleaner 而不实现 AutoCloseable：
后果：资源释放的延迟非常高。必须等到 JVM 判定对象死亡、执行 GC、后台线程被调度后，资源才会释放。
代价：如果是文件句柄或大块 Native 内存，可能会在 GC 触发前就因为资源耗尽导致系统崩溃。

**2. 只用 AutoCloseable（有风险）**

如果你只实现 close() 方法：
后果：万一调用者（其他程序员）忘了写 try-with-resources，或者没手动调 close()，那你的资源就永久泄漏了（除非进程退出）。

一句话：Cleaner + AutoCloseable 黄金组合， AutoCloseable 决定了程序的性能和及时性，而 Cleaner 决定了程序的健壮性和容错性。

多用在框架、三方库中，预防性兜底。万一开发者忘了调用 close()，当对象被 GC 回收时，由专门的后台线程来执行清理。

## 三、引用体系的核心配套：引用队列（ReferenceQueue）

很多开发者使用软/弱/虚引用时，只关注被包装的对象，却忽略了引用队列，这是导致内存泄漏的核心原因。

引用队列的核心作用：当被包装的对象被GC回收后，对应的Reference对象（软/弱/虚引用对象本身）会被JVM自动加入到绑定的引用队列中。开发者可以通过轮询队列，获取这些已经失效的Reference对象，然后清理它们，避免Reference对象本身的内存堆积。

**核心规则**：

- 虚引用必须配合引用队列使用，否则没有任何意义；
- 软/弱引用推荐配合引用队列使用，避免无效引用对象的内存泄漏；
- 引用队列提供remove()（阻塞等待）和poll()（非阻塞轮询）两种方式获取失效引用。

主流框架的底层实现，都离不开引用队列：WeakHashMap通过引用队列清理无效Entry，ThreadLocalMap的过期Entry清理逻辑，本质也是引用队列的设计思想。


## 四、引用体系的底层实现原理

**1. Reference对象的状态流转**
每个Reference对象都有4个核心状态，JVM通过状态流转控制整个引用体系的运转：

- Active：活跃状态，引用的对象还存活，JVM持续监控其可达性；
- Pending：待入队状态，对象已被GC判定为不可达，等待ReferenceHandler线程处理；
- Enqueued：已入队状态，引用对象已被加入引用队列，等待开发者处理；
- Inactive：失效状态，引用对象已被处理，生命周期结束。

**2. ReferenceHandler守护线程**

JVM启动时，会创建一个最高优先级的守护线程ReferenceHandler，它的唯一工作，就是循环处理Pending队列中的Reference对象，将它们加入到对应的引用队列中。这个线程是整个引用体系的运转核心，所有引用的入队，都由这个线程完成。

**3. GC的处理逻辑**

GC标记阶段，会遍历所有的Reference对象，判断被包装的对象是否有强引用链可达，再根据引用类型执行不同的处理：

- 弱引用：立即标记为不可达，加入Pending队列；
- 软引用：根据内存情况和LRU策略，决定是否标记为不可达；
- 虚引用：等待对象被完全回收后，加入Pending队列；

GC清理阶段，会回收被标记的对象，同时通知ReferenceHandler线程处理Pending队列。

## 五、核心认知误区与生产环境最佳实践

**常见认知误区**

1. **误区1：软引用和弱引用没有区别**

    **真相**：二者回收规则天差地别，软引用是内存不足才回收，适合长期缓存；弱引用是GC来了就回收，适合临时映射，用错场景会导致缓存频繁失效、内存泄漏**

    **真相**：弱引用只能避免key的内存泄漏，如果value是强引用且未被清理，依然会导致内存泄漏，最典型的就是ThreadLocal的value泄漏问题。

2. **误区2：finalize()比虚引用更适合做资源释放**

    **真相**：finalize()执行时间不确定，可能复活对象，还会导致GC效率下降，早已被标记为过时，虚引用是唯一可靠的回收跟踪方案。

3. **误区3：所有缓存都应该用软/弱引用实现**

    **真相**：软/弱引用的回收时机不可控，核心业务缓存应使用Caffeine等专业缓存框架，配置主动淘汰策略，软/弱引用仅适合作为内存兜底方案。


## 生产环境最佳实践

1. **强引用最小化生命周期**：尽量使用局部变量，避免静态集合、单例持有无用对象，从根源避免内存泄漏。
2. **缓存场景精准选型**：核心业务缓存用专业缓存框架，非核心大内存缓存用软引用做内存兜底。
3. **非强引用必须配合清理逻辑**：使用软/弱/虚引用时，必须配合引用队列，定期清理无效引用对象，避免内存堆积。
4. **堆外内存必须用虚引用兜底**：业务中使用堆外内存时，必须通过虚引用实现回收后的释放逻辑，避免堆外内存泄漏。
5. **永远不要重写finalize()方法**：所有资源释放优先使用try-with-resources语法，配合虚引用做兜底。

## 参考资料

本篇文章完全是对 https://developer.aliyun.com/article/1716804 的备份和补充。防止原文找不到。