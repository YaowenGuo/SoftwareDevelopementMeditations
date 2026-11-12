# Side Effect (效应/副作用)

> Side Effect 是指应用程序状态的改变发生在 composable 函数的作用域之外。


它既包含"函数体 {} 内的局部世界"，也包含 Compose 替这个函数维护的运行时数据（SlotTable 里属于它的槽位、它持有的 remember
  值、它读写的 State、它产出的 LayoutNode 子树）。

  ---
  为什么不能简单等同于"Kotlin 函数作用域"

  考虑这两行：

  @Composable
  fun A() {
      val list = mutableListOf<Int>()  // ① 普通局部变量
      list.add(1)                      // 改它，算 side effect 吗？

      var n by remember { mutableStateOf(0) }  // ② Compose 管的 state
      n = 1                                     // 改它，算 side effect 吗？
  }

  如果"scope = Kotlin 函数作用域"，那 ① 和 ② 都在 {} 里，应该都不算副作用。

  但实际上：

  - ① 不算 side effect：list 是栈上的局部变量，函数返回就消失了，对 app 的状态没有任何持久影响。
  - ② 也不算 side effect：虽然 n 看似改了"外部"的 State，但这个 State 是 remember 出来的，它的生命周期被 Compose 绑定到这个
  Composable 上，离开组合就回收。Compose 自己管着它。

  再看反例：

  @Composable
  fun A() {
      SomeSingleton.counter++   // 也在 {} 里，但跳出了 Compose 的视野
  }

  这行在 Kotlin 语法上也在函数作用域里，但它改的是 Compose 管不到的全局单例——这才是 side effect。

  所以判定标准不是 {}，而是：这次改动是不是只影响"Compose 替我管的东西"。

  ---
  那"scope"到底是什么的合集

  可以把它理解成下面这几样东西的并集，全都属于"Composable 函数的 scope 内"：

  ┌────────────────────────────────────────────┬─────────────────────────────────────────┬────────────────────────┐
  │                    范围                    │                  例子                   │    离开组合时会怎样    │
  ├────────────────────────────────────────────┼─────────────────────────────────────────┼────────────────────────┤
  │ 函数体内的局部变量                         │ val x = 1                               │ 跟着栈帧消失           │
  ├────────────────────────────────────────────┼─────────────────────────────────────────┼────────────────────────┤
  │ remember { ... } 出来的值                  │ val cache = remember { ... }            │ Compose 释放           │
  ├────────────────────────────────────────────┼─────────────────────────────────────────┼────────────────────────┤
  │ 用 mutableStateOf 在 remember 里建的 State │ var n by remember { mutableStateOf(0) } │ Compose 释放           │
  ├────────────────────────────────────────────┼─────────────────────────────────────────┼────────────────────────┤
  │ 产出的 UI 子树 / LayoutNode                │ Text(...)、Column { ... }               │ Compose 自动从树上摘掉 │
  ├────────────────────────────────────────────┼─────────────────────────────────────────┼────────────────────────┤
  │ 子 Composable 的调用                       │ Greeting(name)                          │ 跟着一起退出组合       │
  └────────────────────────────────────────────┴─────────────────────────────────────────┴────────────────────────┘

  这些东西的共同点："出生—使用—回收"的全过程都在 Compose 的掌控里。

  而下面这些都"逃出 scope"了，因为它们活得比这次组合更久 / 更短 / 不受 Compose 管：

  - 全局/单例变量、ViewModel 内部状态、外部容器
  - 自己启动的协程、注册的监听器
  - 文件、网络、SharedPreferences、Logcat
  - Android View、系统服务


> 由于 composable 方法生命周期的特性：1. 重组不可预测；2. composable 函数重组的执行顺序不固定；3. 重组可以被丢弃的等特性，composable 应该尽可能避免 side-effect。





然而，有时 side-effect 是必要的，例如，为了触发一次性事件，如显示一个 snackbar 或在特定状态条件下导航到另一个屏幕。这些操作应该从一个能感知 composable 生命周期的受控环境中调用。在本页中，您将学习 Jetpack Compose 提供的不同副作用 API。


然而，有时副作用是必要的，例如，为了触发一次性事件，如显示一个 snackbar 或在特定状态条件下导航到另一个屏幕。这些操作应该从一个了解组合生命周期的受控环境中调用。在本页中，您将学习 Jetpack Compose 提供的不同副作用 API。

**理想状态 Compose 应该没有 side-effect，当你需要更改应用的状态（如 Managing state 文档所述）时，你应该使用 Effect API，以便以可预测的方式执行这些副作用。**

**由于 Compose 中 effect 可能性带来的不同影响，它们可能会被轻易地过度使用。确保你在其中所做的工作是与 UI 相关的，并且不会破坏单向数据流，如管理状态文档中所述**

> Key Term: An effect is a composable function that doesn't emit UI and causes side effects to run when a composition completes.
> 关键术语：An Effect(效应)时一个不产出 UI、在重组完成时产应效应的 composable 函数。


## 副作用

