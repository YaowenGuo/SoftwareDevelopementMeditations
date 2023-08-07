# Definition

### C++

C++ 的声明和定义是分开的，还有一个缺点 C++ 不能引用后定义的类，实在是一个不人性化的设计。
```
class ClassName; // 声明，可选的，只要

class ClassName { // 定义

}
```

### Java, PHP, Python
显然其他语言都认识到了这个问题，所以 Java、PHP、Python 都是定义即声明，并且不分前后，前面定义的类可以访问在后面定义的类。
```
class ClassName { // 定义

}
```

### JS

Js 则有些奇葩，它不属于类继承语言，而是对象继承语言。并且 Js 中一切皆对象，包括函数。因此可以看到它的类定义方法非常奇怪，并且多样。

#### 构造函数方式

```
function Shape(width, height)  
{  
    this.width = width ;  
    this.height = height ;  
}

var aShape = new Shape(2, 3);
// 使用 new 创建对象是必须的，否则 aShape 将是 Shape 函数的引用而已。
// 用var可以定义类的private属性，而用this能定义类的public属性。
// 使用 this 创建成员变量，否则是私有变量，在函数执行结束就销毁了，不能通过对象访问。
aShape.width // 没有 this 的私有变量不能通过此种方法访问。
```
可见，JS 并不存在定义类这一概念，而是在创建对象时，使用 new 关键字来表示创建一个对象（申请空间，创建一个拷贝）。不过你依旧可以认为它是一个类，只不过它跟别的语言不同而已，因为它具有类该有的本质性质，就是创建新的对象。


以上这种定义类的方式称为构造函数方式

#### 工厂方式

```
// 1、工厂方式  
function createShape(width, height){  
    var shape = new Object;  
    shape.width = width;  
    shape.height = height;  

    shape.getWidth = function(){  
        return this.width;  
    };  
    return shape;  
}
var aShape = createShape(4, 5);  
aShape.getWidth();
```
但有个小问题，每次创建对象都对创建一个 getWidth 函数对象，这是多余的。可以将其移到外边

```
function getWidth() {
    return this.width;
}

function createShape(width, height){  
    var shape = new Object;  
    shape.width = width;  
    shape.height = height;  

    shape.getWidth = getWidth;
    return shape;
}  
var aShape = createShape(4, 5);  
aShape.getWidth();

```

#### 原型方法

```
function Shape(){  
}  
Shape.prototype.width = 3;  
Shape.prototype.height = 4;  
Shape.prototype.getWidth = function(){  
  return this.width
};  
var aShape = new Shape();  
aShape.getWidth();
```

首先定义了构造函数 Shape，但无任何代码，然后通过 prototype 添加属性。优点：
  a. 所有实例存放的都是指向 getWidth 的指针，解决了重复创建函数的问题
  b. 可以用 instanceof 检查对象类型
  alert(aShape instanceof Shape);//true
  缺点，添加下面的代码：
  bShape.prototype.points = newArray("mike", "sue");
  cShape.drivers.push("matt");
  alert(bShape.points);//outputs "mike,sue,matt"
  alert(bShape.points);//outputs "mike,sue,matt"
  drivers 是指向 Array 对象的指针，proCar 的两个实例都指向同一个数组。

#### 动态原型方法
```
function Shape(width, height){  
    this.width = width;  
    this.height = height;  
    if(typeof Shape.initialized == "undefined"){  
        autoProCar.prototype.getWidth = function() {  
            return this.width;
        };
   };  
   Shape.initialized = true;  
  }  
}  
var aShape = new Shape(3, 4);  
aShape.getWidth();  
```

这种方式是我最喜欢的， 所有的类定义都在一个函数中完成， 看起来非常像其他语言的
类定义，不会重复创建函数，还可以用 instanceof
