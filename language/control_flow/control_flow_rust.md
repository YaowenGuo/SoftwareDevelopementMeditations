# 控制流

顺序、分支、循环

## 分支

```rust
let number = 3;

if number < 5 {
    println!("condition was true");
} else if number = 5 {
    println!("condition was 5");
} else {
    println!("condition was false");
}
```

Rust 的判断语句仅接受 bool 类型，并且没有默认的数据类型转换。因此非 bool 类型将报错。

Because if is an expression, we can use it on the right side of a let statemen

Rust 没有三元运算符，使用 if-else 来赋值

```rust
let number = if condition { 5 } else { 6 };
```

## 循环 (loop, while, for)


## loop

`loop` 没有条件计算，只能在内部通过 `break` 结束循环。

break 可以带有返回值。

```rust
let result = loop {
    counter += 1;

    if counter == 10 {
        break counter * 2;
    }
};
```

## while

while 没有返回值

```rust
fn main() {
    let mut number = 3;

    while number != 0 {
        println!("{}!", number);

        number -= 1;
    }

    println!("LIFTOFF!!!");
}
```

## for-in 用于集合的遍历

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];

    // 更优雅的遍历方式，避免索引越界的问题。
    for element in a.iter() {
        println!("the value is: {}", element);
    }

    // 更优雅的遍历方式
    for number in (1..4).rev() {
        println!("{}!", number);
    }
}
```