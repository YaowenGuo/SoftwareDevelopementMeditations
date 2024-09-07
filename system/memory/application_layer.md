# 应用层



内存访问错误、SIGSEGV、double free、内存泄漏等与内存相关的错误时

### 1. Java 内存泄露和 Native 内存泄露。

目标

1. 定位内存占用较高的原因，包括 java 和 native 对内存的使用，优化对内存的使用

2. 了解Android系统内存使用的正常范围与OOM的边界

输出结果

1.优化直播课页面对内存的使用

2.输出内存占用问题的排查文档

3.输出内存优化的最佳实践文档

1. 内存各个区域分布，各个部分使用和容易引起的问题
2. Native 内存问题检测工具 的使用，排查问题的方法。
3. Java 内存问题工具 CPU Profile，Track 定位问题的方法和监测工具。
4. Truman  内存占用过多问题排查。

C++

2. C/C++ 对象内存分配的方式，以及避免内存泄漏的编程方法。

    1. 浅拷贝的对象只有的对象，只释放一个，持有对象会不会被释放？

    2. 移动构造函数

    3. RVO, NRVO

    4. 指针传递给一个对象，何时释放问题。比如一个对象 A 传给一个函数，不确定这个函数会不会释放 A, 自己主动释放，如果 函数启动新线程，使用了 A 就会崩溃。如果函数先释放了 A, 自己再次释放，又会引起重复释放问题。

3. 类、操作符重载与类型转换

    目标：深入掌握 C/C++, 能够快速定位 Native  问题

    输出结果：

    定位 Native  问题的工具和方法

    Native  内存泄漏原因和检测的工具。

    一些常用语言特性的文档：宏、模板编程、现代化避免程序错误的方法(如 C++11 shared_ptr 和 WebRTC 中 rtc::scoped_refptr 智能指针)、函数指针
   
    深入理解 C/C++ 对象的内存分配和释放，内存分配。避免内存泄漏的方法。

4. 模板编程与 STL的常用类。

    目标：深入掌握 C/C++, 能够快速定位 Native  问题

    输出结果：

    定位 Native  问题的工具和方法

    Native  内存泄漏原因和检测的工具。

    一些常用语言特性的文档：宏、模板编程、现代化避免程序错误的方法(如 C++11 shared_ptr 和 WebRTC 中 rtc::scoped_refptr 智能指针)、函数指针

    深入理解 C/C++ 对象的内存分配和释放，内存分配。避免内存泄漏的方法。

5. 指针和强转，函数指针，安全使用方案

6. 编译、链接的流程和常用参数。
7. LLDB 的使用方法


## 堆

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


## 栈

栈为什么要由高地址向低地址扩展，堆为什么由低地址向高地址扩展？

历史原因：在没有MMU的时代，为了最大的利用内存空间，堆和栈被设计为从两端相向生长。人们对数据访问是习惯于从地址小的位置开始，比如你在堆中申请一个数组，是习惯于把低元素放到低地址，把高位放到高地址，所以堆向上生长比较符合习惯,  而栈则对方向不敏感，一般对栈的操作只有 PUSH 和 pop，无所谓向上向下，所以就把堆放在了低端，把栈放在了高端. 但现在已经习惯这样了。这个和处理器设计有关系，目前大多数主流处理器都是这样设计，但ARM 同时支持这两种增长方式。

1. 调用和返回
    - 如何跳到被调用的函数执行？
    - 如何从被调用函数返回调用者？
2. 传递参数
    - 如何传递参数给被调用函数
3. 局部变量
    - 被调用函数如何存储局部变量？
4. 返回值
    - 被调用函数如何将值返回给调用者？
    - 调用者如何获得返回的值？
5. 优化
    - 调用者和被调用函数如何做到最小的内存占用？

### 1. 调用和返回

