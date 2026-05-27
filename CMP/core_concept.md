# 核心概念


1. 状态流转与精确性能调优（State & Stability）
这是 Compose 开发者的分水岭。
-	**稳定性治理 (Stability)：**深入理解编译器如何标记 Stable 和 Immutable。学会使用 Compose Compiler Metrics 分析报告，能够手动修复 List 或第三方库对象导致的“非必要重组”。

-	**派生状态 (derivedStateOf)：**掌握如何使用它来**缓冲高频状态变更**。资深开发者知道在处理滚动偏移（Scroll Offset）或搜索过滤时，必须用它来防止主线程因过度重组而掉帧。

-	**快照系统 (Snapshot)：**理解 mutableStateOf 底层的快照机制，搞清楚为什么它能实现跨线程的观察者模式。

2. 精准副作用控制（Effect APIs）

资深开发者必须能像外科医生一样精准地控制非 UI 逻辑的触发时机。

- **效应闭环：**不仅会用 LaunchedEffect，还需深刻理解 DisposableEffect 的清理机制（用于监听器注销）和 SideEffect 的同步机制。

- **生命周期协同：**掌握 produceState 如何将外部流（如传感器数据或 Socket）安全地转换为 Compose 状态，并处理好协程的自动取消。

3. 自定义测量与绘制（Custom UI & Phases）
摆脱“堆积木”式开发，能够解决 5% 的复杂交互难题。

- **布局阶段 (MeasurePolicy)：**必须能手写 Layout。当你遇到复杂的瀑布流、环形布局或需要在测量阶段根据子项高度动态调整父项时，MeasurePolicy 是唯一的武器。

- **固有特性测量 (Intrinsic Measurements)：**理解这个概念以解决跨组件的尺寸约束矛盾，比如“让一排高度不定的卡片等高”。

- **图形层优化 (Graphics Layer)：**利用 Modifier.graphicsLayer。资深开发者知道在做旋转、平移或透明度动画时，应该用它来避开**组合 (Composition)** 和 **布局 (Layout)** 阶段，直接进入 **绘制 (Draw)** 阶段，实现 60/120fps 的丝滑体验。

4. 架构设计与底层互操作（Interop & Architecture）
在大型存量项目中，专家必须能平滑处理新旧交替。

- **MVI 与 状态提升 (State Hoisting)：**设计可预测的状态机。知道如何设计 Stateless 组件，使代码具备极高的可测试性和预览性。

- **双向通信 (Interop)：**在 AndroidView 嵌入 Compose 时，如何优雅地处理 Context 注入和生命周期同步。

- **CompositionLocal 的分寸感：**理解其作为“隐式穿参”的危险性，能准确判断何时该用它注入全局配置，何时该拒绝使用它以保持组件的纯净。



## 重组




## 稳定性 Stability


Compose 为了性能，**在执行重组时会智能的跳过没有变化的 composable，甚至可以智能的跳过任意的生命周期。**为此，Compose 需要知道类型是否发生变化才能判断能否跳过对其重组。因此 Compose 使用 `稳定性` 来区别其能够判断的类型。

- **稳定**：不可变类型，以及 Compose 可以在重组期间能够知道其值是否变化了的类型（State 类型）。

- **不稳定**：Compose 在重组期间无法知道其值是否变化了。

***Compose 使用 composable 参数的稳定性来确定它是否可以在重组期间跳过 composable***：

- **稳定参数**：如果 composable 的稳定参数没有发生变化，Compose 会跳过它。
- **不稳定参数**：如果 composable 含有不稳定参数，那么每当其父组件重组时，Compose 都会重组它。

只要有一个参数是不稳定的，这个 Composable 就不再是“可跳过（Skippable）”的。如果应用中存在大量不必要的不稳定组件、导致 Compose 总是重组它们，就可能会出现性能问题以及其他问题。这里将介绍如何提升应用的稳定性，从而改善性能与整体用户体验。

让我们以一个例子来体会稳定性：

> 稳定

