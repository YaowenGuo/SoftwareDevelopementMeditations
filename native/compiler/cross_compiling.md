# 交叉编译

交叉编译是在一个平台上生成另一个平台上的可执行代码。交叉编译不止需要编译器的支持，而且需要指定一组工具链（toolchain）和系统跟目录（sysroot）。


## toolchain

toolchain 是编译目标文件的工具集合，例如对运行在 Linux 上的 C/C++，其包括编译器、汇编器、链接器、反汇编、系统库等。因为系统、运行环境、编译器、库等不同，不同的目标平台往往需要不同的工具链。

由于 GNU utils 的影响力，许多编译系统都使用 GCC 格式的编译设置，其中包括：

- CC: C 编译器
- CXX: C++ 编译器
- AS: 汇编器
- LD: 连接器
- STRIP: 符号表脱除工具
- RANLIB: 

例如为 shell 环境指定工具链。
```shell
export AR=$TOOLCHAIN/bin/llvm-ar
export CC="$TOOLCHAIN/bin/clang --target=$TARGET$API"
export AS=$CC
export CXX="$TOOLCHAIN/bin/clang++ --target=$TARGET$API"
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
```

需要指出的是，

## 目标平台

每种主机/目标(host/target)都有自己的一组二进制文件、头文件、库等组合。要想生成目标主机的可执行程序，就要指定目标主机的类型。`-target <triple>` 选项用于指定编译的主机类型。


triple 的一般格式为<arch><sub>-<sys>-<abi>，其中：

arch = x86_64、i386、arm、aarch、thumb、mips等。
sub = v5, v6m, v7a, v7m等。
vendor = pc, apple, nvidia, ibm,等。
sys = none, linux, win32, darwin, cuda等。
abi = eabi, gnu, android, macho, elf等。

```
$ clang -arch arm64 -o hello hello.c –
```