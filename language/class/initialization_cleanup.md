
不安全的编程方式是编程代价高昂的原因之一，初始化和清理正设计到这个问题。


## 构造函数

构造函数保证了类的成员能在使用之前初始化，而不是由使用者记得去初始化，以及如何初始化，何况等多情况是，使用者并不清楚如何初始化复杂的内部逻辑。

OOP 类型的语言会在创建对象时自动调用构造函数，由于构造函数是由编译器确保调用的，为了让编译器知道，构造函数都有一个固定的名字，而名字是什么则五花八门。

- 构造函数都没有返回值
- 构造函数会在对象创建的时候自动调用，是编辑器的一个行为


### C++ & Java

C++ 和 Java 都使用类名作为初始化函数名。
```
// C++
class ClassName { // 定义
public:
    ClassName([args...]); // 构造函数声明

}

ClassName::ClassName([args...]) {  // 构造函数实现

}


// Java

class ClassName { // 定义
    public ClassName([, args...]) { }; // 构造函数定义

}

```
### PHP

PHP 使用 `__construct` 作为构造函数名
- 使用 `function` 表示这是个函数
```
class ClassName { // 定义
    function __construct([args...]) { }; // 构造函数定义

}
```
### Python

Python 则使用 `__init__` 做函数名，与其他语言不通的是，python 必须在声明的时候将 self 对象自身引用作为第一个参数，这在其他语言中都是隐式传入的，并不需要自己写。

`__init__` 方法的名称中,开头和末尾各有两个下划线,这是一种约定,旨在避免 Python 默认方法与普通方法发生名称冲突。



- 使用 `def` 定义构造函数
```
class ClassName { // 定义
    def __init(self [, args...]) { }; // 构造函数定义

}
```
形参 self 必不可少,还必须位于其他形参的前面。为何必须在方法定义中包
含形参 self 呢?因为 Python 调用这个 __init__() 方法来创建 Dog 实例时,将自动传入实参 self 。每个与类相关联的方法调用都自动传递实参 self ,它是一个指向实例本身的引用,让实例能够访问类中的属性和方法。我们创建 Dog 实例时, Python 将调用 Dog 类的方法 __init__() 。


### JS

由于 JS 不是 OOP 语言，所以并没有构造函数一说，但是并不意味着不能自动对内部变量初始化，可以使用 JS 自有的机制来处理。

Javascript本身并不支持面向对象，它没有访问控制符，它没有定义类的关键字class，它没有支持继承的extend或冒号，它也没有用来支持虚函数的virtual，不过，Javascript是一门灵活的语言，下面我们就看看没有关键字class的Javascript如何实现类定义，并创建对象。

Javascript并不支持OOP，当然也就没有构造函数了，不过，我们可以自己模拟一个构造函数，让对象被创建时自动调用，代码如下：

```
function Shape(width, height)  
{  
    var init = function ()  
    {  
        // 构造函数代码   
        this.width = width;
        this.height = height;
    };  
    init();
}

```
在Shape的最后，我们人为的调用了init函数，那么，在创建了一个Shape对象是，init总会被自动调用，可以模拟我们的构造函数了。

其实这样有些多次一举，因为该定义本身就是函数，它本身就能传入参数，在它内部定义的非函数，都会被自动执行，因此，其本身就可以当做一个构造函数。

```
function Shape(width, height)  
{  
    this.width = width;
    this.height = height;
}

aShape.width
```

我喜欢这种简洁统一的方式，你只需要记住一套逻辑，它在任何时候都试用。他减少了代码的编写，即便是只有几行。



## 析构函数
