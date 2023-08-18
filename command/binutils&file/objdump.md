# llvm-objdump

objdump 是用于查看对象文件内容和反汇编的指令。


> 查看 section 的头信息

```
-h, --headers, --section-headers
Display summaries of the headers for each section.
```

> 查看静态库的依赖

objdump -x <name>.so | grep NEEDED

```shell
$ objdump -x libjingle_peerconnection_so.so  | grep NEEDED
  NEEDED       libEGL.so
  NEEDED       libdl.so
  NEEDED       libm.so
  NEEDED       liblog.so
  NEEDED       libOpenSLES.so
  NEEDED       libc++_shared.so
  NEEDED       libc.so
```

> 反汇编（disassembly): -d

```shell
$ objdump -d libtest_jni.so --start-address=0x0000000000003640 --stop-address=0x00000000000036f0

libtest_jni.so:	file format elf64-littleaarch64

Disassembly of section .text:

0000000000003640 <_ZN3Bar1gEv>:                   # Bar::g() C++方法
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
输出结果分三部分：第一列是地址，接着是实际的数据，然后会反汇编的指令。

-M 制定架构，x86-64
```
objdump -d -M x86-64 hello.o
```

指令会根据 ELF 中信息判断架构，如果是 ARM 汇编就烦汇编ARM, 如果是 X86 汇编，默认显示的AT&T格式的汇编语法, 也可以添加选项显示 Intel 语法的汇编

```
objdump -d -M x86-64 -M intel hello.o
```
> 查看符号表

```
objdump -t xxx.so
```
-T 和 -t 选项在于 -T 只能查看动态符号，如库导出的函数和引用其他库的函数，而 -t 可以查看所有的符号，包括数据段的符号。

-t 查看程序符号，实现 nm 的功能


https://blog.csdn.net/wwchao2012/article/details/79980514