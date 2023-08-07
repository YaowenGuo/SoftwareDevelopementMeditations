# Variable

变量是程序编写最基本的元素之一，设计一套变量系统不止是方便开发人员这么简单，其背后也隐藏着语言设计者的思考和哲学偏好。

一个变量的包含的问题：
- 类型
- 是否可变
- 简洁易读

## 类型推导

让开发者从明显的或者是冗余的类型拼写中解放出来。它使得 C++ 编写的软件更加具有适用性，因为改变代码中的一处地方的类型，编译器会在代码 的其他地方自动的推导出类型定义。但是这使得代码扫描过程更加困难，因为类型推导对编译器来说并不是你想的那么简单。

```kotlin
var variable = 1;
val value = 1;
```

现代强类型语言，都开始使用关键字来声明变量，而不再使用类型。
历史悠久的语言，添加新特性来支持关键字声明。
- ES6: var/let
- C++11: auto, C++ 因为历史兼容原因，类型仍然现在变量前面。

新语言：

- Rust: let mut / let
- Swift: var / let
- Go: var / const


可以看到现代语言中变量声明的发展，都在向着减少类型的方向发展。为什么？

1. 减少冗余信息，打字更少，代码更清晰。

当使用基本类型时，变量名还行，比较少，但是当使用自定义类型时，变量名变得冗长。而且对于需要立即赋值的变量来说，声明类型和创建对象类型前后冗余。
```Java
// Java
List<CachedCaptureFormat> cachedSupportedFormats = new List<CachedCaptureFormat>();
//       ^                                                   ^
//    声明有类型                                            创建还有类型

boolean captureToTexture = true;   // 类型是显而易见的。
CallSessionFileRotatingLogSink calute = createValute(); // 类型扰乱了主要逻辑
```
```Kotlin
val cachedSupportedFormats = new List<CachedCaptureFormat>();
val captureToTexture = true;
val calute = createValute();
```

突出关注点，当我们看代码时，首先关注的是这个变量和其进行的逻辑，而不是变量的具体类型。


2. 由编译器做类型推导，而不是开发人员。把开发人员的精力留给业务逻辑。

当我们进行一个函数调用时的返回值。以及进行一个复杂的逻辑运算，类型显得不那么一眼就能看出。

```Kotlin
val calute = createValute(); // 需要查看函数。
val result = product2 * 3 + refundMoney; // 结果类型不够明显。
```


作为强类型语言，在无法推导类型时，仍然需要声明。例如，仅声明一个变量，而不赋值时。

```Kotlin
val cachedSupportedFormats: List<CachedCaptureFormat>;
```

## 可变性


## 类型（不是数据类型）

- 引用
- 指针
- 右值引用
- const 引用
rust-lang.rust