# Compose 状态变更通知机制

本文档详细说明在同步事件处理器中，多个状态修改如何通知到重组系统，以及如何实现批处理合并。

## 概述

在 Compose 中，当用户在事件处理器（如 `Button` 的 `onClick`）中修改多个状态时，这些修改会被**批处理合并**，最终只触发**一次重组**，而不是每次修改都触发一次重组。

## 示例场景

```kotlin
Button(onClick = {
    // 同步事件处理器
    count++      // ✅ 修改1
    count++      // ✅ 修改2  
    name = "Bob" // ✅ 修改3
    // 所有修改合并，只重组一次
}) {
    Text("$count - $name")
}
```

在这个例子中，虽然有三个状态修改操作，但最终只会触发一次重组。

## 完整通知流程

### 步骤 1: 状态修改触发 setter

当执行 `count++` 时，会调用 `MutableState.value` 的 setter：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/SnapshotState.kt
override var value: T
    get() = next.readable(this).value
    set(value) =
        next.withCurrent {
            if (!policy.equivalent(it.value, value)) {
                next.overwritable(this, it) { this.value = value }
            }
        }
```

**关键点：**
- `count++` 调用 `MutableState.value` setter
- 使用 `overwritable` 方法写入新值
- 在**全局快照**中执行（事件处理器不在重组快照中）

### 步骤 2: `overwritable` 触发写入通知

`overwritable` 方法会调用 `notifyWrite` 来通知快照系统：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt
internal inline fun <T : StateRecord, R> T.overwritable(
    state: StateObject,
    candidate: T,
    block: T.() -> R,
): R {
    val snapshot: Snapshot
    return sync {
            snapshot = Snapshot.current
            this.overwritableRecord(state, snapshot, candidate).block()
        }
        .also { notifyWrite(snapshot, state) }  // ← 关键：通知写入
}
```

### 步骤 3: `notifyWrite` 触发 writeObserver

`notifyWrite` 会触发当前快照的 `writeObserver`：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt
@PublishedApi
internal fun notifyWrite(snapshot: Snapshot, state: StateObject) {
    snapshot.writeCount += 1
    snapshot.writeObserver?.invoke(state)  // ← 触发写入观察者
}
```

**全局快照的 writeObserver：**

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt
internal class GlobalSnapshot(snapshotId: SnapshotId, invalid: SnapshotIdSet) :
    MutableSnapshot(
        snapshotId,
        invalid,
        null,
        { state -> sync { globalWriteObservers.fastForEach { it(state) } } },  // ← 全局写入观察者
    ) {
```

### 步骤 4: 修改累积到 `globalSnapshot.modified`

每次写入都会调用 `recordModified`，将状态对象添加到 `globalSnapshot.modified` 集合中：

```kotlin
// 在 MutableSnapshot 中
override fun recordModified(state: StateObject) {
    (modified ?: mutableScatterSetOf<StateObject>().also { modified = it }).add(state)
}
```

**累积过程：**
- `count++` (第1次) → `count` 添加到 `modified` 集合
- `count++` (第2次) → `count` 已在 `modified` 中（不重复添加）
- `name = "Bob"` → `name` 添加到 `modified` 集合

最终 `globalSnapshot.modified = {count, name}`

### 步骤 5: 触发 applyObserver 通知

在帧信号到达时，`Recomposer` 会调用 `Snapshot.sendApplyNotifications()`：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt
withFrameNanos { frameTime ->
    // Ensure any global changes are observed
    Snapshot.sendApplyNotifications()
}
```

`sendApplyNotifications()` 会检查并推进全局快照：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt
public fun sendApplyNotifications() {
    val changes = sync { globalSnapshot.hasPendingChanges() }
    if (changes) advanceGlobalSnapshot()  // ← 如果有修改，推进全局快照
}
```