下面的代码片段展示了稳定性与重组背后的基本原理。

`Contact` 类是一个不可变的 data class。因为它的所有参数都是用 `val` 关键字定义的原始类型。一旦创建了 `Contact` 实例，你就无法再修改对象属性的值；任何"修改"都会创建一个新对象。

```kotlin
data class Contact(val name: String, val number: String)
```

`ContactRow` 这个 composable 接收一个 `Contact` 类型的参数。

```kotlin
@Composable
fun ContactRow(contact: Contact, modifier: Modifier = Modifier) {
   var selected by remember { mutableStateOf(false) }

   Row(modifier) {
      ContactDetails(contact)
      ToggleButton(selected, onToggled = { selected = !selected })
   }
}
```

考虑当用户点击切换按钮、`selected` 状态发生变化时会发生什么：

1. Compose 评估是否需要重组 `ContactRow` 内部的代码。
2. 它发现 `ContactDetails` 唯一的参数是 `Contact` 类型。
3. 因为 `Contact` 是不可变的 data class，Compose 可以确定 `ContactDetails` 的所有参数都没有变化。
4. 因此，Compose 会跳过 `ContactDetails`，不对其进行重组。
5. 另一方面，`ToggleButton` 的参数已经发生了变化，Compose 会重组该组件。

> 不稳定

前面的示例使用的是不可变对象，但创建可变对象同样是可能的。请看下面的代码片段：

```kotlin
data class Contact(var name: String, var number: String)
```

由于 `Contact` 的每个参数现在都是 `var`，这个类不再是不可变的。如果它的属性发生了变化，Compose 也无法察觉，因为 Compose 只会追踪 Compose `State` 对象的变化。

Compose 会将这样的类视为不稳定的，并且不会跳过不稳定类的重组。因此，如果按这种方式定义 `Contact`，那么前一个示例中的 `ContactRow` 在每次 `selected` 变化时都会被重组。

### 稳定性类型

**稳定性是编译期决定的，不是运行时判断的。** Compose 编译器在编译时分析每个类型，打上"稳定"或"不稳定"的标记，运行时直接使用这个结论。

> 编译器的分析规则

0. 所有函数类型                        -> 稳定 
1. 基本类型 和 String                  → 稳定（不可变，equals() 天然可信）
2. 有 @Immutable 或 @Stable 注解       → 稳定（开发者手动承诺）
3. Kotlin 所有字段都稳定的 class        → 稳定（编译器递归检查每个字段）
4. Java 类                            → 不稳定（编译器不分析 Java 字节码）
5. 含有不稳定字段的类                    → 不稳定（稳定性向上传染）
6. 接口类型                            → 不稳定（实现类未知）

> 为什么有的类型是稳定的，有的不是？

- 所有不可变类型都是稳定的：基本类型、String、函数类型。

- Kotlin 类是稳定的须满足
  - 对于两个相同实例， equals 的结果将永远相同。(? 可靠吗)
  - 如果类型的公共属性发生变化，Composition 将收到通知。（State）
  - 所有公共属性类型也是稳定的。


## 稳定性的本质

Compose 对一个类型的信任程度：

稳定类型  → 信任 equals()：equals() true = 内容一定没变 → 可以跳过重组
不稳定类型 → 不信任 equals()：不敢判断内容有没有变 → 无条件重组

总结对比表

| 比较类型  | Java 实现  | Kotlin 实现  | 备注 |
|----------|-----------|-------------|------|
| 值相等 (Structural) | a.equals(b) | a == b | Kotlin 会自动处理 null 情况 |
| 引用相等 (Referential) | a == b | a === b | 判断是否为同一个内存地址 |

Kotlin 的 `==` 操作符会不是简单的调用 `equals()`，其已经处理了 null 安全的情况，两个为 null 的对象比较时会返回 true，而不是抛出 NullPointerException。

### Compose 中的实现:

了解 Compose 究竟是如何决定哪些函数可以在重组中被跳过的，这虽然不是必须的，但会很有帮助。

