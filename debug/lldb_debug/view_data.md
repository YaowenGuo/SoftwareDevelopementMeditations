# 查看数据

## 静态数据（设置或文件）

### 文件信息 target
`target` 是用于在调试目标文件上操作的命令。列出所有的可执行文件
```shell
(lldb) target list
```

lldb 将程序中的的主题，每个动态库都视为一个 `module`。例如列出程序的所有组成部分：
```shell
(lldb) target modules list
[  0] 8C4C512A-8DF0-34D4-BB0A-8BE115992A63 0x0000000100000000 /Users/lim/Projects/test_native/a.out
[  1] 8E1E5EE2-F89A-33A7-BB0A-74BDC06B7828 0x000000019d5f0000 /usr/lib/dyld
[  2] CC304138-4DB2-35CE-B55F-044E187F356E 0x00000001aa5ee000 /usr/lib/libSystem.B.dylib
[  3] C0BCBAE5-4913-3D80-8E3A-9D4DEC1EA827 0x00000001aa5e8000 /usr/lib/system/libcache.dylib
[  4] 0BA453ED-E5A2-3C2F-86F4-CFCFFA6C1879 0x00000001aa5a3000 /usr/lib/system/libcommonCrypto.dylib
...
```

查看文件段信息，类似于gdb 的 `info files` 的指令为:
```shell
(lldb) target modules dump sections
Dumping sections for 1 modules.
Sections for '/opt/linux/vmlinux' (aarch64):
  SectID     Type             File Address                             Perm File Off.  File Size  Flags      Section Name
  ---------- ---------------- ---------------------------------------  ---- ---------- ---------- ---------- ----------------------------
  0xffffffffffffffff container        [0xffff800080000000-0xffff8000810f9000)  r-x  0x00010000 0x010f9000 0x00000000 vmlinux.PT_LOAD[0]
  0x00000001 code             [0xffff800080000000-0xffff800080010000)  r-x  0x00010000 0x00010000 0x00000006 vmlinux.PT_LOAD[0]..head.text
  0x00000002 code             [0xffff800080010000-0xffff8000810f9000)  r-x  0x00020000 0x010e9000 0x00000006 vmlinux.PT_LOAD[0]..text
  ...
```

或者使用 `target modules` 的别名 `image`。

```shell
(lldb) image dump sections
```

查找虚函数表：
```
image lookup -r -v -s "vtable for YOUR_CLASS_NAME"
```
例如

```shell
$ image lookup -r -v -s "vtable for C"
1 symbols match the regular expression 'vtable for C' in /Users/albert/project/webrtc/test/C++/.target/memory/virtual_function:
        Address: virtual_function[0x0000000100004020] (virtual_function.__DATA_CONST.__const + 0)
        Summary: virtual_function`vtable for C
         Module: file = "/Users/albert/project/webrtc/test/C++/.target/memory/virtual_function", arch = "x86_64"
         Symbol: id = {0x0000014d}, range = [0x0000000100004020-0x0000000100004058), name="vtable for C", mangled="_ZTV1C"
```

### 代码信息 source

例如，查看 `head.text` 的地址为内核的入口地址，查看该地址的对应的代码和文件：
```shell
(lldb) source list -a 0xffff800080000000
/opt/linux/vmlinux`vmlinux[0xffff800080000000]
   55  	 */
   56  		__HEAD
   57  		/*
   58  		 * DO NOT MODIFY. Image header expected by Linux boot-loaders.
   59  		 */
-> 60  		efi_signature_nop			// special NOP to identity as PE/COFF executable
   61  		b	primary_entry			// branch to kernel start, magic
   62  		.quad	0				// Image load offset from start of RAM, little-endian
   63  		le64sym	_kernel_size_le			// Effective size of kernel image, little-endian
   64  		le64sym	_kernel_flags_le		// Informative flags, little-endian
   65  		.quad	0				// reserved
(lldb) source info -a 0xffff800080000000
Lines found in module `vmlinux
[0xffff800080000000-0xffff800080000004): /opt/linux/arch/arm64/kernel/head.S:60
(lldb)
```

## 执行中的数据

- 查看栈内变量
frame

在函数调用期间，与调用关联的运行时信息存储在称为栈帧(stack fram)的内存区域中。帧中包含函数的局部变量的值、形参以及调用该函数位置记录。每次发生函数调用时，都会创建一个新帧，并将其推到一个系统维护的栈上；栈最上方表示当ｉａｎ正在执行的函数，当函数退出时，这个帧被弹出栈，并且被释放。

例如，再insert()函数中暂停示例程序insert_short的执行。当前栈帧中的数据会指出，你通过你个恰好位于process_data()函数（该函数调用inert()）中的特定位置进行的函数调用到达了这个帧。这个帧也会存储存储insert()的唯一局部变量的当前值，稍后你会发现这个值为j.

其他活动函数地啊用的栈帧将包含类似的信息，如果你愿意，也可以查看它们。例如，尽管程序执行当前位于insert()内，但是你也可能希望查看调用栈中以前的帧，几查看process_data()的帧。在gdb中可以用如下命令查看以前的帧。

这样的操作非常有用，因为根据以前的一部分栈帧中的局部变量的值，可能发现一些引起程序错误的代码的线索。

**在程序崩溃时，这通常很有用，因为你可以通过一些调试方法很快找到崩溃点，但是，如果由于传入的参数错误，是在一个库函数内部引起程序奔溃通常使问题变得复杂，我们无法查看库函数的代码，此时的想法是要是能回到该库函数调用之前，就可以验证函数调用的参数是否正确，frame 1能够很好的实现。**

- 查看寄存器
rigieter

### 查看内存

查看内存，支持各种格式和大小的输出

```shell
(lldb) memory read --size 4 --format x --count 4 0xbffff3c0
(lldb) me r -s4 -fx -c4 0xbffff3c0
````

以二进制将内存前 `0x20000` 字节输出到文件 `mem_dump`
```
memory read --force --outfile mem_dump  --binary 0x0 0x20000
```
超出 1024 字节必须加 `--force`

- 打印栈帧的变量和全局变量有何不同？
- 如何 查看数据结构定义 ？（gdb）ptype 变量



### 查看执行的位置
