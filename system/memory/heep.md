# 堆

堆内存的使用更灵活，也是出问题最多的地方，因为内存的管理不是完全自动的：虽然分配需要向内存申请，但是释放的权利却在用户手中。

C++ new 做了两件事：
1. 调用 `operator new` 分配内存。本质是低啊用 `malloc()`。
2. 调用构造函数初始化内存。

delete 的顺序跟 new 相反：
1. 调用对象的析构函数。
2. 调用 `operator delete` 释放内存。本质上是 `fres()`。

`operator new` 和 `operator delete` 定义在标准库中，由各个平台实现。以 Android 使用的 bionic 为例：

```C++
// bionic/new.cpp
void* operator new(std::size_t size) {
    void* p = malloc(size);
    if (p == nullptr) {
        async_safe_fatal("new failed to allocate %zu bytes", size);
    }
    return p;
}

void* operator new[](std::size_t size) {
    void* p = malloc(size);
    if (p == nullptr) {
        async_safe_fatal("new[] failed to allocate %zu bytes", size);
    }
    return p;
}

void  operator delete(void* ptr) throw() {
    free(ptr);
}

void  operator delete[](void* ptr) throw() {
    free(ptr);
}
```
更详细的内容可以查看
http://www.cplusplus.com/reference/new/operator%20new/
http://en.cppreference.com/w/cpp/memory/new/operator_new

思考问题：

1  malloc和free是怎么实现的？

2  malloc 分配多大的内存，就占用多大的物理内存空间吗？

3  free 的内存真的释放了吗（还给 OS ） ?

4  既然堆内内存不能直接释放，为什么不全部使用 mmap 来分配？

5  如何查看堆内内存的碎片情况？

6  除了 glibc 的 malloc/free ，还有其他第三方实现吗？

> my question

1. 如何获取堆的起始地址以及堆大小？
https://stackoverflow.com/questions/23937837/c-c-why-is-the-heap-so-big-when-im-allocating-space-for-a-single-int
2. 如果知道已申请的堆哪些空间被分配了（libc 中整块申请，再细分给用户，可能已经从系统申请，但是还没给用户）？

3. 没看到呢？出现一直递归调用回不来的情况，这样栈上就会出现很多 fac 的帧栈，会造成栈空间耗尽，出现 StackOverflow。这里的原理是，操作系统会在栈空间的尾部设置一个禁止读写的页，一旦栈增长到尾部，操作系统就可以通过中断探知程序在访问栈末端。
