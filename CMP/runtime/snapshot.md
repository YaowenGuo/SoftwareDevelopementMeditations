# 快照

如何实现修改数据 UI 既更新？从命令式 UI 通过开发者手工编写指令明确更新 UI，到声明式 UI 使用数据直接描述 UI，修改数据后既更新 UI。程序并没有什么黑魔法、更新 UI 的指令只不过从开发者手工编写被统一内聚到了 UI 框架里（这也是切面编程的一种体现）、更新UI的指令被抽离进了框架中，就要在数据更改时触发指令的执行。实现的方式就是：观察者模式。不同 UI 框架的考量不同、选择了不同的实现方式。Compose 的实现采用了“快照”。

状态管理与重组机制的运行

注意：git merge 可以在任意分支之间进行合并，而快照的 apply 永远是从当前快照提交到“父快照”。快照上允许嵌套创建快照，因此快照存在父子关系。

快照对状态读写的感知是 Compose 状态更新后自动触发重组的基础

## 什么是快照？

快照是在某个时间点的数据存档，你可以后面任意修改数据，然后将数据作为整体更新。也可以放弃修改回到之前的时间点的数据。

## 为什么 Compose 使用快照系统而不是简单的观察者模式：

### 观察者模式的问题

#### 1. 缺少原子性（Atomicity）
```Kotlin
// 简单观察者模式的问题
var count = 0
var name = ""
// 如果同时修改多个状态
count = 10 // 触发重组
name = "New" // 又触发重组

// 结果：UI 可能看到中间状态 (count=10, name="") 或 (count=0, name="New")
```
问题：多个状态变更会触发多次重组，UI 可能看到不一致的中间状态。

#### 2. 缺少隔离性（Isolation）

```Kotlin
// 观察者模式：状态修改立即生效
@Composable
fun MyComposable() {
    var state = remember { mutableStateOf(0) }

    // 问题：如果在组合过程中修改状态    
    LaunchedEffect(Unit) {        
        state.value = 1  // 立即触发重组，可能导致组合中断    
    }
}
```
问题：组合过程中状态变更会立即影响其他观察者，可能导致不一致。

#### 3. 并发冲突
```Kotlin
// 线程 A
state.value = 10
// 线程 B（同时）
state.value = 20
// 观察者模式：后写入的覆盖，但可能丢失数据
```
问题：无法检测或处理并发修改冲突。

### 快照系统的优势

#### 1. 原子性保证
```Kotlin
// 快照系统：所有更改在快照中隔离，原子应用
val snapshot = Snapshot.takeMutableSnapshot()
snapshot.enter {
    count = 10
    name = "New"
    // 这些更改在快照中隔离，不影响全局状态
}
snapshot.apply()  // 原子应用：要么全部成功，要么全部失败
```
从代码注释可以看到：
```
Snapshot.kt
/**
 * Apply the changes made to state objects in this snapshot to the global state...
 * Once this method returns all changes made to this snapshot are atomically visible...
 */
```

#### 2. 快照隔离（Snapshot Isolation）

```Kotlin
// 组合过程在快照中执行
composition.composeContent {
    // 所有状态读取都看到快照创建时的值
    // 所有状态写入都在快照中隔离
    MyComposable()
}
// 组合完成后，一次性应用所有更改
composition.applyChanges()
```
代码中的说明：
```
Snapshot.kt
/**
 * Changes to a mutable snapshot are isolated, using snapshot isolation,
 * from all other snapshots. Their changes are only visible as global state
 * or to new snapshots once [MutableSnapshot.apply] is called.
 *
 * Composition uses mutable snapshots to allow changes made in a [Composable]
 * functions to be temporarily isolated from the global state and is later
 * applied to the global state when the composition is applied.
 */
```
3. 冲突检测与自动合并
```Kotlin
Snapshot.kt
/**
 * Applying a snapshot can fail if currently visible changes to the state object
 * conflicts with a change made in the snapshot.
 */
public open fun apply(): SnapshotApplyResult {
    // 检测冲突
    val optimisticMerges = optimisticMerges(...)
    
    // 尝试自动合并
    val result = innerApplyLocked(..., optimisticMerges, ...)
    if (result != SnapshotApplyResult.Success) return result
    // 原子应用
    ...
}
```
#### 4. 事务性组合
```Kotlin
// 组合过程 = 一个事务
try {
    // 1. 创建快照
    val snapshot = takeMutableSnapshot(readObserver, writeObserver)
    // 2. 在快照中执行组合
    snapshot.enter {
        composeContent()
    }
    // 3. 应用更改（原子性）
    snapshot.apply().check()
} catch (e: SnapshotApplyConflictException) { 
    // 4. 如果失败，丢弃更改，重新组合
    snapshot.dispose()
    scheduleRecomposition()
}
```

