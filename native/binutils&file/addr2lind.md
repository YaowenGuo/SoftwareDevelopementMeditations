# addr2line

编译器或者 Android NDK toolchain 目录带了一个 addr2line 工具，用于将地址根据符号表转换为对应的函数。

例如 llmv 编译器的 `llvm-addr2line` 以及 NDK 带的

```C++
ndk/21.1.6352462/toolchains/x86-4.9/prebuilt/darwin-x86_64/bin/i686-linux-android-addr2line
ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android-addr2line
ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-addr2line
ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/bin/x86_64-linux-android-addr2line
ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/bin/i686-linux-android-addr2line
ndk/21.1.6352462/toolchains/llvm/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-addr2line
ndk/21.1.6352462/toolchains/x86_64-4.9/prebuilt/darwin-x86_64/bin/x86_64-linux-android-addr2line
ndk/21.1.6352462/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-addr2line
ndk/21.1.6352462/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64/bin/aarch64-linux-android-addr2line
ndk/23.1.7779620/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-addr2line
```

Android 的 NDK 还带了一个方便调试 Android 输出的工具 ndk-stack。

[ndk-stack](https://developer.android.com/ndk/guides/ndk-stack)