# C/C++ 宏

C/C++ 允许定义宏，宏在编译之前被处理，替换成实际的代码。将宏替换为实际代码的阶段称为预处理。只有预处理之后的代码才能编译，编译器并不认识宏。预处理器指令以 `#` 号开头标识，末尾不包含分号。预处理命令不是C/C++语言本身的组成部分，不能直接对它们进行编译和链接。C/C++语言的一个重要功能是可以使用预处理指令和具有预处理的功能。C/C++提供的预处理功能主要有文件包含、宏替换、条件编译等。


## 文件包含

预处理指令 `#include` 用于包含头文件，有两种形式：

- `#include <xxx.h>`
- `#include "xxx.h"`

其中 C++ 格式不带文件的 `.h` 后缀。

- 尖括号形式表示被包含的文件在系统目录中。可以通过 [`cpp -v /dev/null -o /dev/null`](https://gcc.gnu.org/onlinedocs/cpp/Search-Path.html) 指令查看不同系统下默认的头文件搜索路径。例如 linux 下的搜索路径为 `/usr/include`、`/usr/local/include` 等。

- 在双引号形式中可以指出文件路径和文件名。可以是相对路径或者绝对路径。
    - 绝对路径，这种方式在项目中一般不使用，因为项目目录会移动，指定项目中的路径会失效，系统路径应该使用尖括号形式指出。
    - 相对路径，一般是项目或者模块的相对路径，这时需要在编译时通过 `-I<项目或者模块的头文件路径>` 来指定搜索目录。
    - 仅文件名。在文件所在目录搜索。

尖括号的搜索过程是先搜索 `-I` 指定的路径，找不到再搜索系统目录。而尖括号的搜索会直接搜索系统目录。因此对于用户自己编写的头文件，宜用双引号形式。对于系统提供的头文件，既可以用尖括号形式，也可以用双引号形式，都能找到被包含的文件，但显然用尖括号形式更直截了当，效率更高。

C 格式的导入

```C
#include <stdio.h>               // 系统头文件
#include "micro/micro_concat2.h" // 相对路径格式，需要使用 -I<path> 指定搜索路径
#include "micro_concat2.h"       // 文件当前目录。最优先查找。
```

C++ 格式的导入

```C++
#include <iostream>
#include "micro/micro_concat2" // 相对路径格式，需要使用 -I<path> 指定搜索路径
#include "micro_concat2"
```

## 调试

由于宏代码会 在编译前全部展开，我们可以：

- 让编译器 仅输出预处理结果
    - gcc -E 让编译器 在预处理结束后停止，不进行 编译、链接
    - gcc -P 屏蔽编译器 输出预处理结果的 行标记 (linemarker)，减少干扰
    - 另外，由于输出结果没有格式化，建议先传给 clang-format 格式化后再输出

- 屏蔽 无关的 头文件
    - 临时删掉 不影响宏展开的 #include 行
    - 避免多余的 引用展开，导致实际关注的宏代码 “被淹没”


## 宏预处理指令

### 定义宏

定义宏很简单，只要使用 `#define <name> [<value>...]`  即可定义一个宏。**宏可以有值，也可以没有值**，`<value>` 是可选的。宏的值也可以是多个值，替换时会将名字替换为后面的值列表。

```C
// micro_define.c
#define PI 3.1415926
#define PI_MULTI_2 2 * PI
#define EMPTY_SPACE

double circumference(float radius) {
    EMPTY_SPACE
    return PI_MULTI_2 * ragius;
}
```
预处理中 **没有类型** 的概念，输入和输出都是**符号** —— 不涉及编译时的 C++ 语法，只进行编译前的 **文本替换**：

`#undef <宏名>` 取消宏定义

宏在预处理阶段就会被替换为

```C
// clang -E micro_define.c -o micro_define.p.c
double circumference(float radius) {

    return 2 * 3.1415926 * ragius;
}
```
### 编译器预定义的宏

常用的有
```C
__FILE__ // 被编译的路径名
__LINE__ // 当前行号
__DATE__ // 编译时的日期
__TIME__ // 编译时的时间
__STDC__ // 编译器是否遵循标准C规范
```

> 显示特定编译器的预定义的宏

https://blog.kowalczyk.info/article/j/guide-to-predefined-macros-in-c-compilers-gcc-clang-msvc-etc..html


### 宏参数

```C
#define <name>(<args,...>) <args_name...>
```

```
#define ADD(x, y) ((x)+(y))

int x1 = 3;
int x2 = 5;
printf("%d\n", ADD(x1, x2) * ADD(x1, x2));
```
- 一个 `宏参数` 是一个任意的 `符号序列 (token sequence)`，不同宏参数之间用逗号分隔

- 每个参数可以是空序列，且空白字符会被忽略（例如 a + 1 和 a+1 相同）

- 在一个参数内，不能出现逗号 (comma) 或 不配对的括号 (parenthesis)（例如 `FOO(bool, std::pair<int, int>)` 被认为是 FOO() 有三个参数：`bool`, `std::pair<int`  和 `int>`）

如果需要把 std::pair<int, int> 作为一个参数，一种方法是使用 C++ 的 类型别名 (type alias)（例如 using IntPair = std::pair<int, int>;），避免 参数中出现逗号（即 FOO(bool, IntPair) 只有两个参数）。

通用的方法是使用 `括号对` 封装每个参数（下文称为 元组），并在最终展开时 移除括号（元组解包）即可（在变长参数后展示）：

```C++
#define TEST_ARGS(T) T
#define TEST_ARGS2(A, B)  add(A x, B y)
```

### 符号拼接

宏定义不支持复杂的语法，仅仅是字符串的替换，`宏编程` 很多功能都是通过宏函数拼接成其他符号，在进一步展开，达到宏编程的目的。

符号拼接使用 `##` 。然而，如果一个宏参数用于拼接标识符（或 获取字面量），那么它不会被展开：

```C
#define CONCAT() concat
#define CONCAT_STR(SYMBOL) test_ ## SYMBOL


CONCAT_STR(CONCAT())  // -> test_CONCAT() 这里 CONCAT() 没有被展开为 concat，因为展开是由外而内进行的。先被拼接为 test_CONCAT()，test_CONCAT 是一个标识符，找不到进一步展开的匹配。
```

想要避免这种情况，一种通用的方法是 `延迟拼接操作`（或 延迟 获取字面量 操作）：

```C
// micro/micro_concat2.h
#define CONCAT_STR(SYMBOL)  CONCAT_STR_IMPL(test_, SYMBOL)

#define CONCAT_STR_IMPL(A, B) A ## B

#define CONCAT() concat

CONCAT_STR(CONCAT())  // -> test_concat
```

整个预处理分为两个阶段：

1. 预扫描：展开参数，展开 **未用于** 拼接标识符 或 **获取字面量** 的所有参数

2. 宏展开：首先进行红展开。宏函数展开后，替换后的文本会进行 二次扫描 (scan twice)，继续展开 结果里出现的宏

因此 `CONCAT_STR` 宏函数预扫描时，由于 `SYMBOL` 没有用于拼接，就会对参数 `CONCAT()` 进行展开，替换为 `concat`。
阶段 2 宏展开宏函数时，实际展开的是 `CONCAT_STR(concat)`。

另外，在预扫描前后，宏函数都要求参数个数必须匹配，否则无法展开

定义通用的宏，用于以下的测试。
```C
// micro/common.h
#define PP_COMMA() ,
#define PP_LPAREN() (
#define PP_RPAREN() )
#define PP_EMPTY()
```

```C
// micro/prescan_args_not_match.h
#include "micro/common.h"
#include "micro/micro_concat2.h"

CONCAT_STR_IMPL(x PP_COMMA() y)  // too few arguments (before prescan) 扫描之前没有逗号，只有一个参数。
CONCAT_STR_IMPL(x, PP_COMMA())   // too many arguments (after prescan) 扫描之后，连个逗号，三个参数。
```

### 参数字面量 `#`

`#` 的功能是将其后面的宏参数进行**字符串化操作**（Stringizing operator），简单说就是在它引用的宏变量的左右各加上一个双引号。如定义好 #define STRING(x) #x 之后，下面二条语句就等价。

```C
#define STRING(x) #x

char *pChar = "hello";
char *pChar = STRING(hello);
```

还有一个 `#@` 是加单引号（Charizing Operator）

```C
#define makechar(x)  #@x

char ch = makechar(b);
char ch = 'b'; // 等价。
```

**跟 `##` 一样， `#`、`#@` 也属于 `字符化操作`, 会导致宏参数不再进一步展开。** 需要展开宏参数时，需要使用 **延迟化拼接** 来处理。


### 变长参数

C11/C++11 开始支持变长参数`...`，接受任意个宏参数，必须出现在参数列表中的最后一个。使用 `__VA_ARGS__` 获取实参。

- 可以通过 `__VA_ARGS__` 获取所有参数，也可以通过 `#__VA_ARGS__` 获取参数的字符串。
- 另外，允许传递空参数，即 __VA_ARGS__ 替换为空

**变长参数通常用于将参数透传给其他函数或者宏函数。**

```C++
// micro/micro_variadic_args.h
#define log(format, ...) printf("LOG: " format, __VA_ARGS__)

log("%d%f", 1, .2);    // -> printf("LOG: %d%f", 1, .2);
log("hello world");    // -> printf("LOG: hello world", );
log("hello world", );  // -> printf("LOG: hello world", );
```

log 函数并不关心每个参数都是什么，或者长度，而是直接将参数传递给 printf 即可。这在编程中很常见。如果其它宏函数关心参数，需要在定义宏时给出参数名，以在使用时通过名称访问，如 `printf(format, arg1, arg2, ...)`，则这个宏只关心前三个参数。

后两种调用分别对应 **不传变长参数**、**变长参数为空** 的情况。展开结果会多出一个逗号，导致 C/C++ 编译错误（而不是宏展开错误）。对于空参数，展开时需要处理多余逗号的问题：

为了解决这个问题，一些编译器（例如 gcc/clang）扩展了 `, ## __VA_ARGS__` 的用法 —— 如果 `不传变长参数，则省略前面的逗号`：

```C++
// micro/variadic_args.h
#define log(format, ...) printf("LOG: " format, ## __VA_ARGS__)

log("%d%f", 1, .2);    // -> printf("LOG: %d%f", 1, .2);
log("hello world");    // -> printf("LOG: hello world");
log("hello world", );  // -> printf("LOG: hello world", );
```
`, ##` 解决了不传变长参数的问题，却没有解决变长参数为空的问题。为了进一步处理 **变长参数为空** 的情况，C++ 20 引入了 __VA_OPT__ 标识符 —— 如果变长参数是空参数，不展开该符号（不仅限于逗号）。需要为编译器指定 `-std=c++20` 和 `-Wvariadic-macros` 参数；

```C++
// micro/variadic_args.h
#define log(format, ...) printf("LOG: " format __VA_OPT__(,) __VA_ARGS__)

log("%d%f", 1, .2);    // -> printf("LOG: %d%f", 1, .2);
log("hello world");    // -> printf("LOG: hello world");
log("hello world", );  // -> printf("LOG: hello world");
```
### 结合复合语句表达式使用

C 语言中 `{}` 包裹的多个语句为复合语句。加上 `()` 则变成了表达式语句，就可以进行赋值。

```C
#include <stdio.h>

void test_add(int* a, int* b) {
    *a = *a + *b ;
}

#define ADD(A, B)                \
    ({                           \
       int tempA = A, tempB = B; \
       test_add(&tempA, &tempB); \
       tempA;                    \
    })


int main() {
    int a = 3, b = 4;
    int result = ({ int tempA = a, tempB = b; test_add(&tempA, &tempB); tempA; });
    printf("%d add %d result is: %d", a, b, result);
    return 0;
}
```

这里调用 test_add 只是为了演示复合语句如何返回值，不太合理。更优化的代码会调用宏等，减少函数的调用。


#### 使用案例

> 1. 元组去括号

对于括号对封装的参数，可以通过变长参数来去括号（类似于 python 元组解包）

```C
//
#define MY_REMOVE_PARENS(T) MY_REMOVE_PARENS_IMPL T

#define MY_REMOVE_PARENS_IMPL(...) __VA_ARGS__
```


宏对于变长参数的访问支持比较弱，如果想随意操作变长参数，需要定义一下辅助宏。

> 2. 获取变长参数指定下标的参数

前面说过，如果宏对参数感兴趣，必须定义声明参数名来访问变量。因此定义：
```C++
#define MY_GET_ARG(N, ...) MY_CONCAT(MY_GET_ARG_, N)(__VA_ARGS__)
#define MY_GET_ARG_0(_0, ...) _0
#define MY_GET_ARG_1(_0, _1, ...) _1
#define MY_GET_ARG_2(_0, _1, _2, ...) _2
#define MY_GET_ARG_3(_0, _1, _2, _3, ...) _3
#define MY_GET_ARG_4(_0, _1, _2, _3, _4, ...) _4
#define MY_GET_ARG_5(_0, _1, _2, _3, _4, _5, ...) _5
#define MY_GET_ARG_6(_0, _1, _2, _3, _4, _5, _6, ...) _6
#define MY_GET_ARG_7(_0, _1, _2, _3, _4, _5, _6, _7, ...) _7
#define MY_GET_ARG_8(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) _8
#define MY_GET_ARG_9(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) _9
```

此时，如果我们想要获取变长参数的第二个参数，就可以使用 `MY_GET_ARG(1, __VA_GRGS__)` (下标从 0 开始)。

MY_GET_ARG 的 N 为几，就会拼接，展开为 `MY_GET_ARG_<N>`, 进而展开为参数的值。



## 条件编译

有时候希望程序部分只有在满足一定条件时才编译，如果不满足就不编译，这就是条件编译。例如 `编译为共享库`、`开启某特性`、`针对不同平台编译` 等等。条件编译可根据表达式的值或某个特定宏是否被定义来确定编译条件。

```C
#if     表达式非零就对代码进行编译；
#ifdef  如果宏被定义就进行编译；
#ifndef 如果宏未被定义就进行编译；
#else   作为其它预处理的剩余选项进行编译；
#elif   这是一种#else和#if的组合选项；
#endif  结束编译块的控制。
```
1. 逻辑编译

```C
#if <常数表达式>
...
#elif <常数表达式>
...
#else
...
#endif
```

`#if` 和 `#endif` 一定要配对出现。

预处理器表达式包括的操作符主要涉及到单个数的操作（+、-、~、<<、>>）、多个数的运算（*、/、%、+、-、&、^、|）、关系比较（<、<=、>、>=、==、!=）、宏定义判断（defined）、逻辑操作（!、&&、||），其优先级和行为方式与C/C++表达式操作符相同。对于预处理器表达式，一定要记住它们是在编译器预处理器上执行的，是在编译前进行的。

可以用圆括号改变优先级顺序。

预处理表达式使用场景很少，主要是其支持的功能很少，例如不支持宏替换，例如 `if MAX(A, B) > 3` 是不合法的操作。。

2. 是否定义了宏

```C
#ifdef 宏
...
#else
...
#endif

// 或者
#ifndef
...
#endif
```

**#ifndef 与#if !defined意义相同，#ifdef 与#if defined意义相同。**

## 其它预处理指令

除了上面讨论的常用预处理指令外，还有三个不太常见的预处理指令：#line、#error、#pragma。


### `#line`

`#line` 指令用于重新设定当前由 `__FILE__` 和 `__LINE__` 宏指定的源文件名字和行号。 `#line` 一般形式为`#line number "filename"`，其中行号 number 为任何正整数，文件名 filename 可选。`#line` 主要用于调试及其它特殊应用，注意在 `#line` 后面指定的行号数字是表示从下一行开始的行号。


### `#error`


`#error` 指令使预处理器发出一条错误消息，然后停止执行预处理。 `#error` 一般形式为 `#error <info>`，如`#error MFC requires C++ compilation.`。


### `#pragma`


`#pragma` 指令可能是最复杂的预处理指令，它的作用是设定编译器的状态或指示编译器完成一些特定的动作。

`#pragma` 一般形式为#pragma para，其中para为参数，下面介绍一些常用的参数。

`#pragma once`，只要在头文件的最开始加入这条指令就能够保证头文件被编译一次。

`#pragma message("info")`，在编译信息输出窗口中输出相应的信息，例如#pragma message("Hello")。

`#pragma warning`，设置编译器处理编译警告信息的方式，例如 `#pragma warning(disable:4507 34;once : 4385;error:164)` 等价于 `#pragma warning(disable:4507 34)`（不显示4507和34号警告信息）、`#pragma warning(once:4385)`（4385号警告信息仅报告一次）、`#pragma warning(error:164)`（把164号警告信息作为一个错误）。

`#pragma comment(…)`，设置一个注释记录到对象文件或者可执行文件中。常用lib注释类型，用来将一个库文件链接到目标文件中，一般形式为#pragma comment(lib,"*.lib")，其作用与在项目属性链接器“附加依赖项”中输入库文件的效果相同。

```C
#pragma message( __FILE__ ## ", " __LINE__ ## "Enter main()...\n")
```

## 编译器参数指定宏 `-D<Macro<=Value>>`


例如
```C++
# cat test.c
char* str = macro;

# clang -Dmacro=\"aaa\" -E -c test.c
# 1 "text.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 366 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "text.c" 2
char* str = "aaa";
```

`-E` 表示只进行预处理，不编译。可以看到 `-D` 指定的宏已经被替换为了其值。


## 函数别名

```C
int test(int num) {
    return num;
}
```

> 1. 宏定义
```C
#define TEST test
TEST(4);
```

> 2.函数指针

> 3 __attribute__ ((weak, alias(#name))), 弱引用

```C
static __typeof(test) testAlias __attribute__ ((weak, alias("test")))
```

- __typeof 会返回变量或者函数返回值的实际类型信息。__typeof(test) 就是 int。__typeof__() 和 __typeof() 和  typeof() 都是 C 的扩展，且意思是相同的，标准C不包括这样的运算符。如果希望更安全，建议使用 __typeof__() 或者 __typeof()。
- __attribute__ 用于给 `testAlias` 添加属性，`alias` 指定了其为 `test` 的别名。`weak`指定别名是弱类型，可以省略(__attribute__((alias(#name))))，默认为强类型。可以通过 `nm <目标文件>` 来查看符号表，带 `W` 的是弱别名。


```C
#include <stdio.h>
// clang 不支持 alias，只能在 gcc 编译器上编译。
int test() {
    printf("test\n");
}

__typeof(test) testWeakAlias __attribute__((weak, alias("test")));


__typeof(test) testAlias __attribute((alias("test")));

int main() {
    test();
    testWeakAlias();
    testAlias();
    return 0;
}
```
```bash
$ nm test_alias.p
0000000000001149 T test
0000000000001149 T testAlias
0000000000001149 W testWeakAlias // W, 弱别名，前面的对符号表的地址是一样的。
```


参考：

[详解C/C++预处理器](https://www.cnblogs.com/lidabo/archive/2012/08/27/2658909.html)
[C/C++ 宏编程的艺术](https://bot-man-jl.github.io/articles/?post=2020/Macro-Programming-Art)