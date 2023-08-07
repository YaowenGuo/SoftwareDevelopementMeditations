# objdump

查看二进制文件

> 查看静态库的依赖

objdump -x <name>.so | grep NEEDED

```
$ objdump -x libjingle_peerconnection_so.so  | grep NEEDED
  NEEDED       libEGL.so
  NEEDED       libdl.so
  NEEDED       libm.so
  NEEDED       liblog.so
  NEEDED       libOpenSLES.so
  NEEDED       libc++_shared.so
  NEEDED       libc.so

```

-d 反汇编（disassembly)，

-M 制定架构，x86-64
```
objdump -d -M x86-64 hello.o
```

默认显示的AT&T格式的汇编语法, 也可以添加选项显示Intel语法的汇编

```
objdump -d -M x86-64 -M intel hello.o
```


-t 查看程序符号，实现nm的功能

ndisasmw -o 0x7c00  boot.bin >> disboot.asm

指定按地址启示地址0x7c00计算，返汇编，适合用org指定了汇编地址的程序。

https://blog.csdn.net/wwchao2012/article/details/79980514