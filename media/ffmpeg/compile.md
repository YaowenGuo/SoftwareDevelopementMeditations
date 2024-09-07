## 编译

C/C++ 的编译分为编译，链接两部分。如果是作为函数调用，编译为 `.so` 动态链接库就可以了，但是如果想要运行，需要链接为相应的可运行程序。

### 主机编译

要在当前平台编辑并使用 ffmpeg. 可以编译生成最新版本的应用。C/C++ 开源库都会提供一个 configure 的 shell 脚本, 用于生成编译的 Makefile文件。该脚本的配置非常复杂, 但一般都提供一个帮助选项。

常规的安装只需要执行

```bash
./configure
make
make install
``` 
即可完成安装。但是仅包含基础的功能，有一些功能并没有默认开启，要做一些定制，需要使用 configure 进行配置。

```bash
./configure --help
```

```
Help options: 帮助指令
...
Standard options: 标准配置
...
Configuration options:
...

Program options: 不生成命令行应用
...

Documentation options: 不生成文档
...

Component options: 不生成组件
...

Individual component options: 关闭默认开启的一些编码、封装或者协议。

External library support: 扩展库
...
```

支持或者屏蔽这些功能的方法很简单，只需要将 help 列出的关键字以空格分割的形式列到指令的后面即可。

```
./configure --disable-encoders --enable-libx264
```

### 交叉编译

主要配置使用的编译器，连接器，编译链接的目标平台（CPU架构）依赖库等。

- 编译器：
    - NDK17 开始，`make_standalone_toolchain.py` 用于替换之前的 `make-standalone-toolchain.sh` 用于在 windows 不用配置 bash 环境也能编译，但是实际情况是许多使用 `Autoconf` 配置编译的三方库仍旧无法在 Windows 上编译。 

    - 从 NDK 19 开始，NDK 中默认带有 `toolchains` 可供使用，与任意构建系统进行交互时不再需要使用 `make_standalone_toolchain.py` 脚本。如果是 NDK 19 之前的版本，请查看 [NDK 18 及之前编译](https://developer.android.com/ndk/guides/standalone_toolchain)。
    
    - NDK 17 开始默认使用 clang 作为编译器， NDK18 删除了 gcc, 只提供了 clang 的编译器。

    - 综上，现在编译三方库的最佳方式是使用 NDK `toolchain` 目录中的编译器工具链和平台库。使用 `gcc` 和 `make_standalone_toolchain.py` 等生成编译链的做法都是较陈旧的做法。

- 配置：
    - 常用的配置方法


配置编译过程不同的项目有不同的做法，流程的做法是使用 `autoconf` 的 configure 配置，或者配置环境变量，执行 `Makefile`。 FFmpeg 是使用 `autoconf` 进行配置，但是由于要配置的 `configure` 参数比较多，一不小心就会配置错误，或者需要多次修改，更方便的做法是再编写一个 shell 脚本文件，制定调用 configure 的参数并执行。

调整 configure 的参数主要用于对编译进行调整，例如对编译器的优化等级进行配置，对运行目标平台进行设置，对编辑软件进行剪裁，只包含使用到的部分，其他功能的模块不编译，从而减小包体积。对于 ffmpeg 来说，如果想要使用 lib 库，可以只编译 lib 开发库，如果想要使用指令的方式运行，就不能屏蔽 `ffmpeg`, `fplay` 等命令行工具。

### 编译 x264

创建 `.sh` 结尾的脚本文件, 如`make_x264.sh`，添加执行权限。 脚本中已经内置了下载 x264 方式，但是要确保 git 命令可用。

[查看 make_x264.sh](make_x264.sh)

遗留问题：x86 平台编译不成功，会导致 ffmpeg 的对应版本也无法编译 x86 版本。不影响使用，因为该版本主要用于虚拟机。错误信息:

```
/base.o: relocation R_386_GOTOFF against preemptible symbol x264_log_default cannot be used when making a shared object
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

编译 ffmpeg

[查看 make_ffmpeg.sh](make_ffmpeg.sh)

#### 问题处理

```
toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi16-clang is unable to create an executable file.
C compiler test failed.
```

`confiure` 指令要指定 `--cpu=` 参数，并且要严格按照下面的字符串对应，例如，不能将 `armv7-a` 写成 `armabiv7-a`

```
CPUS=(
    armv7-a
    arm64-v8a
    x86
    x86_64
)
```

> GNU assembler not found

```
GNU assembler not found, install/update gas-preprocessor

If you think configure made a mistake, make sure you are using the latest
version from Git.  If the latest version fails, report the problem to the
ffmpeg-user@ffmpeg.org mailing list or IRC #ffmpeg on irc.freenode.net.
Include the log file "ffbuild/config.log" produced by configure as this will help
solve the problem.
```

这是是 `--as=$AS` 参数引起的问题，应该是调用了系统的汇编程序，但是没找到，安装一下就好了。或者给 `./configure` 添加 `--disable-asm` 参数禁用汇编优化。

> error: undefined reference to

```
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_idivmod'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_d2ulz'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_ul2f'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_uidivmod'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_uidiv'
libavcodec/libavcodec.so: error: undefined reference to '__aeabi_f2ulz'
fftools/cmdutils.o:cmdutils.c:function parse_number_or_die: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function parse_number_or_die: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function opt_timelimit: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function opt_timelimit: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function grow_array: error: undefined reference to '__aeabi_idiv'
fftools/ffmpeg_opt.o:ffmpeg_opt.c:function open_output_file: error: undefined reference to '__aeabi_f2lz'
fftools/ffmpeg_opt.o:ffmpeg_opt.c:function opt_target: error: undefined reference to '__aeabi_ldivmod'
fftools/ffmpeg.o:ffmpeg.c:function main: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function main: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function transcode: error: undefined reference to '__aeabi_uldivmod'
fftools/ffmpeg.o:ffmpeg.c:function transcode: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function transcode: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_uldivmod'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function process_input_packet: error: undefined reference to '__aeabi_ldivmod'
fftools/ffmpeg.o:ffmpeg.c:function process_input_packet: error: undefined reference to '__aeabi_ldivmod'
fftools/ffmpeg.o:ffmpeg.c:function process_input_packet: error: undefined reference to '__aeabi_ldivmod'
```

应该是额外的链接参数引起的 `extra_ldflags="-nostdlib -lc"` 并且设置了 `--as=$AS` 但是提示 `GNU assembler not found`。禁用汇编优化就好了 `--disable-asm`。
 
## 集成到 Android Studio

新建一个 Module，选择 Android Library。 然后在新建文件，也可以从新建的 JNI 项目中拷贝过来。

```
# srm/main/cpp/CMakelists.txt

# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             native-lib.cpp )

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
                       native-lib

                       # Links the target library to the log library
                       # included in the NDK.
                       ${log-lib} )
```

修改 module 的 gradle, 添加

```
android {
        ...
    defaultConfig {
        ...
        externalNativeBuild {
            cmake {
                cppFlags ""
            }
        }
    }

    ...
    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.10.2"
        }
    }
    ndkVersion '21.3.6528147'
}

```