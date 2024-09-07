# Clang

## C/C++ 编译流程

> 查看编译的步骤

```shell
$ clang -ccc-print-phases hello.cpp

0: input, "hello.cpp", c++
1: preprocessor, {0}, c++-cpp-output
2: compiler, {1}, ir
3: backend, {2}, assembler
4: assembler, {3}, object
5: linker, {4}, image
6: bind-arch, "arm64", {5}, image
```

```

-> 1 预处理 --> 2，3. 编译 --> 4. 汇编 --> 5. 链接 --> 6. 封装为制定架构的可执行文件。
```

已下面的代码为例，因为 `iostream` 的内容太多，这里为了演示，不使用系统的函数，否则导入会导致代码太多而影响核心查看。

```c
// hello.h
#ifndef HELLO_CPP
#define HELLO_CPP

#define PI 3.1415926

#endif

// hello.cpp
#include "hello.h"

using namespace std;

int main() {
    int radius = 4;
    int air = PI * radius * radius;
}
```

分步执行

1. 预处理: 宏的替换、头文件的导入，以及类似#if的处理。

```shell
clang -E hello.cpp

# 1 "hello.cpp"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 395 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "hello.cpp" 2
# 1 "./hello.h" 1
# 2 "hello.cpp" 2
```
```cpp
using namespace std;

int main() {
    int radius = 4;
    int air = 3.1415926 * radius * radius;
}
```

可以看到宏定义 `PI` 已经被替换成 `3.1415926`。


2. 编译: 将源代码编译成 LLVM 中间代码。

clang 是使用LLVM最为后端，所以支持编译成LLVM的字节码。gcc 不可以生成 LLVM 字节码，mac os 上 gcc 命令本质是 clang，也可以生成。


```
clang -emit-llvm -o hello.bc -c hello.cpp

# 或者
clang -O3 -emit-llvm hello.c -c -o hello.bc
```
将生成为 llvm 的中间机器码，之所以设计中间机器码一层，而不是直接编译为汇编代码，是为了隔离各种机器平台，方便优化语义分析、语法分析以及进行各种优化。而不必影响到各个平台相关代码。同时，对不同机器平台的编译进直接编译字节码和相应平台汇编程序，更加容易扩展。

`llvm-dis` 命令是LLVM反汇编。它可以一个LLVM bitcode文件并将其转换为人类可读的LLVM汇编语言。

反编译LLVM 字节码：

```
llvm-dis < hello.bc | less

llvm-dis hello.bc -o -
```

3. 汇编: 将LLVM 中间代码编译为汇编代码

```
clang++ -S -mllvm --x86-asm-syntax=intel hello.bc
# 或者
clang++ -S -masm=intel  hello.bc

# -S -masm=intel 参数是为了生成 intel 格式的汇编指令。如果不用指定，可以直接使用。

clang++ -S -masm=intel  hello.bc

```

会输出一个汇编文件 hello.s

```asm
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 11, 0	sdk_version 11, 1
	.globl	_main                   ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16             ; =16
	.cfi_def_cfa_offset 16
	mov	w8, #4
	str	w8, [sp, #12]
	ldr	w8, [sp, #12]
	scvtf	d0, w8
	mov	x9, #55370
	movk	x9, #19730, lsl #16
	movk	x9, #8699, lsl #32
	movk	x9, #16393, lsl #48
	fmov	d1, x9
	fmul	d0, d1, d0
	ldr	w8, [sp, #12]
	scvtf	d1, w8
	fmul	d0, d0, d1
	fcvtzs	w8, d0
	str	w8, [sp, #8]
	mov	w8, #0
	mov	x0, x8
	add	sp, sp, #16             ; =16
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
```


4. 汇编: 将汇编代码编译为具体平台的机器码


```shell
clang -c hello.s -o hello.o
```

5. 链接

链接成为库文件可以分为两种：静态库（.a、.lib...）和动态库（.so、.dll...）windows上对应的是.lib .dll linux上对应的是.a .so。不同平台的文件名后缀可能不同。

> 静态库：

之所以称为【静态库】，是因为在链接阶段，将目标文件.o与引用到的库一起链接排列到可执行文件中。在运行时整个文件加载到内存运行。一个静态库可以简单看成是一组目标文件（.o/.obj文件）的集合。


打包静态库：

```shell
# archive file
ar -crv hello.a hello.o # 可以有更多 .o 文件。
```

> 动态库

动态库在程序编译时并不会被连接到目标代码中，而是在程序运行是才被载入。不同的应用程序如果调用相同的库，那么在内存里只需要有一份该共享库的实例。

```shell
clang hello.o -shared -o hello.so
```


> 可执行文件

```shell
ld hello.o -o hello
```

但是要链接成为可运行程序，还需要链接系统库，如标准输入输出。这可能会出错，因为 ln 不知道这些信息。为此可以使用 clang 并显示详细链接的参数。

