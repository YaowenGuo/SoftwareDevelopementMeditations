# Ownership

堆内存的管理一直是内存管理的一个难题，目前处理堆内存管理主要有两种方式：

- 开发者自己管理堆的申请和释放。C，C++ 都是需要开发者来处理。这种方式主要的问题是，开发很可能忘记释放内存，在逻辑复杂的情况下，很可能很难判断什么时候该释放。

- 有垃圾回收器定期回收。垃圾回收器由独立的内存管理进程，定期回收不再使用的堆空间。垃圾回收器的问题是，因为牵涉到现有变量内存的整理和变量指向修改。垃圾回收会暂停程序的执行，而且时间是不可预测的。这对于实时系统是不可接受的。


Rust 才用了一中独特的方式，有编译器来推测并释放对空间。没有垃圾回收的耗时，拥有和开发者自主管理释放堆一样的效率。同时由于有编译器的来管理释放，开发者不再费劲心力关于堆空间的释放。而且由于编译器的强制检查，不会存在被忘记释放的内存。

为了实现编译器的推测，Rust 引入了所有权和生命周期的概念。

## 所有权规则

- 每个值都有一个变量，被称为所有者。
- 在同一时刻仅能有一个所有者。
- 当所有者出来自己的作用域之后，该值被删除。

变量复制、函数参数传递、返回值都会转移所有权。

When a variable goes out of scope, Rust calls a special function for us. This function is called drop

When a variable that includes data on the heap goes out of scope, the value will be cleaned up by drop unless the data has been moved to be owned by another variable.


哪些类型是复制的？

- All the integer types, such as u32.
- The Boolean type, bool, with values true and false.
- All the floating point types, such as f64.
- The character type, char.
- Tuples, if they only contain types that are also Copy. For example, (i32, i32) is Copy, but (i32, String) is not.
- A type has the Copy trait, an older variable is still usable after assignment. Rust won’t let us annotate a type with the Copy trait if the type, or any of its parts, has implemented the Drop trait. 

通常，任何一组简单标量值可能是复制的。任何部分不需要申请资源的是复制的。 For example, (i32, i32) is Copy, but (i32, String) is not.


## 引用

引用不转移所有权。

```rust
let s1 = String::from("hello");

// let s: &String;
let s = &s1;

println!("The reference of s1 {} is {}.", s1, s);
```
![](images/reference.svg)

可以看到 Rust 的引用很像 C 的指针，指向变量的地址，同时赋值也是使用 `&` 取地址。不同的是访问值可以直接使用 `s` 而不用使用 C 中特殊的取值符号‘*’。

我们称引用赋值为租借，并没有获得所有权。所以当引用超出作用域后，引用被删除。由于租借从没有拥有所有权，所以也不会删除变量。


但是可变引用有一个很大的限制:在统一作用域内，只能有一个对特定数据的可变引用。这个代码将会失败

```rust
let mut s = String::from("hello");

let r1 = &mut s;
let r2 = &mut s;

println!("{}, {}", r1, r2);
```

有这个限制的好处是，Rust 可以防止编译时的数据竞争。数据竞争类似于竞争条件，当这三种行为发生时就会发生数据竞争

- 两个或多个指针同时访问相同的数据。

- 至少有一个指针用于写入数据。

- 没有用于同步访问数据的机制。

数据竞争会导致未定义的行为，当您试图在运行时跟踪它们时，很难诊断和修复它们。Rust阻止了这个问题的发生，因为它甚至不会编译带有数据竞争的代码。

不在同一作用域得代码可以定义多个可变引用。

```rust
let mut s = String::from("hello");

{
    let r1 = &mut s;
} // r1 goes out of scope here, so we can make a new reference with no problems.

let r2 = &mut s;
```

当我们拥有不变的参考时，我们也不能拥有可变的参考。 不变引用的用户不会期望值从它们下面突然改变！ 但是，可以使用多个不可变的引用，因为没有人会仅仅影响读取数据。

Note that a reference’s scope starts from where it is introduced and continues through the last time that reference is used. For instance, this code will compile because the last usage of the immutable references occurs before the mutable reference is introduced:

```
let mut s = String::from("hello");

let r1 = &s; // no problem
let r2 = &s; // no problem
println!("{} and {}", r1, r2);
// r1 and r2 are no longer used after this point

let r3 = &mut s; // no problem
println!("{}", r3);
// println!("r1: {}, r3: {}",r1, r3); // BIG PROBLEM
```


### Dangling References

In languages with pointers, it’s easy to erroneously create a dangling pointer, a pointer that references a location in memory that may have been given to someone else, by freeing some memory while preserving a pointer to that memory. In Rust, by contrast, the compiler guarantees that references will never be dangling references: if you have a reference to some data, the compiler will ensure that the data will not go out of scope before the reference to the data does.


```rust
fn main() {
    let reference_to_nothing = dangle();
}

fn dangle() -> &String { // dangle returns a reference to a String

    let s = String::from("hello"); // s is a new String

    &s // we return a reference to the String, s
} // Here, s goes out of scope, and is dropped. Its memory goes away.
  // Danger!
```

解决办法是避免 s 的回收，直接返回 s 本身，将所有权转移出函数作用域。


### 切片

slice for all sorts of other collections.

String Literals Are Slices

```rust
let s = "Hello, world!";
```

The type of s here is &str: it’s a slice pointing to that specific point of the binary. This is also why string literals are immutable; &str is an immutable reference.

```rust
fn first_word(s: &String) -> &str
```
```rust
fn first_word(s: &str) -> &str;
```

If we have a string slice, we can pass that directly. If we have a String, we can pass a slice of the entire String. Defining a function to take a string slice instead of a reference to a String makes our API more general and useful without losing any functionality:

```rust
fn main() {
    let my_string = String::from("hello world");

    // first_word works on slices of `String`s
    let word = first_word(&my_string[..]);

    let my_string_literal = "hello world";

    // first_word works on slices of string literals
    let word = first_word(&my_string_literal[..]);

    // Because string literals *are* string slices already,
    // this works too, without the slice syntax!
    let word = first_word(my_string_literal);
}
```


### 引用的生存时间

大多数情况下，生存时间是隐式的，并且被自动推断。当引用的生存期可以以几种不同的方式关联时，我们必须注释生存期。Rust要求我们使用通用生命周期参数来注释关系，以确保在运行时使用的实际引用绝对有效。

可以说，lifetime 是 Rust 中最独特的功能。

？
Lifetime annotations don’t change how long any of the references live. Just as functions can accept any type when the signature specifies a generic type parameter, functions can accept references with any lifetime by specifying a generic lifetime parameter. Lifetime annotations describe the relationships of the lifetimes of multiple references to each other without affecting the lifetimes.
？

生存期注释的语法有一点不同寻常:生存期参数的名称必须以撇号(')开头，通常都是小写的，而且非常短，就像泛型类型一样。

```rust
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

一个生命周期注释本身并没有多大意义，因为注释的目的是告诉 Rust 多个引用的通用生命周期参数如何相互关联。 例如，假设我们有一个函数，该函数的第一个参数是对寿命为'a 的 i32 的引用。 该函数还具有另一个名为 second 的参数，这是对 i32的另一个引用，该i32也具有生存期'a。 生命周期注释表明第一个和第二个引用必须都与该通用生命周期一样长。

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```


