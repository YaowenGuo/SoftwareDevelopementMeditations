# 06 实战篇：堆策略、调优与内存排查

> 目标：把前五篇的原理落到手上。搞清楚 ART 堆是怎么「自己长大又自己收缩」的、前后台为什么用不同策略、OOM 和系统级 Low Memory Killer 的区别，以及一套「先分类、再定位、后验证」的内存排查流程和工具。

承接全系列：[01](01_architecture_overview.md) 内存版图 → [02](02_heap_and_spaces.md) Space → [03](03_allocation.md) 分配 → [04](04_gc_principles.md) 原理 → [05](05_gc_collectors.md) 收集器。本篇是收尾的「怎么用」。系统层的 [OOM](../../oom.md) 与 [OOM Killer](../../oom_killer.md) 已有专门笔记，这里侧重「ART 堆自身」的调与查。

---

## What：ART 堆不是固定大小，它会「呼吸」

初学者常以为「堆就是一个固定上限」。实际上 ART 堆的大小是**动态的**——每次 GC 后，ART 会根据「当前活了多少」重新决定「下次让堆长到多大再触发 GC」。这套逻辑叫**堆增长策略**，核心是一个目标利用率。

```mermaid
graph TD
    GC["一次 GC 结束"] --> LIVE["算出存活量 live"]
    LIVE --> TARGET["按目标利用率算下次触发阈值<br/>target = live / TargetUtilization"]
    TARGET --> CLAMP["夹在 [最小堆, 最大堆] 之间<br/>(growth limit)"]
    CLAMP --> WAIT["应用继续分配, 用量涨到 target"]
    WAIT --> GC

    classDef k fill:#dae8fc,stroke:#6c8ebf;
    class TARGET,CLAMP k;
```

几个关键参数（都是 `gc::Heap` 的字段 / 系统属性）：

| 概念 | 含义 | 对应 |
|---|---|---|
| **Target Utilization** | 目标利用率，默认约 0.5–0.75。GC 后让「存活/堆容量」维持在这个比例 | 比例越低→堆留白越多→GC 越少但更费内存 |
| **Growth Limit** | 单个 App 允许的堆增长上限（`dalvik.vm.heapgrowthlimit`） | 到顶还不够 → OOM |
| **Heap Max Size** | 硬上限（`dalvik.vm.heapsize`） | 大堆应用（`largeHeap=true`）用它 |
| **Min Free / Max Free** | GC 后保留的最小/最大空闲量，给增长留缓冲 | 平滑「呼吸」幅度 |

一句话：**堆用量在「触发 GC」和「GC 后回落」之间来回波动，像呼吸；目标利用率决定呼吸的深浅——留白多则省 CPU 费内存，留白少则省内存费 CPU。**

```cpp
// 源码：art/runtime/gc/heap.h（只看相关字段语义）
class Heap {
  double target_utilization_;      // 目标利用率
  size_t growth_limit_;            // 堆增长上限
  size_t max_allowed_footprint_;   // 当前允许的堆足迹（下次 GC 阈值）
  size_t min_free_, max_free_;     // GC 后保留空闲的上下限
};
```

> 阈值（`concurrent_start_bytes_` / `max_allowed_footprint_`）就在这里由 `GrowForUtilization` 设下。但阈值只是一个数字——**由谁盯着它、命中后哪段代码扣扳机**，见下一节。

---

## How：GC 的触发时机与代码路径——阈值定好了，谁来扣扳机

开头「堆会呼吸」一节算出了「下次堆长到多大就触发 GC」，但阈值只是一个数字——**由谁盯着它、命中之后哪段代码把 GC 发起来、又发给哪个线程去跑**，才是这一节要补的另一半。先看 ART 到底为哪几种「因」（GcCause）触发 GC：

