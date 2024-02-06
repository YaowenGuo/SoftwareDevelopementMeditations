# Core dump

Core dump 是程序发生崩溃时，体统保存的进程内存和崩溃信息。是调试程序崩溃的有效方法之一，在主流系统上都有该功能。

这里只介绍 Linux 的 coredump，要想得到 coredump 必须先开启该功能。

1. 打开core文件生成开关（注意这个仅在当前 terminal 窗口有效），unlimited表示不限制core文件大小，可以使用-c查看是否开启，默认是0

```
prompt> ulimit -c
0
prompt> ulimit -c unlimited
```

2. 编译程序必须加上 -g 参数表示生成调试信息；可执行文件默认名为a.out，可以用-o参数自定义。

```
prompt> clang++ test.cpp -g 
prompt> ./a.out
...
Segmentation fault (core dumped)
```

3. 当发生错误时，终端输出提示 `(core dumped)` 表示 coredump 已经生成，默认使用在当前目录生成文件名为 `core` 的输出文件。

使用 lldb 调试
```
prmpt> lldb --core core a.out
(lldb) target create --core "core"
Core file '/opt/webrtc/core' (x86_64) was loaded.
(lldb) bt
* thread #1, name = 'a.out', stop reason = signal SIGSEGV
  * frame #0: 0x00007f86b05140ee
    frame #1: 0x00007f86b04e2609 libpthread.so.0`start_thread + 217
    frame #2: 0x00007f86b0409293 libc.so.6`__clone + 67
```

https://www.likecs.com/show-308298859.html#sc=650