当 Compose 编译器处理你的代码时，它会用若干标签（tag）来标记每一个函数和类型。这些标签反映了 Compose 在重组期间将如何处理该函数或类型。

> **注意**：这些标签对于理解前面章节所描述的重组与稳定性来说不是必需的。但当你在调试稳定性问题时，它们会非常有用。

#### 函数

Compose 可以将函数标记为 **Skippable（可跳过）** 或 **Restartable（可重启）**。注意，一个函数可能被标为其中之一、两者都标，或者两者都不标：

- **Skippable**：如果编译器将一个 composable 标记为 skippable，那么当它的所有参数都与上次调用时的值相等时，Compose 就可以在重组期间跳过它。
- **Restartable**：被标记为 restartable 的 composable 充当一个"作用域（scope）"，重组可以从这里开始。换句话说，该函数可以作为状态变化后 Compose 重新执行代码进行重组的入口点。

#### 类型

Compose 会将类型标记为 **Immutable（不可变）** 或 **Stable（稳定）** 之一：

- **Immutable**：当一个类型的属性永远不会改变，并且其所有方法都是引用透明（referentially transparent）的时，Compose 会将其标记为 immutable。
  - 注意：所有原始类型都被标记为 immutable，包括 `String`、`Int` 和 `Float`。

- **Stable**：表示一个类型的属性在构造之后可以发生变化；当这些属性在运行时发生变化时，Compose 能够感知到这些变化。

> **注意**：composable 的参数不必是不可变的，Compose 也可以认为它是 skippable 的。只要 Compose 运行时能被通知到所有变化，参数也可以是可变的。对大多数类型来说，遵守这种契约都不太现实；不过，Compose 自身提供了一些满足这一契约的可变类，例如 `MutableState`、`SnapshotStateMap` 和 `SnapshotStateList`。

### 调试稳定性

如果你的应用正在重组一个参数实际上没有发生变化的 composable，首先检查它的定义中是否存在明显可变的参数。当你传入带有 `var` 属性的类型，或者属性是 `val` 但本身又使用了已知的不稳定类型时，Compose 总会重组该组件。

关于如何诊断 Compose 中复杂的稳定性问题，详见"Debug stability"指南。

### 修复稳定性问题

关于如何为你的 Compose 实现带来稳定性，详见"Fix stability issues"指南。

### 小结

总的来说，你需要注意以下几点：

- **参数（Parameters）**：Compose 会判断 composable 各个参数的稳定性，以确定哪些 composable 可以在重组中被跳过。
- **直接修复（Immediate fixes）**：如果你发现某个 composable 没有被跳过，并且这正在引起性能问题，应当首先检查显而易见的不稳定原因，例如 `var` 参数。
- **编译器报告（Compiler reports）**：你可以使用编译器报告来查看 Compose 推断出的类的稳定性。
- **集合（Collections）**：Compose 总会将集合类视为不稳定的，例如 `List`、`Set` 和 `Map`。这是因为无法保证它们是不可变的。你可以改用 Kotlinx 不可变集合，或者将你的类标注为 `@Immutable` 或 `@Stable`。
- **其他模块（Other modules）**：对于来自未运行 Compose 编译器的模块的类，Compose 总会视为不稳定。如有需要，可将这些类包装为 UI 模型类。

## 不可跳过函数


- 函数具有非 Unit 的返回类型

- 函数使用 @NonRestartableComposable 或 @NonSkippableComposable 进行注解

- 


## 强跳过模式

Kotlin 2.0.20 开始，编译器默认开启了强跳过模式。它改变了编译器的行为。

- 所有的 restartable 的 composable 都可以跳过——无论参数是否稳定；非 restartable 的 composable 仍然无法跳过

- unstable capture 的 Lambdas 是 remembered 的。 

不过比较是否变化的方式不同：

- 不稳定参数比较是否为同一实例（===）

- 稳定参数比较对象是否相等（== 既 equals() ）

如果想要某个 composable 避免强跳过，既 restartable 的 composable 是不可跳过的，可以使用 `@NonSkippableComposable` 注解。

