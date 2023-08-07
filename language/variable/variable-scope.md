# The scope of the Variable

[TOC]

javascript 的 let 和其他语言相同，但是 var 很特别，需要单独说明。

## 同一级不能重复定义

> C、C++、Java、Js 的 let

```
int a = 1;
int a = 2; // 语法错误
```
不需要指定变量的定义的语言显然分不出是否重复定义，因为他们的定义和重复复制是一样的，所以这类语言对变量的表示的使用即定义。


> python、php、Js 的 var

python

```
a = 1 // 定义和赋值
a = 2 // 改变其值为2
```
php
```
$a = 1; // 定义并赋值
$a = 2; // 改变其值为2
```

有意思的是，不需要指定变量定义的语言，由于不存在声明，所以变量是不允许不赋值的。即在 python和 php 中，使用 `a;` 是错误的。这更符号现代语言建议的：延迟定义变量的建议。

## 代码块中定义的是不同变量（显然不适合非声明式语言: python, php）

> C、C++、Java、Js 的 let

```
int a = 1;
{
    int a = 2;
    print("%d\n", a); // 输出 2
}
print("%d\n", a); // 输出 1, 局部作用域中的变量和外部变量时两个不同的变量，虽然同名。
```

> Python、PHP、Js 的 var。（非声明式语言）是对外部的变量进行赋值。

python 由于不使用 `{}` 表示代码的块，所以没有单独的块说明，只有 if、while、foreace 之类的块作用域。

## 代码块中可以对外部变量进行赋值

> C、C++、Java、python、js 的 let 和 var 终于保持一致了

```
int a = 1;
{
    a = 2;
    print("%d\n", a); // 输出 2
}
print("%d\n", a); // 输出 2，更改的是外部作用域的变量。
```


## 代码块中定义的变量的声明周期为代码块，(Python、PHP 不是)。

> C、C++、Java、js 的 let

```

{
    a = 2;
    print("%d\n", a); // 输出 2
}
print("%d\n", a); // 错误，未定义
```
> Python 和 PHP Js 的 var 块中定义的变量都可以带出作用域

```
if (True):
    a = 2
    print(a) # 2
print(a) # 2
```
PHP
```
if (true):
    $a = 2
    print($a) // 2
print($a) // 2
```
