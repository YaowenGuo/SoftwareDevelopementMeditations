# 架构设计

## Compose 的四阶段分离架构

Compose 采用**四阶段分离**的架构设计，将 UI 渲染流程清晰地分为：**状态观察（State Observation）**、**重组（Recomposition）**、**布局（Layout）** 和 **绘制（Draw）** 四个独立的阶段。这种分离设计带来了更好的模块化、可测试性和性能优化。

### 架构分层图

```
┌─────────────────────────────────────────────────────────┐
│                    应用层                                │
│            @Composable 函数、状态管理                      │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  阶段 1: 状态观察 (State Observation)                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Snapshot 系统                                     │  │
│  │  - MutableState / StateObject                      │  │
│  │  - Snapshot.registerApplyObserver()                │  │
│  │  - 状态变更检测和通知                               │  │
│  └───────────────────────────────────────────────────┘  │
│  职责：检测状态变化，通知需要重组的部分                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  阶段 2: 重组 (Recomposition)                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Recomposer + Composer                            │  │
│  │  - Slot Table 管理                                 │  │
│  │  - 增量重组算法                                    │  │
│  │  - 位置记忆化 (Positional Memoization)              │  │
│  └───────────────────────────────────────────────────┘  │
│  职责：重新执行 Composable 函数，更新 UI 树结构           │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  阶段 3: 布局 (Layout)                                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │  LayoutNode + LayoutModifier                        │  │
│  │  - measure() - 测量阶段                            │  │
│  │  - place() - 定位阶段                              │  │
│  │  - LayoutConstraints                               │  │
│  └───────────────────────────────────────────────────┘  │
│  职责：测量和定位 UI 元素                                 │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  阶段 4: 绘制 (Draw)                                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │  DrawModifier + Canvas                            │  │
│  │  - draw() - 绘制操作                              │  │
│  │  - GraphicsLayer                                  │  │
│  │  - 平台特定绘制 (Skia/Android Canvas)             │  │
│  └───────────────────────────────────────────────────┘  │
│  职责：将 UI 树绘制到画布上                               │
└─────────────────────────────────────────────────────────┘
```

## 各阶段详细说明

### 1. 状态观察（State Observation）

**位置**：`compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/`

**核心组件**：
- `Snapshot` 系统：提供状态隔离和变更检测
- `MutableState` / `StateObject`：可观察的状态对象
- `Snapshot.registerApplyObserver()`：注册状态变更观察者

**职责**：
- 检测状态对象的变更
- 通过 `applyObserver` 通知需要重组的 Composition
- 支持快照隔离，允许多个并发状态变更

**关键代码**：
```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt
val unregisterApplyObserver =
    Snapshot.registerApplyObserver { changed, _ ->
        synchronized(stateLock) {
            if (_state.value >= State.Idle) {
                val snapshotInvalidations = snapshotInvalidations
                changed.fastForEach {
                    snapshotInvalidations.add(it)  // 记录需要重组的对象
                }
                deriveStateLocked()  // 唤醒重组协程
            }
        }
    }
```

**特点**：
- **解耦**：状态变更检测与重组执行完全分离
- **批处理**：多个状态变更可以合并，减少重组次数
- **线程安全**：通过快照系统支持并发状态访问

### 2. 重组（Recomposition）

**位置**：`compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/`

**核心组件**：
- `Recomposer`：重组调度器
- `Composer`：重组执行器
- `SlotTable`：存储 Composable 函数的状态和结构

**职责**：
- 接收状态变更通知
- 重新执行需要更新的 Composable 函数
- 增量更新 Slot Table，只更新变化的部分
- 应用更改到 UI 树（LayoutNode 树）

**关键代码**：
```kotlin
// compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt
private inline fun <T> composing(
    composition: ControlledComposition,
    modifiedValues: MutableScatterSet<Any>?,
    block: () -> T,
): T {
    val snapshot = Snapshot.takeMutableSnapshot(
        readObserverOf(composition),      // 记录读取的状态
        writeObserverOf(composition, modifiedValues),  // 记录写入的状态
    )
    try {
        return snapshot.enter(block)  // 在快照中执行重组
    } finally {
        applyAndCheck(snapshot)  // 应用快照变更
    }
}
```

**特点**：
- **增量更新**：只重组变化的部分，不是整个 UI 树
- **位置记忆化**：基于调用位置记忆化，支持 `remember`
- **快照隔离**：重组在快照中执行，不影响其他线程的状态访问

### 3. 布局（Layout）

**位置**：`compose/ui/ui/src/commonMain/kotlin/androidx/compose/ui/layout/`

**核心组件**：
- `LayoutNode`：布局节点
- `LayoutModifier`：布局修饰符
- `MeasurePolicy`：测量策略

**职责**：
- **测量阶段**：计算每个 UI 元素的尺寸
- **定位阶段**：确定每个 UI 元素的位置
- 处理布局约束（Constraints）
- 支持自定义布局（如 `Row`、`Column`、`Box`）

**关键代码**：
```kotlin
// compose/ui/ui/src/androidMain/kotlin/androidx/compose/ui/platform/AndroidComposeView.android.kt
override fun dispatchDraw(canvas: android.graphics.Canvas) {
    // 在绘制之前先执行布局
    measureAndLayout()
    Snapshot.notifyObjectsInitialized()
    
    // 然后执行绘制
    root.draw(canvas = this, graphicsLayer = null)
}
```

**特点**：
- **两阶段布局**：测量和定位分离，支持复杂布局需求
- **延迟布局**：只在需要时执行布局计算
- **约束传递**：通过 Constraints 在布局树中传递尺寸约束