```kotlin
@NonSkippableComposable
@Composable
fun MyNonSkippableComposable {}
```

如果想要使用对象比较而不是实例比较，仍然需要使用 `@Stable` 注解标注类。一个适用场景是：当观察 Room 作为数据源的类表时，Room 会在对下国内变化时重新生成对象。

### Lambdas 记忆化

强跳过模式下，composable 方法中的任何 Lambdas 被自动记忆。


#### 示例

为了在强跳过模式下实现 Lambdas 的记忆化，编译器会将 Lambdas 包装进 remember 调用。它使用 lambda 的 capture 作为键。

如下的实例
```Kotlin
@Composable
fun MyComposable(unstableObject: Unstable, stableObject: Stable) {
    val lambda = {
        use(unstableObject)
        use(stableObject)
    }
}
```
强敲过模式下编译后为：
```Kotlin
@Composable
fun MyComposable(unstableObject: Unstable, stableObject: Stable) {
    val lambda = remember(unstableObject, stableObject) {
        {
            use(unstableObject)
            use(stableObject)
        }
    }
}
```
跟普通 remember 调用不同、包装 lambdas 与可组合函数相同的比较规则。运行时使用实例相等性比较不稳定的键。它使用对象相等性比较稳定的键。


### 记忆化与重组

没有记忆化、重组期间 lambda 在重组期间创建新的对象，任何接受对应 lambda 作为参数的 composable 更可能发生重组。lambda 记忆化极大的增加了重组期间 composable 可跳过的数量。


> **注意：**一个常见的误解是，具有不稳定捕获的 lambda 本身是不稳定的。这是不正确的。Compose 编译器总是将 lambda 视为稳定的。然而，当禁用 Strong 跳过时，编译器不会对它们进行记忆化，并且在重新组合期间运行时会分配它们。因此，具有不稳定捕获的 lambda 会导致 Compose 不跳过可组合项，因为它们具有不相等的参数。

### 避免记忆化

如果你有一个不想记忆化的 lambda，请使用 @DontMemoize 注解。

```
val lambda = @DontMemoize {
    ...
}
```

### APK 大小


编译时，可跳过的组合式组件生成的代码比不可跳过的组合式组件更多。启用强跳过模式时，编译器会将几乎所有组合式组件标记为可跳过，并将所有 lambda 表达式包装在 remember{...} 中。因此，启用强跳过模式对应用程序 APK 大小的影响非常小。

在 Now In Android 中启用强跳过模式使 APK 大小增加了 4KB。大小的差异主要取决于之前不可跳过的组合式组件的数量，但应该相对很小。



---

## 诊断稳定性问题 Diagnose stability issues

如果你遇到由不必要或过度重组导致的性能问题，那么应当对应用的稳定性进行调试。本指南介绍了几种调试方法。

> **重要**：应当尽量避免不必要或过早的优化。在针对稳定性进行优化之前，请先确认你已经遵循了 Compose 性能方面的最佳实践（best practices）。

> **注意**：关于如何正确地度量性能，请参阅 Macrobenchmark 指南。

### Layout Inspector

Android Studio 中的 **Layout Inspector** 可以让你看到应用中哪些 composable 正在被重组。它会显示 Compose 对每个组件进行重组（recompose）或跳过（skip）的次数。

Recomposition and skips counts in the Layout Inspector（Layout Inspector 中显示的重组与跳过次数）

### Compose 编译器报告 Compose compiler reports

Compose 编译器可以输出其稳定性推断的结果，供你检查。借助这些输出，你可以确定自己的哪些 composable 是 skippable 的、哪些不是。下面的小节简要介绍如何使用这些报告，更详细的信息可以参考其技术文档。

> **警告**：仅当你确实遇到与稳定性相关的性能问题时，才应使用此方法。试图让整个 UI 都变成 skippable 是一种过早的优化，可能会在将来带来维护上的困难。

#### 配置 Setup