```shell
clang hello.o -o hello -v
```



## 其它编译工具


> 查看操作内部命令，可以使用 -### 命令

clang -### hello.cpp -o main


预处理完成后就会进行词法分析，这里会把代码切成一个个 Token，比如大小括号，等于号还有字符串等。

```
clang -fmodules -fsyntax-only -Xclang -dump-tokens main.m
```

clang 命令参数

```
-x 编译语言比如objective-c
-arch 编译的架构，比如arm7
-f 以-f开头的。
-W 以-W开头的，可以通过这些定制编译警告
-D 以-D开头的，指的是预编译宏，通过这些宏可以实现条件编译
-iPhoneSimulator10.1.sdk 编译采用的iOS SDK版本
-I 把编译信息写入指定的辅助文件
-F 需要的Framework
-c 标识符指明需要运行预处理器，语法分析，类型检查，LLVM生成优化以及汇编代码生成.o文件
-o 编译结果
-s strip，剥离调试符号
```


## 导入搜索路径

- --sysroot=XX

使用XX作为这一次编译的头文件与库文件的查找目录，查找XX下面的 usr/include、usr/lib目录。

- -isysroot XX
头文件查找目录,覆盖--sysroot ，查找 XX/usr/include。什么意思，比如说"gcc --sysroot=目录1 main.c"，如果main.c中依赖于头文件和库文件，则会到目录1中的user/include和user/lib目录去查找，而如果"gcc --sysroot=目录1 -isysroot 目录2 main.c"意味着会查找头文件会到目录2中查找而非--sysroot所指定的目录1下的/usr/include了，当然查找库文件还是在目录1下的user/lib目录去查找。

- -isystem XX
指定头文件查找路径（直接查找根目录）。比如"gcc --sysroot=目录1 -isysroot 目录2 -isystem 目录3  -isystem 目录4 main.c"意味着头文件查找除了会到目录2下的/usr/include，还会到isystem指定的目录3和目录4下进行查找，注意：这个isystem指定的目录就是头文件查找的全路径，而非像isysroot所指定的目录还需要定位到/usr/include目录。

- -IXX
头文件查找目录。

其查找头文件的优先级为：
- -I -> -isystem -> sysroot

比如说：“gcc --sysroot=目录1 -isysroot 目录2 -isystem 目录3  -isystem 目录4 -I目录5 main.c”，其头文件首先会去目录5找，如果没找到则会到目录3和4找，如果还没找到则会到目录2找。

- -LXX
指定库文件查找目录。
- -lxx.so
指定需要链接的库名。


https://www.cnblogs.com/webor2006/p/9946061.html

`-H` 参数可以输出导入文件详细目录和导入关系

## 问题排查

### 查找静态库中的函数

```
$ nm --demangle libwebrtc.a | grep -i webrtc::CreatePeerConnectionFactory
0000000000000000 T webrtc::CreatePeerConnectionFactory(rtc::Thread*, rtc::Thread*, rtc::Thread*, rtc::scoped_refptr<webrtc::AudioDeviceModule>, rtc::scoped_refptr<webrtc::AudioEncoderFactory>, rtc::scoped_refptr<webrtc::AudioDecoderFactory>, std::__1::unique_ptr<webrtc::VideoEncoderFactory, std::__1::default_delete<webrtc::VideoEncoderFactory> >, std::__1::unique_ptr<webrtc::VideoDecoderFactory, std::__1::default_delete<webrtc::VideoDecoderFactory> >, rtc::scoped_refptr<webrtc::AudioMixer>, rtc::scoped_refptr<webrtc::AudioProcessing>, webrtc::AudioFrameProcessor*)
```

## 编译参数

```
-Wall # 即 Warning all 打开gcc的所有警告
-Werror # 即 Warning as error. 它要求gcc将所有的警告当成错误进行处理。 会导致警告也导致编译失败。
-v 查看编译流程
```

这应该让clang 用 Intel语法发出汇编代码：
```
 clang++ -S -mllvm --x86-asm-syntax=intel test.cpp
```
您可以使用-mllvm <arg> 从clang命令行传入llvm选项。 可悲的是，这个选项似乎没有很好的logging，因此我只能通过浏览llvm邮件列表来find它。

如下面的@thakis所述 ，Clang（3.5+）的新版本不再需要它，因为它现在支持-masm=intel语法。

从r208683 （clang3.5+）开始，它理解-masm=intel 。 所以如果你的 clang 是新的，你可以使用它。

假设您可以让 Clang 发出正常的LLVM字节代码，然后可以使用llc编译为汇编语言，并使用其--x86-asm-syntax=intel选项以英特尔语法获得结果。

```
g++ simplegrep.c -o simplegrep -I/usr/local/include/hs -L/usr/local/lib64/ -lhs -lhs_runtime

-I：头文件目录

-L:静态库目录

-l:静态库名字
```