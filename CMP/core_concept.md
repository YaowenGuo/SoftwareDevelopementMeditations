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


## 生命周期



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

1. 基本类型 和 String                  → 稳定（不可变，equals() 天然可信）
2. 有 @Immutable 或 @Stable 注解       → 稳定（开发者手动承诺）
3. Kotlin 所有字段都稳定的 class        → 稳定（编译器递归检查每个字段）
4. Java 类                            → 不稳定（编译器不分析 Java 字节码）
5. 含有不稳定字段的类                    → 不稳定（稳定性向上传染）
6. 接口类型                            → 不稳定（实现类未知）

> 为什么有的类型是稳定的，有的不是？

## 稳定性的本质

Compose 对一个类型的信任程度：

稳定类型  → 信任 equals()：equals() true = 内容一定没变 → 可以跳过重组
不稳定类型 → 不信任 equals()：不敢判断内容有没有变 → 无条件重组

总结对比表

| 比较类型  | Java 实现  | Kotlin 实现  | 备注 |
|----------|-----------|-------------|------|
| 值相等 (Structural) | a.equals(b) | a == b | Kotlin 会自动处理 null 情况 |
| 引用相等 (Referential) | a == b | a === b | 判断是否为同一个内存地址 |

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