| 触发因（GcCause） | 命中条件 | 派发方式 | 去哪看 |
|---|---|---|---|
| **达并发阈值** | 分配后 `已用字节 ≥ concurrent_start_bytes_` | **异步**，甩给守护线程，App 不停 | 本节 |
| **分配要不到内存**（`GC_FOR_ALLOC`） | 慢路径向 Space 要内存失败 | **同步**，就在当前线程阻塞跑 | [03 篇](03_allocation.md) |
| **显式**（`Explicit`） | 代码调 `System.gc()` | 被动触发，打乱自适应节奏 | [05 篇](05_gc_collectors.md) 触发表 |
| **前后台切换**（`CollectorTransition`） | App 退到后台，切省内存策略 | 异步 | 下一节 |
| **native 压力**（`NativeAlloc`） | native 分配累计到阈值 | 异步 | [05 篇](05_gc_collectors.md) |

> 这张表和 [05 篇](05_gc_collectors.md) 的「触发类型」表是**两个角度**：那张教你**从 logcat 关键字反推**发生了什么，这张讲**代码里哪段逻辑扣的扳机**。排查线上问题用 05 的，读源码理解机制用这张。

### 触发代码：阈值检查就藏在分配快路径的末尾

并发 GC 的扳机不在什么定时器里，而在**每次分配成功之后**顺手比一下阈值——这段检查紧贴 [03 篇](03_allocation.md) TLAB 快路径的尾巴：

```cpp
// 源码：art/runtime/gc/heap.cc(语义示意，省略无关参数)
inline void Heap::CheckConcurrentGCForJava(Thread* self,
                                           size_t new_num_bytes_allocated,
                                           ObjPtr<mirror::Object>* obj) {
  // new_num_bytes_allocated：本次分配后，堆里已用的总字节
  if (new_num_bytes_allocated >= concurrent_start_bytes_) {  // 命中并发触发线
    RequestConcurrentGCAndSaveObject(self, /*force_full=*/false, obj);
    // ↑ 不在这里跑 GC，只是「请求」一次，把活儿丢给守护线程
  }
}
```

- `concurrent_start_bytes_` 正是开头呼吸那节里 `GrowForUtilization` 在上一次 GC 收尾时设下的那条线——**呼吸负责设阈值、这里负责比阈值**，指的是同一个字段。它比真正的「装满线」`max_allowed_footprint_` 略低，留出提前量，好让并发 GC 在堆被填满**之前**就开跑，避免退化成同步阻塞的 `GC_FOR_ALLOC`。
- 这段检查处在**最热的分配路径**上，所以只做一次整数比较，绝不在此处真正回收——回收的活儿被「请求」出去了。请求之后发生什么，就是下面这张时序图。

### 代码时序图：从「阈值命中」到「GC 真正跑起来」

ART 把 GC 分成**异步**和**同步**两条派发路，同一次 `new` 视内存松紧走其一：

```mermaid
sequenceDiagram
    participant APP as 应用线程(正在 new)
    participant HEAP as Heap
    participant TP as GC守护线程(HeapTaskDaemon)
    participant COL as 收集器 collector

    Note over APP,COL: 路径一 异步并发GC(达阈值, App 不阻塞)
    APP->>HEAP: 分配成功, CheckConcurrentGCForJava
    HEAP->>HEAP: 已用字节 ≥ concurrent_start_bytes_ ?
    HEAP->>TP: RequestConcurrentGCAndSaveObject (入任务队列)
    APP-->>APP: 立刻拿到新对象继续跑, 不等 GC
    TP->>HEAP: 取出任务 → Heap::ConcurrentGC
    HEAP->>HEAP: CollectGarbageInternal (选 GcType)
    HEAP->>COL: collector RunPhases() (进入 05 篇五阶段)
    COL-->>HEAP: 回收完成
    HEAP->>HEAP: GrowForUtilization() 重设阈值, 闭环回呼吸

    Note over APP,COL: 路径二 同步GC_FOR_ALLOC(要不到内存, App 阻塞)
    APP->>HEAP: 慢路径分配失败 → AllocateInternalWithGc
    HEAP->>HEAP: 就地 CollectGarbageInternal (当前线程)
    HEAP->>COL: collector RunPhases()
    COL-->>HEAP: 回收完成, 腾出空间
    HEAP-->>APP: 重试分配, 成功才返回 (全程被阻塞)
```

