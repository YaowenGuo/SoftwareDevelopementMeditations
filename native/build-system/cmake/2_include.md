https://blog.csdn.net/qq_34347375/article/details/110672955

## 添加宏定义

除了在源码中定义宏和编译器预定义的宏，编译器也可以以参数的形式传递宏。clang/gcc 的 -d 参数即使用于指定宏的。而 CMake 的 `target_compile_definitions` 用于定义宏传递给源文件。

https://cmake.org/cmake/help/latest/command/target_compile_definitions.html#command:target_compile_definitions

https://www.cnblogs.com/Need4Speak/p/5397949.html


## 添加编译选项

target_compile_options