ARM 使用 BL 指令作为函数调用，该指令在执行时将跳转地址加载到 CP 寄存器的同时，会将下一条指令地址加载到 X30 寄存器。调用 ret 指令从函数返回时同时将 `X30` 恢复到 SP 寄存器。


函数调用的参数和局部数据都会放在栈中。首先看参数传递：


[栈的使用涉及到以下几个方面](https://www.cs.princeton.edu/courses/archive/spr19/cos217/lectures/15_AssemblyFunctions.pdf)

以计算两个数字绝对值的和为例：
```C
int test() {
    return testCall(2, 4);
}

test:
	stp	x29, x30, [sp, #-16]! // SP = SP - 16; PUSH FP, LR
	mov	x29, sp               // FP = SP
	mov	w0, #2
	mov	w1, #4
	bl	testCall              // JUMP testCall; LR = .bl_ret
.bl_ret:
	ldp	x29, x30, [sp], #16   //
	ret
```

#### 1. 调用和返回

如何从调用者次跳到被调用函数？即，跳到被调用者第一条指令的地址。

被调用方法如何跳转回调用者的正确位置？即跳到执行跳转到被调用方法的指令后面最近的指令。

> 栈空间大小

系统的栈空间并不是一个统一的值（特别是不同系统，或者不同 CPU 平台），但是也有一般的


BL: 绝对跳转 #imm，并将返回地址（下一跳指令的地址）保存到 LR(x30)

```
stp x29, x30 ,[sp, #-0x10]! 加 “！” 的作用相当于：
sub sp, sp, #0x10
stp x29, x30, [sp]
```

![栈帧](images/stack_frame.png)


#### 2. 传递参数

通用的做法是入栈，而 ARM 的做法稍有不同：

- 前 8 个参数（integer or address）保存在寄存器中，以提高效率。
    - X0..X7（64 位） and/or W0..W7（32 位）
- 多余 8 个参数或者非简单数据类型放到栈中

被调用函数
- 将寄存器传入的参数保存到栈中或者直接使用（优化）。
- 被调用函数通过 `SP+正偏移` 获取参数。


Observation: Accessing memory is expensive
• More expensive than accessing registers
• For efficiency, want to store parameters and local variables in
registers (and not in memory) when possible
Observation: Registers are a finite resource
• In principle: Each function should have its own registers
• In reality: All functions share same small set of registers
Problem: How do caller and callee use same set of registers
without interference?
• Callee may use register that the caller also is using
• When callee returns control to caller, old register contents
may have been lost
• Caller function cannot continue where it left off

#### ARM Solution: Register Conventions

1. 优先使用寄存器保存数据，而不是内存。

使用 X0~X7 传递参数，
- 多余八个使用栈存储。
- 结构体使用栈


2. 返回值：
- 整数和地址使用 X0
- 浮点数使用浮点数寄存器
- 结构体使用内存保存，使用 X8 保存。

被调用者负责的寄存器：
- X19..X29 (or W19..W29)
- 被调用 **必须保存** 其内容
- 如果需要使用
    - 在函数开始保存其内容。
    - 在函数结束恢复其内容。

调用者需要保存的寄存器
- X8..X18 (or W8..W18) – 加上用于保存参数的 X0..X7
- 被调用者 **可能修改** 其内容。
- 如果用到了这些寄存器：
    - 将其放到 X19~X29 之中，否则
    - 在调用函数前将其保存到栈中。
    - 在调用结束后恢复其内容。

使用 X0 返回普通数据类型，

**这意味着很多函数不用再保存数据到栈中，函数能够在 X0~X18 寄存器就能处理自己的逻辑，就没有必要存储数据到寄存器。在调用函数时，也可以将数据保存到 X19~X29 中，被调用如果没有调用函数，就不必保存 X19~X29 寄存器，这就减少了很多的内存的操作。**

**上面的描述太多分散，不便于理解，让我们聚焦于一个函数。一个函数一定是一个被调用者，同时也可能调用其它函数，作为被调用者，其可以任意使用 X0~X18，除非逻辑需要而不必考虑保存数据。而当其需要调用函数时，在函数调用之后仍然需要使用到的局部变量，不必保存到内存，只需要将其移到 X19~X29 寄存器中。注意要先保存用到的寄存器再使用（因为自己也是一个被调用者）。如果子程序可能用不到 X19~X29 寄存器，就会入栈的操作，从而达到了优化的目的。其实这种规则主要明确了由谁保存寄存器的问题，而不会出现同一个寄存器在调用者和被调用者中重复保存的问题。**



#### 3. 局部变量



**在不同语言的编译器中，调用参数压栈的顺序，参数栈的弹出，名字修饰是不同的。例如 c/c++ 的参数是从由右向左开始压栈，由调用方负责弹出，命名修饰使用 `下划线 + 函数名`**

#### 栈攻击

由上面栈内存布局可以看出，栈很容易被破坏和攻击，通过栈缓冲器溢出攻击，用攻击代码首地址来替换函数帧的返回地址，当子函数返回时，便跳转到攻击代码处执行,获取系统的控制权，所以操作系统和编译器采用了一些常用的防攻击的方法：

- ASLR(地址空间布局随机化)：操作系统可以将函数调用栈的起始地址设为随机化（这种技术被称为内存布局随机化，即Address Space Layout Randomization (ASLR) ），加大了查找函数地址及返回地址的难度。

- Cannary

[clang/gcc 的编译参数](https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-fstack-protector-strong)

| 编译参数                                 |  作用                                                       |
| -                                       | -                                                          |
| -fstack-protector, -fno-stack-protector | 开启或者关闭栈保护，只有带有 char 数组局部变量的函数才会插入保护代码。|
| -fstack-protector-all                   | 对所有函数开启堆栈保护                                         |
| -fstack-protector-strong                | 和 -fstack-protector 一样，增加对函数内有数组定义，对局部站上地址引用的函数的保护 |

开启Canary之后，函数开始时在ebp和临时变量之间插入一个随机值，函数结束时验证这个值。如果不相等（也就是这个值被其他值覆盖了），就会调用 _stackchk_fail函数，终止进程。对应GCC编译选项-fno-stack-protector解除该保护。

- NX.
  NX 即 No-eXecute（不可执行）的意思，NX（DEP）的基本原理是将数据所在内存页标识为不可执行，当程序溢出成功转入shellcode时，程序会尝试在数据页面上执行指令，此时CPU就会抛出异常，而不是去执行恶意指令。gcc编译器默认开启了NX选项，如果需要关闭NX选项，可以给gcc编译器添加 `-z execstack`参数。 `-z` 其实是将 `execstack` 传给连接器，clang 的连接器并没有使用该选项。


```C
int testCall(int a) {
    return a + 5;
}

// -fstack-protector-all

testCall(int):                           // @testCall(int)
        sub     sp, sp, #32                     // =32
        stp     x29, x30, [sp, #16]             // 16-byte Folded Spill
        add     x29, sp, #16                    // =16
        adrp    x8, __stack_chk_guard
        ldr     x8, [x8, :lo12:__stack_chk_guard]

        str     x8, [sp, #8]
        str     w0, [sp, #4]
        ldr     w9, [sp, #4]
        add     w0, w9, #5                      // =5

        adrp    x8, __stack_chk_guard
        ldr     x8, [x8, :lo12:__stack_chk_guard]
        ldr     x10, [sp, #8]
        subs    x8, x8, x10
        str     w0, [sp]                        // 4-byte Folded Spill
        b.ne    .LBB0_2
        ldr     w0, [sp]                        // 4-byte Folded Reload
        ldp     x29, x30, [sp, #16]             // 16-byte Folded Reload
        add     sp, sp, #32                     // =32
        ret
.LBB0_2:
        bl      __stack_chk_fail
```

## 栈帧

栈帧: 一个函数调用所使用的栈空间被称为一个栈帧。栈帧的概念在各种调试器和 backtrack 中使用到，这也是调试器用于解析函数局部变量的地方。理解栈帧能更方便准确的定位问题。

```
Low                   |                          |
                      +--------------------------+
SP -----------------> |          ARGS            |
                      |          ARGS            |
                      |          ARGS            |
                      +==========================+
FP -----------------> |           FP'            |
                      +--------------------------+
                      |           IR'            |
High                  |                          |
```

例如：
```C
#include <math.h>
long test(long);
long absadd(long a, long b)
{
    long absA, absB, sum;
    absA = test(a);
    absB = test(b);
    sum = absA + absB;
    return sum;
}
```
编译后为：
```assembly
absadd(long, long):                             // 进入函数，此时 FP(x29)指向当前栈的栈底。由于该函数没有参数通过栈传递，SP 和 FP 指向同一个位置。
        stp     x29, x30, [sp, #-32]!           // 增加栈空间，保存 FP, IR
        stp     x20, x19, [sp, #16]             // 需要用到 X20,X19，先保存 X20,X19 变量
        mov     x29, sp                         // 要调用函数了，FP 指向 test 的栈底。
        mov     x19, x1                         // 保存 x1 内容到 x19
        bl      test(long)                      // 调到 test 执行是 FP 已经指向了新的栈底，bl 会保存返回地址到 LR(x30)。
        mov     x20, x0
        mov     x0, x19
        bl      test(long)
        add     x0, x0, x20
        ldp     x20, x19, [sp, #16]             // 恢复 x20, x19 的内容
        ldp     x29, x30, [sp], #32             // 恢复 FP 和 LR
        ret
```
从这个示例中我们可以看到：

- 一个函数中 FP 不一定一直指向栈底，其在调用子函数是会指向栈顶。即子哈数的栈底。

- 栈大小不是固定的，在函数内部会根据需要变化。例如这里为了保存 `x29, x30, x20, x19` 增加了 32 字节。

- 当没有参数通过栈传递时，SP 和 FP 指向同一个位置。


BP: 栈底指针
LR(Link Register): 函数返回地址 (arm: x30, )
FP(Frame Pointer): 栈帧指针 (arm: r29, x86: rbp)
SP(Stak Pointer):  栈顶指针 （arm：sp）



#### 栈异常处理

一个函数（或方法）抛出异常，那么它首先将当前栈上的变量全部清空(unwinding)，如果变量是类目标的话，将调用其析构函数，接着，异常来到call stack的上一层，做相同操作，直到遇到catch语句。

**指针是一个普通的变量，不是类目标，所以在清空call stack时，指针指向资源的析构函数将不会调用。** 需要格外注意。



### 创建线程的数量


## unwind

如何获取寄存器和堆栈调用信息？即如何生成 backtrace？我们通常把生成 backtrace 的过程叫作 unwind，unwind 看似和我们平时开发并没有什么关系，但其实很多功能都是依赖 unwind 的。举个例子，比如你要绘制火焰图或者是在崩溃发生时得到 backtrace，都需要依赖 unwind。


### backtrace 

**backtrace 中的 pc 指是堆栈中函数返回要执行的指令的地址。**不同的堆栈解析程序输出的结果可能不同，对于动态库，Android 输出的是一个相对地址，如果执行当前指令出错了，此时的 PC 正是这个 Frame 0 中地址在内存中的绝对地址。PC 减去 Frame0 中PC 的相对地址，就是动态库的加载地址。

由于 backtrace 的地址在指向函数中某个指令，而不是函数的起始地址。想要知道调用的函数是什么，需要找到地址前最近的一个函数。

1. 如何根据地址快速找到函数？
2. 如何反汇编单个函数？

对于带有调试信息的目标文件，给 addr2line 添加 `-f -demangle=true` 参数。
```shell
addr2line -f -demangle=true -e <bin file> <addr ...>               # 同时输出函数名
llvm-nm -SC <bin file> | grep '<symbol name>'                      # 获取函数名的地址和大小
```
例如：
```shell
$ llvm-addr2line -f -demangle=true -e libtest_jni.so 0000000000003674
Bar::g()
/Users/lim/Project/android/AndroidTest/app/app/src/main/cpp/test_jni.cpp:78

$ llvm-nm -SC libtest_jni.so | grep "Bar::g()"
0000000000003640 000000000000004c W Bar::g()

$ objdump -d libtest_jni.so --start-address=0x0000000000003640 --stop-address=0x000000000000368c

libtest_jni.so:	file format elf64-littleaarch64

Disassembly of section .text:

0000000000003640 <_ZN3Bar1gEv>:
    3640: ff 83 00 d1  	sub	sp, sp, #32
    3644: fd 7b 01 a9  	stp	x29, x30, [sp, #16]
    3648: fd 43 00 91  	add	x29, sp, #16
    364c: e0 07 00 f9  	str	x0, [sp, #8]
    3650: c0 00 80 52  	mov	w0, #6
    3654: e1 ff ff d0  	adrp	x1, 0x1000 <_ZN3Bar1gEv+0xc>
    3658: 21 fc 2f 91  	add	x1, x1, #3071
    365c: e2 ff ff d0  	adrp	x2, 0x1000 <_ZN3Bar1gEv+0x14>
    3660: 42 04 22 91  	add	x2, x2, #2177
    3664: a3 0f 00 94  	bl	0x74f0 <__android_log_print@plt>
    3668: ff 03 00 f9  	str	xzr, [sp]
    366c: e9 03 40 f9  	ldr	x9, [sp]
    3670: a8 00 80 52  	mov	w8, #5
    3674: 28 01 00 b9  	str	w8, [x9]
    3678: e8 03 40 f9  	ldr	x8, [sp]
    367c: 00 01 40 b9  	ldr	w0, [x8]
    3680: fd 7b 41 a9  	ldp	x29, x30, [sp, #16]
    3684: ff 83 00 91  	add	sp, sp, #32
    3688: c0 03 5f d6  	ret
```

对于没有调试信息的二进制文件，使用 objdump 直接使用符号名反汇编？

```
$ objdump -d <bin file> --start-address=<start> --stop-address=<end> # 根据地址反汇编函数

$ objdump ---disassemble-symbols=<symbole> <input object files>
```

带有符号表的情况下，还能通过增加 `--demangle` 参数，从而使用解析过的原始符号时。没有符号表就只能使用编译后的符号。

查看符号的起始地址：

```
llvm-objdump --dynamic-syms libtest_jni.so
```

### 1、获取程序的调用栈

在Linux上的C/C++编程环境下，我们可以通过如下三个函数来获取程序的调用栈信息。
```C
#include <execinfo.h>
 
/* Store up to SIZE return address of the current program state in
   ARRAY and return the exact number of values stored.  */
int backtrace(void **array, int size);
 
/* Return names of functions from the backtrace list in ARRAY in a newly
   malloc()ed memory block.  */
char **backtrace_symbols(void *const *array, int size);
 
/* This function is similar to backtrace_symbols() but it writes the result
   immediately to a file.  */
void backtrace_symbols_fd(void *const *array, int size, int fd);
它们由GNU C Library提供，关于它们更详细的介绍可参考Linux Programmer’s Manual中关于backtrack相关函数的介绍。

```

## C函数调用栈约定

在函数调用时，需要将函数的参数放到栈上，一个函数调用使用到的栈，被称为一个栈帧。不同语言的压栈方式不同，例如 C 语言参数从后向前压栈。



参考：

https://www.phpgolang.com/archives/833
https://blog.csdn.net/jinking01/article/details/126564672