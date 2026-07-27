# 基础概念

重组通过跟踪状态的写入和读取来实现。

## State VS MutableState

Compose 需要观察状态的变化进行重组、因此观察的变量一定是可变的才需要观察，有了 MutableState，为什么还提供了 State 这种不可变的？

1. 一些组件为了避免错误，不应该修改该状态，需要使用 State 来避免修改。
1. 单一数据源or单一修改点？

remember: 记住重组时状态值
rememberSaveable: 页面重建的状态值。rememberSaveable 能够记住保存在 bundle 的任何值。对于其它值可以传入自定义的 Saver。

## 状态托管

**不要用状态提升、状态提升是像鲁棒性一样的垃圾翻译。**

使用 remember 将状态保存在可组合项会让组合项变成有状态的。

**不保存任何状态的可组合项称为无状态可组合项**。如需创建**无状态**可组合项，一种简单的方法是使用**状态托管**

**状态托管**是将状态移动到调用方以让组合项保持无状态的方法。


- **无状态可组合项**是指不具有任何状态的可组合项，这意味着它不会存储、定义或修改新状态。
- **有状态可组合项**是一种具有可以随时间变化的状态的可组合项。
- 在实际应用中，让可组合项 100% 完全无状态可能很难实现，具体取决于可组合项的职责。在设计可组合项时，您应该让可组合项拥有尽可能少的状态，并能够在必要时通过在可组合项的 API 中公开状态来提升状态。

<p>要点：提升状态时，有三条规则可帮助您弄清楚状态应去向何处：</p>

<li>状态应至少提升到使用该状态（读取）的所有可组合项的<strong>最低共同父项</strong>。</li>
<li>状态应至少提升到<strong>它可以发生变化（写入）的最高级别</strong>。</li>
<li><strong>如果两种状态发生变化以响应相同的事件，它们应提升到同一级别</strong>。</li>

<p>您可以将状态提升到高于这些规则要求的级别，但如果未将状态提升到足够高的级别，则遵循单向数据流会变得困难或不可能。</p>


## 状态管理

UI 状态的位置取决于它是用于控制 UI 逻辑的还是业务逻辑。


> **最佳实践**：UI 状态应该提升到所有读写它的 composable 的最近公共祖先（lowest common ancestor）。**状态应尽量靠近使用它的地方。** 从状态拥有者（state owner）向消费者**暴露不可变的状态（immutable state）**，**以及用于修改状态的事件（events）**。


### UI 状态和 逻辑

- UI 状态：UI 状态是描述 UI 的属性。UI 状态有两种类型：
    - **屏幕 UI 状态（Screen UI state）** 是你需要在屏幕上显示的内容。例如，一个 NewsUiState 类可以包含新闻文章以及渲染 UI 所需的其他信息。这种状态通常与 UI 树中的其他层相关联，因为它包含了 App 数据。

    - **UI 元素状态（UI element state）** 指的是 UI 元素自身固有的、影响其渲染方式的属性。一个 UI 元素可能被显示或隐藏，也可能具有某种字体、字号或字体颜色。在 Jetpack Compose 中，状态是位于 composable 外部的（无状态），你甚至可以把它从 composable 的紧邻位置提升到调用它的 composable 函数中，或提升到一个状态持有者（state holder）中。一个例子就是 Scaffold composable 所用的 ScaffoldState。


- 逻辑：应用中的逻辑可以是业务逻辑或 UI 逻辑

    - 业务逻辑（Business logic） 是针对 App 数据实现产品需求。例如，在新闻阅读 App 中，当用户点击按钮时收藏一篇文章。这种把书签保存到文件或数据库的逻辑，通常放在 domain 层或 data 层。状态持有者通常通过调用这些层所暴露的方法，把该逻辑委托给它们处理。

    - UI 逻辑（UI logic） 与如何在屏幕上显示 UI 状态有关。例如，当用户选择了某个分类后获取对应的搜索栏提示文字、滚动到列表中的某一项，或者当用户点击按钮时导航到某个特定屏幕的导航逻辑。


### UI 逻辑

当 UI 逻辑需要读取或写入状态时，你应该把状态限定在 UI 的作用域内，使其跟随 UI 的生命周期。要做到这一点，你应该提升该状态到 composable 函数中合适的层级。或者，你也可以提升它到一个普通状态持有类（plain state holder class）中——这个类同样的限定在 UI 生命周期作用域内。

