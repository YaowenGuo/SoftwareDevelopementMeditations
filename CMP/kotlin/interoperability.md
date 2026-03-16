# 互操作

这里主要是 Kotlin 调用 C 和 Swift，是编译成库之后，编译后才链接的，并不是直接调用其语言文件，同时编译（这句话是个废话，任何语言都是编译后调用的，但同一语言是总是给人以错觉，这对于理解 Kotlin 和 C/Swift 文件为什么不能同时编译有帮助）。（是不是可以在一个模块中配置 native 库，再配置互调用？）

1. kotlin native 已经为流行系统库提供了默认包装，不用再单独配置。例如：posix 标准库、OpenGL, zlib, and Foundation.

2. 调用没有提供包装的 C 库时，需要配置 Cinterop 工具为 C 库生成 Kotlin 绑定。


## 配置流程

https://kotlinlang.org/docs/native-app-with-c-and-libcurl.html#create-a-definition-file

几点注意：

- 除了 Cinterop 工具生成的 Kotlin 带 @ExperimentalForeignApi 注解。调用了这些函数，需要使用 @OptIn(ExperimentalForeignApi::class) 注解。

- 定义文件可以用户配置各种选项，例如：函数参数的命名、返回值的命名、函数参数的类型、函数返回值的类型等。而且 headerFilter 可以用户包体积优化和解决包之间的冲突。

- Kotlin 调用 C 和 

## 对象映射关系：

| Kotlin | Swift |  C  |
| ------ | ----- | --- |
| Any    | Any   | void |
| Int    | Int32 | int |
| Float  | Float | float |
| Double | Double | double |
| Boolean | Boolean | bool |
| String | String | char* |
| Array  | Array | void* |
| Map    | Map | void* |

## Kotlin 和 C 互操作

内存分配：



## Kotlin 和 Swift 互操作

### Kotlin 调用 Swift



### Swift 调用 Kotlin

在 Swift 或者 Object C 中调用 Kotlin 是将 Kotlin 编译成 apple 平台的 framework 库，然后将 .framwork 库链接到程序中完成的。

例如 Kotlin 代码：

```kotlin
// MainViewController.kt
fun MainViewController() = ComposeUIViewController { App() }
```
构建为 framework 库：
```bash
iosTarget.binaries.framework {
    baseName = "ShareModel"
    isStatic = true
}
```
在 Swift 中使用，导入 Kotlin 模块：
```swift
import ShareModel
```

调用 Kotlin 函数：
```swift
MainViewControllerKt.MainViewController()
```

## TODO

依赖注入
