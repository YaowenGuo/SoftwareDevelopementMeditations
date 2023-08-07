# Jetpack Compose

解绑 UI 工具包：

google 团队每次修复一个问题或者发布新功能，老旧的设备都无法立即使用到，开发者甚至需要几年时间等待老的设备淘汰掉。

改变原有 UI 设计中的问题：
    例如，所有视图的基类 View.java 的拥有进 3W 行的代码量。
    Button 继承自 TextView, TextView 有很多功能，导致 Button 中的文字具有 TextView 具有可选中、可编辑。


    编写自定义 View 有点令人生畏，View 系统是如此复杂，想要处理好各种逻辑并提供一套优秀的 API 并不简单。
        - 各种设置
        - 需要再 attr.xml 中添加 xml 自定义属性
        - 编写一套默认主题的样式
        - 处理布局和触摸事件
    Fragment 适合于一个可替换的块，更粗粒度的方式具有声明周期的模型。
    但是应有开发随着时间推移会发生变化，有时候 View 更合适，有时候 Framgment 更合适，然而从一个抽象模型切换到另一个抽象模型带来非常高的工程成本。

[Over the last several years, the entire industry has started shifting to a declarative UI model, which greatly simplifies the engineering associated with building and updating user interfaces. ](https://developer.android.com/jetpack/compose/mental-model)

通过描述 `是什么` 而不是 `如何做` 来构建 UI.