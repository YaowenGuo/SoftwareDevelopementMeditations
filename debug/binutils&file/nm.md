## nm(name)

nm 也是一个依赖调试符号表的命令。其输出符号表中的符号名，以及符号名的相关信息。如果没有指定文件名，将使用当前目录下的 a.out 作为输入。如果使用 `-` 作为文件名，将从标准输入流中读取文件。

输出格式

```
十六进制地址    类型字符 符号名
00000000000002d0 r note_end
0000000000000244 r note_name
000000000000311c t pthread_atfork
                 U pthread_rwlock_rdlock
```
每行打印一条记录; 如果符号地址相同，会省略地址时，用8个空格代替。

> 类型字符

这部分是指符号所指向的数据的属性，或者说是所在数据段的属性。支持的类型字符如下。如果小写和大写字符的含义相同，则小写字符表示本地符号，而大写字符表示全局(外部)符号

```
a, A: 符号的值是绝对值，不会被更改
b, B: 未被初始化的全局数据，放在.bss段
C   : Common symbol. Multiple definitions link together into one definition.
d, D: 已经初始化的全局数据
i, I: COFF: .idata symbol or symbol in a section with IMAGE_SCN_LNK_INFO set.
n   : ELF: local symbol from non-alloc section. COFF: debug symbol.
N   : ELF: debug section symbol, or global symbol from non-alloc section.
s, S: COFF: section symbol.

Mach-O: absolute symbol or symbol from a section other than __TEXT_EXEC __text, __TEXT __text, __DATA __data, or __DATA __bss.

r, R: Read-only data object.
t, T: Code (text) object.
u   : ELF: GNU unique symbol.
U   : Named object is undefined in this file. 链接时常碰到的未定义符号，需要从其它文件查找。
v   : ELF: Undefined weak object. It is not a link failure if the object is not defined.
V   : ELF: Defined weak object symbol. This definition will only be used if no regular definitions exist in a link. If multiple weak definitions and no regular definitions exist, one of the weak definitions will be used.
w   : Undefined weak symbol other than an ELF object symbol. It is not a link failure if the symbol is not defined.
W   : Defined weak symbol other than an ELF object symbol. This definition will only be used if no regular definitions exist in a link. If multiple weak definitions and no regular definitions exist, one of the weak definitions will be used.

?   : Something unrecognizable.

Because LLVM bitcode files typically contain objects that are not considered to have addresses until they are linked into an executable image or dynamically compiled “just-in-time”, llvm-nm does not print an address for any symbol in an LLVM bitcode file, even symbols which are defined in the bitcode file.
```


查看函数名

```
nm -Ca <native lib>
```

```
OVERVIEW: LLVM symbol table dumper

USAGE: llvm-nm [options] <input object files>

OPTIONS:
  -a --debug-syms      Show all symbols, even debugger only
  -C --demangle        Demangle C++ symbol names
  --no-demangle        Don't demangle symbol names

  -D --dynamic         Display dynamic symbols instead of normal symbols 一般用于动态库
  --export-symbols     Export symbol list for all inputs
  -g --extern-only     Show only external symbols
  -f <format> --format=<format> Specify output format: bsd (default), posix, sysv, darwin, just-symbols
  --no-llvm-bc         Disable LLVM bitcode reader
  -p --no-sort         Show symbols in order encountered
  -W --no-weak         Show only non-weak symbols
  -n -v --numeric-sort 显示的符号以地址排序，而不是名称排序
  --portability        Alias for --format=posix
  --print-armap        Print the archive map
  -o/-A --print-file-name Precede each symbol with the object file it came from
  -S --print-size      Show symbol size as well as address
  --quiet              Suppress 'no symbols' diagnostic
  -t --radix=<radix>   Radix (o/d/x) for printing symbol Values
  -r --reverse-sort    Sort in reverse order
  --size-sort          Sort symbols by size
  --special-syms       Do not filter special symbols from the output

  -U --defined-only    Show only defined symbols
  -u --undefined-only  Show only undefined symbols

  -j                   Alias for --format=just-symbols
  -m                   Alias for --format=darwin
  -P                   Alias for --format=posix
  -X <value>           Specifies the type of ELF, XCOFF, or IR object file to examine. The value must be one of: 32, 64, 32_64, any (default)
```


在接下来的三行中
```
 0000000000000000    B g_uninit 
 0000000000000000    D str 
 0000000000000000    T func1()
```

令人疑惑的是，为什么他们的地址都是0，难道说mcu的 0 地址同时可以存三种数据？

其实不是这样的，按照上面的符号表规则，g_uninit 属于.bss段，str 属于全局数据区，而func1() 属于代码段，这个地址其实是相对于不同数据区的起始地址，即 g_uninit 在.bss段中的地址是 0，以此类推，而 .bss 段具体被映射到哪一段地址，这属于平台相关，并不能完全确定。
在目标文件中指定的地址都是逻辑地址，符号真正的地址需要到链接阶段时进行相应的重定位以确定最终的地址。