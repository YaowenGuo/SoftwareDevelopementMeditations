# Modifier

## 自定义

两种方式：

- A modifier factory：就是使用**扩展函数**来**组合**现有的 modifier。（注：这里突然叫工厂有点反应不过来，因为组合现有 modifier 只是调用了一个函数，而不是构造器创建对象，看起来不像工厂；这是因为调用的 modifer 方法本身是一个工厂，内部 return 新的对象。 ）
    - 普通工厂：没有 @Composable 注解的扩展函数。
    - 可组合：带有 @Composable 注解的扩展函数。

- A modifier element

## 工厂方法

### modifier factory

没有 @Composable 注解的扩展函数，例如 Modifier.clip() 这个修饰符就是利用 graphicsLayer 这个修饰符实现的

```Kotlin
fun Modifier.clip(shape: Shape) = graphicsLayer(shape = shape, clip = true)
```
这种方式用于定义已经经常使用的一组修改器。

```Kotlin
fun Modifier.myBackground(color: Color) = padding(16.dp)
    .clip(RoundedCornerShape(8.dp))
    .background(color)

```

### 修改器工厂

```Kotlin
fun Modifier.fade(enable: Boolean): Modifier {
    val alpha by animateFloatAsState(if (enable) 0.5f else 1.0f)
    return this then Modifier.graphicsLayer { this.alpha = alpha }
}
```

### 区别

需要在函数内部使用 Composable 的 API (state/CompositionLocal/动画)，因为 Composable 只能在 Composable 的作用域中使用。

### 特别注意

1. 警告：在创建自定义修改器时，切勿破坏修改器链。必须始终引用 this ，否则之前添加的任何修改器都会失效。你可以像在前面的例子中那样使用 this then Modifier ，或者隐式使用 return graphicsLayer { this.alpha = alpha } 。

2. Composable 工厂修改器永远不会被跳过，因为那些有返回值的组合函数是无法被跳过的。这意味着你的修改器函数会在每次重组时被调用，如果这种重组频繁发生的话，可能会比较耗费性能。

3. 就像所有可组合的函数一样，一个可组合的工厂修饰符也必须从组合体内被调用。这限制了该修饰符可以被提升到的位置，因为它永远无法脱离组合体而被提升。相比之下，非可组合的工厂修饰符则可以脱离可组合的函数被提升，这样就能更方便地复用，并提高性能。

## Modifier.Node 实现自定义修改器行为