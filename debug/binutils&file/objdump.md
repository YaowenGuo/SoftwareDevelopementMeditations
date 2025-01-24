# llvm-objdump

objdump 是用于查看对象文件内容和反汇编的指令。readobj 只能用于查看对象文件的各个 section 的信息，并不能读取内容数据，objdump 虽然也能查看部分 section 信息，但更善于读取数据。

objdump 能做 readelf 无法做到的事情：
1. `--show-lma` 输出 LMA
2. 反汇编

```
USAGE: objdump [options] <input object files>
```

objdump 中的一些参数也需要符号表，当没有符号表的时候会无法得到结果。例如 `-t`，`-C` 都需要。`-T` 需要的动态符号表跟调试符号表不同，是动态库加载到内存中用于动态链接的符号，因此即使是 strip 掉调试符号信息的动态库也是存在的。

```
OPTIONS:
  -a --archive-headers          Display archive header information(文件格式信息)
  -f --file-headers             Display the contents of the overall file header
  -p --private-headers          Display format specific file headers
  -x --all-headers              Display all available header information, relocation entries and the symbol table
  -h --[section-]headers        Display summaries of the headers for each section.
  -j <value> --section=<value>  Operate on the specified sections only. With --macho dump segment,section

  -s --full-contents            Display the content of each section
  --fault-map-section           Display the content of the fault map section


  --D -disassemble-all          Disassemble all sections found in the input files
  -d --disassemble              Disassemble all executable sections found in the input files
  --disassemble-symbols=<value> List of symbols to disassemble. Accept demangled names when --demangle is specified, otherwise accept mangled names
  -z --disassemble-zeroes       Do not skip blocks of zeroes when disassembling(一般反汇编输出将省略大块的零，该选项使得这些零块也被反汇编。 )
  -M <value> --disassembler-options=options Pass target specific disassembler options
  -S --source                   When disassembling, display source interleaved with the disassembly. Implies --disassemble
  -l --line-numbers             When disassembling, display source line numbers. Implies --disassemble
  --start-address=address       Set the start address for disassembling, printing relocations and printing symbols
  --stop-address=address        Set the stop address for disassembling, printing relocations and printing symbols
  --no-leading-addr             When disassembling, do not print leading addresses
  --no-show-raw-insn            When disassembling instructions, do not print the instruction bytes.
  --symbolize-operands          Symbolize instruction operands when disassembling


  --adjust-vma=offset           Increase the displayed address by the specified offset
  --arch-name=<value>           Target arch to disassemble for, see --version for available targets
  --build-id=<hex>              Build ID to look up. Once found, added as an input file

  --debug-file-directory=<dir>  Path to directory where to look for debug files
  --debug-vars-indent=<value>   Distance to indent the source-level variable display, relative to the start of the disassembly
  --debug-vars=<value>          Print the locations (in registers or memory) of source-level variables alongside disassembly. Supported formats: ascii, unicode (default)
  --debuginfod                  Use debuginfod to find debug files
  -C --demangle                 Demangle symbol names


  --dwarf=<value>               Dump the specified DWARF debug sections. The only supported value is 'frames'
  -R --dynamic-reloc            Display the dynamic relocation entries in the file
  -t --syms                     Display the symbol table(显示文件的符号表入口。类似于nm -s提供的信息)
  -T --dynamic-syms             Display the contents of the dynamic symbol table(动态符号表入口，仅仅对动态目标文件意义，比如某些共享库。它显示的信息类似于 nm -D|--dynamic 显示的信息。 )
                       

  --help                        Display available options (--help-hidden for more)
  --mattr=a1,+a2,-a3,...        Target specific attributes (--mattr=help for details)
  --mcpu=cpu-name               Target a specific cpu type (--mcpu=help for details)
  --no-print-imm-hex            Do not use hex format for immediate values (default)
  --prefix-strip=prefix         Strip out initial directories from absolute paths. No effect without --prefix
  --prefix=prefix               Add prefix to absolute paths
  --print-imm-hex               Use hex format for immediate values
  --raw-clang-ast               Dump the raw binary contents of the clang AST section
  -r --reloc                    Display the relocation entries in the file
                      
  --show-lma                    Display LMA column when dumping ELF section headers

  --symbol-description          Add symbol description for disassembly. This option is for XCOFF files only.

  --triple=<value>              Target triple to disassemble for, see --version for available targets
  -u --unwind-info              Display unwind information

  --wide                        Ignored for compatibility with GNU objdump
  --x86-asm-syntax=att          Emit AT&T-style disassembly
  --x86-asm-syntax=intel        Emit Intel-style disassembly

```


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

```
objdump-16 -s -d -j .text  testelf.o
```
> 查看符号表

```
objdump -t xxx.so
```
-T 和 -t 选项在于 -T 只能查看动态符号，如库导出的函数和引用其他库的函数，而 -t 可以查看所有的符号，包括数据段的符号。