副作用是指：函数的结果不只是依赖输入内容、还会因其它数据而改变。或者产生了除了输出结果以外的影响。


以加法为例子，加法的结果应该仅依赖输入的两个参数。如果结果还依赖额外的缓存、或者除了 return 外还将结果放置到缓存中，就产生了副作用。


理想情况是 composable 没有 effect，但是有时候 side-effect 是有用且必要的，例如，内存缓存、数据库、执行网络请求、文件读取、日志处理、弹出<a href="https://so.csdn.net/so/search?q=toast&amp;spm=1001.2101.3001.7020" target="_blank" class="hl hl-1" data-report-click="{&quot;spm&quot;:&quot;1001.2101.3001.7020&quot;,&quot;dest&quot;:&quot;https://so.csdn.net/so/search?q=toast&amp;spm=1001.2101.3001.7020&quot;,&quot;extra&quot;:&quot;{\&quot;searchword\&quot;:\&quot;toast\&quot;}&quot;}" data-tit="toast" data-pretit="toast">toast</a>提醒、页面跳转等等。**由于 composable 函数生命周期的特性：可以执行0次或多次，且不可预测**。为了避免这种不可预测性、控制副作用已可预测的时机运行，Compose 提供了一批副作用方法。

![Lifecycle of composable](https://developer.android.com/static/develop/ui/compose/images/lifecycle-composition.png?hl=zh-cn)

**为了在 Compose 生命周期的特定阶段执行，副作用函数得感知应用的生命周期。**


## 副作用函数

|  方法                     |   是否为 composable   |    可调用挂起函数    |       生命周期       |  适用场景                  |  举例     |
| ------------------------- | --------------------- | -------------------- | -------------------- | -------------------------- | --------- |
| LaunchedEffect            | ✔                     | ✔                    | key 变化或者组合移除 | 随状态/参数自动触发挂起调用| 数据加载  |
| rememberCoroutineScope    | ❌                    | ✔                    | 组合移除             | 用户事件触发挂起调用       | 点击按钮显示 Snackbar |
| 

## LaunchedEffect + rememberCoroutineScope


● LaunchedEffect(key)

  场景：组合中需要随状态/参数自动触发的挂起调用。
  - 进入页面或 id 变化时拉数据：LaunchedEffect(userId) { vm.load(userId) }
  - 收集一次性事件 Flow：LaunchedEffect(Unit) { vm.events.collect { showSnackbar(it) } }
  - 跑动画：LaunchedEffect(visible) { animatable.animateTo(...) }
  - 延时/超时逻辑：LaunchedEffect(Unit) { delay(3000); dismiss() }

  判断标准："当 X 变化时，自动做 Y"，Y 是挂起函数。

  rememberCoroutineScope()

  场景：用户事件触发的挂起调用。
  - 点击按钮发请求 / 显示 Snackbar：
  val scope = rememberCoroutineScope()
  Button(onClick = { scope.launch { snackbarHostState.showSnackbar(...) } })
  - LazyListState.animateScrollToItem(...) 这类需要在事件里调用的挂起 API
  - 拖拽结束后触发的异步动作

  判断标准："用户做了 X，我才去做 Y"，Y 是挂起函数。不要为此用 LaunchedEffect（会变成"进入组合就执行"）。

  produceState(initial, key)

  场景：把非 State 的异步源转成 State<T> 直接读。
  - 把 Flow 转 State（不过现在更常用 collectAsStateWithLifecycle）
  - 包装回调式 API（位置、传感器）成 State：
  val location by produceState<Location?>(null) {
      val cb = LocationCallback { value = it }
      locationClient.register(cb)
      awaitDispose { locationClient.unregister(cb) }
  }

  判断标准："我想直接c by 读一个值，但它来自异步源"。

  DisposableEffect(key)

  场景：需要注册 + 显式注销的非协程订阅。
  - 注册 LifecycleObserver / BackPressedCallback
  - 注册 BroadcastReceiver、SensorEventListener、LocationListener
  - 启停 Camera、MediaPlayer、SurfaceView 绑定
  DisposableEffect(lifecycleOwner) {
      val observer = LifecycleEventObserver { _, e -> ... }
      lifecycleOwner.lifecycle.addObserver(observer)
      onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
  }

  判断标准："必须配对：注册必有注销"，且 API 不是挂起函数。

  SideEffect { }

  场景：每次重组都要把最新 Compose 状态推给非 Compose 世界，且不需要清理。
  - 上报分析事件 / 埋点：SideEffect { analytics.setUserProp(...) }
  - 给第三方对象 setter：SideEffect { view.setData(latest) }
  - 更新外部全局变量

  判断标准："组合每成功一次就同步一次外部状态"，无需取消、无需协程。

  ---
  快速决策树：

  1. 是挂起函数吗？
    - 是 → 由谁触发？
        - 状态变化自动触发 → LaunchedEffect
      - 用户事件触发 → rememberCoroutineScope
      - 要把结果当 State 读 → produceState
    - 否 → 要不要清理？
        - 要 → DisposableEffect
      - 不要，只是同步给外部 → SideEffect