#### 5. 批量更新优化

```Kotlin
// 观察者模式：每次修改都触发通知
state1.value = 1  // 通知
state2.value = 2  // 通知
state3.value = 3  // 通知
// 结果：3 次重组

// 快照系统：批量应用
snapshot.enter {
    state1.value = 1
    state2.value = 2
    state3.value = 3
}
snapshot.apply() // 一次通知，一次重组
```
### 实际场景对比

#### 场景 1：组合过程中的状态修改
```Kotlin
@Composablefun MyScreen() {
    var count = remember { mutableStateOf(0) }

    // 在组合过程中修改状态
    SideEffect {
        count.value = 10  // 如果使用观察者模式，这会立即触发重组，可能导致无限循环
    }
    Text("Count: ${count.value}")
}
```
快照系统：修改在快照中隔离，组合完成后统一应用，避免中间状态和不必要的重组。


#### 场景 2：多线程并发修改

```Kotlin 
// 线程 A：组合过程
composition.composeContent { ... }

// 线程 B：用户交互
button.onClick { state.value = newValue }
```
快照系统：
- 组合在快照中执行，看到创建时的状态
- 用户修改在全局快照中
- 应用时检测冲突，必要时重新组合

#### 场景 3：复杂状态依赖

```Kotlin
@Composable
fun ComplexUI(state1: State<Int>, state2: State<String>) {
    // 如果 state1 和 state2 需要同时更新
    // 观察者模式：可能看到 (state1=新值, state2=旧值) 的不一致状态
    // 快照系统：要么看到 (旧值, 旧值)，要么看到 (新值, 新值)
}
```

总结
| 特性       |	观察者模式  | 快照系统 |
| --------- | ----------- | ------ |
| 原子性     |  ❌ 无	  |  ✅ 有 |
| 隔离性     |	❌ 无	  |  ✅ 有 |
| 冲突检测   |	❌ 无	  |  ✅ 有 |
| 事务性     |	❌ 无	  |  ✅ 有 |
| 批量优化   |	❌ 困难	  |  ✅ 自然支持 |
| 一致性保证  |	❌ 弱	  |  ✅ 强 |

观察者模式可以实现声明式 UI，但无法保证：
- 状态变更的原子性
- 组合过程中的隔离性
- 并发冲突的处理
- 事务性回滚

快照系统通过快照隔离和原子应用，提供了这些保证，使 Compose 能够：
- 安全地在组合过程中修改状态
- 处理并发修改
- 保证 UI 状态的一致性
- 优化性能（批量更新）

这是 Compose 选择快照系统而非简单观察者模式的原因

## 其它

1. 快照的 ID 是个 lang 类型，会不会发生溢出？

SnapshotId 是 Long 类型，最大值：Long.MAX_VALUE = 9,223,372,036,854,775,807。假设每帧创建一个快照（60fps）：
每秒：60 个快照
每年：60 × 31,536,000 ≈ 19 亿个快照
需要约 487 万年才会溢出，但在实际应用中，这个风险可以忽略不计。


参考： 

https://blog.csdn.net/vitaviva/article/details/124657607