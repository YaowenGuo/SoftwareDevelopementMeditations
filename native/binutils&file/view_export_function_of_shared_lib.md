# [View the List of Functions Exported by a Linux Shared Library](https://www.baeldung.com/linux/shared-library-exported-functions)

## 1. Overview

In this tutorial, we’ll learn about exported symbols in Linux shared libraries and how we can view them.


## Using readelf

We can use the readelf command with the -s flag to view exported symbols:

```shell
$ readelf -s lib.so
Symbol table '.dynsym' contains 8 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_deregisterT[...]
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND puts@GLIBC_2.2.5 (2)
     3: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
     4: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND _ITM_registerTMC[...]
     5: 0000000000000000     0 FUNC    WEAK   DEFAULT  UND [...]@GLIBC_2.2.5 (2)
     6: 000000000000111f    22 FUNC    GLOBAL DEFAULT   12 lib_exported2
     7: 0000000000001109    22 FUNC    GLOBAL DEFAULT   12 lib_exported1
...
```

## Using objdump

We can also use the objdump command with the -T flag to view exported symbols:

```shell
$ objdump -T lib.so
lib.so:     file format elf64-x86-64
DYNAMIC SYMBOL TABLE:
0000000000000000  w   D  *UND*	0000000000000000  Base        _ITM_deregisterTMCloneTable
0000000000000000      DF *UND*	0000000000000000  GLIBC_2.2.5 puts
0000000000000000  w   D  *UND*	0000000000000000  Base        __gmon_start__
0000000000000000  w   D  *UND*	0000000000000000  Base        _ITM_registerTMCloneTable
0000000000000000  w   DF *UND*	0000000000000000  GLIBC_2.2.5 __cxa_finalize
000000000000111f g    DF .text	0000000000000016  Base        lib_exported2
0000000000001109 g    DF .text	0000000000000016  Base        lib_exported1
```

Let’s compile our library as C++ and see how objdump handles mangled symbols:

```shell
$ g++ lib.c -shared -o lib.so
$ objdump -T lib.so
lib.so:     file format elf64-x86-64
DYNAMIC SYMBOL TABLE:
...
0000000000001109 g    DF .text	0000000000000016  Base        _Z13lib_exported1v
000000000000111f g    DF .text	0000000000000016  Base        _Z13lib_exported2v
```

It doesn’t demangle symbols by default, so we must pass the –demangle flag:

```shell
$ objdump -T --demangle lib.so
lib.so:     file format elf64-x86-64
DYNAMIC SYMBOL TABLE:
...
0000000000001109 g    DF .text	0000000000000016  Base        lib_exported1()
000000000000111f g    DF .text	0000000000000016  Base        lib_exported2()
```

## 3.3. Using nm

Finally, we can also use the nm command with the -D flag to view exported symbols. It can demangle names with the –demangle flag just like objdump:
```shell
$ nm -D --demangle lib.so
                 w __cxa_finalize@GLIBC_2.2.5
                 w __gmon_start__
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
                 U puts@GLIBC_2.2.5
0000000000001109 T lib_exported1()
000000000000111f T lib_exported2()
```