两条路的分水岭就一句话：**阈值是「提前预警」，异步补；真装满了是「当场断供」，只能同步堵着等。** 但注意它们最终都汇入同一个 `Heap::CollectGarbageInternal`——这是所有 GC 的总闸，[05 篇](05_gc_collectors.md) 的 `RunPhases()` 就在它内部被调起。而它收尾时又调一次 `GrowForUtilization` 重设 `concurrent_start_bytes_`，**正好闭环回开头的呼吸**：这就是「堆呼吸」在代码里跑完整的一圈。

### 对着 AOSP 读：关键方法地图

想顺着源码走一遍，`art/runtime/gc/heap.cc` 里这几个入口是骨架：

| 方法 | 职责 | 属于哪条路 |
|---|---|---|
| `CheckConcurrentGCForJava` | 分配后比阈值，命中就请求并发 GC | 异步·触发点 |
| `RequestConcurrentGCAndSaveObject` | 把 `ConcurrentGCTask` 丢进 `HeapTaskDaemon` 队列 | 异步·派发 |
| `ConcurrentGC` | 守护线程取到任务后执行的任务体 | 异步·执行 |
| `AllocateInternalWithGc` | 分配失败时就地循环触发（GcType 递增）的 GC | 同步·GC_FOR_ALLOC |
| `CollectGarbage` | `System.gc()` 等显式入口 | Explicit |
| **`CollectGarbageInternal`** | **总闸**：所有触发因最终都汇到这里，内部调收集器 `RunPhases` | 两条路共用 |
| `GrowForUtilization` | 一次 GC 收尾：算下次足迹 + 重设 `concurrent_start_bytes_` | 闭环回呼吸 |

> 建议阅读顺序：先 `CheckConcurrentGCForJava` 看**扳机在哪** → 再 `RequestConcurrentGCAndSaveObject` + `HeapTaskDaemon` 看**怎么把活儿甩给守护线程** → 然后 `CollectGarbageInternal` 看**总闸** → 最后回 `GrowForUtilization` 看**阈值怎么被重设、闭环回呼吸**。和本系列一贯的「先入口、再派发、后闭环」同一个读法。

---

## Why：为什么前台后台要用不同策略

Android 要在有限 RAM 上同时保活一堆进程，所以 ART 对「前台可见的 App」和「退到后台的 App」区别对待——这是省内存的关键一环。

```mermaid
graph LR
    FG["前台 App<br/>用户正在看"] -->|"进入后台"| BG["后台 App"]
    FG -.策略.-> FGP["低延迟优先<br/>目标利用率偏低(留白多)<br/>GC 少, 少卡顿"]
    BG -.策略.-> BGP["省内存优先<br/>CollectorTransition<br/>触发压缩型 GC 挤掉留白<br/>把堆缩到最小"]

    classDef fg fill:#d5e8d4,stroke:#82b366;
    classDef bg fill:#ffe6cc,stroke:#d79b00;
    class FGP fg; class BGP bg;
```

- **前台**：优先响应速度，容忍多占一点内存，尽量少 GC、GC 停顿短（用户看得见卡顿）。
- **后台**：优先省内存。ART 会做一次 **CollectorTransition** / 压缩，把堆里的留白挤掉、footprint 缩到最小——因为后台 App 随时可能被系统回收，占内存越少活得越久。你在日志里看到的 `Background` / `CollectorTransition` GC（[05 篇](05_gc_collectors.md) 的触发类型表）就是这一步。
- **`onTrimMemory()`**：系统还会回调 App，示意「该主动放缓存了」——呼应 [对象生命周期管理](../lifecycle_management.md) 里软引用/缓存收缩的用法。

---

## What：OOM ≠ 被系统杀——两种「内存不够」要分清

这是最容易混淆的一点，排查方向完全不同：

