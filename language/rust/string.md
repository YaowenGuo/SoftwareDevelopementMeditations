# 定义和初始化

Rust将字符串 &str和String区别
    &str字符串类型存储于栈上，str字符串序列存储于程序的静态只读数据段或者堆内存中。由两部分组成：
        1) 指向字符串序列的指针；
        2) 记录长度的值。

String类型本质是一个成员变量为Vec<u8>类型的结构体，所以它是直接将字符内容存放于堆中的。由三部分组成：
        1) 执行堆中字节序列的指针（as_ptr方法）
        2) 记录堆中字节序列的字节长度（len方法）
        3) 堆分配的容量（capacity方法）
                
```
let data = "initial contents";
```


```Rust
let s = String::new();

let s = data.to_string();
// 等价于
// the method also works on a literal directly:
let s = "initial contents".to_string();

let s = String::from("initial contents");
```

```
use std::iter::FromIterator;
let v = vec!['a', 'b', 'c', 'd'];
let s = String::from_iter(v);
// vs
let s: String = v.into_iter().collect();
```

- data 和 s 是不同类型，data 是 &str 类型，是字面值的一个引用。而 s 是 String 类型。

**Rust 使用的是 UTF-8 编码，因此不能直接 byte 访问**

```
Strings are always valid UTF-8. This has a few implications, the first of which is that if you need a non-UTF-8 string, consider OsString. It is similar, but without the UTF-8 constraint. The second implication is that you cannot index into a String:

ⓘ
let s = "hello";

println!("The first letter of s is {}", s[0]); // ERROR!!!
Run
Indexing is intended to be a constant-time operation, but UTF-8 encoding does not allow us to do this. Furthermore, it’s not clear what sort of thing the index should return: a byte, a codepoint, or a grapheme cluster. The bytes and chars methods return iterators over the first two, respectively.
```

既然不能通过字符量判断数据大小？为什么可以声明容量？如何申请缓存区的？最大的字符长度计算的吗？

```
let mut fixsize_str = String::with_capacity(2);
```

## 读写

```Rust

```

## 属性

```
s.len();
s.capicaty();

```

```
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2; // note s1 has been moved here and can no longer be used
// let s3 = s1.clone() + &s2;
println!("{}, {}", s1, s3);
```

## 转换

```
let my_string = "27".to_string();  // `parse()` works with `&str` and `String`!
let my_int = my_string.parse::<i32>().unwrap();
// 或者
let my_int: i32 = my_string.parse().unwrap();
```

## 处理每个字符

```
for c in "नमस्ते".chars() {
    println!("{}", c);
}
```

```
for b in "नमस्ते".bytes() {
    println!("{}", b);
}
```
不像 C 和其他语言可以直接通过索引来更改字符串，Rust 中的字符串是不能通过索引访问字符的。这是因为 Rust 采用 UTF-8 编码，这种字符编码的字节长度可变，因此无法计算位置。这意味访问字符的时间复杂度为 O(n)。