Compose 编译器报告默认是未启用的。你可以通过一个编译器 flag 将其启用。具体配置因项目而异，对于使用 Compose compiler gradle 插件的项目，可以在每个模块的 `build.gradle` 中添加如下内容：

```groovy
android { ... }

composeCompiler {
  reportsDestination = layout.buildDirectory.dir("compose_compiler")
  metricsDestination = layout.buildDirectory.dir("compose_compiler")
}
```

构建项目时就会生成 Compose 编译器报告。

> **重要**：务必在 release 构建上运行该功能，以确保结果准确。

#### 输出示例 Example output

`reportsDestination` 会输出三个文件。以下是 JetSnack 的示例输出：

- `<modulename>-classes.txt`：本模块中类的稳定性报告。
- `<modulename>-composables.txt`：本模块中 composable 的 restartable / skippable 情况报告。
- `<modulename>-composables.csv`：composables 报告的 CSV 版本，可以导入电子表格或用脚本处理。

> **注意**：`metricsDestination` 配置会输出关于项目中 composable 数量等的整体统计信息。

> **注意**：这些报告使用了《稳定性 Stability》指南中介绍的编译器标签。

#### Composables 报告

`composables.txt` 文件详细列出了该模块中每个 composable 函数，包括它们各个参数的稳定性，以及函数本身是否 restartable、skippable。以下是一个来自 JetSnack 的假想示例：

```
restartable skippable scheme("[androidx.compose.ui.UiComposable]") fun SnackCollection(
  stable snackCollection: SnackCollection
  stable onSnackClick: Function1<Long, Unit>
  stable modifier: Modifier? = @static Companion
  stable index: Int = @static 0
  stable highlight: Boolean = @static true
)
```

这个 `SnackCollection` composable 是完全 restartable、skippable 且稳定的。这通常是更可取的状态，但并非强制要求。

另一方面，再来看下面这个例子：

```
restartable scheme("[androidx.compose.ui.UiComposable]") fun HighlightedSnacks(
  stable index: Int
  unstable snacks: List<Snack>
  stable onSnackClick: Function1<Long, Unit>
  stable modifier: Modifier? = @static Companion
)
```

`HighlightedSnacks` 这个 composable 不是 skippable 的。Compose 在重组期间永远不会跳过它，即使它的所有参数都没有发生变化也是如此。原因在于它有一个 unstable 参数 `snacks`。

#### Classes 报告

`classes.txt` 文件包含针对该模块中类的类似报告。下面是 `Snack` 类的输出片段：

```
unstable class Snack {
  stable val id: Long
  stable val name: String
  stable val imageUrl: String
  stable val price: Long
  stable val tagline: String
  unstable val tags: Set<String>
  <runtime stability> = Unstable
}
```

作为参考，下面是 `Snack` 的定义：

```kotlin
data class Snack(
    val id: Long,
    val name: String,
    val imageUrl: String,
    val price: Long,
    val tagline: String = "",
    val tags: Set<String> = emptySet()
)
```

Compose 编译器将 `Snack` 标记为 unstable。原因在于 `tags` 参数的类型是 `Set<String>`。这是一个不可变类型——因为它不是 `MutableSet`。然而，像 `Set`、`List`、`Map` 这些标准集合类归根结底都是接口，其底层实现仍然可能是可变的。

例如，你可以写 `val set: Set<String> = mutableSetOf("foo")`。这个变量是常量、其声明类型也是不可变的，但其实际实现却是可变的。Compose 编译器只能看到声明类型，无法确定该类的不可变性，因此将 `tags` 标记为 unstable。

> **重要**：关于如何为这种不稳定的类带来稳定性，请参阅 Fix stability issues 指南。


## 修复稳定行问题

稳定性问题是类引起的，修复也是从类下手。

1. 最简单的办法就是开启启用强跳过（enable Skipping）功能 **（Kotlin 2.0.20 开始默认启用）**。对于不稳定的类，Compose 会将它们视为稳定的，并且在重组期间跳过它们。**这是一种过早的优化，可能会导致维护上的困难，因此应当谨慎使用**。

