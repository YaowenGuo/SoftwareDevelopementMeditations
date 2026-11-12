# Lifecycle of composables

当 Jetpack Compose 首次运行 composables 时，在初始 composition 期间，它会**记录**描述 UI 的 composables 调用。之后，当应用的状态发生变化时，Jetpack Compose 会安排重新组合。重新组合是指 Jetpack Compose 重新执行可能因状态变化而改变的 composables，然后更新 composition 以反映任何变化。

Composition 只能通过初始组合生成并通过重组来更新。修改 composition 的唯一方式是通过重新组合。

> 关键点：composable 的生命周期由以下事件定义：进入 composition 、被重新组合 0 次或多次，以及离开组合。

![Lifecycle of composable](https://developer.android.google.cn/static/develop/ui/compose/images/lifecycle-composition.png)

> 注意：composable 的生命周期比 View、Activity 和 Fragment 的生命周期简单。当一个 composable 需要管理或与外部资源交互时，这些资源具有更复杂的生命周期，你应该使用 Effect。

- 如果一个 composable 被多次调用，多个实例会被添加到 composition 中。每次调用在 composition 中都有自己的生命周期。(代码中的调用点，而不是运行时的调用) Composition 中的 com

> 关键术语：call site 是 composable 被调用的源代码位置。这影响它在 Composition 中的位置，从而影响 UI 树。

## Composition 中的 composable 剖析

如果在重新组合期间，一个 composable 调用了与之前组合不同的 composables，Compose 将识别出哪些 composables 被调用或未被调用，对于在两次组合中都被调用的 composables，如果它们的输入没有改变，Compose 将避免重新组合它们。

保持识别对于将 side affect 与 composable 关联起来至关重要，以便它们能够成功完成而不是在每次重组时重新启动。


### 添加额外信息帮助智能重组

多次调用 composable 会多次将其添加到 composition 中。当从同一个 call site 多次调用 composable 时，Compose 没有足够的信息来唯一标识每次对该 composable 的调用，因此除了调用点之外，还会使用执行顺序来保持实例之间的区别。这种行为有时是足够的，但在某些情况下可能会导致意外的行为。

```Kotlin
@Composable
fun MoviesScreen(movies: List<Movie>) {
    Column {
        for (movie in movies) {
            // MovieOverview composables are placed in Composition given its
            // index position in the for loop
            MovieOverview(movie)
        }
    }
}
```

在上面的例子中，Compose 使用执行顺序以及调用点来确保实例在组合中保持独立。如果在列表底部添加一个新的 movie ，Compose 可以重用已经在 Composition 中的实例，因为它们在列表中的位置没有改变，因此，对于这些实例， movie 的输入是相同的。

![](https://developer.android.google.cn/static/develop/ui/compose/images/lifecycle-newelement-bottom.png)

然而，如果 movies 列表在顶部或中间添加、删除或重新排序项目，它将导 MovieOverview 中的所有参数列表位置变法调用发生重组。这在使用 affect 时非常重要，例如 MovieOverview 使用副作用获取视频封面图，如果在 affect 进行过程中发生重新组合，affect 将被取消并重新开始。

```Kotlin
@Composable
fun MovieOverview(movie: Movie) {
    Column {
        // Side effect explained later in the docs. If MovieOverview
        // recomposes, while fetching the image is in progress,
        // it is cancelled and restarted.
        val image = loadNetworkImage(movie.url)
        MovieHeader(image)

        /* ... */
    }
}
```
![](https://developer.android.google.cn/static/develop/ui/compose/images/lifecycle-newelement-top-all-recompose.png)

通过用对关键可组合项的调用将一段代码包裹起来，并传递一个或多个值，这些值将被组合起来用于在组合中标识该实例。 key 的值不需要全局唯一，它只需要在调用可组合项的位置上是唯一的。所以在本示例中，每个 movie 都需要有一个在 movies 中唯一的 key ；如果它与其他地方的某个可组合项共享该 key ，这是可以的。

```Kotlin
@Composable
fun MoviesScreenWithKey(movies: List<Movie>) {
    Column {
        for (movie in movies) {
            key(movie.id) { // Unique ID for this movie
                MovieOverview(movie)
            }
        }
    }
}
```

有了以上内容，即使列表中的元素发生变化，Compose 也能识别对 MovieOverview 的单独调用并可以重用它们。

![](https://developer.android.google.cn/static/develop/ui/compose/images/lifecycle-newelement-top-keys.png)

一些 composable 内置支持 key 参数。例如， LazyColumn 允许在 items DSL 中指定自定义 key 。

```Kortlin
@Composable
fun MoviesScreenLazy(movies: List<Movie>) {
    LazyColumn {
        items(movies, key = { movie -> movie.id }) { movie ->
            MovieOverview(movie)
        }
    }
}
```



Compose 更新帧时会经历三个阶段：

- 组合：Compose 确定要显示的内容。它会运行可组合函数并构建界面树。
- 布局：Compose 确定界面树中每个元素的大小和位置。
- 绘制：Compose 实际渲染各个界面元素。

Compose 可以智能地跳过其中任何不需要的阶段。例如，假设单个图形元素在尺寸相同的两个图标之间切换。由于此元素不会更改大小，并且不会添加或移除界面树的任何元素，因此 Compose 可以跳过组合和布局阶段并重新绘制这一个元素。

不过，代码错误可能会导致 Compose 难以确定可以安全跳过哪些阶段，在这种情况下，Compose 会运行所有三个阶段，这可能会降低界面的速度。因此，许多性能最佳实践都旨在帮助 Compose 跳过不需要的阶段。

## Composition 移除 Composable

当 composable 方法被执行时，它被记录到 Composition 中，只有它在整个 Composable 执行中都不被调用到时，它才会被移出 Composition。移除跟屏幕是否可见、Activity 重建没有关系。

移出 Composition 的情况：


1. 控制流不再调用它

父级重组后，原本会调用某个 composable 的分支不再执行。最常见：
```Kotlin
```
if (showDialog) {
    MyDialog()   // showDialog 变 false → MyDialog 离开 Composition
}

when (page) {
    Page.A -> PageA()
    Page.B -> PageB()  // 切到 A 时，PageB 离开
}
```
```

2. 列表里的 key 不再出现

LazyColumn / LazyRow 或 key(...) { } 包裹的项，当对应的 key 在新一轮重组里不再出现时被移除。滚出可视区域的 lazy item
也会被 dispose（除非被 rememberSaveable / state holder 保留状态）。

```Kotlin
```
LazyColumn {
    items(list, key = { it.id }) { ... }   // id 从列表里消失 → 移除
}
```
```

3. 宿主销毁

- Android：承载 Composition 的 ComposeView / Activity 销毁，或 setContent 被替换。
- iOS：ComposeUIViewController 被 dismiss。
- OHOS：ComposeArkUIViewController 对应的 ArkUI 节点被销毁。

整棵 Composition 被释放，所有 DisposableEffect.onDispose / RememberObserver.onForgotten 触发。

4. movableContentOf 搬迁后旧位置

被 movableContentOf 包裹的内容，在移动到新位置时不会
dispose（这是它的卖点），但如果搬迁后没有新宿主调用它，旧位置依旧算作离开。

---
触发的回调顺序（常用来验证）：
- DisposableEffect { onDispose { ... } } 的 onDispose 块执行。
- LaunchedEffect 的协程被取消。
- remember { ... } 持有的对象如果实现了 RememberObserver，onForgotten() 被调用（onAbandoned() 则是从未进入 composition
就被丢弃的情形）。

一句话总结：当父级重组后不再调用某个 composable，或承载它的 Composition 整体销毁时，它就离开 Composition。 key
变化和条件分支是最常见的两种触发方式。



## 一般原则

- **尽可能将计算移出可组合函数。** 每当界面发生变化时，可能都需要重新运行可组合函数。您放置在可组合项中的任何代码都会重新执行，可能是针对动画的每一帧。将可组合项的代码限制为仅包含构建界面所需的代码。

- **尽可能延后读取状态。** 通过将状态读取移至可组合子项或后续阶段，您可以最大限度地减少重组或完全跳过组合阶段。为此，您可以传递 lambda 函数（而不是状态值）以适应频繁变化的状态，并在传入频繁变化的状态时优先使用基于 lambda 的修饰符。您可以在遵循最佳做法的尽可能延后读取部分中查看此方法的示例。


## 很多问题都是因为 composable 的生命周期导致的。

### 1. 避免向后写入


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


### 


# 页面生命周期

❎ androidx.lifecycle -> org.jetbrains.androidx.lifecycle 但是这个是以 Native 的页面不适合。

 各平台事件到底由什么触发（重点）

┌───────────────┬──────────────────────────────────┬──────────────────────────────────────────────────────┐
│     平台      │        ON_START / ON_STOP         │                 ON_RESUME / ON_PAUSE                 │
├───────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────┤
│ Android       │ Activity 生命周期                 │ Activity 生命周期                                      │
├───────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────┤
│ iOS           │ viewDidAppear / viewDidDisappear │ App 前后台（willEnterForeground/didEnterBackground）   │
├───────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────┤
│ Desktop       │ 窗口可见 / 最小化                   │ 窗口获得/失去焦点                                      │
├───────────────┼──────────────────────────────────┼──────────────────────────────────────────────────────┤
│ Web (Wasm/JS) │ visibilitychange                 │ 页面 focus/blur                                      │
└───────────────┴──────────────────────────────────┴──────────────────────────────────────────────────────┘

✅ androidx.navigation 多平台版（推荐，和 Android 写法完全一致）：

implementation("org.jetbrains.androidx.navigation:navigation-compose:2.8.0-alpha10")

```
NavHost(navController, startDestination = "home") {
    composable("home") {
        // 这里的 LocalLifecycleOwner 是 NavBackStackEntry，
        // push/pop 会正确触发 pause/resume
        LifecycleResumeEffect(Unit) { ... }
    }
}

Decompose：不用 Compose 的 Lifecycle，用 Essenty 的 Lifecycle，每个 Component 自带子生命周期，页面语义更准：

lifecycle.doOnResume { reportPageShow() }
```