```mermaid
graph TD
    subgraph JAVA["① Java 堆 OOM (应用自己的问题)"]
        A["堆涨到 Growth Limit 仍分配不出"] --> B["抛 OutOfMemoryError<br/>有 Java 栈, 可 try-catch"]
    end
    subgraph SYS["② Low Memory Killer (系统的决定)"]
        C["整机物理内存紧张"] --> D["LMK 按 oom_adj 优先级<br/>直接 SIGKILL 掉某个进程"]
        D --> E["App 无感被杀, 无异常无栈<br/>只能从系统日志看到"]
    end
    classDef j fill:#f8cecc,stroke:#b85450;
    classDef s fill:#ffe6cc,stroke:#d79b00;
    class A,B j; class C,D,E s;
```

| | Java OOM | Low Memory Killer（LMK/LMKD） |
|---|---|---|
| 谁判定 | ART，堆到上限分配失败 | 系统，整机物理内存紧张 |
| 现象 | 抛 `OutOfMemoryError`，有 Java 栈 | 进程直接被 `SIGKILL`，无异常 |
| 影响范围 | 当前 App 的 Java 堆 | 任意进程（按 `oom_adj` 优先级挑） |
| 排查方向 | 查 Java 堆泄漏/大对象 | 查整机内存 + 本进程各类内存总量 |
| 深入 | 本系列 [04](04_gc_principles.md)/[05](05_gc_collectors.md) | 见 [OOM](../../oom.md) / [OOM Killer](../../oom_killer.md) |

**关键判断**：如果崩溃日志里有 `OutOfMemoryError` + Java 栈，那是 Java 堆的问题（本系列范围）；如果 App「悄无声息就没了」、只在 `logcat` 或 `dmesg` 里看到 `lowmemorykiller` / `Killing`，那是被系统杀的，得看整机内存和本进程的 Native/Graphics 等**非 Java 部分**（[01 篇](01_architecture_overview.md) 的内存版图）。

---

## How：一套内存排查流程——先分类，再定位

排查内存问题，最忌一上来就抓 heap dump。正确顺序是**先分类（是哪块内存涨了）→ 再定位（涨的是什么对象）→ 后验证（改完真的降了吗）**。

```mermaid
graph TD
    START["内存偏高/OOM/被杀"] --> STEP1["① 分类: dumpsys meminfo<br/>看是 Java Heap / Native / Code / Graphics 哪块涨"]
    STEP1 --> J{"Java Heap 涨?"}
    J -->|是| STEP2J["② 定位: heap dump + 分析<br/>看哪类对象多、被谁 GC Root 持有"]
    J -->|否| STEP2N["② 定位: 对应工具<br/>Native→heapprofd; Graphics→GPU 工具"]
    STEP2J --> STEP3["③ 验证: 改完复测 meminfo + GC 日志"]
    STEP2N --> STEP3

    classDef s fill:#dae8fc,stroke:#6c8ebf;
    class STEP1,STEP2J,STEP2N,STEP3 s;
```

### 第一步工具：`dumpsys meminfo`（分类）

呼应 [01 篇](01_architecture_overview.md) 的内存版图，这一步只回答「**哪一块在涨**」：

```shell
adb shell dumpsys meminfo <pkg>
```

看输出里 `Java Heap` / `Native Heap` / `Code` / `Graphics` 哪个 `PSS` 最大、最异常。**这一步决定后面用哪套工具**——不同块的泄漏定位手段完全不同。

### 第二步工具（按分类分流）

| 涨的是 | 用什么定位 | 找什么 |
|---|---|---|
| **Java Heap** | Android Studio Memory Profiler / `am dumpheap` 导出 `.hprof` + MAT | 哪类对象数量异常、被哪个 GC Root 链持有不放（泄漏） |
| **Native Heap** | `heapprofd`（Perfetto 的 native 内存剖析） | 哪个 native 调用栈在持续分配不释放 |
| **全景/时间线** | **Perfetto** 系统级 trace | GC 事件、内存随时间曲线、卡顿与 GC 的关联 |
| **实时增长** | `adb logcat -s art`（[05 篇](05_gc_collectors.md) 日志读法） | GC 频率、`GC_FOR_ALLOC`、堆 footprint 变化 |