2. 


## 最佳实践

Compose 中存在一些陷阱、一些看似简单直白的代码可能会导致性能问题。

### 使用 remember 来最小化昂贵的计算


可组合函数可以运行得非常频繁，频繁到可以每帧动画运行一次。因此，你应该尽可能少地在组合函数的主体中进行计算。

一个重要的技巧是使用 remember 存储计算结果。这样，计算只运行一次，你可以在需要时获取结果。

例如一个按名字字母顺序排序的用户列表：

```Kotlin
@Composable
fun ContactList(
    contacts: List<Contact>,
    comparator: Comparator<Contact>,
    modifier: Modifier = Modifier
) {
    LazyColumn(modifier) {
        // DON’T DO THIS
        items(contacts.sortedWith(comparator)) { contact ->
            // ...
        }
    }
}
```

每次 ContactsList 被重新组合时，整个联系人列表都会重新排序——即使列表没有改变。如果用户滚动列表，每当出现新行时，Composable 都会被重新组合。

为了解决这个问题，在 LazyColumn 外部对列表进行排序，并用 remember 存储排序后的列表：

```Kotlin
@Composable
fun ContactList(
    contacts: List<Contact>,
    comparator: Comparator<Contact>,
    modifier: Modifier = Modifier
) {
    val sortedContacts = remember(contacts, comparator) {
        contacts.sortedWith(comparator)
    }

    LazyColumn(modifier) {
        items(sortedContacts) {
            // ...
        }
    }
}
```

现在，列表只在 ContactList 首次组合时排序一次。如果联系人或比较器发生变化，排序后的列表将被重新生成。否则，Composable 可以使用缓存的排序列表。

> 注意：如果可能的话，最好将计算移到可组合项之外。在这种情况下，你可能希望在其他地方对列表进行排序，比如在你的 ViewModel 中，然后将排序后的列表作为输入提供给可组合项。


### 懒布局使用 key

懒布局能够有效地重用列表项，只在必要时重新生成或重新组合它们。


例如，展示一个按修改时间排序的笔记列表，最近修改的笔记在顶部。

```Kotlin
@Composable
fun NotesList(notes: List<Note>) {
    LazyColumn {
        items(
            items = notes
        ) { note ->
            NoteRow(note)
        }
    }
}
```

用户操作导致列表中的某个项移动时，上面这段代码存在一个问题。例如底部的笔记被修改了，现在它是最近修改的笔记，它应该移动到了列表的顶部，其他所有笔记都向下移动了一个位置。

当前代码 Compose 无法识别列表中未更改的项目只是被移动了位置。解决方式是为每个列表项提供一个稳定的键可以让 Compose 避免不必要的重新组合。通过比较 Key，Compose 可以确定现在位于位置 3 的项目与之前位于位置 2 的项目是同一个。由于该列表项的数据没有改变，Compose 不需要重新组合它。

```Kotlin
@Composable
fun NotesList(notes: List<Note>) {
    LazyColumn {
        items(
            items = notes,
            key = { note ->
                // Return a stable, unique key for the note
                note.id
            }
        ) { note ->
            NoteRow(note)
        }
    }
}
```

### 使用 derivedStateOf 来限制重新组合


使用状态的一个风险是，如果状态变化迅速，你的 UI 可能会被重新组合多次，超出实际需要。例如，假设你正在显示一个可滚动的列表。你检查列表的状态，以确定列表中第一个可见的项目：

```Kotlin
val listState = rememberLazyListState()

LazyColumn(state = listState) {
    // ...
}

val showButton = listState.firstVisibleItemIndex > 0

AnimatedVisibility(visible = showButton) {
    ScrollToTopButton()
}
```

这里的问题是，如果用户滚动列表， listState 会随着用户手指的拖动而不断变化。这意味着列表会不断被重新组合。然而，实际上你不需要如此频繁地重新组合它——你不需要重新组合，直到新项目在底部变得可见。所以，这是大量的额外计算，会导致你的 UI 性能不佳。

