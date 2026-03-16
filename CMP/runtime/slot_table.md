# SlotTable

两棵树：

- 状态树：SlotTable <-- runtime 层
- 渲染树：LayoutNode 树 <-- ui 层


SlotTable 是 Compose 架构中的核心概念，负责存储 Composable 函数的状态和结构。

**Composable 函数执行过程中产生的所有数据都会存入 SlotTable， 包括 State、CompositionLocal，remember 的 key 与 value 等等 ，这些数据不随函数的出栈而消失，可以跨越重组存在。Composable 函数在重组中如果产生了新数据则会更新 SlotTable。**

查看 SlotTable 的源码需要理解的核心概念：
- Index: group 和 slot 在数组中的（Group 是逻辑）索引。 group是用 Int 数组表示的，group 所以的1, 应该是 int 数组的 5。Slot 则不会有这个问题。
- Address: 忽略间隙的偏移量。如果间隙在末尾，则 Address 和  Index相同。
- Anchor: Index 的编码值，以便在插入和删除时不必更新 Anchor。在之前的是正值，在之后的是负值。负值表示其距离末尾的距离（熟悉 Python 应该很好理解这一点）。


```
Index:    0     1     2     3     4     5
Address:  0     1                 2     3
Anchor:   1     2                -2    -1
          ↓     ↓     gap   gap    ↓    ↓
Array:  [ A ] [ B ] [ _ ] [ _ ] [ C ] [ D ]

```

Data: Slot 数组中与 group 关联的数据。包括 slots、ObjectKey、Node、以及 Aux（如果有的话）。同一 group 的 Slot 是连续的。

Group fileds: group 数组中5个连续的整数元素，并以5对齐。包括 key、group info bits、parent anchor、data size、data anchor
```
// Group info is laid out as follows,
// 31 30 29 28_27 26 25 24_23 22 21 20_19 18 17 16__15 14 13 12_11 10 09 08_07 06 05 04_03 02 01 00
// 0  n  ks ds m  cm|                                node count                                    |
// where n is set when the group represents a node
// where ks is whether the group has a object key slot
// where ds is whether the group has a group data slot
// where m is whether the group is marked
// where cm is whether the group contains a mark
```
Group: 指 graup 树、包含其子 group。子 group 紧跟在父 group 之后。这种数据结构有利于对子节点进行线性扫描。除非通过 group anchor，否则随机访问代价较高。


Aux          - auxiliary data that can be associated with a node and set independent of groups slots. This is used, for example, by the composer to record CompositionLocal  maps as the map is not known at the when the group starts, only when the map is calculated after using an arbitrary number of slots.

所有引用数组索引的字段和变量都假定是 Index 值，而不是 Address 值，除非明确以 Address 结尾。

为了 reader 的简单性和效率，gap 总是被移动到末尾，因此 reader 中 Index 和 Address 是相同的。


[GapBuffer](https://blog.csdn.net/vitaviva/article/details/154885542)
