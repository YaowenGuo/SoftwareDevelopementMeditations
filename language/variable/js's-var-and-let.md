# const、let、var区别+js严格模式

[TOC]

## 一、const、let、var的区别

const定义的变量不可修改，const一般在require一个模块的时候用或者定义一些全局常量
let声明的变量作用域是在块级域中，函数内部使用let定义后，对函数外部无影响，可以在声明变量时为变量赋值，默认值为undefined,也可以稍后在脚本中给变量赋值，在生命前无法使用。
var 声明的变量作用域是全局的或者是函数级的


## 二、let和var关键字的异同

### 声明后未赋值，表现相同
```
'use strict';

(function() {
  var varTest;
  let letTest;
  console.log(varTest); //输出undefined
  console.log(letTest); //输出undefined
}());
```
### 使用未声明的变量，表现不同:
(function() {
  console.log(varTest); //输出undefined(注意要注释掉下面一行才能运行)
  console.log(letTest); //直接报错：ReferenceError: letTest is not defined

  var varTest = 'test var OK.';
  let letTest = 'test let OK.';
}());

### 重复声明同一个变量时，表现不同：
```
'use strict';

(function() {
  var varTest = 'test var OK.';
  let letTest = 'test let OK.';

  var varTest = 'varTest changed.';
  let letTest = 'letTest changed.'; //直接报错：SyntaxError: Identifier 'letTest' has already been declared

  console.log(varTest); //输出varTest changed.(注意要注释掉上面letTest变量的重复声明才能运行)
  console.log(letTest);
}());
```
### 变量作用范围，表现不同
```
'use strict';

(function() {
  var varTest = 'test var OK.';
  let letTest = 'test let OK.';

  {
    var varTest = 'varTest changed.';
    let letTest = 'letTest changed.';
  }

  console.log(varTest); //输出"varTest changed."，内部"{}"中声明的varTest变量覆盖外部的letTest声明
  console.log(letTest); //输出"test let OK."，内部"{}"中声明的letTest和外部的letTest不是同一个变量
}());
```

### let 具有块级作用域

```
'use strict';

(function() {
  {
    var varTest = 'varTest.';
    let letTest = 'letTest changed.';
  }

  console.log(varTest); // 输出"varTest."，"{}"内部声明的varTest变量被提到函数的顶级作用域中
  console.log(letTest); // 直接报错：ReferenceError: letTest is not defined。 因为 let 声明的变量具有块级作用域。
}());
```

## 三、javascript严格模式'use strict';

- 判断浏览器是否支持严格模式：var hasStrictMode=(function(){"use strict";return this===unsefined;}());
- 在严格模式中禁止使用with语句
- 在严格模式中，所有变量要先声明，否则catch从句参数或全局对象的书zing赋值，将会throw一个引用错误（在非严格模式下，这种隐式声明的全局变量的方法是给全局对象添加一个新属性）
- 在严格模式中，调用的函数（不是方法）中的一个this值是undefined.(在非严格模式下，调用函数中的this值总是全局对象)。可以利用这种特性来判断js实现是否支持严格模式。
- 同样，在严格模式中，当通关过call()或apply()来调用函数时，其中的this值就是call()或apply()传入的第一个参数（在非严格模式下，Null和undefined值被全局对象和转换为对象的非对象值所代替）
- 在严格模式下，给只读属性赋值和给不可扩展的对象创建新成员都将抛出一个类型错误异常（在非严格模式下，这些操作只是简单的操作失败，不会抛错）
- 在严格模式下，传入eval_r()的代码不能在调用程序所在的上下文中声明变量或定义函数，二在非严格模式中可以这样的。姓范，变量和函数定义是在eval_r()创建的新作用于中，这个作用域在eval_r()返回就弃用了。
- 更多更详细的关于”javascript 严格模式”说明，请参考阮一峰的博客 《Javascript 严格模式详解》