使用派生状态的解决方案。派生状态允许你告诉 Compose 哪些状态变化实际上应该触发重组。在这种情况下，指定你关心第一个可见项变化时的状态值。当该状态值发生变化时，UI 需要重新组合，但如果用户还没有滚动到足以将新项带到顶部，则不需要重新组合。


```Kotlin
val listState = rememberLazyListState()

LazyColumn(state = listState) {
    // ...
}

val showButton by remember {
    derivedStateOf {
        listState.firstVisibleItemIndex > 0
    }
}

AnimatedVisibility(visible = showButton) {
    ScrollToTopButton()
}
```

### 尽可能推迟读取

在 Jetpack Compose 中，延迟状态读取（Deferred State Reading） 是性能优化的核心手段。其基本原理是：将状态读取的时机从“组合（Composition）阶段”推迟到“布局（Layout）阶段”或“绘制（Draw）阶段”，从而避免不必要的重组。
以下是延迟状态读取的方法分类及核心函数全列举：
#### 1. Lambda 表达式包装类（最常用）
通过将状态读取包装在 Lambda 中，使该状态在特定的阶段才被解包读取。

* Modifier.offset { IntOffset }：
* 函数：Modifier.offset(offset: Density.() -> IntOffset)
   * 原理：相比普通 offset(x, y)，Lambda 版在布局阶段读取状态。常用于跟随滚动的位移，避免滚动时整棵 UI 树重组。
* Modifier.graphicsLayer { ... }：
* 函数：Modifier.graphicsLayer(block: GraphicsLayerScope.() -> Unit)
   * 原理：在绘制阶段读取状态。用于缩放、旋转、透明度动画。
* Modifier.drawBehind { ... } / Canvas { ... }：
* 原理：在绘制阶段直接读取状态并绘图，完全跳过组合和布局阶段。
* 自定义 Layout Lambda：
* 函数：layout(width, height) { ... } 中的内容。
   * 原理：在布局阶段读取尺寸相关状态。

#### 2. 派生状态与计算缓冲类
通过中间层拦截高频变化，仅在结果变化时才让外部读取。

* derivedStateOf { ... }：
* 核心逻辑：将一个高频变化的状态（如 ListState.firstVisibleItemIndex）转换为一个低频变化的状态。
   * 延迟效果：只有当 Lambda 内部的计算结果发生变化时，才会通知外部读取者，有效减少重组次数。

#### 3. 性能优化专用读取控制类
显式控制读取时机的底层方法。

* snapshotFlow { ... }：
* 原理：将 Compose 状态转换为协程流。它会在后台收集状态变化，你可以通过流操作符（如 distinctUntilChanged）进一步延迟或过滤实际的读取响应。
* SideEffect { ... }：
* 原理：将状态读取推迟到重组成功完成后。用于将 Compose 状态同步给外部系统。

#### 4. 显式读取抑制类
主动告诉系统“现在不要记录我的读取”。

* Snapshot.withoutReadObservation { ... }：
* 原理：在块内读取状态，但不会建立“状态 -> UI”的订阅关系。这彻底延迟（或取消）了重组的发生，常用于只需要获取快照而不关注意后续变化的场景。





###  避免向后写入


在 composable 中写入状态值是非常危险的事情，如果在 composable 中同时观察了状态变化，可能导致每一帧都发生重新组合，无限循环。

```Kotlin
@Composable
fun BadComposable() {
    var count by remember { mutableIntStateOf(0) }

    // Causes recomposition on click
    Button(onClick = { count++ }, Modifier.wrapContentSize()) {
        Text("Recompose")
    }

    Text("$count")
    count++ // Backwards write, writing to state after it has been read</b>
}
```

点击按钮后，由于 Compose 会重新组合这个可组合项，看到一个过时的状态读取，因此会安排另一个重新组合，导致计数器在无限循环中迅速增加。

**Composable 应该禁止修改状态。应该在在响应事件时以 lambda 的形式写入状态，就像前面的 onClick 示例一样。**