`advanceGlobalSnapshot()` 会触发所有注册的 `applyObservers`：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt
private fun <T> advanceGlobalSnapshot(block: (invalid: SnapshotIdSet) -> T): T {
    val globalSnapshot = globalSnapshot
    
    val modified: MutableScatterSet<StateObject>?
    val result = sync {
        modified = globalSnapshot.modified  // ← 取出所有累积的修改
        if (modified != null) {
            pendingApplyObserverCount.add(1)
        }
        resetGlobalSnapshotLocked(globalSnapshot, block)
    }
    
    // 通知所有注册的 applyObservers
    modified?.let {
        try {
            val observers = applyObservers
            observers.fastForEach { observer -> 
                observer(it.wrapIntoSet(), globalSnapshot)  // ← 触发 applyObserver
            }
        } finally {
            pendingApplyObserverCount.add(-1)
        }
    }
    
    return result
}
```

### 步骤 6: applyObserver 添加到 `snapshotInvalidations`

`Recomposer` 注册的 `applyObserver` 会将变更添加到 `snapshotInvalidations`：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt
val unregisterApplyObserver =
    Snapshot.registerApplyObserver { changed, _ ->
        synchronized(stateLock) {
            if (_state.value >= State.Idle) {
                val snapshotInvalidations = snapshotInvalidations
                changed.fastForEach {
                    if (it is StateObjectImpl && !it.isReadIn(ReaderKind.Composition)) {
                        return@fastForEach
                    }
                    snapshotInvalidations.add(it)  // ← 添加到集合中
                }
                deriveStateLocked()  // ← 唤醒等待的协程
            }
        }
        ?.resume(Unit)
    }
```

**关键点：**
- `changed` 包含 `{count, name}`（所有修改的状态对象）
- 它们被添加到 `snapshotInvalidations` 集合中
- `deriveStateLocked()` 唤醒 `workContinuation`，通知有工作需要处理

### 步骤 7: 批处理到下一帧

`Recomposer` 的主循环会等待帧信号，然后一次性处理所有累积的变更：

```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt
while (shouldKeepRecomposing) {
    awaitWorkAvailable()  // ← 被唤醒，因为有工作
    
    if (!recordComposerModifications()) continue
    
    // Align work with the next frame to coalesce changes.
    parentFrameClock.withFrameNanos { frameTime ->
        trace("Recomposer:recompose") {
            // 1. 收集所有累积的变更
            recordComposerModifications()
            
            synchronized(stateLock) {
                compositionInvalidations.forEach { toRecompose += it }
                compositionInvalidations.clear()  // ← 清空，准备处理
            }
            
            // 2. 在一帧内处理所有重组
            while (toRecompose.isNotEmpty() || toInsert.isNotEmpty()) {
                toRecompose.fastForEach { composition ->
                    performRecompose(composition, modifiedValues)?.let {
                        toApply += it
                    }
                }
            }
        }
    }
}
```

## 完整流程图

```
事件处理器执行：
┌─────────────────────────────────────────┐
│ Button(onClick = {                      │
│     count++      // 修改1                │
│       ↓                                  │
│     MutableState.value setter           │
│       ↓                                  │
│     overwritable()                      │
│       ↓                                  │
│     notifyWrite()                       │
│       ↓                                  │
│     记录到 globalSnapshot.modified      │
│     {count}                             │
│                                         │
│     count++      // 修改2                │
│       ↓                                  │
│     记录到 globalSnapshot.modified      │
│     {count}  (已存在，不重复)            │
│                                         │
│     name = "Bob"  // 修改3               │
│       ↓                                  │
│     记录到 globalSnapshot.modified      │
│     {count, name}                       │
│                                         │
│ } // 事件处理器结束                      │
└─────────────────────────────────────────┘
              ↓
         (等待帧信号)
              ↓
┌─────────────────────────────────────────┐
│ withFrameNanos {                        │
│     Snapshot.sendApplyNotifications()    │
│       ↓                                  │
│     advanceGlobalSnapshot()             │
│       ↓                                  │
│     触发 applyObservers                 │
│       ↓                                  │
│     applyObserver { changed, _ ->       │
│         changed = {count, name}          │
│         snapshotInvalidations.addAll()   │
│     }                                   │
│       ↓                                  │
│     recordComposerModifications()       │
│       ↓                                  │
│     传播到 Composition                  │
│       ↓                                  │
│     执行一次重组（处理所有变更）          │
│ }                                       │
└─────────────────────────────────────────┘
```

