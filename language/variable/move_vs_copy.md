# 移动语义

## 移动
移动语义： 右值和移动语义是 C++11 中最为重要的特性之一，可以说它深刻地改变了整个 C++。Rust 语言没有历史包袱，它默认就是移动语义，不需要你去考虑右值引用、引用折叠，完美转发这种问题，使用起来非常自然。

移动语义作用的对象：

- 栈上的并且持有堆上资源的对象。

纯栈上和纯堆上对象都没有意义；并且栈上指针和指向的堆上对象也没有意义（将其归为纯堆上对象）。纯栈上对象，一定是拷贝的；纯堆上对象，通过指针传递，就是移动。栈上的对象，持有堆上的资源。在函数调用时栈上资源发生了拷贝，为了避免避免拷贝堆上资源引起的浪费，从而转移堆上资源的所有权给新堆上对象。


移动语义解决的问题：

- 当栈上对象拷贝时，连同堆上资源一起拷贝引起的浪费。
- 堆上资源的释放由谁负责。


**Rust 默认赋值就是移动语义的。**


## 借用

默认移动带来了一个问题，就是一旦移动之后，原始对象就不能再使用了。而很多情况下，我们希望将变量作为函数函数参数，通常函数改变了对象内部的值，我们希望在函数结束后，使用改变后的值。这时候原始对象已经无法使用了。为了处理这个问题，才有了借用。借用在使用过程中原始对象不能在再使用，一直到函数返回，归还所有权原始对象才能使用。

Rust 的借用符号是 `&`


## copy

有时候也需要复制，每个对象使用各自的内容。

要实现 copy 我们甚至不用自己实现逻辑，只需要使用 `#[derive(Copy, Clone)]` 标注结构体。这时候赋值默认就是 copy 的。如果不想默认发生 copy，就只使用 `#[derive(Clone)]` driver。

```Rust
#[derive(Copy, Clone)]
struct Bird {
    length: u32,
    weight: u32
}

fn copy_func(bird: Bird) {
    println!("bird: {} {}", bird.length, bird.weight);
}

fn learn_copy() {
    let bird = Bird {
        length: 10,
        weight: 20
    };
    copy_func(bird);
    println!("bird: {} {}", bird.length, bird.weight); // 继续使用
}
```

Copy 的限制：

- 需要所有成员都是Copy的，结构体才能够被打上Copy标记。
- 如果一个类型是 Copy 的，rust 在赋值和传参的时候默认使用 copy 语义
- 如果结构体实现了析构函数，就不允许打上 Copy 标记了。


### Clone 和 Copy 的区别

https://blog.csdn.net/shangsongwww/article/details/118992654
https://blog.csdn.net/jiangjkd/article/details/121784688