# 运行时

Compose rutime 是 Compose 架构的核心，runtime 提供：
- 状态管理
- 重组（Recomposition）
- 布局（Layout）
- 绘制（Draw）

## 架构
![runtime 组件图](./runtime_img/compose-runtime-components.png)

- Recomposer 是调度器，负责调度 Composition 的重组。
- Composition 是容器，负责存储 Composable 函数的状态和结构。
- Applier 是执行器，负责将 Compose 的声明式描述转换为具体的平台 UI 对象。
- SlotTable 是蓝图，负责存储 Composable 函数的状态和结构。
- Applier 是施工队，负责将 Compose 的声明式描述转换为具体的平台 UI 对象。


### Recomposer

Recomposer 默认一个 Window 只创建一个（除非手动创建传递），最大化的复用对象，减少内存占用。例如 Compose 中包含 View, View 内再添加 Compose, 也只会共用一个 Recomposer。

但是安卓上每个 Activity、Dialog、多窗口模式（分屏/画中画）都会创建一个 Window，因此 Recomposer 会有多个。


创建:
1. 已经创建则保存在 View 的 tag 中 R.id.androidx_compose_ui_view_composition_context。 直接获取即可
2. 没有创建则创建一个，并存储在 View 的 tag 中。

```Kotlin
AbstractComposeView.ensureCompositionCreated()
View.windowRecomposer
    -> WindowRecomposerPolicy.createAndInstallWindowRecomposer(rootView)
        -> WindowRecomposerFactory.LifecycleAware.createRecomposer(rootView)
            -> View.createLifecycleAwareWindowRecomposer(rootView)
```

// 共享 Recomposer 的好处：
// 1. 统一的重组调度
val sharedRecomposer = Recomposer(Dispatchers.Main.immediate)

// 2. 批量更新：所有 Composition 的状态变化会批量处理
sharedRecomposer.scheduleRecompose(scope1)
sharedRecomposer.scheduleRecompose(scope2)
sharedRecomposer.scheduleRecompose(scope3)

// 3. 单帧内只执行一次重组循环
sharedRecomposer.runRecomposeAndApplyChanges() // 批量处理所有

// 4. 节省内存
减少对象创建，减少内存占用。


CompositionImpl （容器），但这个类不公开，反而是由 Composition() 方法创建。

Applier 是 Compose 架构中最关键的抽象层之一，它负责将 Compose 的声明式描述转换为具体的平台 UI 对象。

简单记忆：

- Compose 说"什么"（声明式描述）

- Applier 做"如何"（命令式执行）

- SlotTable 是"蓝图"

- Recomposer 是"调度员"

- Applier 是"施工队"

1. Compose不会每次修改数据都立即重组，而是会将多个数据更改智能合并，通常在一个帧绘制周期中只重组一次。
2. 

## 运行时创建(安卓为例)

```Kotlin
private fun doSetContent(
    owner: AndroidComposeView,
    parent: CompositionContext,
    content: @Composable () -> Unit,
): Composition {
    ...

    val wrapped =
        owner.view.getTag(R.id.wrapped_composition_tag) as? WrappedComposition
            ?: WrappedComposition(owner, Composition(UiApplier(owner.root), parent)).also {
                owner.view.setTag(R.id.wrapped_composition_tag, it)
            }
    wrapped.setContent(content)
    ...
    return wrapped
}
```

安卓创建了一个 WrappedComposition 来做调用层。

1. 在一个 Activity 中，通常只有一个共享的 Runtime：ComposeView 都共享同一个 Recomposer 和 CompositionContext.
只有一个 Recomposer 负责调度所有 Composition 的重组。

特殊情况：
```Kotlin
// 在一个普通的 View 中使用 ComposeView
class CustomView(context: Context) : LinearLayout(context) {
    init {
        // 这个 ComposeView 没有父 CompositionContext
        val composeView = ComposeView(context)
        addView(composeView)
        
        // 这里会创建新的 Runtime
        composeView.setContent {
            Text("独立的 ComposeView")
        }
    }
}
```
如果手动传递 parentCompositionContext → 强制共享

## Composition

Composition 是 Compose 架构中的核心概念，负责存储 Composable 函数的状态和结构。每个 CompositionView 都会创建一个 Composition。由于安卓上 Compose 和  View 被设计为可以相互嵌套的，每嵌套一个 ComposeView 就会创建一个 Composition。




[ComposeView Jetpack Compose 完全脱离 View 系统了吗?](https://www.jianshu.com/p/0ecc880980a9)