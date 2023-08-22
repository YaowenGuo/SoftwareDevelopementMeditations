# addr2line

addr2line 用于将 backtrack 中的地址信息转换为代码行。此转换需要目标文件带有调试的符号表信息。如果没有调试信息就不能使用这种方式。

```
llvm-addr2line [options] addresses...
```
需要注意的是 addresses 对于可执行文件来说，是一个绝对地址，直接使用就行了。对于动态库其实是一个偏移地址。想安卓的 backtrack 输出的就是偏移位置，可以直接使用。如果 bracktrack 输出的是运行时的绝对地址，应该减去动态库被加载到的起始地址。该信息可以在进程的 maps 中找到 `/proc/self/maps`。


```
OPTIONS:
  -e <file>             指定目标文件

  --build-id=<value>    使用 Build ID 查找目标文件


控制输出：
  -a                    同时输出地址信息
  --adjust-vma=<offset> Add specified offset to object file addresses
  -s                    只输出文件名，不输出路径名。
  -C                    :将低级别的符号名解码为用户级别的名字。
  -f                    同时输出地址所在函数的函数名
  -i                    如果需要转换的地址是一个内联函数，则还将打印返回第一个非内联函数的信息。
  --demangle            解析函数名，对 C++ 等面向目标的语言有意义，例如 _ZN3Bar1gEv 解析函数定义的 `Bar::g()`
  -p                    更易读的方式打印，对 llvm 来说意义不大。

  --color=<value>       Whether to use color when symbolizing log markup: always, auto, never
  --color               Use color when symbolizing log markup.


  --dwp=<file>          Path to DWP file to be use for any split CUs

  --fallback-debug-path=<dir> Fallback path for debug binaries
  --filter-markup       Filter symbolizer markup from stdin.

  --debug-file-directory=<dir>  Path to directory where to look for debug files
  --debuginfod          Use debuginfod to find debug binaries
  --no-debuginfod       Don't use debuginfod to find debug binaries
  --no-untag-addresses  Remove memory tags from addresses before symbolization

  --output-style=style  Specify print style. Supported styles: LLVM, GNU, JSON
  --print-source-context-lines=<value> 输出所在行的 n 行代码上下文。
  --relative-address    Interpret addresses as addresses relative to the image base
  --relativenames       Strip the compilation directory from paths
  --verbose             Print verbose line info
  --cache-size=<value>  Max size in bytes of the in-memory binary cache.
```


## 2、捕获系统异常信号输出调用栈

当程序出现异常时通常伴随着会收到一个由内核发过来的异常信号，如当对内存出现非法访问时将收到段错误信号 SIGSEGV，然后才退出。利用这一点，当我们在收到异常信号后将程序的调用栈进行输出，它通常是利用signal()函数，关于系统信号的内容，请前面的文章。


## 其它

### LLVM 和 NDK 的工具
编译器或者 Android NDK toolchain 目录带了一个 addr2line 工具，用于将地址根据符号表转换为对应的函数。

例如 llmv 编译器的 `llvm-addr2line` 以及 NDK 带的

```C++
ndk/21.1.6352462/toolchains/x86-4.9/prebuilt/darwin-x86_64/bin/i686-linux-android-addr2line
ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android-addr2line
...
```

llvm-addr2line 是 llvm-symbolizer 的一个别名应用，用于提供 GNU Utils 的替代。因此提供了不同于 llvm-symbolizer 的默认设置。


Android 的 NDK 还带了一个方便调试 Android 输出的工具 ndk-stack。

[ndk-stack](https://developer.android.com/ndk/guides/ndk-stack)


### ndkstack

Usage
To use ndk-stack, you first need a directory containing unstripped versions of your app's shared libraries. If you use ndk-build, these unstripped shared libraries are found in $PROJECT_PATH/obj/local/<abi>, where <abi> is your device's ABI.

There are two ways to use the tool. You can feed the logcat text as direct input to the program. For example:

```SHELL
adb logcat | $NDK/ndk-stack -sym $PROJECT_PATH/obj/local/armeabi-v7a
```
You can also use the -dump option to specify the logcat as an input file. For example:

```SHELL
adb logcat > /tmp/foo.txt
$NDK/ndk-stack -sym $PROJECT_PATH/obj/local/armeabi-v7a -dump foo.txt
```
When it begins parsing the logcat output, the tool looks for an initial line of asterisks. For example:

```
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
```
