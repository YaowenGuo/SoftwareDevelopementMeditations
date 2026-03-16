# Android UI

View 中嵌入 Compose: ComposeView <-- 是一个传统的 View
Compose 中嵌入 View: AndroidView <-- 是一个 Composable 函数

## View 中嵌入 Compose

安卓页面的根还是 View 体系，Compose 只在一个 ViewGroup 中封装的。

```
DecorView
└── LinearLayout (R.id.content)
    └── ComposeView (继承自ViewGroup)
        └── AndroidComposeView (继承自ViewGroup)
```

关键发现：无论你在Compose代码中写多少层嵌套（Column、Row、Box等），最终在View层级中永远只有两层(ComposeView + AndroidComposeView)。这就是为什么Compose说"不关心布局层级"——因为所有Compose组件都被解析并绘制在AndroidComposeView这个自定义View上，不会增加View树的深度。


| View | 类型 | 作用 |
|------|------|------|
| ComposeView | 传统ViewGroup | 作为传统View世界的入口，负责生命周期管理和Composition创建 |
| AndroidComposeView | 传统ViewGroup | Compose世界的根容器，持有LayoutNode树，在dispatchDraw中触发Compose的绘制 |

AndroidComposeView是真正的核心——它内部持有一个LayoutNode树（Compose的Node树），并在dispatchDraw方法中触发整个Compose UI的测量、布局和绘制：
```Kotlin
// AndroidComposeView 的绘制入口[citation:8]
override fun dispatchDraw(canvas: Canvas) {
    // 触发Compose的测量和布局
    measureAndLayout()
    
    // 触发Compose的绘制
    canvasHolder.drawInto(canvas) { 
        root.draw(this)  // root是LayoutNode树的根节点
    }
}
```


## 