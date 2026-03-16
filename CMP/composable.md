# Composable

Composable 注解的函数是一个普通函数，跟 @Async 注解的函数一样，会在编译期插入参数。

```
```
Composable 函数最终会像普通函数一样被执行，方式为：
```Kotlin
internal actual fun invokeComposable(composer: Composer, composable: @Composable () -> Unit) {
    @Suppress("UNCHECKED_CAST") val realFn = composable as Function2<Composer, Int, Unit>
    realFn(composer, 1)
}
```

Composable 函数会的设置流程为，在设置过程中完成了一系列对象的创建。

```Kotlin
ComponentActivity.setContent
ComposeView.setContent
        确保在 attachToWindow 时才执行 ComposeView.ensureCompositionCreated()
ComposeView.ensureCompositionCreated()
        resolveParentCompositionContext 确保创建了 Recomposer 请注册了生命周期感知。
AbstractComposeView.setContent
        确保创建了 AndroidComposeView
AbstractComposeView.doSetContent
       创建 WrappedComposition 并和 AndroidComposeView 绑定。
AndroidComposeView.setOnViewTreeOwnersAvailable 监听 ViewTreeOwners 才执行
CompositionImpl.setContent
CompositionImpl.composeInitial
Recomposer.composeInitial
Recomposer.composing
GapComposer.doCompose
    observeDerivedStateRecalculations() {
        invokeComposable()
    }
```

直到 observer 监听到 state 变化， observer 调用会调中会调用 invokeComposable 初始化整个 SlotTable。

SlotTable 的初始化流程是整个 Composable 函数执行的执行流程。