下面将分别描述这两种方案，并解释何时该用哪一种。

#### Composable 函数持有状态

**无需状态提升：当没有其他 composable 共享某个状态时，不必提升状态。**
**提升到最近的公共祖先**

#### 普通状态持有类（plain state holder class）中

**当 UI 逻辑包含了复杂的逻辑，或者包含了多个 composable 共享的状态时**。应该把状态提升到一个普通状态持有类中。需要说明的是，这个类也要遵循上一个小节中提到的提升状态的规则。

一个例子是 LazyListState 普通状态持有者类，它在 Compose 中实现，用于控制 LazyColumn 或 LazyRow 的 UI 复杂性。
```Kotlin
// LazyListState.kt

@Stable
class LazyListState constructor(
    firstVisibleItemIndex: Int = 0,
    firstVisibleItemScrollOffset: Int = 0
) : ScrollableState {
    /**
     *   The holder class for the current scroll position.
     */
    private val scrollPosition = LazyListScrollPosition(
        firstVisibleItemIndex, firstVisibleItemScrollOffset
    )

    suspend fun scrollToItem(/*...*/) { /*...*/ }

    override suspend fun scroll() { /*...*/ }

    suspend fun animateScrollToItem() { /*...*/ }
}
```
LazyListState 封装了存储此 UI 元素的滚动位置的 LazyColumn 的状态。它还公开了通过例如滚动到给定项目来修改滚动位置的方法

### 业务逻辑

**业务逻辑应该提升为屏幕UI状态**

如果说 composable 和普通状态持有类负责的是 UI 逻辑和 UI 元素状态，那么**屏幕级状态持有者（screen level state holder）**则负责以下任务：

- 提供对应用业务逻辑的访问入口——这些业务逻辑通常放在层级中的其他层中，例如业务层（business layer）和数据层（data layer）。

- 为某个特定屏幕准备好用于展示的应用数据，这些数据即构成该屏幕的屏幕 UI 状态（screen UI state）。

#### ViewModels 作为状态持有者

ViewModel 并不作为 Composition 的一部分被存储。它们由框架提供，并且其作用域绑定到一个 ViewModelStoreOwner——这个所有者可以是 Activity、Fragment、导航图（navigation graph），或者导航图中的某个目的地（destination）。

如此一来，ViewModel 就成为了 UI 状态的单一可信来源（source of truth）以及最近公共祖先（lowest common ancestor）。

**如果存在需要读取或写入 UI 元素状态的业务逻辑，您可以将 UI 元素状态提升到屏幕级别状态持有者**

#### 属性逐层下传（Property drilling）

“属性逐层下传”指的是把数据穿过若干层嵌套的子组件，一路传递到真正读取它的位置。

在 Compose 中，property drilling 的一个典型场景是：你在顶层注入屏幕级状态持有者，然后把状态和事件逐层向下传递给子 composable。这可能还会额外导致 composable
  函数签名变得臃肿（参数过多）。

尽管把事件作为一个个独立的 lambda 参数暴露出来会让函数签名变长，但这样做能最大化地体现该 composable 函数的职责——你一眼就能看出它做了什么。

相比创建包装类（wrapper class）把状态和事件集中封装在一起，property drilling 是更可取的做法，因为包装类会降低 composable 职责的可见性。不使用包装类，你也更可能只把
  composable 真正需要的参数传给它，而这正是一项最佳实践。

如果这些事件是导航事件（navigation events），同样适用这条最佳实践，你可以在导航文档中了解更多。

如果你发现了性能问题，也可以选择延迟读取状态（defer reading of state）。可以查阅[性能文档](https://developer.android.com/develop/ui/compose/performance/bestpractices#defer-reads)了解更多。


**注意**：如果这个变量并被业务逻辑所需要，那它就不应该被提升到屏幕级状态持有者中。它应该被定义并存储在 UI 中，更靠近真正需要它的那个 composable 函数。

**注意**：一个屏幕级的 composable 完全可以同时拥有一个提供业务逻辑访问入口的 ViewModel，以及一个管理其 UI 逻辑和 UI 元素状态的普通状态持有类（plain state holder class）。


## CompositionLocal 是一个通过 Composition 隐式传递数据的工具
