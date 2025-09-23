# Thread Local Storage

TLS 有两种实现：

1. 编译器支持的 TLS: 通过 __thread（GCC）或 _Thread_local（C11）关键字定义线程本地变量。

2. POSIX 线程特定数据: 通过 pthread_key_create 创建键，pthread_setspecific/pthread_getspecific 存取数据。

thread_local 是 C11 中引入的线程本地存储，由编译器进行支持，使用简单，编译器和运行时环境会自动管理变量的生命周期。
pthread_XXX 是 POSIX 线程库（pthread）实现的线程本地存储，需要先使用 pthread_key_create 创建一个键。使用 pthread_setspecific 将数据与键关联起来。使用 pthread_getspecific 根据键检索数据。需要手动管理内存和键的生命周期，包括在适当的时候销毁键。pthread 实现的 TLS 使用虽然更复杂，但是更灵活，能够在运行时动态的创建。

thread_local 和 pthread TLS 可以结合使用，例如 1. thread_local 适合在编译前就能确定数据类型的场景，pthread TLS 适合在运行时需要动态创建的场景。2. thread_local 无法为线程退出时定义执行的操作，如果需要释放函数，则使用 pthread_key_create 来指定。

## _Thread_local

这种方式有一些限制：

1. 必须是全局变量（这个还可以接受，毕竟是多个线程都需要访问。疑问点是，如果是有部分线程需要，其它不需要的线程也会创建本次存储的空间吗？）



存储位置：

TLS 数据存储在 线程的独立内存段 中，通常位于线程栈的顶部或专用的 TLS 段（如 .tdata 和 .tbss 段）。

每个线程的 TLS 数据在内存中是连续且隔离的，通过段寄存器（如 FS 或 GS）配合偏移量访问。

## Pthread TLS

1. pthread_key_create 关联释放函数后，线程必须通过 `pthread_setspecific` 设置值之后，释放函数才被调用，否则释放函数不会被调用。

2. pthread_setspecific 需要用户自己 malloc 申请空间。

3. pthread_key_create 释放函数的参数就是 pthread_setspecific 设置的值，需要在释放函数中主动释放。

4. 在 C++ 中 thread_local机制，是按需触发，即在第一次使用定义的变量时才会触发thread_local的构造函数，触发过构造函数自然对应的在线程“正常”退出时触发析构

如下测试中，tls_destructor 释放函数只会被调用一次，只有 thread1 中设置了 `tls_key` 的值，因此会调用释放函数。
```C
#include <stdio.h>
#include "base/csapp.h"

thread_local int testTls = 0;
// 定义线程本地存储的键
pthread_key_t tls_key;
void tls_destructor(void *value) {
    printf("Thread local storage destroyed\n");
    free(value);
}


/* thread routine */
void* thread1(void* vargp) {
    char *data = (char *)malloc(100);
    pthread_setspecific(tls_key, (void *)data);
    testTls = 5;
    printf("Sub thread, value of testTls: %d\n", testTls);
    return NULL;
}

/* thread routine */
void* thread2(void* vargp) {
    testTls = 10;
    printf("Sub thread, value of testTls: %d\n", testTls);
    return NULL;
}

int main() {
    if (pthread_key_create(&tls_key, tls_destructor) != 0) {
        perror("pthread_key_create");
        return 1;
    }

    pthread_t tid1, tid2;
    Pthread_create(&tid1, NULL, thread1, NULL);
    Pthread_create(&tid2, NULL, thread2, NULL);
    Pthread_join(tid1, NULL);
    Pthread_join(tid2, NULL);
    printf("Main thread, value of testTls: %d\n", testTls);
    return 0;
}
```
