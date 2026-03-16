# Kotlin 移植

## 编译

git clone --depth=1 --single-branch -b v2.3.0 https://github.com/JetBrains/kotlin.git

按照 `kotlin-native/README.md` 中的方法和配置进行编译。在 Mac 上配置 Brew 的软链接路径报错找不到 jni 的头文件：
```shell
> Task :kotlin-native:libclangInterop:clangstubs.o FAILED
/Users/lim/projects/jetbrain/kotlin/kotlin-native/libclangInterop/gen/main-macos_arm64/c/clangstubs.c:3:10: fatal error: 'jni.h' file not found
    3 | #include <jni.h>
      |          ^~~~~~~
1 error generated.

FAILURE: Build failed with an exception.
```

需要配置跟目录 gradle.properties ：
```
org.gradle.java.home=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
```

编译：
```shell
./gradlew :kotlin-native:dist :kotlin-native:distPlatformLibs
```
```
./kotlin-native/dist/bin/kotlinc-native hello.kt -o hello
Error: Could not find or load main class org.jetbrains.kotlin.cli.utilities.MainKt
Caused by: java.lang.ClassNotFoundException: org.jetbrains.kotlin.cli.utilities.MainKt
```

## Kotlin plugin 最小版本要求

```
Configuration problem: Minimal supported Kotlin Gradle Plugin version is 2.1.0
```

composeMultiplatform = "1.10.0"

composeMultiplatform = { id = "org.jetbrains.compose", version.ref   = "composeMultiplatform" }


版本兼容性: 

KMP 需要的 Gradle 版本：https://kotlinlang.org/docs/multiplatform/multiplatform-compatibility-guide.html#version-compatibility

Compose 需要的 Kotlin 版本：https://developer.android.com/jetpack/androidx/releases/compose-kotlin

CMP 和 Jetpack Compose 的版本关系：https://kotlinlang.org/docs/multiplatform/whats-new-compose-110.html#dependencies