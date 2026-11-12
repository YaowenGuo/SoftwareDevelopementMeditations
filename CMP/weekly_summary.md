# Compose 基础

## by 关键字

Kotlin 的 by 关键字是一个软关键字（Soft Keyword），意味着它在特定上下文中作为关键字使用，在其他地方（如变量名）则没有限制。

它的核心作用是实现委托（Delegation），主要用在两个场景：类委托和属性委托。使用时的主要限制是：类委托只能基于接口，而属性委托则要求委托对象必须提供特定名称的函数。

## 类代理

代理模式被证明是继承的一种有效替代方式，Kotlin 通过 by 关键字提供了内置支持。

下面的示例演示了 Derived 将对 Base 接口的所有公有方法委托给 b 对象，而不是自己实现它。
```Kotlin
interface Base {
    fun print()
}

class BaseImpl(val x: Int) : Base {
    override fun print() { print(x) }
}

class Derived(b: Base) : Base by b

fun main() {
    val base = BaseImpl(10)
    Derived(base).print()
}
```

**限制**
1. **只能两个代理给实现同样接口的类**
2. **只能委托方法，属性不能直接委托**

```Kotlin 
interface Base {
    val message: String
    fun print()
}

class BaseImpl(x: Int) : Base {
    override val message = "BaseImpl: x = $x"
    override fun print() { println(message) }
}

class Derived(b: Base) : Base by b {
    // This property is not accessed from b's implementation of `print`
    override val message = "Message of Derived"
}

fun main() {
    val b = BaseImpl(10)
    val derived = Derived(b)
    derived.print()  // 打印 b 的 10，可以委托。
    println(derived.message) // 打印 Derived 的 message，不能委托
}
```

## 属性委托

要理解属性委托，首先需要了解 Kotlin 中的属性的本质。 Kotlin 中的变量其本质是一个属性，而非简单的对象名。

该如何理解属性呢？val 和 var 其本质是声明了 getXXX 和 setXXX 方法，实际是否有实际分配存储空间看实际的代码

```kotlin
class User {
    var firstName: String = ""
    var lastName: String = ""
    val name
     get() = "$firstName $lastName"
}
```
对应的 Java 代码为
```Java
public final class User {
   @NotNull
   private String firstName = "";
   @NotNull
   private String lastName = "";
    ...

   @NotNull
   public final String getFirstName() { return this.firstName; }

   public final void setFirstName(@NotNull String value) {
      Intrinsics.checkNotNullParameter(value, "<set-?>");
      this.firstName = value;
   }

   @NotNull
   public final String getLastName() { return this.lastName; }

   public final void setLastName(@NotNull String value) {
      Intrinsics.checkNotNullParameter(value, "<set-?>");
      this.lastName = value;
   }

    // name 没有存储空间，而是一个方法调用。
   @NotNull
   public final String getName() { return this.firstName + ' ' + this.lastName; }
}

```


### 属性委托

属性委托将属性的 `getter`（和 `setter`）逻辑委托给另一个对象。

**使用条件**：`by` 右侧的委托对象必须提供特定签名的 `getValue()` 函数；如果属性是 `var`，还必须提供 `setValue()` 函数。这两个函数需要用 `operator` 标记。

```kotlin
class MyDelegate {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): String {
        return " delegated value"
    }
    // 如果是 var，还需要 setValue
}

class MyClass {
    val p: String by MyDelegate()
}
```
生成的实际代码为：

```kotlin
class MyClass {
    private val p$delegate = MyDelegate()

    val p: String
        get() = p$delegate.getValue(this, this::p)
}
```


### `by` 后跟方法调用：委托的是返回值

**`by` 后面的方法调用会被立即执行，Kotlin 将此次调用的返回值作为实际的委托对象。** 它委托给的是“返回值”，而不是“方法本身”或“方法的执行过程”。

### 1. 属性委托场景

```kotlin
val name: String by lazy {
    println("计算中...")
    "Kotlin"
}
```

很多人误以为 `by` 委托给了 `lazy` 这个方法。实际上：
- `lazy { ... }` 被立即调用，返回一个 `Lazy<String>` 对象。
- `by` 真正委托给的是这个返回的 `Lazy` 对象。
- Lambda 内部的代码此时并未执行，只有第一次访问 `name` 时才会执行。

**自定义委托验证**：

```kotlin
fun createDelegate(): StringDelegate {
    println("方法被调用了")
    return StringDelegate()
}

class MyClass {
    val prop: String by createDelegate() // 输出 "方法被调用了"
}
```
**一句话总结**：`by` 右侧的代码会被当作普通表达式求值，Kotlin 拿最终算出的“结果对象”去做委托，而不是委托“计算过程”。

