# 异常处理

## 在 JNI 中消耗异常

当 Native 调用一个 Java 方法发生异常时，可以通过如下方法消耗异常，从而避免程序崩溃。

```C++
// 加入这里调用 Java 方法发生了一个除 0 错误。
jthrowable err = env->ExceptionOccurred();
// 或者使用 ExceptionCheck 检查是否有异常发生。
// if (env->ExceptionCheck()) {}
if (err) {
    // 处理异常的 代码
    ...
    // 打印异常的堆栈信息。
    env->ExceptionDescribe();
    // 清除异常，不再向上抛异常
    evn->ExceptionClear();
    // 由于异常发生后后面的代码仍然能够执行，通常会在此抛出一个 Java 异常，然后 return 程序。
}

```
**JNI 中的异常有一个特点，异常发生后，后面的 Native 代码仍然能够执行，直到 Java 层报错**
当然该异常如果 Native 不处理，在 Java 中捕获异常也是可以的。

## Native 中抛出异常

Native 中也可以通过 JNI 向 Java 抛出异常。这样在 Java 中捕获并处理异常。

Native 中使用 `JNIEnv::ThrowNew()` 方法向 Java 抛出异常。
```C++
jclass cls = env->FindClass("java/lang/IllegalArgumentException");

env->TherowNew(cls, "Some Error Message");
```
