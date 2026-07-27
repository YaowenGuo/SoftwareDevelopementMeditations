# 自定义绘制

自定绘制使用 Modifier.drawBehind() 或 Modifier.drawWithContent() 来实现。

```Kotlin
// Spacer 就是一个不绘制、只占尺寸的空组件
Spacer(Modifier.size(50.dp).drawBehind { drawCircle(Color.Black) })
```

或者使用已经封装好的 Canvas 组件来实现自定义绘制。

```Kotlin
Canvas(modifier = Modifier.size(200.dp)) {
    // this: DrawScope
    drawCircle(color = Color.Red, radius = size.minDimension / 2)
    drawLine(Color.Blue, start = Offset.Zero, end = Offset(size.width, size.height))
}
```

而 Canvas 只是对 Modifier.drawBehind() 的封装。

```Kotlin
@Composable
fun Canvas(modifier: Modifier, onDraw: DrawScope.() -> Unit) = Spacer(modifier.drawBehind(onDraw))
```

## 原生 Canvas

Compose 内原生 Canvas 的使用方法
DrawScope 的 drawIntoCanvas() 在它的 block 参数上提供了一个 Compose 的 Canvas 对象。

该接口在各个平台自己实现，安卓上则是 AndroidCanvas。


https://blog.csdn.net/tmacfrank/article/details/146328845
