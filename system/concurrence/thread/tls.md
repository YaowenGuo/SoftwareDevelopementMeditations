# Thread Local Storage

TLS 有两种实现：

1. 编译器支持的 TLS: 通过 __thread（GCC）或 _Thread_local（C11）关键字定义线程本地变量。

2. POSIX 线程特定数据: 通过 pthread_key_create 创建键，pthread_setspecific/pthread_getspecific 存取数据。

thread_local 是 C11 中引入的线程本地存储，由编译器进行支持，使用简单，编译器和运行时环境会自动管理变量的生命周期。
pthread_XXX 是 POSIX 线程库（pthread）实现的线程本地存储，需要先使用 pthread_key_create 创建一个键。使用 pthread_setspecific 将数据与键关联起来。使用 pthread_getspecific 根据键检索数据。需要手动管理内存和键的生命周期，包括在适当的时候销毁键。pthread 实现的 TLS 使用虽然更复杂，但是更灵活，能够在运行时动态的创建。

thread_local 和 pthread TLS 可以结合使用，例如 1. thread_local 适合在编译前就能确定数据类型的场景，pthread TLS 适合在运行时需要动态创建的场景。2. thread_local 无法为线程退出时定义执行的操作，需要 pthread_key_create 来指定。

## _Thread_local

这种方式有一些限制：

1. 必须是全局变量（这个还可以接受，毕竟是多个线程都需要访问。疑问点是，如果是有部分线程需要，其它不需要的线程也会创建本次存储的空间吗？）



存储位置：

TLS 数据存储在 线程的独立内存段 中，通常位于线程栈的顶部或专用的 TLS 段（如 .tdata 和 .tbss 段）。

每个线程的 TLS 数据在内存中是 连续且隔离的，通过段寄存器（如 FS 或 GS）配合偏移量访问。

示例：

static __thread tsd_t tsd_tls;  // TLS 变量
2. POSIX 线程特定数据（TSD，慢速路径）
实现方式：通过 pthread_key_create 创建键，pthread_setspecific/pthread_getspecific 存取数据。

存储位置：

TLS 数据存储在 堆内存 中，由线程自行管理。

线程通过键值（pthread_key_t）从全局哈希表中查找对应的数据指针。

示例：

c
static pthread_key_t tsd_key;
pthread_key_create(&tsd_key, destructor);  // 创建键
pthread_setspecific(tsd_key, ptr);         // 存储数据
