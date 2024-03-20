# Symbole

想要调试 native 代码，必须添加调试信息到可执行文件中

## 添加调试信息

如果使用cc/gcc/g++/clang做编译器，-g选项让编译器将符号表（即对应程序的变量的代码行的内存地址表表）保存在生成的可执行文件中。

clang -g hello.c -o hello

这样才能再调试会话过程中引用源代码中的变量名和行号。如果没有-g，你将看不到程序的函数名，变量名，所有代替的都是运行时的内存地址。

编译流程细分为 6 步：

```
-> 1 预编译 --> 2，3 编译 --> 4. 汇编 --> 5. 链接 --> 6. 封装为制定架构的可执行文件。
```

clang 比 gcc 多了第 3 步，clang 直接将源代码汇编代码，而 clang 先将源码编译为 llvm 的低层代码，然后才经过第 3 步，编译为汇编。

> 查看编译的步骤

```
# clang -ccc-print-phases hello.cpp

0: input, "hello.cpp", c++
1: preprocessor, {0}, c++-cpp-output
2: compiler, {1}, ir
3: backend, {2}, assembler
4: assembler, {3}, object
5: linker, {4}, image
6: bind-arch, "arm64", {5}, image
```

You need to use -g for all the steps (compiling your source files and linking).

[如何确定编译文件是否包含符号表](https://newbedev.com/how-to-know-the-given-shared-library-is-built-with-debug-symbols-or-not)
**clang --shared -g 在 linux 生成动态库包含的符号表，dwarfdump 能识别，在 mac 上生成 dwarfdump 则识别不了。奇葩！！！**

符号表：是内存地址与函数名、文件名、行号的映射表。

This -g option will generate debug sections - binary sections to insert into program’s binary. These sections are usually in DWARF format. For ELF binaries these debug sections have names like .debug_*, e.g. .debug_info or .debug_loc. These debug sections are what makes the magic of debugging possible - basically, it’s a mapping of assembly level instructions to the source code.

To find whether your program has debug symbols you can list the sections of the binary with objdump:

as we see it has .debug_* section, hence it has debug info.

Debug info is a collection of DIEs - Debug Info Entries. Each DIE has a tag specifying what kind of DIE it is and attributes that describes this DIE - things like variable name and line number.

To find the sources GDB parses .debug_info section to find all DIEs with tag DW_TAG_compile_unit. The DIE with this tag has 2 main attributes DW_AT_comp_dir (compilation directory) and DW_AT_name - path to the source file. Combined they provide the full path to the source file for the particular compilation unit (object file).

To parse debug info you can again use objdump:


```
objdump -g ./python | vim -
```

此时的调试信息和编译目标保存在一起。可以将符号表单独保存成文件，这在编译目标非常大的时候非常有用。

```
$ objcopy --only-keep-debug a.out a.out.symbol
```
或者在 mac 上使用 llvm 的 objcopy 是 llvm-objcopy. 该命令将生成单独的符号表文件 `a.out.symbol`。同样适用与其他类型的文件，如静态库（.s），动态库（.so）。

剥离符号表

```
objcopy --strip-debug a.out
```
该命令将 `a.out` 中的符号表清除。 或者使用 `strip` 也可以。


## [gdb 加载符号表调试](https://stackoverflow.com/questions/20380204/how-to-load-multiple-symbol-files-in-gdb)
https://alex.dzyoba.com/blog/gdb-source-path/


或者在 lldb 启动后动态加载符号表。

```shell
# lldb --core core
(lldb)
(lldb) settings append target.exec-search-paths <你的带 debug symbole 的路径>
```
查看添加的符号表文件

```shell
settings show target.exec-search-paths
```

也可以查看可以设置的所有可用

```shell
(lldb) settings show
auto-confirm (boolean) = false
auto-indent (boolean) = true
auto-one-line-summaries (boolean) = true
dwim-print-verbosity (enum) = none
...
```
或者进一步只查看 target 所支持的设置
```shell
(lldb) settings show target
target.arg0 (string) =
target.auto-apply-fixits (boolean) = true
target.auto-import-clang-modules (boolean) = true
target.auto-install-main-executable (boolean) = true
target.auto-source-map-relative (boolean) = true
...
```


## 查看符号表

nm 是有编译器提供过的查看符号表的指令（llvm-nm），可以查看各种二级制文件（符号表文件、.o、.so、.a 等）的符号表。

```shell
nm -g <file name>
```

编译器编译以后，函数的名字会被改成编译器内部的名字，这个名字会在链接的时候用到。例如 std::string::size()经过修饰后是 _ZNKSs4sizeEv。添加 "-C" 选项，可以对底层符号表译成用户级名称(demangle)，具有更好的可读性。