```shell
# 导出 Java 堆快照做泄漏分析
adb shell am dumpheap <pkg> /data/local/tmp/dump.hprof
adb pull /data/local/tmp/dump.hprof
# 转成 MAT/AndroidStudio 可读格式
hprof-conv dump.hprof dump-conv.hprof
```

> 自动化泄漏检测可用 LeakCanary（已有笔记 [leak_canary](../leak_canary.md)）——它本质就是用 [04 篇](04_gc_principles.md) 的可达性分析 + 弱引用（[lifecycle_management](../lifecycle_management.md)），在对象「本该被回收却仍可达」时报告泄漏链。

### 第三步：验证

改完别只看「不崩了」。回到 `dumpsys meminfo` 和 GC 日志复测：Java Heap 的 PSS 有没有真的降、`GC_FOR_ALLOC` 是不是变少了、footprint 曲线是否平稳。**没有前后对比的「修复」不算修复。**

---

## How：常用调优手段（克制使用）

调优的第一原则是**先测量再动手**，绝大多数 App 不需要动 ART 参数，优先改代码（少持有、及时释放、用对引用类型）。确需调整时：

| 手段 | 场景 | 注意 |
|---|---|---|
| `android:largeHeap="true"`（manifest） | 确实需要大堆（图像/编辑类） | 治标，滥用会挤占整机内存、更易被 LMK 盯上 |
| 减少大对象 / 复用缓冲 | 大 `Bitmap`、大数组频繁分配 | 大对象走 LOS（[03 篇](03_allocation.md)），复用比调参有效得多 |
| 用对引用类型 | 缓存、监听器 | 软/弱引用（[lifecycle_management](../lifecycle_management.md)）让 GC 能在紧张时回收缓存 |
| 响应 `onTrimMemory` | 后台主动放缓存 | 配合前后台策略，降低被杀概率 |
| 避免 `System.gc()` | —— | 手动触发常打乱 ART 的自适应节奏，通常有害无益 |

> 记住：ART 的堆策略（目标利用率、前后台切换、自适应触发）已经相当聪明。**多数「内存问题」是代码持有不当，不是 GC 不给力。** 调参是最后手段。

---

## 综合实验：完整跑一遍「分类 → 定位 → 验证」

准备一个可复现的泄漏：在测试 App 里，用一个 `static List` 不断往里塞对象且从不清空（模拟经典的静态集合泄漏）。然后：

```shell
PKG=你的测试包名

# ① 基线：先记一次 meminfo（重点抄下 Java Heap 的 PSS）
adb shell dumpsys meminfo $PKG | grep -A2 "App Summary\|Java Heap"

# ② 操作 App 触发泄漏（反复进出那个页面若干次）

# ③ 再记一次 meminfo，对比 Java Heap 是否单调上涨
adb shell dumpsys meminfo $PKG | grep -A2 "App Summary\|Java Heap"

# ④ 同时观察 GC 日志：泄漏会让存活量涨→堆频繁增长→GC 更频繁
adb logcat -s art | grep -iE "GC freed|GC_FOR_ALLOC|paused"

# ⑤ 导出堆快照定位是谁在泄漏
adb shell am dumpheap $PKG /data/local/tmp/leak.hprof
adb pull /data/local/tmp/leak.hprof
# 用 Android Studio / MAT 打开，看 static List 的持有链
```

预期观察：
- meminfo 的 `Java Heap` 随操作单调上涨、不回落；
- GC 日志里存活量（`X MB/Y MB` 的前一个数）越 GC 越大——GC 拼命跑也回收不掉，因为对象仍被 `static List`（GC Root 链，[04 篇](04_gc_principles.md)）可达；
- heap dump 里能看到那个 `static` 集合持有着一大堆本该死掉的对象。

