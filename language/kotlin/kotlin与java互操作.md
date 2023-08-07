# Kotlin JVM 注解

Kotlin 提供了几个注释，以促进 Kotlin 与 Java 之间的兼容性。在本教程中，我们将专门探讨 Kotlin 的 JVM 注释，如何使用它们，以及它们在 Java 中调用 Kotlin 类时起的作用。

**Kotlin 的 JVM 注释影响将 Kotlin 代码编译为字节码的方式，以及在Java中如何使用生成的类。**

这些注解对 Kotlin 中的使用，大多数不会产生影响。只有@JvmName 和 @JvmDefault （Kotlin 1.5 之后被 -Xjvm-default 取代了）对 Kotlin 的使用也会产生影响。

##  @JvmName

@JvmName 纾解可以应用于文件、函数、属性、getter和setter。以定义其在字节码中的名称，这也是我们在从 Java 引用时可以使用的名称。

**但它不会改变它们在 Kotlin 中的名称**。我们进一步演示其各个使用方法。

### 文件名

默认情况下，Kotlin 中的顶层函数和属性会被编译成所在文件的 `[file name]KT.class`，类被编译成 `[class name].class`。这也影响到到顶层函数在 Java 中的调用名，就是 `[file name]KT.functionName(...)`。

当我们想要修改顶层函数在 Java 中的类名时，我们可以使用 `@file:JvmName("new name")` 来命名其生成的类名。假入有文件名为 `message.kt` 的 Kotlin 代码

```Kotlin
package jvmannotation

fun getMyName() : String {
    return "myUserId"
}

class Message {
}
```
此时 Kotlin 生成的 `MessageKt` 和 `Message` 两个类。我们可以将文件名命名为 `MessageHelper`

```Kotlin
@file:JvmName("MessageHelper")
package jvmannotation
```
此时就可以在 Java 中调用

```Java
String me = MessageHelper.getMyName();
```

### 方法名

@JvmName 注释更改字节码中函数的名称。例如
```Kotlin
@JvmName("getMyUsername")
fun getMyName() : String {
    return "myUserId"
}
```

但是我们在 Kotlin 中只能使用原名称。



**重命名需要注意混淆的问题**

也可以改名生成的 geter 和 setter 方法。

```Kotlin
@get:JvmName("getContent")
@set:JvmName("setContent")
var text = ""
```

**重命名同样遵循访问控制权限，给 val 类型变量重命名 set，或者重命名 private 类型的 getter/setter 名称都会报错**

## @JvmStatic and @JvmField


### @JvmField
Kotlin 默认情况下不会暴露字段（字段都是 private 的）。即使 public 也是对于其 getter 和 setter 而言。

为例能像 Java 一样将字段声明为 public，可以使用 `@JvmField` 做到这一点。此时不会再为字段生成 setter 和 getter 方法。

```Kotlin
open class MessageBroker2 {
    var messageWord = 0

    @JvmField
    var maxMessagePerSecond = 0
}
```
对应的 Java 代码
```Java
public class MessageBroker2 {
   private int messageWord;
   @JvmField
   public int maxMessagePerSecond;

   public final int getMessageWord() {
      return this.messageWord;
   }

   public final void setMessageWord(int var1) {
      this.messageWord = var1;
   }
}
```

如下情况无法使用 `@JvmField` 注解：

- private 属性

- open, override, const 修饰的属性

- 委托的属性


### @JvmStatic

`@JvmStatic` 注解可以应用于使用 `object` 所创建对象或者伴生对象的属性或方法。

```Kotlin
object MessageBroker {
    var totalMessagesSent = 0
    fun clearAllMessages() { }
}
```
在 Kotlin 中我们可以通过类名访问
```Kotlin
val total = MessageBroker.totalMessagesSent
MessageBroker.clearAllMessages()
```
但是在 Java 中
```
int total = MessageBroker.INSTANCE.getTotalMessagesSent();
MessageBroker.INSTANCE.clearAllMessages();
```
为了能在 Java 中也使用相同的方式访问，我们需要使用 `@JvmStatic` 注解

```Kotlin
object MessageBroker {
    @JvmStatic
    var totalMessagesSent = 0
    @JvmStatic
    fun clearAllMessages() { }
}
```

###  @JvmStatic 与 @JvmField 差异

为了更好地理解@JvmField、@JvmStatic和Kotlin中的常量之间的区别，让我们看一下下面的示例
```Kotlin
object MessageBroker {
    @JvmStatic
    var totalMessagesSent = 0

    @JvmField
    var maxMessagePerSecond = 0

    const val maxMessageLength = 0
}
```
命名对象是单例的 Kotlin 实现。它被编译成一个带有私有构造函数和公共静态 INSTANCE 字段的 final 类。上面类等价的 Java 代码是

