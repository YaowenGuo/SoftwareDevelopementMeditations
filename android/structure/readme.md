# 架构设计

最好的架构不是分层最多的，而是能清晰分离职责，同时又足够简单、让团队能轻松理解的。


## MVC: Model - View - Controller

Model： 负责管理业务数据逻辑，如网络请求、数据库处理；
View： Layout XML 文件；

Controller: 负责处理表现逻辑。有的文章说是 Activity/Controller 承担，有的说是子单独的 Controller 类承担。显然是架构刚刚兴起、大家的共识都没有达成统一。但核心的区别是，Controller 直接持有 View 和 Model 的引用，而不是通过接口回调。这造成了 MVC 的缺点：

- Controller 支持持有 View 和 Model 的引用，导致分离不够，难以测试。
- View 和 Controller 的职责不明确，Activity/Fragment 往往同时承担了 View 和 Controller 的职责，Activity 代码臃肿，难以维护。


## MVP: Model - View - Presenter

View 和 Presenter 中间会定义一个协议接口 Contract，这个接口会约定 View 如何向 Presenter 发指令和 Presenter 如何 Callback 给 View。这样的架构里 Activity 不再有表现逻辑的部分，Activity 作为 View 的角色只处理和 UI 有关的事情。但还是存在一些缺点：

- 双向依赖： View 和 Presenter 是双向依赖的，修改需要大量的接口页跟着修改。
- 协议接口类膨胀： View 层和 Presenter 层的交互需要定义接口方法，当交互非常复杂时，需要定义很多接口方法和回调方法，也不好维护。
- 数据更新时，会调用大量 View 接口方法，代码稍显繁琐





## MVVM: Model - View - ViewModel

ViewModel： 存储视图状态，负责处理表现逻辑，并将数据设置给可观察数据容器

MVVM 首次引入了状态驱动 UI、，但 ViewModel 不会直接向 View 回调，而是让 View 通过观察者的模式去监听数据的变化，有效规避了 MVP 双向依赖的缺点。**数据驱动UI**

多数据流： View 与 ViewModel 的交互分散，缺少唯一修改源，不易于追踪；
LiveData 膨胀： 复杂的页面需要定义多个 MutableLiveData，并且都需要暴露为不可变的 LiveData。



## MVI: Model - View - Intent

单一数据源、单向数据流。

MVI 模式的改动在于将 View 和 ViewModel 之间的多数据流改为基于 ViewState 的单数据流。MVI 将代码分为以下四个部分：
Intent： 定义数据操作，是将数据传到 Model 的唯一来源，相比 MVVM 是新的概念

单数据流： View 和 ViewModel 之间只有一个数据流，只有一个地方可以修改数据，确保数据是安全稳定的。并且 View 只需要订阅一个 ViewState 就可以获取所有状态和数据，相比 MVVM 是新的特性；

响应式： ViewState 包含页面当前的状态和数据，View 通过订阅 ViewState 就可以完成页面刷新，相比于 MVVM 是新的特性。




可能很多小伙伴一直没有明白“负责协调 UI 状态”到底什么意思？简单的来讲，就是 UE 上的逻辑。即从仓库获取数据后，如何将这些数据显示在UI上，这个逻辑以及UI的状态，正是 ViewModel 职责所在！

状态变化会触发重组，事件从 UI 向上传递，状态从 ViewModel 向下流动，形成单向数据流。

如何防止 ViewModel 变得臃肿？

开发老手的应对方法是“主动向外剥离逻辑”：复杂业务操作移到用例，数据映射移到专门的映射器类，数据组合逻辑放到仓库，导航决策可以封装成事件，由导航处理器处理。


2026年了，该用 Flow 还是 LiveData其实这个问题，在三年前就应该下结论——Flow 一把梭哈！

选择 Flow 还有另一个很重要的原因：Flow 是纯 Kotlin 实现的，这是跨平台开发的唯一选择。

老手们会观察“信号”再决定是否添加领域层：如果业务规则复杂、需要在多个功能中复用、或者需要脱离 Android 独立测试，领域层就很有价值；如果应用只是简单展示远程数据，几乎不需要数据转换，那更简单的结构就足够了。

参考：
[Android UI 架构演进：从 MVC 到 MVP、MVVM、MVI](https://cloud.tencent.com/developer/article/2123801)
[Android 架构之争：MVI 真的比 MVVM 更胜一筹吗？](https://mp.weixin.qq.com/s/OapCCD59_payf7fpPzC9ew)