把 `static List` 改成会清理的结构（或用弱引用），重跑上面步骤 ①–④，验证 Java Heap 回落、GC 恢复平稳——这一整套，就是内存排查的完整闭环。

---

## 课后验证

### 思考题

1. 为什么说 ART 堆会「呼吸」？目标利用率调低和调高，分别在拿什么换什么？
2. 前台和后台 App 的 GC 策略有什么不同？为什么后台要主动把堆压缩到最小？
3. `OutOfMemoryError` 和「被 Low Memory Killer 杀掉」有什么本质区别？各自应该往哪个方向排查？
4. 为什么内存排查要「先 `dumpsys meminfo` 分类，再上 heap dump」，而不是反过来？
5. 一次 GC 后存活量持续变大、GC 越来越频繁却回收不动，最可能是什么问题？怎么定位？
6. 并发 GC 和 `GC_FOR_ALLOC` 在「派发方式」和「是否阻塞应用线程」上有什么本质区别？各自由哪段代码发起？

<details>
<summary>参考答案</summary>

1. 因为堆用量在「涨到阈值触发 GC」和「GC 后回落」之间反复波动。目标利用率调低→GC 后留白多→GC 更少但更占内存（省 CPU 费内存）；调高→留白少→更省内存但 GC 更频繁（省内存费 CPU）。
2. 前台低延迟优先、少 GC 少停顿、容忍多占内存；后台省内存优先，做 CollectorTransition/压缩把留白挤掉、footprint 缩到最小。因为后台进程随时可能被系统回收，占内存越少存活越久。
3. Java OOM 是 ART 判定「堆到上限分配失败」，抛异常有 Java 栈，查 Java 堆泄漏/大对象；LMK 是系统判定整机内存紧张、按优先级直接 SIGKILL 进程，无异常无栈，要查整机内存和本进程 Native/Graphics 等非 Java 部分。
4. 因为不同内存块（Java/Native/Graphics）的定位工具完全不同，先分类才能选对工具；若直接抓 Java heap dump，而问题其实在 Native/Graphics，就白忙且被误导。
5. 典型的 Java 内存泄漏——对象仍被某 GC Root 链（如 static 集合、未注销监听器）可达，GC 无法回收，于是存活量涨、堆频繁增长、GC 频繁但徒劳。用 heap dump + MAT/Profiler 看该类对象的 GC Root 持有链定位。
6. 并发 GC 是**异步**：`CheckConcurrentGCForJava` 在分配后发现已用字节到达 `concurrent_start_bytes_`，调 `RequestConcurrentGCAndSaveObject` 把任务丢给 `HeapTaskDaemon` 守护线程，应用线程立刻拿到对象继续跑、不阻塞。`GC_FOR_ALLOC` 是**同步**：慢路径真要不到内存，`AllocateInternalWithGc` 就在当前应用线程就地调 `CollectGarbageInternal` 并阻塞等回收腾空间。前者是「提前预警、后台补」，后者是「当场断供、堵着等」，所以频繁 `GC_FOR_ALLOC` 才是坏信号。两条路最终都汇入同一个 `CollectGarbageInternal`。

</details>

### 总复习：把六篇连成一条线

试着不看文档、用一句话串起来回答：**一个 `new Object()`，从 `Runtime` 拿到 `Heap`、在某个 `Space` 里由某个分配器零售出内存，到它不可达后被某代收集器标记回收，中间发生了什么？** 能顺畅讲完这条链，你就真的吃透 ART 的内存管理了。

- 拿堆：[01 架构篇](01_architecture_overview.md)
- 选 Space：[02 分区篇](02_heap_and_spaces.md)
- 分配器零售：[03 分配篇](03_allocation.md)
- 判死（可达性/三色/屏障）：[04 GC 原理篇](04_gc_principles.md)
- 谁来收（CMS/CC/CMC）：[05 收集器演进篇](05_gc_collectors.md)
- 怎么调怎么查：本篇