## 关键机制总结

### 1. 修改累积机制

所有状态修改都记录到 `globalSnapshot.modified` 集合中，而不是立即触发重组：

```kotlin
// 每次修改都会调用
override fun recordModified(state: StateObject) {
    (modified ?: mutableScatterSetOf<StateObject>().also { modified = it }).add(state)
}
```

**特点：**
- 使用 `MutableScatterSet` 存储，自动去重
- 同一个状态对象多次修改，只记录一次
- 不同状态对象的修改都会记录

### 2. 延迟通知机制

状态修改不会立即触发重组，而是等待帧信号：

```kotlin
// 在帧信号到达时才处理
parentFrameClock.withFrameNanos { frameTime ->
    // 处理所有累积的变更
    recordComposerModifications()
    // 执行重组
}
```

**优势：**
- 与显示刷新率同步（通常 60fps）
- 避免中间帧，保证 UI 流畅
- 批处理多个变更，减少重组次数

### 3. 批处理合并机制

所有累积的变更在 `applyObserver` 回调中一次性通知：

```kotlin
// 一次性通知所有变更
applyObserver { changed, _ ->
    // changed 包含所有修改的状态对象
    // {count, name} 而不是分别通知两次
    snapshotInvalidations.addAll(changed)
}
```

### 4. 帧对齐机制

重组与显示帧对齐，确保 UI 更新与屏幕刷新同步：

```kotlin
// Align work with the next frame to coalesce changes.
parentFrameClock.withFrameNanos { frameTime ->
    // 在下一帧开始时处理所有变更
}
```

## 性能优化

### 为什么这样设计？

1. **减少重组次数**：多个状态变更合并为一次重组
2. **帧对齐**：与显示刷新率同步，避免不必要的中间帧
3. **原子性**：同一帧内的变更一起处理，保证 UI 一致性
4. **性能优化**：减少 UI 树遍历和布局计算次数

### 实际效果

```kotlin
// 假设在同一个函数中快速修改多个状态
var count by remember { mutableStateOf(0) }
var name by remember { mutableStateOf("") }
var enabled by remember { mutableStateOf(false) }

// 这些修改会：
count = 1      // → 添加到 globalSnapshot.modified
name = "Test"  // → 添加到 globalSnapshot.modified  
enabled = true // → 添加到 globalSnapshot.modified

// 但只会触发一次重组（在下一帧）
// 而不是三次重组
```

## 相关代码位置

### 核心文件

1. **状态修改通知**：
   - `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/SnapshotState.kt`
   - `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt`

2. **重组调度**：
   - `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt`

3. **快照系统**：
   - `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt`

### 关键方法

- `SnapshotMutableStateImpl.value.setter` - 状态修改入口
- `notifyWrite()` - 写入通知
- `advanceGlobalSnapshot()` - 推进全局快照并触发通知
- `Snapshot.registerApplyObserver()` - 注册应用观察者
- `Recomposer.runRecomposeAndApplyChanges()` - 重组主循环

## 总结

在同步事件处理器中的多次状态修改会被：

1. **累积**：所有修改记录到 `globalSnapshot.modified` 集合
2. **延迟**：等待帧信号，不立即触发重组
3. **合并**：在 `applyObserver` 回调中一次性通知所有变更
4. **批处理**：在下一帧中执行一次重组，处理所有变更

这种设计确保了 Compose 的高性能，同时保持了响应性和 UI 一致性。
