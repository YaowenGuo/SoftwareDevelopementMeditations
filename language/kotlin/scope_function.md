# 作用域函数

先看一个小例子：

在 Java 中，如果我们需要连续调用一个对象的多个函数，通常是这样：


```Java
MomentModule module = MomentModule.getInstance();
module.init(application);
module.setCompatibleRouter((context, url) -> CompatibleRouter.getInstance().open(context, url));
module.setHav(UniApplication.ARTICLE_API_VERSION);
```

为了简化代码，一种方式是供链式的调用方式，这时候需要函数的返回对象是该对象的实例本身：

```Java
public UniApplication init(Appapplication) {
    ...
    return this; // <------- 返回自身
}

// 这时候我们可以进行链式调用：
MomentModule.getInstance()
    .init(application)
    .setCompatibleRouter((context, url) -> CompatibleRouter.getInstance().open(context, url));
```

但是这样的调用显然有一个明显的缺陷。就是当函数本身有返回值的时候，就会终止链式调用。而对于没有返回值的方法，改为返回 this 也有诸多不便：
- 一种是都返回 this，这种为未来预留接口的作坊，当用不到就显得多余。
- 另一种是用到时再修改，但是如果是三方库，未必能立即修改。

另一点是在 Kotlin 中，对于可空对象的空判断，多次调用对象的代码会使代码变得比较难看。

```Kotlin
// 假如 intent 是可空的
intent?.setAction("miui.intent.action.APP_PERM_EDITOR");
intent?.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity");
intent?.putExtra("extra_pkgname", packageName);
```

为了解决这样的问题，Kotlin 提供了作用域函数。使用作用域函数我们的代码能够书写起来更加简洁：

```Kotlin
intent?.with {
    setAction("miui.intent.action.APP_PERM_EDITOR");
    setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity");
    putExtra("extra_pkgname", packageName);
}
```

作用域函数为 `执行的代码块`提供`一个临时作用域`，可以使代码更加简洁和可读。


Kotlin 中常用的五个作用域函数：`let`、`with`、`also`、`run`、`apply`。

这些作用域函数的区别主要有以下三部分：
- 是拓展函数，还是普通函数
- 上下文对象是 `this` 还是 `it`
- 返回值是自身还是lambda的最后一行


| 函数	| 类型 | 参数类型（it,this）| 返回值(本身，最后一行) |
| ---- | --- | ----------------- | ------------------ |
| with | 非拓展函数	 | this	       | 最后一行            |
| run  | 非拓展函数  | 无	       | 最后一行             |
| T.run	| 拓展函数	 | this	      | 最后一行             |
| T.let | 拓展函数	 | it	      | 最后一行             |
| T.also | 拓展函数	 | it	      | 本身                |
| T.apply |	拓展函数 | this	      | 本身                |


run 和 with 这种普通函数，主要用于封装代码，将同一逻辑的代码分块(在 Java 代码中我们通常使用添加空行来分割不同逻辑的代码块)：

例如

```Kotlin
fun main() {
    val name = "write code"
    val name2 = run {
        var name = "read code"
        println(name) //输出read code
        name = "write code"
        name
    }
    println(name) //输出write code
    println(name==name2) //输出true
}
```
`with` 接收一个参数，使用的情况不多，在面向对象的编程风格中，优先选择扩展函数。
```Kotlin
fun learnWith(){
    val person = Person("hui","boy")
    with(person){
        print(name)
        print(sex)
    }
}
```

使用扩展函数

```Kotlin
intent?.with {
    setAction("miui.intent.action.APP_PERM_EDITOR");
    setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity");
    putExtra("extra_pkgname", packageName);
}
```

## 选择哪个函数

对于扩展函数形式的作用域函数，let、run、also、apply 首先考虑的是返回值和参数的名称。

- 如果要接收返回类型，根据返回类型选择。
- 使用 this 还是 it 作为参数的函数主要考虑上下文。当在一个类的方法中调用时，当仅仅访问类的成员，可以忽略 this 时，通常更简洁。

```Kotlin
val adam = Person("Adam").apply {
    age = 20                       // same as this.age = 20
    city = "London"
}
println(adam)
```

但是如果需要访问对象本身，this 很容易和类的 this 混淆，使代码不够清晰，反而使用 `it` 的函数代码更加清晰。
```
val adam = Person("Adam").let {
    it.age = 20                       // same as this.age = 20
    it.city = "London"
    println(it)
}
```


## 其它使用

有了这些作用域函数，我们可以将函数调用变得更加丝滑。也可以解决在链式调用的时候某个
函数因为有返回类型而导致调用链终止。


```Kotlin
val dialogBuilder = Dialog.Builder()
    .setWidth(width)
    .setHeight(height)
    .with {
        setBgColor(Color.WHITE)  // 有一个没有返回对象自身的函数，无法进行链式调用
        this
    }
    .build()
```


参考文档： https://kotlinlang.org/docs/scope-functions.html#takeif-and-takeunless