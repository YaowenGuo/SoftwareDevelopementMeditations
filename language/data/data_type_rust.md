# 数据类型

## (标量 scalar)


由于 Rust 是一种系统级变成语言，为了更好的理解数据的存储，Rust 抛弃了常用数据语言各种数据类型的概念，直接使用位来表示数据类型。简洁而有规律：

四种类型的数据: integers, floating-point numbers, Booleans, and characters. 

其中整形有：

| Length |	Signed | Unsigned |
| ------ | ------- | -------- |
| 8-bit	 |  i8	   | u8       |
| 16-bit |	i16	   | u16      |
| 32-bit |	i32	   | u32      |
| 64-bit |	i64	   | u64      |
| 128-bit|	i128   | u12      |
| arch	 |  isize  | usi      |

另外，isize和usize类型取决于您的程序运行的计算机类型：如果您使用的是64位体系结构，则为64位；如果您使用的是32位体系结构，则为32位。

Rust 默认整数类型的默认设置为i32：即使在64位系统上，这种类型通常也是最快的。 您要使用isize或usize的主要情况是在对某种集合进行索引时。

### 浮点类型

f32 和 f64.

默认是 64 为浮点类型，因为在现代计算机上，两者速度差不多，但精度更高。

```rust
fn main() {
    let x = 2.0; // f64

    let y: f32 = 3.0; // f32
}
```

### 布尔类型

true 和 false

### 字符类型

Rust’s char type is four bytes in size and represents a Unicode Scalar Value。

```rust
fn main() {
    let c = 'z';
    let z = 'ℤ';
    let heart_eyed_cat = '😻';
}
```

### 单元类型 (Unit type)

Unit type 仅有一个值，即 (); 单元类型用于表示没有值，类似于其他语言中的 void; 

Everything in Rust is an expression, and expressions that return "nothing" actually return (). The compiler will give an error if you have a function without a return type but return something other than () anyway. For example

1. unit type是一个类型，有且仅有一个值，都写成小括号()
单元类型()类似c/c++/java语言中的void。当一个函数并不需要返回值的时候，c/c++/java中函数返回void，rust则返回()。但语法层面上，void仅仅只是一个类型，该类型没有任何值;而单位类型()既是一个类型，同时又是该类型的值。

2. 单元类型()也类似c/c++/java中的null，但却有很大不同。 null是一个特殊值，可以赋给不可类型的值，例如java中的对象，c中指向struct实例的指针，c++中的对象指针。但在rust中，()不可以赋值给除单元类型外的其它的类型的变量，()只能赋值给()。
3. Rust标准库中使用单元类型()的一个例子是HashSet。一个HashSet只不过是HashMap的一个非常简单地包裹，写作：HashMap<T, ()>。HashMap的第二个泛型类型参数即用了单元类型()

4. 可以用Result<(), MyErrorType>代替Option，某些开发者认为Result<(), MyErrorType>语义上能更简明地表示一个“结果”。

```rust
fn f() {
    1i32 // error: mismatched types: expected `()` but found `int`
}
```



## 复合 compound

Rust 原生支持两种复合类型：元祖，数组

### 元组

- 长度不可变
- 数据类型不一定相同。
- 可以解构

```rust
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("The value of y is: {}", y);

    let five_hundred = tup.0;

    let six_point_four = tup.1;

    let one = tup.2;
}
```

### 数组

- 长度不可变
- 数据类型必须相同
- 每一项课更改

可以像如下的方式来声明一定数量的数组。

```rust
let months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];

let a: [i32; 5];

let a = [3; 5]; // 申请长度为 5 的数组，并且全部赋值为 3.
```

**与许多低级语言不同，Rust 会检查索引访问是否越界，一旦越界将导致程序崩溃。这是 Rust 避免内存溢出访问，保证安全的方式之一。内存溢出是 C/C++ 内存攻击的方式之一。**


## 语句(Statement)和表达式(expression)

Rust 是一中基于表达式的语言。表达式和语句有着明显的区别。

- 语句是执行某些操作且不具有返回值。 表达式则计算结果为结果值。表达式有返回值，语句没有。

声明变量是一种语句

```rust
let y = 6;
// 不合法，let y 不具有返回值。
let x = (let y = 6);
```

大多数操作都是表达式，例如算数运算。

```rust
let y = {
    let x = 3;
    x + 1 // 注意没有分号，否则将变成语句。
};
```

- 表达式不包括结尾分号。添加分号将表达式变成语句。

- 表达式可以不使用 `return` 关键字，在函数最后一样时，而自动作为返回值。

```rust
fn five() -> i32 {
    5
}

// 或者
fn five() -> i32 {
    return 5; // 注意分号。
}

```

## 自定义

三种

1. struct
    1. struct
    2. tuple struct
    3. unit-like struct
2. enum

3. trait object