### 4. 绘制（Draw）

**位置**：`compose/ui/ui/src/commonMain/kotlin/androidx/compose/ui/graphics/`

**核心组件**：
- `DrawModifier`：绘制修饰符
- `Canvas`：绘制画布
- `GraphicsLayer`：图形图层

**职责**：
- 将 UI 树绘制到画布上
- 处理绘制顺序和图层
- 支持硬件加速（通过 GraphicsLayer）
- 平台特定的绘制实现（Skia/Android Canvas）

**关键代码**：
```kotlin
// compose/ui/ui/src/androidMain/kotlin/androidx/compose/ui/platform/AndroidComposeView.android.kt
override fun dispatchDraw(canvas: android.graphics.Canvas) {
    measureAndLayout()
    Snapshot.notifyObjectsInitialized()
    
    canvasHolder.drawInto(canvas) {
        root.draw(
            canvas = this,
            graphicsLayer = null
        )
    }
}
```

**特点**：
- **平台抽象**：通过 Canvas 抽象，支持多平台
- **图层支持**：支持 GraphicsLayer，实现硬件加速
- **绘制顺序**：按照布局树的顺序递归绘制

## 阶段分离的优势

### 1. 模块化设计

每个阶段都有清晰的职责边界，可以独立开发、测试和优化：

- **状态观察**：专注于状态管理和变更检测
- **重组**：专注于 UI 树结构的更新
- **布局**：专注于尺寸计算和位置确定
- **绘制**：专注于图形渲染

### 2. 性能优化

阶段分离使得每个阶段都可以独立优化：

- **状态观察**：批处理多个状态变更，减少重组次数
- **重组**：增量更新，只更新变化的部分
- **布局**：延迟布局，只在需要时计算
- **绘制**：支持硬件加速和图层优化

### 3. 可测试性

每个阶段都可以独立测试：

- 状态观察：可以测试状态变更检测逻辑
- 重组：可以测试 Composable 函数的执行
- 布局：可以测试布局算法
- 绘制：可以测试绘制结果

### 4. 跨平台支持

阶段分离使得不同平台可以有不同的实现：

- **状态观察**：完全平台无关（Snapshot 系统）
- **重组**：完全平台无关（Composer）
- **布局**：平台无关的布局算法
- **绘制**：平台特定的绘制实现（Skia/Android Canvas）

## 执行流程

### Android 平台

```
1. 状态变更
   ↓
2. Snapshot.apply() → 触发 applyObserver
   ↓
3. Recomposer.runRecomposeAndApplyChanges() → 重组阶段
   ↓
4. measureAndLayout() → 布局阶段
   ↓
5. root.draw() → 绘制阶段
   ↓
6. 帧完成
```

### Desktop (Skiko) 平台

```kotlin
// compose/ui/ui/src/skikoMain/kotlin/androidx/compose/ui/scene/BaseComposeScene.skiko.kt
override fun render(canvas: Canvas, nanoTime: Long) {
    // 1. 执行 Effects
    recomposer.performScheduledEffects()
    
    // 2. 执行重组
    recomposer.performScheduledRecomposerTasks()
    frameClock.sendFrame(nanoTime)
    
    // 3. 布局
    doMeasureAndLayout()
    
    // 4. 通知状态变化
    Snapshot.sendApplyNotifications()
    
    // 5. 绘制
    draw(canvas)
}
```

## 关键设计原则

### 1. 单向数据流

```
状态变更 → 状态观察 → 重组 → 布局 → 绘制
```

数据流是单向的，每个阶段只依赖前一阶段的结果，不反向依赖。

### 2. 延迟执行

- 状态变更不会立即触发重组，而是等待帧信号
- 布局不会立即执行，而是在绘制前执行
- 绘制由系统调度，与显示刷新率同步

### 3. 增量更新

- 重组：只更新变化的部分
- 布局：只重新测量和定位变化的节点
- 绘制：只重绘脏区域（dirty regions）

### 4. 快照隔离

重组在快照中执行，确保：
- 状态读取的一致性
- 状态写入的原子性
- 并发状态访问的安全性

## 相关代码位置

### 状态观察
- `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/snapshots/Snapshot.kt`
- `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/SnapshotState.kt`

### 重组
- `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Recomposer.kt`
- `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/GapComposer.kt`
- `compose/runtime/runtime/src/commonMain/kotlin/androidx/compose/runtime/Composition.kt`

### 布局
- `compose/ui/ui/src/commonMain/kotlin/androidx/compose/ui/node/LayoutNode.kt`
- `compose/ui/ui/src/commonMain/kotlin/androidx/compose/ui/layout/`
- `compose/ui/ui/src/androidMain/kotlin/androidx/compose/ui/platform/AndroidComposeView.android.kt`

### 绘制
- `compose/ui/ui/src/commonMain/kotlin/androidx/compose/ui/node/NodeCoordinator.kt`
- `compose/ui/ui/src/commonMain/kotlin/androidx/compose/ui/graphics/`
- `compose/ui/ui/src/androidMain/kotlin/androidx/compose/ui/platform/AndroidComposeView.android.kt`

## 总结

Compose 的四阶段分离架构通过清晰的职责划分，实现了：

1. **高内聚低耦合**：每个阶段专注于自己的职责
2. **易于优化**：每个阶段可以独立优化
3. **易于测试**：每个阶段可以独立测试
4. **跨平台支持**：不同平台可以实现不同的绘制层
5. **性能优化**：批处理、增量更新、延迟执行等优化策略

这种架构设计是 Compose 高性能、可维护性和跨平台能力的基础。