```Java
public final class MessageBroker {
    private static int totalMessagesSent = 0;
    public static int maxMessagePerSecond = 0;
    public static final int maxMessageLength = 0;
    public static MessageBroker INSTANCE = new MessageBroker();

    private MessageBroker() {
    }

    public static int getTotalMessagesSent() {
        return totalMessagesSent;
    }

    public static void setTotalMessagesSent(int totalMessagesSent) {
        this.totalMessagesSent = totalMessagesSent;
    }
}
```

- `@JvmStatic` 注释的属性生成私有静态字段以及相应的 getter 和 setter 方法。

- `@JvmField` 注释的字段生成一个公共静态字段，不生成 getter 和 setter 方法。

- 常量相当于一个 public 静态 final 字段。


## JvmOverloads

在 kotlin 中函数允许有默认值，Java 中没有这个功能，但是希望能够像带默认值一样使用。JvmOverloads 注解能够将带默认值的函数生成 Java 的重载函数。

```Kotlin
class KotlinClass @JvmOverloads constructor(var name: String, var age: UInt)
```

## @Throws

Kotlin 没有检查异常，这意味着调用抛出异常的函数的 try-catch 总是可选的

```Kotlin
fun findMessages(sender : String, type : String = "text", maxResults : Int = 10) : List<Message> {
    if(sender.isEmpty()) {
        throw IllegalArgumentException()
    }
    return ArrayList()
}


MessageBroker.findMessages("me")

try {
    MessageBroker.findMessages("me")
} catch(e : IllegalArgumentException) {
}
```
在 Java 中调用同样也是可选的，为了能在 Java 中强制使用 try-cache 可以使用 `@Throws` 修饰 findMessages 函数。

## @JvmWildcard and @JvmSuppressWildcards

当使用 Kotlin 时，子类的容器能够赋值给父类的容器:

```Kotlin
val numberList : List<Number> = ArrayList<Int>()
```
但是在 Java 中，我们必须使用通配符来实现同样的操作

```Java
List<? extends Number> numberList = new ArrayList<Integer>();
```

当泛型作为参数时，Kotlin 会根据规则来生成合适的 Java 通配符，方便互操作。

```Kotlin
fun transformList(list : List<Number>) : List<Number>
```

实际上，Kotlin 生成的代码就等价于如下 Java 代码:
```Java
public List<Number> transformList(List<? extends Number> list)
```

Kotlin 生成的规则是，如果参数类型可继承就会生成通配符，否则 final 类型不会生成通配符。

使用 `@JvmWildcard` 总是生成带通配符的泛型，而 `@JvmSuppressWildcards` 则避免生成通配符的泛型。

```Kotlin
fun transformList(list : List<@JvmSuppressWildcards Number>) : List<@JvmWildcard Number>
```
等价的 Java 代码是

```Java
public List<? extends Number> transformListInverseWildcards(List<Number> list)
```


##  @JvmMultifileClass

当使用 `@JvmName` 将文件生成的类重命名时，如果有两个类重名，就会导致错误。此时我们可以使用 `@file:JvmMultifileClass` 告诉编译器将两个类合并。

```Kotlin
@file:JvmName("MessageHelper")
@file:JvmMultifileClass
package jvmannotationfun
convert(message: Message) = // conversion code
```

```Kotlin
@file:JvmName("MessageHelper")
@file:JvmMultifileClass
package jvmannotation
fun archiveMessage() =  // archiving code
```

## @JvmSynthetic

如果你写的一个函数你只想给 kotlin 代码调用而不想被 java 的代码调用，可以使用此注解。

## @PurelyImplements

将 Java 类指定为某个 Kotlin 接口的实现类。使该类中的每个参数都当成非平台类型处理。

Kotlin 会将 Java 中的类作为平台类型处理，由开发者处理其是可空还是非空。但即便将其声明为非空，但其实他还是能接收空值或者返回空值。
```Java
// java文件

class MyList<T> extends AbstractList<T> { ... }
```

```Kotlin
// kotlin文件
MyList<Int>().add(null) // 编译通过
```

借助 `@PurelyImplements` 注解，并携带对应的 Kotlin 接口。使其与 Kotlin 接口对应的类型参数不被当作平台类型来处理。

```Java
@PurelyImplements("kotlin.collections.MutableList")
class MyList<T> extends AbstractList<T> { ... }
```
```Kotlin
// kotlin文件
MyList<Int>().add(null) // 编译错误
```

**注解中的 Kotlin 类一定有相同的方法，对应的 Java 方法才会有对应检查。**


## 其余

`@JvmRecord` 注解只有用JVM 15+的版本去编译 Kotlin 代码时才能够使用，用于支持 Java 14 中引入的 record class。
`@Strictfp` 等价于Java的strictfp关键字
`@Transient` 等价于Java的transient关键字
`@Volatile` 等价于Java的volatile关键字
`@Synchronized` 等价于Java的synchronized关键字
`@JvmInline` 和 `value` 同时使用，将 Kotlin 类声明为内联类，编译后，类会去封装，类会被替换成原始类型。

```Kotlin
@JvmInline
value class User(val name: String)
```



https://www.baeldung.com/kotlin/jvm-annotations#jvm-multifile-class