### 重要陷阱：返回值必须有“资格”

- **属性委托**：返回值必须有 `operator fun getValue(...)`（`var` 还需要 `setValue`）。

```kotlin
fun returnString(): String = "hello"

class Test {
    // 编译报错！String 没有 getValue 方法
    val msg: String by returnString() 
}
```

### 局部变量中的 `by`：代理函数长什么样？

从 Kotlin 1.1 开始，方法内部也可以使用 `by` 声明局部变量，称为**局部委托属性**。但这里有一个核心真相：

**`by` 在方法内部不会生成像类属性那样的 getter/setter 代理函数**，因为方法内部没有“字段”和“属性访问器”的概念。

### 1. 类属性 vs 局部变量

**类中的属性**：

```kotlin
class MyClass {
    val name: String by lazy { "Kotlin" }
}
```

编译器会生成一个私有的 `Lazy` 委托对象字段，以及 `getName()` 方法，内部调用 `lazy.getValue(this, 属性元数据)`。

**方法中的局部变量**：

```kotlin
fun test() {
    val name: String by lazy { "Kotlin" }
    println(name)
    println(name)
}
```

编译器不会生成 getter，而是：
1. 将委托对象（`Lazy` 实例）保存为普通局部变量。
2. 每次读取 `name` 时，直接把代码替换成对委托对象 `getValue()` 的调用。

逻辑上等价于：

```kotlin
fun test() {
    val $delegate = lazy { "Kotlin" }
    println($delegate.getValue(null, $property$name))
    println($delegate.getValue(null, $property$name))
}
```

### 2. `getValue` 参数的变化

| 参数 | 类属性中 | 局部变量中 |
| :--- | :--- | :--- |
| **`thisRef`** | 传入外部类实例 (`this`) | **传入 `null`** |
| **`property`** | 编译器生成静态 `KProperty` | 编译器合成临时 `KProperty` |

### 3. 重要影响

由于局部变量中 `thisRef` 传 `null`，**并不是所有委托对象都支持在方法内使用**。

- **`lazy` 支持**：它忽略 `thisRef`，传 `null` 没问题。
- **自定义委托**：如果 `getValue` 要求 `thisRef` 非空（如 `ReadWriteProperty<Any, T>`），则不能用于局部变量。
- 标准库中的 `Delegates.observable` 实际接受 `Any?`，因此可以用于局部变量；但如果你自定义的委托声明为 `ReadWriteProperty<Any, T>`，就会失败。

**总结**：方法内的 `by` 不生成 getter/setter，而是直接内联调用 `getValue`/`setValue`，`thisRef` 传 `null`。类中的 `by` 会生成 getter/setter，`thisRef` 传类实例。


## 四、Kotlin 变量与其他语言的不同


## 五、CMP 中 `by` 的应用

在 Compose Multiplatform 开发中，`by` 是连接 Kotlin 语言特性与声明式 UI 的桥梁。

### 1. Compose 状态管理（最常用）

```kotlin
// 不使用 by
val countState = remember { mutableStateOf(0) }
// 需要写 countState.value

// 使用 by
var count by remember { mutableStateOf(0) }
// 可以直接写 count
```

`collectAsState()` / `collectAsStateWithLifecycle()` 也常配合 `by`：

```kotlin
val uiState by viewModel.uiState.collectAsStateWithLifecycle()
```

### 2. ViewModel 与架构组件

```kotlin
@Composable
fun MyScreen() {
    val viewModel: MyViewModel by viewModel()
}
```

在 ViewModel 内部，可以用 `by` 配合 `mutableStateOf` 定义可变状态，并用 `private set` 对外暴露只读属性。

### 3. 依赖注入（如 Koin）

```kotlin
class MyRepository(val api: ApiService) {
    val apiService: ApiService by inject()
}
```

### 4. 导航与架构库（如 Decompose）

```kotlin
class MyComponent(componentContext: ComponentContext) : 
    ComponentContext by componentContext
```

通过类委托实现 `ComponentContext`，避免不必要的继承。Decompose 的 `Value<T>` 也支持 `by` 委托。

### 5. 自定义属性委托

可以创建自定义委托，封装跨平台逻辑，例如设置存储：

```kotlin
val theme by settings.bound<AppTheme>()
```

在 Android 上使用 `SharedPreferences`，在 iOS 上使用 `NSUserDefaults`，公共代码中像普通属性一样读写。

### 6. 类委托封装平台 SDK

```kotlin
interface PlatformSDK { fun doSomething() }

class MyBusinessLogic(sdk: PlatformSDK) : PlatformSDK by sdk {
    override fun doSomething() {
        println("做一些额外的事情...")
    }
}
```